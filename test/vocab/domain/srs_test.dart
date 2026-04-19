import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/domain/srs.dart';

UserWord _newWord({
  double easeFactor = 2.5,
  int intervalDays = 0,
  int consecutiveCorrect = 0,
  WordStatus status = WordStatus.newWord,
  DateTime? lastReviewedAt,
  DateTime? nextReviewAt,
}) {
  final t = DateTime.utc(2026, 1, 1);
  return UserWord(
    id: 'uw_x',
    wordId: 'w_x',
    easeFactor: easeFactor,
    intervalDays: intervalDays,
    consecutiveCorrect: consecutiveCorrect,
    status: status,
    lastReviewedAt: lastReviewedAt,
    nextReviewAt: nextReviewAt,
    createdAt: t,
    updatedAt: t,
    firstSeenAt: t,
  );
}

void main() {
  final now = DateTime.utc(2026, 4, 20, 12);

  group('cardOutcomeForErrors', () {
    test('maps error count to outcome', () {
      expect(cardOutcomeForErrors(0), CardOutcome.easy);
      expect(cardOutcomeForErrors(1), CardOutcome.good);
      expect(cardOutcomeForErrors(2), CardOutcome.hard);
      expect(cardOutcomeForErrors(3), CardOutcome.again);
      expect(cardOutcomeForErrors(7), CardOutcome.again);
    });
  });

  group('SM-2 algorithm', () {
    test('quality=5 on a brand new word sets interval=1, next_review=now+1d',
        () {
      final w = _newWord();
      final r = applySrs(w, CardOutcome.easy, now: now);
      expect(r.intervalDays, 1);
      expect(r.nextReviewAt, now.add(const Duration(days: 1)));
      expect(r.lastReviewedAt, now);
      expect(r.timesSeen, 1);
      expect(r.timesCorrect, 1);
      expect(r.consecutiveCorrect, 1);
    });

    test('quality=5 on a word at interval=1 sets new interval=6', () {
      final w = _newWord(intervalDays: 1, consecutiveCorrect: 1);
      final r = applySrs(w, CardOutcome.easy, now: now);
      expect(r.intervalDays, 6);
      expect(r.nextReviewAt, now.add(const Duration(days: 6)));
    });

    test('quality=5 on a word at interval=6 applies ease_factor multiplier',
        () {
      final w = _newWord(
        intervalDays: 6,
        easeFactor: 2.5,
        consecutiveCorrect: 2,
      );
      final r = applySrs(w, CardOutcome.easy, now: now);
      // round(6 * 2.5) = 15
      expect(r.intervalDays, 15);
    });

    test('quality=2 (again) resets interval to 1 but preserves ease_factor',
        () {
      final w = _newWord(
        intervalDays: 30,
        easeFactor: 2.7,
        consecutiveCorrect: 4,
        status: WordStatus.reviewing,
      );
      final r = applySrs(w, CardOutcome.again, now: now);
      expect(r.intervalDays, 1);
      expect(r.easeFactor, 2.7); // unchanged on fail
      expect(r.timesCorrect, 0); // unchanged: was 0 in factory
    });

    test('quality=2 resets consecutive_correct to 0', () {
      final w = _newWord(
        intervalDays: 30,
        consecutiveCorrect: 4,
        status: WordStatus.reviewing,
      );
      final r = applySrs(w, CardOutcome.again, now: now);
      expect(r.consecutiveCorrect, 0);
    });

    test('ease_factor never drops below 1.3 across many "hard" reviews', () {
      var w = _newWord(easeFactor: 1.5, intervalDays: 6, consecutiveCorrect: 1);
      for (var i = 0; i < 20; i++) {
        w = applySrs(w, CardOutcome.hard, now: now);
      }
      expect(w.easeFactor, greaterThanOrEqualTo(1.3));
      expect(w.easeFactor, lessThan(1.5)); // it did drop, just floored
    });
  });

  group('Status transitions', () {
    test('new → learning on first encounter (regardless of outcome)', () {
      final fail = applySrs(_newWord(), CardOutcome.again, now: now);
      expect(fail.status, WordStatus.learning);

      final win = applySrs(_newWord(), CardOutcome.easy, now: now);
      expect(win.status, WordStatus.learning);
    });

    test('learning → reviewing after first successful review (interval > 1)',
        () {
      // First success: status=learning, interval=1 → still learning.
      final firstSuccess = applySrs(_newWord(), CardOutcome.easy, now: now);
      expect(firstSuccess.status, WordStatus.learning);
      expect(firstSuccess.intervalDays, 1);

      // Second success: interval=1 → 6, transitions to reviewing.
      final secondSuccess =
          applySrs(firstSuccess, CardOutcome.easy, now: now);
      expect(secondSuccess.status, WordStatus.reviewing);
      expect(secondSuccess.intervalDays, 6);
    });

    test('reviewing → mature when interval > 90', () {
      final w = _newWord(
        intervalDays: 60,
        easeFactor: 2.5,
        consecutiveCorrect: 4,
        status: WordStatus.reviewing,
      );
      // 60 * 2.5 = 150 → mature
      final r = applySrs(w, CardOutcome.easy, now: now);
      expect(r.intervalDays, greaterThan(90));
      // Retirement also kicks in here (5 consecutive + interval > 60), so the
      // strict reviewing→mature transition is best demonstrated when the
      // retirement door is closed.
      expect(r.status, WordStatus.retired);

      // Now isolate the mature transition: 4 consecutive (not 5), interval
      // about to cross 90 — should land in mature, not retired.
      final w2 = _newWord(
        intervalDays: 50,
        easeFactor: 2.0,
        consecutiveCorrect: 3,
        status: WordStatus.reviewing,
      );
      final r2 = applySrs(w2, CardOutcome.easy, now: now);
      expect(r2.intervalDays, 100); // 50 * 2.0
      expect(r2.consecutiveCorrect, 4); // not yet 5 → no retirement
      expect(r2.status, WordStatus.mature);
    });

    test('retires when consecutive_correct >= 5 AND interval > 60', () {
      // Both conditions must hold together.
      final almost = _newWord(
        intervalDays: 30, // <= 60
        easeFactor: 2.0,
        consecutiveCorrect: 4,
        status: WordStatus.reviewing,
      );
      final r1 = applySrs(almost, CardOutcome.easy, now: now);
      expect(r1.consecutiveCorrect, 5);
      expect(r1.intervalDays, 60); // 30 * 2.0 = 60, NOT > 60
      expect(r1.status, isNot(WordStatus.retired));

      // Now nudge interval over 60.
      final retiring = _newWord(
        intervalDays: 31,
        easeFactor: 2.0,
        consecutiveCorrect: 4,
        status: WordStatus.reviewing,
      );
      final r2 = applySrs(retiring, CardOutcome.easy, now: now);
      expect(r2.consecutiveCorrect, 5);
      expect(r2.intervalDays, 62); // > 60
      expect(r2.status, WordStatus.retired);
    });
  });
}
