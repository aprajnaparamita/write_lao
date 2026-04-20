import 'dart:math' as math;

import 'package:write_it_lao/vocab/data/models/vocab_lesson.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/domain/deck_study_planner.dart';
import 'package:write_it_lao/vocab/domain/hear_identify_planner.dart';
import 'package:write_it_lao/vocab/domain/srs.dart';

/// Whether a card was scheduled as a fresh introduction, a spaced
/// review of a previously-seen word, or a hear-and-identify listening test.
enum LessonCardKind { newWord, review, hearIdentify }

class LessonCard {
  final String wordId;
  final LessonCardKind kind;

  /// Distractor word IDs. Only populated for [LessonCardKind.hearIdentify];
  /// empty for the other kinds.
  final List<String> distractorWordIds;

  const LessonCard({
    required this.wordId,
    required this.kind,
    this.distractorWordIds = const [],
  });
}

class LessonPlan {
  final String sessionId;
  final String lessonId;
  final List<LessonCard> cards;

  const LessonPlan({
    required this.sessionId,
    required this.lessonId,
    required this.cards,
  });
}

/// Result of starting a deck-study session. Has no [sessionId] because
/// deck-study runs *outside* the course-progress lifecycle — completing
/// these cards updates per-word SRS state but never advances the user's
/// `current_lesson_id` / `current_unit_id`.
class DeckStudyPlan {
  final String deckId;
  final List<LessonCard> cards;

  const DeckStudyPlan({required this.deckId, required this.cards});
}

/// Orchestrates the per-lesson lifecycle: pick which words to show, persist
/// the in-flight session, apply SM-2 after each card, then advance the
/// user's progress when the lesson finishes.
class LessonEngine {
  final CourseRepository course;
  final UserWordRepository userWords;
  final UserVocabProgressRepository userProgress;
  final UserSessionRepository userSessions;
  final FlagDeckRepository? flagDecks;
  final Clock now;
  final math.Random _random;

  /// Default review-slot count per lesson. The first lesson of the course
  /// has none simply because no prior words exist to review.
  static const int defaultReviewSlots = 2;

  /// Window for "due-or-coming-soon" reviews: anything `next_review_at`
  /// before `now + reviewWindow` counts.
  static const Duration reviewWindow = Duration(hours: 24);

  /// Hear-and-identify card knobs. Defaults to enabled at 25% probability.
  /// Pass `HearIdentifyConfig.disabled` (or override via settings later) to
  /// turn the feature off without code changes.
  final HearIdentifyConfig hearIdentify;

  LessonEngine({
    required this.course,
    required this.userWords,
    required this.userProgress,
    required this.userSessions,
    this.flagDecks,
    Clock? now,
    math.Random? random,
    this.hearIdentify = const HearIdentifyConfig(),
  })  : now = now ?? (() => DateTime.now().toUtc()),
        _random = random ?? math.Random();

  /// Build the ordered card list for [lessonId], create a [UserSession] row,
  /// and ensure a [UserWord] row exists for every word in the plan.
  LessonPlan startLesson(String lessonId) {
    final lesson = course.getLesson(lessonId);
    if (lesson == null) {
      throw ArgumentError('Unknown lessonId: $lessonId');
    }

    final newCards = [
      for (final id in lesson.newWordIds)
        LessonCard(wordId: id, kind: LessonCardKind.newWord),
    ];

    final reviewIds = _selectReviewIds(lesson);
    final reviewCards = [
      for (final id in reviewIds)
        LessonCard(wordId: id, kind: LessonCardKind.review),
    ];

    // Ensure UserWord rows exist for every word in the plan; the SRS step
    // assumes the row is already there.
    for (final card in [...newCards, ...reviewCards]) {
      if (userWords.getByWordId(card.wordId) == null) {
        userWords.create(card.wordId);
      }
    }

    var cards = <LessonCard>[...newCards, ...reviewCards];

    final hi = _maybeBuildHearIdentifyCard(lesson, reviewCards);
    if (hi != null) {
      // Replace the LAST review card slot with the hear-identify card so
      // the SRS-shaped review still gets at least one slot when possible.
      final lastReviewIdx = cards.lastIndexWhere(
        (c) => c.kind == LessonCardKind.review,
      );
      if (lastReviewIdx >= 0) {
        cards = [...cards];
        cards[lastReviewIdx] = hi;
      } else {
        cards = [...cards, hi];
      }
    }

    final session = userSessions.start(lessonId);
    return LessonPlan(
      sessionId: session.id,
      lessonId: lessonId,
      cards: cards,
    );
  }

