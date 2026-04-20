/// Configuration values for the vocabulary feature.
///
/// Adjust these to tune the free-user experience and content pacing.
class VocabConfig {
  /// How many lessons in unit 1 are playable without purchase.
  ///
  /// Set to 1 for a single-lesson preview. Set to 0 to disable preview.
  static const int freePreviewLessons = 1;

  /// How many times the upsell is dismissed before it reappears.
  ///
  /// E.g., 3 means "show again after every 3rd dismiss."
  static const int upsellDismissCooldown = 3;

  /// How many launches of the vocabulary section before re-prompting
  /// a user who has dismissed the upsell.
  static const int upsellLaunchCooldown = 3;
}
