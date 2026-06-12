import 'package:hive/hive.dart';

/// Key for storing whether the Unit 1 free banner has been dismissed.
const String _prefUnit1BannerDismissed = 'unit1_banner_dismissed';

/// Counter of completed character practice / test sessions.
const String _prefCharSessions = 'char_sessions';

/// Whether the user dismissed the vocab upsell prompt shown after
/// character sessions.
const String _prefVocabUpsellDismissed = 'vocab_upsell_dismissed';

/// After this many character sessions, the vocab upsell dialog appears.
const int charSessionUpsellThreshold = 3;

/// After this many character sessions, the "Enjoying Write Lao?" review
/// prompt appears (only if the vocab upsell was already dismissed or the
/// user purchased).
const int ratingPromptThreshold = 5;

/// Whether the user dismissed the review prompt.
const String _prefRatingPromptDismissed = 'rating_prompt_dismissed';

/// Simple key-value store for user preferences persisted in Hive.
/// Exposed as a StateNotifier so that consumers can watch changes reactively.
class VocabPreferencesRepository {
  final Box<dynamic> _box;

  VocabPreferencesRepository(this._box);

  // ── Unit 1 banner ───────────────────────────────────────────────────────

  bool get unit1BannerDismissed =>
      _box.get(_prefUnit1BannerDismissed, defaultValue: false) as bool;

  Future<void> setUnit1BannerDismissed(bool value) async {
    await _box.put(_prefUnit1BannerDismissed, value);
  }

  Future<void> dismissUnit1Banner() async {
    await setUnit1BannerDismissed(true);
  }

  // ── Character session counter ────────────────────────────────────────────

  int get charSessionCount =>
      _box.get(_prefCharSessions, defaultValue: 0) as int;

  Future<void> incrementCharSessions() async {
    await _box.put(_prefCharSessions, charSessionCount + 1);
  }

  // ── Vocab upsell prompt ─────────────────────────────────────────────────

  bool get vocabUpsellDismissed =>
      _box.get(_prefVocabUpsellDismissed, defaultValue: false) as bool;

  Future<void> dismissVocabUpsell() async {
    await _box.put(_prefVocabUpsellDismissed, true);
  }

  // ── Rating prompt ────────────────────────────────────────────────────────

  bool get ratingPromptDismissed =>
      _box.get(_prefRatingPromptDismissed, defaultValue: false) as bool;

  Future<void> dismissRatingPrompt() async {
    await _box.put(_prefRatingPromptDismissed, true);
  }
}