  /// Returns a hear-identify [LessonCard] if the eligibility and probability
  /// gates pass, otherwise null. Picks the correct word from the
  /// already-scheduled review cards when possible (so the user hears a word
  /// that was due anyway), falling back to any learned word otherwise.
  LessonCard? _maybeBuildHearIdentifyCard(
    VocabLesson lesson,
    List<LessonCard> reviewCards,
  ) {
    final allLearned = filterLearned(userWords.getAll());
    final learnedIds = allLearned.map((w) => w.wordId).toList();

    final unitLessons = course.getLessonsInUnit(lesson.unitId);
    final isFirstInUnit = unitLessons.isNotEmpty &&
        unitLessons.first.lessonId == lesson.lessonId;

    final shouldInsert = shouldInsertHearIdentify(
      config: hearIdentify,
      learnedPoolSize: learnedIds.length,
      isFirstLessonOfUnit: isFirstInUnit,
      random: _random,
    );
    if (!shouldInsert) return null;

    // Prefer a correct word that was already in the review queue.
    final reviewIds = reviewCards.map((c) => c.wordId).toSet();
    final correctId = learnedIds.firstWhere(
      reviewIds.contains,
      orElse: () => learnedIds.first,
    );

    final distractors = pickDistractors(
      correctWordId: correctId,
      learnedPool: learnedIds,
      count: hearIdentify.distractorCount,
      random: _random,
    );
    if (distractors.length < hearIdentify.distractorCount) return null;

    return LessonCard(
      wordId: correctId,
      kind: LessonCardKind.hearIdentify,
      distractorWordIds: distractors,
    );
  }

  /// Select the review-slot word IDs for [lesson]. Pre-declared review IDs
  /// in the content bundle are honored first; remaining slots fill from
  /// SRS-eligible candidates, then from a weighted-random fallback over
  /// previously-introduced words.
  List<String> _selectReviewIds(VocabLesson lesson) {
    final priorIntroduced = course
        .getWordsIntroducedBefore(lesson.lessonId)
        .map((w) => w.wordId)
        .toSet();
    if (priorIntroduced.isEmpty) {
      // No prior lessons → no review pool. (Covers U1L1.)
      return const [];
    }

    final excluded = <String>{...lesson.newWordIds};
    final chosen = <String>[];

    // Pre-declared reviews — but only honor those that have actually been
    // introduced before this lesson; ignore content-author mistakes silently.
    for (final id in lesson.reviewWordIds) {
      if (priorIntroduced.contains(id) && !excluded.contains(id)) {
        chosen.add(id);
        excluded.add(id);
      }
    }

    final slotsLeft = defaultReviewSlots - chosen.length;
    if (slotsLeft <= 0) return chosen;

    final unitId = lesson.unitId;
    final srsCandidates = getReviewCandidates(unitId)
        .where((c) => !excluded.contains(c.wordId))
        .map((c) => c.wordId)
        .toList();

    for (final id in srsCandidates.take(slotsLeft)) {
      chosen.add(id);
      excluded.add(id);
    }

    final stillNeeded = defaultReviewSlots - chosen.length;
    if (stillNeeded <= 0) return chosen;

    // Fallback: random pull from prior-lesson introductions, weighted toward
    // lower times_seen so we don't keep showing the same one.
    final fallback = priorIntroduced
        .where((id) => !excluded.contains(id))
        .toList();
    final picks = _weightedSampleByLowTimesSeen(fallback, stillNeeded);
    chosen.addAll(picks);
    return chosen;
  }

