import 'dart:math' as math;

import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';

/// User-facing card outcomes. Mapped from in-card error counts before being
/// passed to [applySrs]; the SM-2 algorithm itself thinks in 0–5 quality.
enum CardOutcome { easy, good, hard, again }

/// SM-2 quality value for an outcome (2–5 range — we never feed 0 or 1).
int qualityFor(CardOutcome o) => switch (o) {
      CardOutcome.easy => 5,
      CardOutcome.good => 4,
      CardOutcome.hard => 3,
      CardOutcome.again => 2,
    };

/// Map raw error count from a card to an outcome bucket.
/// 0 errors → easy, 1 → good, 2 → hard, 3+ (or abandoned) → again.
CardOutcome cardOutcomeForErrors(int errors) {
  if (errors <= 0) return CardOutcome.easy;
  if (errors == 1) return CardOutcome.good;
  if (errors == 2) return CardOutcome.hard;
  return CardOutcome.again;
}

/// Lower bound on ease factor (SM-2 default; matches Anki).
const double _easeFloor = 1.3;

/// Apply one SM-2 step to [w] given a [outcome] derived from card performance.
/// Returns a fresh [UserWord] with all SRS fields updated. The repository's
/// `save()` is responsible for bumping `updated_at`.
UserWord applySrs(
  UserWord w,
  CardOutcome outcome, {
  required DateTime now,
}) {
  final quality = qualityFor(outcome);
  final passed = quality >= 3;

  late final int newInterval;
  late final double newEase;
  late final int newConsecutive;

  if (passed) {
    if (w.intervalDays == 0) {
      newInterval = 1;
    } else if (w.intervalDays == 1) {
      newInterval = 6;
    } else {
      newInterval = (w.intervalDays * w.easeFactor).round();
    }
    final delta = 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02);
    newEase = math.max(_easeFloor, w.easeFactor + delta);
    newConsecutive = w.consecutiveCorrect + 1;
  } else {
    newInterval = 1;
    newEase = w.easeFactor; // SM-2 leaves EF alone on lapse
    newConsecutive = 0;
  }

  return w.copyWith(
    easeFactor: newEase,
    intervalDays: newInterval,
    consecutiveCorrect: newConsecutive,
    nextReviewAt: now.add(Duration(days: newInterval)),
    lastReviewedAt: now,
    timesSeen: w.timesSeen + 1,
    timesCorrect: w.timesCorrect + (passed ? 1 : 0),
    status: _nextStatus(
      current: w.status,
      passed: passed,
      newInterval: newInterval,
      newConsecutive: newConsecutive,
    ),
  );
}

/// Status machine. Transitions are evaluated in order; retirement supersedes
/// everything else when both clauses are satisfied.
WordStatus _nextStatus({
  required WordStatus current,
  required bool passed,
  required int newInterval,
  required int newConsecutive,
}) {
  var status = current;
  if (status == WordStatus.newWord) {
    status = WordStatus.learning;
  }
  if (status == WordStatus.learning && passed && newInterval > 1) {
    status = WordStatus.reviewing;
  }
  if (status == WordStatus.reviewing && newInterval > 90) {
    status = WordStatus.mature;
  }
  if (newConsecutive >= 5 && newInterval > 60) {
    status = WordStatus.retired;
  }
  return status;
}
