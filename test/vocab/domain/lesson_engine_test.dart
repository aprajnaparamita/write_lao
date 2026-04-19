import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/domain/lesson_engine.dart';

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

  String _suffix() => DateTime.now().microsecondsSinceEpoch.toString();

  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;
  late Box<UserSession> sessionBox;
  late UserWordRepository userWords;
  late UserVocabProgressRepository userProgress;
  late UserSessionRepository userSessions;
  late CourseRepository course;
  late LessonEngine engine;
  late DateTime currentNow;

  setUp(() async {
    final s = _suffix();
    wordBox = await Hive.openBox<UserWord>('lew_$s');
    progressBox = await Hive.openBox<UserVocabProgress>('lep_$s');
    sessionBox = await Hive.openBox<UserSession>('les_$s');

    currentNow = DateTime.utc(2026, 4, 20, 12);
    DateTime now() => currentNow;

    userWords = UserWordRepository(wordBox, now: now);
    userProgress = UserVocabProgressRepository(progressBox, now: now);
    userSessions = UserSessionRepository(sessionBox, now: now);
    course = await _loadFixtureRepo();
    engine = LessonEngine(
      course: course,
      userWords: userWords,
      userProgress: userProgress,
      userSessions: userSessions,
      now: now,
    );
  });

  tearDown(() async {
    await wordBox.deleteFromDisk();
    await progressBox.deleteFromDisk();
    await sessionBox.deleteFromDisk();
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
}
