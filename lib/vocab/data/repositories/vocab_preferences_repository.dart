import 'package:hive/hive.dart';

/// Key for storing whether the Unit 1 free banner has been dismissed.
const String _prefUnit1BannerDismissed = 'unit1_banner_dismissed';

/// Simple key-value store for user preferences persisted in Hive.
/// Exposed as a StateNotifier so that consumers can watch changes reactively.
class VocabPreferencesRepository {
  final Box<dynamic> _box;

  VocabPreferencesRepository(this._box);

  bool get unit1BannerDismissed =>
      _box.get(_prefUnit1BannerDismissed, defaultValue: false) as bool;

  Future<void> setUnit1BannerDismissed(bool value) async {
    await _box.put(_prefUnit1BannerDismissed, value);
  }

  Future<void> dismissUnit1Banner() async {
    await setUnit1BannerDismissed(true);
  }
}