  /// SRS-eligible review words for [unitId]'s scope.
  ///
  /// Eligible iff:
  /// - the word was introduced in a unit whose `unit_number <= unitId`'s
  /// - `status != retired`
  /// - `next_review_at` is null OR within [reviewWindow] of `now`
  ///
  /// Ordered by `next_review_at` ASC (most overdue first) then
  /// `consecutive_correct` ASC (most struggling first).
  List<UserWord> getReviewCandidates(String unitId) {
    final eligibleWordIds = course
        .getWordsIntroducedInOrBeforeUnit(unitId)
        .map((w) => w.wordId)
        .toSet();
    if (eligibleWordIds.isEmpty) return const [];

    final cutoff = now().add(reviewWindow);
    final out = <UserWord>[];
    for (final uw in userWords.getAll()) {
      if (!eligibleWordIds.contains(uw.wordId)) continue;
      if (uw.status == WordStatus.retired) continue;
      final due = uw.nextReviewAt;
      if (due != null && due.isAfter(cutoff)) continue;
      out.add(uw);
    }

    out.sort((a, b) {
      // A null `next_review_at` means the word has been introduced but no
      // SRS step has run yet — sort it AFTER words with an explicit due
      // date, so genuinely-due reviews win the slot.
      final ad = a.nextReviewAt;
      final bd = b.nextReviewAt;
      if (ad == null && bd != null) return 1;
      if (ad != null && bd == null) return -1;
      if (ad != null && bd != null) {
        final c = ad.compareTo(bd);
        if (c != 0) return c;
      }
      return a.consecutiveCorrect.compareTo(b.consecutiveCorrect);
    });
    return out;
  }

  /// Weighted-random sample of [k] items from [pool]. Items with no
  /// matching UserWord row (never seen) get the highest weight; otherwise
  /// weight = 1 / (1 + times_seen) so often-seen words are shown less.
  List<String> _weightedSampleByLowTimesSeen(List<String> pool, int k) {
    if (pool.isEmpty || k <= 0) return const [];
    final remaining = [...pool];
    final out = <String>[];
    while (out.length < k && remaining.isNotEmpty) {
      final weights = remaining.map((id) {
        final uw = userWords.getByWordId(id);
        final seen = uw?.timesSeen ?? 0;
        return 1.0 / (1.0 + seen);
      }).toList();
      final total = weights.fold<double>(0, (a, b) => a + b);
      var roll = _random.nextDouble() * total;
      var picked = 0;
      for (var i = 0; i < remaining.length; i++) {
        roll -= weights[i];
        if (roll <= 0) {
          picked = i;
          break;
        }
      }
      out.add(remaining.removeAt(picked));
    }
    return out;
  }

  /// Build a study plan for the words flagged into [deckId]. Cards inherit
  /// their kind (newWord vs review) from the user's current SRS status, so
  /// the existing intro/practice/test/outro flow can render them. No
  /// [UserSession] is created — deck-study lives outside course progress.
  ///
  /// Skips retired words (per Phase 06 spec). Orders by oldest
  /// `last_reviewed_at`, never-reviewed first. Caps at [limit].
  DeckStudyPlan startDeckStudy(
    String deckId, {
    int limit = defaultDeckStudyLimit,
  }) {
    final repo = flagDecks;
    if (repo == null) {
      throw StateError(
        'startDeckStudy called but no FlagDeckRepository was injected.',
      );
    }

    final wordIds = repo.getWordsInDeck(deckId).map((dw) => dw.wordId).toList();

    // Ensure a UserWord row exists for each candidate; mirrors startLesson.
    for (final id in wordIds) {
      if (userWords.getByWordId(id) == null) {
        userWords.create(id);
      }
    }

    final byWordId = <String, UserWord>{
      for (final uw in userWords.getAll()) uw.wordId: uw,
    };
    final ordered = planDeckStudy(
      wordIds: wordIds,
      userWordsByWordId: byWordId,
      limit: limit,
    );

    final cards = [
      for (final id in ordered)
        LessonCard(
          wordId: id,
          kind: byWordId[id]?.status == WordStatus.newWord
              ? LessonCardKind.newWord
              : LessonCardKind.review,
        ),
    ];

    return DeckStudyPlan(deckId: deckId, cards: cards);
  }

