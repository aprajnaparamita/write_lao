import 'package:write_lao/vocab/data/models/vocab_word.dart';

/// Strings shown by practice/test cards. Kept here so v2 localization can
/// swap them out without touching widget code. English-only in v1.
class CharacterStrings {
  static const tracePrompt = 'Trace this character';
  static const showHint = 'Show hint';
  static const abort = 'Cancel';

  static String typeHint(CharacterType type) {
    switch (type) {
      case CharacterType.consonant:
        return 'Draw a consonant';
      case CharacterType.vowel:
        return 'Draw a vowel';
      case CharacterType.tone:
        return 'Draw a tone mark';
    }
  }

  /// "Character {n} of {total}".
  static String progressLabel(int oneBasedIndex, int total) =>
      'Character $oneBasedIndex of $total';
}
