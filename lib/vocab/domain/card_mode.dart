import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';

/// Whether a per-character card should show the stroke guide (practice) or
/// hide it and rely on memory (test).
enum CardMode { practice, test }

/// Map an SRS [WordStatus] to the card mode the user should see for that
/// word's characters.
///
/// `new` and `learning` get the guide. `reviewing`, `mature`, and `retired`
/// are recall-mode (no guide). Per Phase 04 spec; owned by the engine, not
/// the widgets.
CardMode cardModeFor(WordStatus status) {
  switch (status) {
    case WordStatus.newWord:
    case WordStatus.learning:
      return CardMode.practice;
    case WordStatus.reviewing:
    case WordStatus.mature:
    case WordStatus.retired:
      return CardMode.test;
  }
}
