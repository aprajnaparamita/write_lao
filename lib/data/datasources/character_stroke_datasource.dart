import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';

/// Loads stroke data from asset files.
class CharacterStrokeDataSource {
  static const String _assetPath = 'assets/stroke_data/';

  /// Map of loaded stroke data, keyed by codepoint (without U+ prefix).
  final Map<String, CharacterStrokeData> _cache = {};

  /// Load stroke data for a character.
  /// Returns null if not found or if strokeCount is 0.
  Future<CharacterStrokeData?> loadStrokeData(String codepoint) async {
    // Normalize codepoint format
    final normalized = codepoint.toUpperCase().replaceAll('U+', '');

    // Check cache first
    if (_cache.containsKey(normalized)) {
      final data = _cache[normalized]!;
      return data.strokeCount > 0 ? data : null;
    }

    // Try to load from assets
    try {
      final assetPath = '$_assetPath$normalized.json';
      final jsonString = await rootBundle.loadString(assetPath);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final data = CharacterStrokeData.fromJson(json);

      _cache[normalized] = data;

      // Return null if no strokes
      return data.strokeCount > 0 ? data : null;
    } catch (e) {
      // File not found or parse error
      _cache[normalized] = CharacterStrokeData(
        codepoint: normalized,
        strokeCount: 0,
        strokes: const [],
      );
      return null;
    }
  }

  /// Check which characters have stroke data available.
  Future<Set<String>> getAvailableCodepoints() async {
    // For asset-based loading, we would need to scan the asset bundle.
    // This is not straightforward in Flutter, so we rely on the cache
    // being populated as characters are loaded.
    // A more robust solution would use a manifest file.
    return _cache.keys
        .where((cp) => _cache[cp]!.strokeCount > 0)
        .toSet();
  }

  /// Preload stroke data for a list of codepoints.
  Future<void> preloadStrokeData(List<String> codepoints) async {
    await Future.wait(
      codepoints.map((cp) => loadStrokeData(cp)),
    );
  }

  /// Clear the cache (useful for testing).
  void clearCache() {
    _cache.clear();
  }

  /// Check if stroke data is available for a codepoint (without loading).
  bool hasStrokeData(String codepoint) {
    final normalized = codepoint.toUpperCase().replaceAll('U+', '');
    return _cache[normalized]?.strokeCount != null;
  }
}
