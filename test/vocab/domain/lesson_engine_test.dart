import 'dart:io';
import 'dart:math' show Random;

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_lao/vocab/domain/hear_identify_planner.dart';
import 'package:write_lao/vocab/domain/lesson_engine.dart';
import 'package:write_lao/vocab/domain/srs.dart';

import '../fixtures/course_fixtures.dart';

Future<CourseRepository> _loadFixtureRepo() async {
  final ds = CourseContentDataSource(
    loadString: (_) async => validBundleJson,
    assetExists: (path) async => validBundleAssetPaths.contains(path),
  );
  return CourseRepository(await ds.load());
}

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_lesson_engine_test_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String uniqueSuffix() => DateTime.now().microsecondsSinceEpoch.toString();

  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;
  late Box<UserSession> sessionBox;
  late Box<FlagDeck> deckBox;
  late Box<FlagDeckWord> deckWordBox;
  late UserWordRepository userWords;
  late UserVocabProgressRepository userProgress;
  late UserSessionRepository userSessions;
  late FlagDeckRepository flagDecks;
  late CourseRepository course;
  late LessonEngine engine;
  late DateTime currentNow;

  setUp(() async {
    final s = uniqueSuffix();
    wordBox = await Hive.openBox<UserWord>('lew_$s');
    progressBox = await Hive.openBox<UserVocabProgress>('lep_$s');
    sessionBox = await Hive.openBox<UserSession>('les_$s');
    deckBox = await Hive.openBox<FlagDeck>('led_$s');
    deckWordBox = await Hive.openBox<FlagDeckWord>('ledw_$s');

    currentNow = DateTime.utc(2026, 4, 20, 12);
    DateTime now() => currentNow;

    userWords = UserWordRepository(wordBox, now: now);
    userProgress = UserVocabProgressRepository(progressBox, now: now);
    userSessions = UserSessionRepository(sessionBox, now: now);
    flagDecks = FlagDeckRepository(deckBox, deckWordBox, now: now);
    course = await _loadFixtureRepo();
    engine = LessonEngine(
      course: course,
      userWords: userWords,
      userProgress: userProgress,
      userSessions: userSessions,
      flagDecks: flagDecks,
      now: now,
      hearIdentify: HearIdentifyConfig.disabled,
    );
  });

  tearDown(() async {
    await wordBox.deleteFromDisk();
    await progressBox.deleteFromDisk();
    await sessionBox.deleteFromDisk();
    await deckBox.deleteFromDisk();
    await deckWordBox.deleteFromDisk();
  });

  group('getReviewCandidates', () {
    test('excludes retired words', () {
      // Seed: w_0001 introduced (in u_01) and retired.
      var w = userWords.create('w_0001');
      w = userWords.save(w.copyWith(
        status: WordStatus.retired,
        intervalDays: 120,
        consecutiveCorrect: 7,
        nextReviewAt: currentNow.subtract(const Duration(days: 1)),
      ));

      // Also seed w_0002 as a normal due-soon word.
      var w2 = userWords.create('w_0002');
      w2 = userWords.save(w2.copyWith(
        status: WordStatus.reviewing,
        intervalDays: 6,
        consecutiveCorrect: 1,
        nextReviewAt: currentNow.subtract(const Duration(hours: 2)),
      ));

      final candidates = engine.getReviewCandidates('u_02');
      final ids = candidates.map((c) => c.wordId).toSet();
      expect(ids, contains('w_0002'));
      expect(ids, isNot(contains('w_0001')));
    });

    test('filters by unit scope (only words from <= given unit)', () {
      // w_0001 is introduced in u_01 lesson 1. w_0007 is introduced in u_02.
      var w1 = userWords.create('w_0001');
      w1 = userWords.save(w1.copyWith(
        status: WordStatus.reviewing,
        intervalDays: 6,
        nextReviewAt: currentNow.subtract(const Duration(hours: 1)),
      ));
      var w7 = userWords.create('w_0007');
      w7 = userWords.save(w7.copyWith(
        status: WordStatus.reviewing,
        intervalDays: 6,
        nextReviewAt: currentNow.subtract(const Duration(hours: 1)),
      ));

      final inU01 = engine.getReviewCandidates('u_01').map((c) => c.wordId);
      expect(inU01, contains('w_0001'));
      expect(inU01, isNot(contains('w_0007')));

      final inU02 = engine.getReviewCandidates('u_02').map((c) => c.wordId);
      expect(inU02, containsAll(['w_0001', 'w_0007']));
    });
  });

  group('startLesson', () {
    test('lesson 1 of unit 1 returns exactly 3 cards (3 new, 0 review)',
        () async {
      final plan = engine.startLesson('l_01_01');
      expect(plan.cards, hasLength(3));
      expect(
        plan.cards.map((c) => c.wordId).toList(),
        ['w_0001', 'w_0002', 'w_0003'],
      );
      expect(
        plan.cards.every((c) => c.kind == LessonCardKind.newWord),
        isTrue,
      );
    });

    test('honors pre-declared review_word_ids', () {
      // Pretend the user has already studied l_01_01 (w_0001, w_0002, w_0003).
      for (final id in ['w_0001', 'w_0002', 'w_0003']) {
        userWords.create(id);
      }
      // l_01_02 has review_word_ids = ['w_0001', 'w_0002'] in the fixture.
      final plan = engine.startLesson('l_01_02');
      expect(plan.cards, hasLength(5)); // 3 new + 2 review
      final reviewCards = plan.cards
          .where((c) => c.kind == LessonCardKind.review)
          .map((c) => c.wordId)
          .toList();
      expect(reviewCards, equals(['w_0001', 'w_0002']));
    });

    test('with empty review_word_ids fills slots from SRS candidates', () {
      // Seed w_0001..w_0006 (l_01_01 + l_01_02 introductions). Make w_0001
      // and w_0002 due (so they out-rank the others as review candidates).
      for (final id in ['w_0001', 'w_0002', 'w_0003', 'w_0004', 'w_0005',
        'w_0006']) {
        userWords.create(id);
      }
      var w1 = userWords.getByWordId('w_0001')!;
      w1 = userWords.save(w1.copyWith(
        status: WordStatus.reviewing,
        intervalDays: 6,
        nextReviewAt: currentNow.subtract(const Duration(hours: 5)),
      ));
      var w2 = userWords.getByWordId('w_0002')!;
      w2 = userWords.save(w2.copyWith(
        status: WordStatus.reviewing,
        intervalDays: 6,
        nextReviewAt: currentNow.subtract(const Duration(hours: 1)),
      ));

      // l_02_01 has new=[w_0007..w_0010], review_word_ids=[]. Engine should
      // fill 2 review slots from SRS candidates.
      final plan = engine.startLesson('l_02_01');
      final reviewIds = plan.cards
          .where((c) => c.kind == LessonCardKind.review)
          .map((c) => c.wordId)
          .toList();
      expect(reviewIds, hasLength(2));
      // Most overdue first (w_0001 has older next_review_at).
      expect(reviewIds, equals(['w_0001', 'w_0002']));
      // Total = 4 new + 2 review = 6 cards.
      expect(plan.cards, hasLength(6));
    });
  });

  group('hear-identify insertion', () {
    LessonEngine engineWith({
      required HearIdentifyConfig hi,
      int seed = 1,
    }) {
      return LessonEngine(
        course: course,
        userWords: userWords,
        userProgress: userProgress,
        userSessions: userSessions,
        flagDecks: flagDecks,
        now: () => currentNow,
        random: Random(seed),
        hearIdentify: hi,
      );
    }

    void seedLearned(List<String> ids, {WordStatus status = WordStatus.learning}) {
      for (final id in ids) {
        var w = userWords.create(id);
        w = userWords.save(w.copyWith(status: status));
      }
    }

    test('skipped when fewer than min learned words', () {
      // Only 4 learned; default minLearnedWords=5.
      seedLearned(['w_0001', 'w_0002', 'w_0003', 'w_0004']);
      final eng = engineWith(hi: const HearIdentifyConfig(probability: 1.0));
      final plan = eng.startLesson('l_02_01');
      expect(
        plan.cards.any((c) => c.kind == LessonCardKind.hearIdentify),
        isFalse,
      );
    });

    test('skipped on the first lesson of a unit even when pool is large', () {
      seedLearned(
        ['w_0001', 'w_0002', 'w_0003', 'w_0004', 'w_0005', 'w_0006'],
      );
      final eng = engineWith(hi: const HearIdentifyConfig(probability: 1.0));
      // l_02_01 is the first lesson of u_02.
      final plan = eng.startLesson('l_02_01');
      expect(
        plan.cards.any((c) => c.kind == LessonCardKind.hearIdentify),
        isFalse,
      );
    });

    test('inserts exactly one hear-identify card with 3 distractors', () {
      seedLearned([
        'w_0001', 'w_0002', 'w_0003', 'w_0004', 'w_0005', 'w_0006',
      ]);
      final eng = engineWith(hi: const HearIdentifyConfig(probability: 1.0));
      // l_01_02 is NOT the first lesson of u_01.
      final plan = eng.startLesson('l_01_02');
      final hi = plan.cards
          .where((c) => c.kind == LessonCardKind.hearIdentify)
          .toList();
      expect(hi, hasLength(1));
      expect(hi.first.distractorWordIds, hasLength(3));
      expect(
        hi.first.distractorWordIds,
        isNot(contains(hi.first.wordId)),
      );
    });

    test('disabled config never inserts', () {
      seedLearned([
        'w_0001', 'w_0002', 'w_0003', 'w_0004', 'w_0005', 'w_0006',
      ]);
      final eng = engineWith(hi: HearIdentifyConfig.disabled);
      final plan = eng.startLesson('l_01_02');
      expect(
        plan.cards.any((c) => c.kind == LessonCardKind.hearIdentify),
        isFalse,
      );
    });
  });

  group('completeLesson', () {
    test('advances current_lesson_id to the next lesson in the same unit', () {
      // Start at the first lesson.
      final p0 = userProgress.save(userProgress.getOrCreate().copyWith(
            currentUnitId: 'u_01',
            currentLessonId: 'l_01_01',
          ));
      expect(p0.currentLessonId, 'l_01_01');

      final plan = engine.startLesson('l_01_01');
      engine.completeLesson(plan.sessionId, totalErrors: 0);

      final advanced = userProgress.getOrCreate();
      expect(advanced.currentUnitId, 'u_01');
      expect(advanced.currentLessonId, 'l_01_02');
      expect(advanced.lessonsCompleted, 1);
    });

    test('completing the last lesson of a unit advances current_unit_id', () {
      userProgress.save(userProgress.getOrCreate().copyWith(
            currentUnitId: 'u_01',
            currentLessonId: 'l_01_02',
          ));
      // Seed prerequisite words so review-slot fill doesn't crash.
      for (final id in ['w_0001', 'w_0002', 'w_0003']) {
        userWords.create(id);
      }
      final plan = engine.startLesson('l_01_02');
      engine.completeLesson(plan.sessionId, totalErrors: 0);

      final advanced = userProgress.getOrCreate();
      expect(advanced.currentUnitId, 'u_02');
      expect(advanced.currentLessonId, 'l_02_01');
      expect(advanced.unitsCompleted, 1);
    });
  });

  group('startDeckStudy', () {
    test('orders by oldest last_reviewed_at, never-reviewed first', () {
      final deck = flagDecks.createDeck('Tricky');
      for (final id in ['w_0001', 'w_0002', 'w_0003']) {
        flagDecks.flagWord(deckId: deck.id, wordId: id);
      }
      // w_0001 reviewed earliest, w_0002 never reviewed, w_0003 reviewed latest.
      var w1 = userWords.create('w_0001');
      userWords.save(w1.copyWith(
        status: WordStatus.reviewing,
        lastReviewedAt: currentNow.subtract(const Duration(days: 5)),
      ));
      var w3 = userWords.create('w_0003');
      userWords.save(w3.copyWith(
        status: WordStatus.mature,
        lastReviewedAt: currentNow.subtract(const Duration(hours: 1)),
      ));
      // w_0002 has no UserWord row yet — startDeckStudy should create it.

      final plan = engine.startDeckStudy(deck.id);
      expect(
        plan.cards.map((c) => c.wordId).toList(),
        equals(['w_0002', 'w_0001', 'w_0003']),
      );
    });

    test('caps at default 10 cards', () {
      final deck = flagDecks.createDeck('Big');
      for (var i = 1; i <= 15; i++) {
        final id = 'w_${i.toString().padLeft(4, '0')}';
        flagDecks.flagWord(deckId: deck.id, wordId: id);
        var w = userWords.create(id);
        userWords.save(w.copyWith(
          status: WordStatus.learning,
          lastReviewedAt:
              currentNow.subtract(Duration(days: 30 - i)),
        ));
      }
      final plan = engine.startDeckStudy(deck.id);
      expect(plan.cards, hasLength(10));
    });

    test('skips retired words (v1)', () {
      final deck = flagDecks.createDeck('Mixed');
      for (final id in ['w_0001', 'w_0002']) {
        flagDecks.flagWord(deckId: deck.id, wordId: id);
      }
      var w1 = userWords.create('w_0001');
      userWords.save(w1.copyWith(status: WordStatus.retired));
      var w2 = userWords.create('w_0002');
      userWords.save(w2.copyWith(status: WordStatus.reviewing));

      final plan = engine.startDeckStudy(deck.id);
      expect(plan.cards.map((c) => c.wordId).toList(), equals(['w_0002']));
    });

    test('does NOT create a UserSession or advance course progress', () {
      // Set the user's current lesson — we want to confirm it stays put.
      userProgress.save(userProgress.getOrCreate().copyWith(
            currentUnitId: 'u_01',
            currentLessonId: 'l_01_02',
          ));
      final deck = flagDecks.createDeck('Sandbox');
      flagDecks.flagWord(deckId: deck.id, wordId: 'w_0001');

      final sessionsBefore = sessionBox.length;
      final plan = engine.startDeckStudy(deck.id);

      expect(sessionBox.length, sessionsBefore,
          reason: 'deck-study must not create a UserSession');
      expect(plan.cards, hasLength(1));

      // Even after recording outcomes for every card, progress is unchanged.
      for (final c in plan.cards) {
        engine.recordCardOutcome(c.wordId, CardOutcome.good);
      }
      final progress = userProgress.getOrCreate();
      expect(progress.currentLessonId, 'l_01_02');
      expect(progress.currentUnitId, 'u_01');
      expect(progress.lessonsCompleted, 0);
    });

    test('updates SRS state of the studied word', () {
      final deck = flagDecks.createDeck('SRS check');
      flagDecks.flagWord(deckId: deck.id, wordId: 'w_0001');

      final plan = engine.startDeckStudy(deck.id);
      expect(plan.cards, hasLength(1));

      final beforeUw = userWords.getByWordId('w_0001')!;
      expect(beforeUw.timesSeen, 0);

      engine.recordCardOutcome('w_0001', CardOutcome.good);

      final afterUw = userWords.getByWordId('w_0001')!;
      expect(afterUw.timesSeen, greaterThan(beforeUw.timesSeen));
    });
  });
}
