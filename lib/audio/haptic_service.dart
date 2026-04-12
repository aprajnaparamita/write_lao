import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service for haptic feedback on mobile.
class HapticService {
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  /// Set whether haptic feedback is enabled.
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Light impact feedback - for correct strokes.
  Future<void> lightImpact() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }

  /// Medium impact feedback - for incorrect strokes.
  Future<void> mediumImpact() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }

  /// Heavy impact feedback - for character complete.
  Future<void> heavyImpact() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }

  /// Selection click - for button taps.
  Future<void> selectionClick() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }

  /// Vibrate - for general feedback.
  Future<void> vibrate() async {
    if (!_isEnabled) return;
    
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Haptic error: $e');
    }
  }

  /// On stroke correct.
  Future<void> onStrokeCorrect() async {
    await lightImpact();
  }

  /// On stroke incorrect.
  Future<void> onStrokeIncorrect() async {
    await mediumImpact();
  }

  /// On character complete.
  Future<void> onCharacterComplete() async {
    await heavyImpact();
  }

  /// On button tap.
  Future<void> onButtonTap() async {
    await selectionClick();
  }

  /// On star earned.
  Future<void> onStarEarned() async {
    await lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }
}
