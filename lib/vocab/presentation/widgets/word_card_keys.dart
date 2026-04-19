import 'package:flutter/widgets.dart';

/// Stable widget keys used by intro/outro card tests.
class WordCardKeys {
  static const image = ValueKey('vocab.wordCard.image');
  static const headwordPlayButton = ValueKey('vocab.wordCard.headwordPlay');
  static const example1PlayButton = ValueKey('vocab.wordCard.example1Play');
  static const example2PlayButton = ValueKey('vocab.wordCard.example2Play');
  static const continueButton = ValueKey('vocab.wordCard.continue');
  static const nextButton = ValueKey('vocab.wordCard.next');
  static const flagButton = ValueKey('vocab.wordCard.flag');
  static const mutedIndicator = ValueKey('vocab.wordCard.muted');

  // Practice / Test card keys (Phase 04).
  static const progressLabel = ValueKey('vocab.charCard.progress');
  static const characterTypeHint = ValueKey('vocab.charCard.typeHint');
  static const showHintButton = ValueKey('vocab.charCard.showHint');
  static const abortButton = ValueKey('vocab.charCard.abort');
  static const wordPreview = ValueKey('vocab.charCard.preview');
  static const strokeCanvas = ValueKey('vocab.charCard.canvas');

  // Test-only fake canvas hooks.
  static const fakeStrokeIncorrect = ValueKey('vocab.fakeCanvas.incorrect');
  static const fakeStrokeCorrect = ValueKey('vocab.fakeCanvas.correct');
  static const fakeCharacterComplete =
      ValueKey('vocab.fakeCanvas.characterComplete');
}
