/// Result of one user pass through a single word's character sequence.
/// The lesson engine consumes this to call `recordCardOutcome` (Phase 02).
class WordOutcome {
  final String wordId;
  final int errorCount;
  final int durationMs;

  const WordOutcome({
    required this.wordId,
    required this.errorCount,
    required this.durationMs,
  });
}
