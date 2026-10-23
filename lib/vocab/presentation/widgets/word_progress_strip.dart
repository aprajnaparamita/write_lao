import 'package:flutter/material.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Strip showing the word being built up, character by character. Already-
/// drawn slots render in normal weight; the current slot is highlighted;
/// future slots show as `_`. The current slot is hidden when [revealCurrent]
/// is false (test mode).
///
/// [fontSize] controls the Lao glyph size. Callers should pass a larger value
/// in portrait (e.g. 40) and a somewhat smaller one in landscape (e.g. 32)
/// since vertical space is limited there.
class WordProgressStrip extends StatelessWidget {
  final List<WordCharacter> characters;
  final int currentIndex;
  final bool revealCurrent;

  /// Point size of the Lao characters. Defaults to 36 which is comfortably
  /// readable on phone screens in both orientations.
  final double fontSize;

  const WordProgressStrip({
    super.key,
    required this.characters,
    required this.currentIndex,
    this.revealCurrent = true,
    this.fontSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Base style: larger, Noto Lao for correct Lao shaping.
    final base = TextStyle(
      fontFamily: 'Noto Lao',
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: theme.textTheme.headlineMedium?.color,
      height: 1.3,
    );

    final spans = <InlineSpan>[];
    for (var i = 0; i < characters.length; i++) {
      final char = characters[i].character;
      final isDone = i < currentIndex;
      final isCurrent = i == currentIndex;
      late final TextStyle style;
      late final String text;
      if (isDone) {
        text = char;
        style = base;
      } else if (isCurrent) {
        text = revealCurrent ? char : '_';
        style = base.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        );
      } else {
        text = '_';
        style = base.copyWith(color: theme.disabledColor);
      }
      spans.add(TextSpan(text: text, style: style));
      if (i < characters.length - 1) {
        // Don't insert a space before a combining mark (vowel or tone).
        // Unicode combining characters must immediately follow their base
        // consonant — a space in between breaks the shaping and causes the
        // mark to render to the right instead of above the base glyph.
        final nextType = characters[i + 1].type;
        final nextIsCombining =
            nextType == CharacterType.vowel || nextType == CharacterType.tone;
        if (!nextIsCombining) {
          spans.add(TextSpan(text: ' ', style: base));
        }
      }
    }
    return RichText(
      key: WordCardKeys.wordPreview,
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
    );
  }
}
