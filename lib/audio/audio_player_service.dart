import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing audio effects and character pronunciations.
class AudioPlayerService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _pronunciationPlayer = AudioPlayer();
  
  bool _isEnabled = true;

  /// SFX volume (0.0 – 1.0).  Applied before every play call because
  /// setting it once in the constructor can race against the underlying
  /// platform player initialisation.
  static const double _sfxVolume = 0.25;

  bool get isEnabled => _isEnabled;
  
  /// Set whether audio is enabled.
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Play character pronunciation audio.
  Future<void> playPronunciation(String codepoint) async {
    if (!_isEnabled) return;
    
    try {
      final path = 'assets/audio/pronunciation/$codepoint.mp3';
      await _pronunciationPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) {
      // Silently fail if audio doesn't exist
      debugPrint('Audio not found for $codepoint: $e');
    }
  }

  Future<void> _playSfx(String assetPath) async {
    if (!_isEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource(assetPath), volume: _sfxVolume);
    } catch (e) {
      debugPrint('SFX error ($assetPath): $e');
    }
  }

  /// Play correct stroke sound effect.
  Future<void> playCorrectSound() => _playSfx('audio/sfx/correct.mp3');

  /// Play incorrect stroke sound effect.
  Future<void> playIncorrectSound() => _playSfx('audio/sfx/incorrect.mp3');

  /// Play all strokes complete sound effect.
  Future<void> playCompleteSound() => _playSfx('audio/sfx/complete.mp3');

  /// Play star earned sound effect.
  Future<void> playStarSound() => _playSfx('audio/sfx/star.mp3');

  /// Play a sequence of stars (for test results).
  Future<void> playStarSequence(int count) async {
    for (var i = 0; i < count; i++) {
      await playStarSound();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  /// Stop all audio playback.
  Future<void> stopAll() async {
    await _sfxPlayer.stop();
    await _pronunciationPlayer.stop();
  }

  /// Dispose resources.
  void dispose() {
    _sfxPlayer.dispose();
    _pronunciationPlayer.dispose();
  }
}
