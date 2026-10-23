import 'package:write_lao/vocab/data/models/vocab_user_state.dart';

/// Default cards per deck-study session — matches the prompt spec
/// ("Default: 10 cards per deck study session"). Decks smaller than
/// the limit just use whatever they have.
const int defaultDeckStudyLimit = 10;

/// Pure-function planner: given the [wordIds] flagged into a deck and a
/// snapshot of the user's per-word SRS state, return the ordered list of
/// wordIds to study this session.
///
/// Rules (from prompt):
/// - Skip retired words (v1 default).
/// - Order by `last_reviewed_at` ASC, with never-reviewed words first.
/// - Words with no [UserWord] row yet are treated as never-reviewed.
/// - Cap at [limit] (or all of them if the deck is smaller).
List<String> planDeckStudy({
  required List<String> wordIds,
  required Map<String, UserWord> userWordsByWordId,
  int limit = defaultDeckStudyLimit,
}) {
  if (limit <= 0 || wordIds.isEmpty) return const [];

  final filtered = <String>[];
  for (final id in wordIds) {
    final uw = userWordsByWordId[id];
    if (uw != null && uw.status == WordStatus.retired) continue;
    filtered.add(id);
  }

  filtered.sort((a, b) {
    final ua = userWordsByWordId[a]?.lastReviewedAt;
    final ub = userWordsByWordId[b]?.lastReviewedAt;
    // Never-reviewed (null) sorts BEFORE any reviewed word.
    if (ua == null && ub != null) return -1;
    if (ua != null && ub == null) return 1;
    if (ua == null && ub == null) return 0;
    return ua!.compareTo(ub!);
  });

  return filtered.take(limit).toList();
}
