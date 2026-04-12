import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing audio effects and character pronunciations.
class AudioPlayerService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _pronunciationPlayer = AudioPlayer();
  
  bool _isEnabled = true;
  
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

  /// Play correct stroke sound effect.
  Future<void> playCorrectSound() async {
    if (!_isEnabled) return;
    
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/correct.mp3'));
    } catch (e) {
      debugPrint('Correct sound error: $e');
    }
  }

  /// Play incorrect stroke sound effect.
  Future<void> playIncorrectSound() async {
    if (!_isEnabled) return;
    
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/incorrect.mp3'));
    } catch (e) {
      debugPrint('Incorrect sound error: $e');
    }
  }

  /// Play all strokes complete sound effect.
  Future<void> playCompleteSound() async {
    if (!_isEnabled) return;
    
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/complete.mp3'));
    } catch (e) {
      debugPrint('Complete sound error: $e');
    }
  }

  /// Play star earned sound effect.
  Future<void> playStarSound() async {
    if (!_isEnabled) return;
    
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/star.mp3'));
    } catch (e) {
      debugPrint('Star sound error: $e');
    }
  }

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
