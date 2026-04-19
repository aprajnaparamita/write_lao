/// Pick the best translation for [locale] from a `lang -> string` map.
///
/// Match order:
/// 1. Exact match on `languageCode_scriptCode` (e.g., `zh_Hant`).
/// 2. Exact match on `languageCode` (e.g., `fr`).
/// 3. English fallback.
/// 4. First available value (so the UI never silently shows blank).
String pickTranslation(
  Map<String, String> translations, {
  required String languageCode,
  String? scriptCode,
}) {
  if (scriptCode != null) {
    final scriptKey = '${languageCode}_$scriptCode';
    final scripted = translations[scriptKey];
    if (scripted != null) return scripted;
  }
  final byLang = translations[languageCode];
  if (byLang != null) return byLang;
  final en = translations['en'];
  if (en != null) return en;
  if (translations.isNotEmpty) return translations.values.first;
  return '';
}