  /// Apply SM-2 to the [wordId]'s UserWord based on the card's [outcome].
  /// Returns the updated record.
  UserWord recordCardOutcome(String wordId, CardOutcome outcome) {
    final existing = userWords.getByWordId(wordId);
    if (existing == null) {
      throw StateError(
        'recordCardOutcome called for $wordId but no UserWord row exists. '
        'startLesson should create one.',
      );
    }
    final updated = applySrs(existing, outcome, now: now());
    return userWords.save(updated);
  }

  /// Mark [sessionId] complete and advance `current_lesson_id` /
  /// `current_unit_id` if the completed lesson was the current one.
  void completeLesson(
    String sessionId, {
    Duration? duration,
    int totalErrors = 0,
  }) {
    final session = userSessions.getById(sessionId);
    if (session == null) {
      throw ArgumentError('Unknown sessionId: $sessionId');
    }
    userSessions.save(session.copyWith(
      completedAt: now(),
      durationSeconds: duration?.inSeconds,
      errorsCount: totalErrors,
    ));

    final lesson = course.getLesson(session.lessonId);
    if (lesson == null) return;

    final progress = userProgress.getOrCreate();
    // Only advance when the session was for the user's current lesson —
    // replays of an earlier lesson must not double-count progress.
    final isCurrent = progress.currentLessonId == null ||
        progress.currentLessonId == session.lessonId;
    if (!isCurrent) return;

    final next = _nextLessonAndUnit(lesson.unitId, session.lessonId);
    final isLastInUnit = next.unitId != lesson.unitId || next.lessonId == null;

    userProgress.save(progress.copyWith(
      currentUnitId: next.unitId,
      currentLessonId: next.lessonId,
      lessonsCompleted: progress.lessonsCompleted + 1,
      unitsCompleted:
          progress.unitsCompleted + (isLastInUnit ? 1 : 0),
    ));
  }

  /// Read the singleton progress row, creating defaults if missing.
  UserVocabProgress getCurrentProgress() => userProgress.getOrCreate();

  _NextPosition _nextLessonAndUnit(String unitId, String completedLessonId) {
    final lessonsInUnit = course.getLessonsInUnit(unitId);
    final idx = lessonsInUnit
        .indexWhere((l) => l.lessonId == completedLessonId);
    if (idx >= 0 && idx + 1 < lessonsInUnit.length) {
      return _NextPosition(
        unitId: unitId,
        lessonId: lessonsInUnit[idx + 1].lessonId,
      );
    }
    // Last lesson of the unit — try the next unit.
    final allUnits = course.getAllUnits();
    final unitIdx = allUnits.indexWhere((u) => u.unitId == unitId);
    if (unitIdx >= 0 && unitIdx + 1 < allUnits.length) {
      final nextUnit = allUnits[unitIdx + 1];
      final firstLessons = course.getLessonsInUnit(nextUnit.unitId);
      return _NextPosition(
        unitId: nextUnit.unitId,
        lessonId: firstLessons.isEmpty ? null : firstLessons.first.lessonId,
      );
    }
    // Course complete.
    return const _NextPosition(unitId: null, lessonId: null);
  }
}

class _NextPosition {
  final String? unitId;
  final String? lessonId;
  const _NextPosition({required this.unitId, required this.lessonId});
}
