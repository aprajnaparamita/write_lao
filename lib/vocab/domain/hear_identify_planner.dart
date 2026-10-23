import 'dart:math' as math;

import 'package:write_lao/vocab/data/models/vocab_user_state.dart';

/// Knobs for the hear-and-identify card. v1 is enabled by default with a
/// 25% probability and requires the user to have at least 5 learned words
/// in the pool. The lesson engine reads this off itself, not from settings,
/// so it stays unit-testable.
class HearIdentifyConfig {
  final bool enabled;
  final double probability; // 0.0–1.0
  final int minLearnedWords;
  final int distractorCount;

  const HearIdentifyConfig({
    this.enabled = true,
    this.probability = 0.25,
    this.minLearnedWords = 5,
    this.distractorCount = 3,
  });

  static const disabled = HearIdentifyConfig(enabled: false);
}

/// Statuses considered "learned" for hear-and-identify purposes. New and
/// retired words are excluded — new because the user hasn't met them yet,
/// retired because re-testing fully-mastered words wastes review budget.
const Set<WordStatus> learnedStatuses = {
  WordStatus.learning,
  WordStatus.reviewing,
  WordStatus.mature,
};

bool _isLearned(UserWord uw) => learnedStatuses.contains(uw.status);

/// Filter [pool] to user-words whose status counts as "learned" for the
/// hear-identify card.
List<UserWord> filterLearned(Iterable<UserWord> pool) =>
    pool.where(_isLearned).toList();

/// Pick [count] distinct distractor word IDs from [learnedPool], excluding
/// [correctWordId]. Returns fewer than [count] only if the pool is too
/// small (caller must check eligibility before calling).
///
/// Pure: deterministic given the same [random].
List<String> pickDistractors({
  required String correctWordId,
  required List<String> learnedPool,
  required int count,
  required math.Random random,
}) {
  final candidates = learnedPool.where((id) => id != correctWordId).toList();
  if (candidates.length <= count) return candidates;
  candidates.shuffle(random);
  return candidates.take(count).toList();
}

/// Decide whether to insert a hear-identify card into a lesson, given the
/// current learned-pool size, whether this lesson is the first of its unit,
/// the config, and a random roll source.
bool shouldInsertHearIdentify({
  required HearIdentifyConfig config,
  required int learnedPoolSize,
  required bool isFirstLessonOfUnit,
  required math.Random random,
}) {
  if (!config.enabled) return false;
  if (isFirstLessonOfUnit) return false;
  // Need at least 1 correct + distractors.
  if (learnedPoolSize < config.minLearnedWords) return false;
  if (learnedPoolSize < config.distractorCount + 1) return false;
  return random.nextDouble() < config.probability;
}
