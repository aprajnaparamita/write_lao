import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/audio/audio_player_service.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/widgets/character_test_card.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

import '../../fakes/fake_stroke_canvas.dart';

const _allChars = [
  WordCharacter(position: 0, character: 'ສ', type: CharacterType.consonant),
  WordCharacter(position: 1, character: 'ະ', type: CharacterType.vowel),
  WordCharacter(position: 2, character: 'ບ', type: CharacterType.tone),
];

class _NoOpAudioService extends AudioPlayerService {
  @override
  Future<void> playPronunciation(String codepoint) async {}
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      audioPlayerServiceProvider.overrideWithValue(_NoOpAudioService()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 400, height: 760, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('CharacterTestCard', () {
    testWidgets('renders type hint and NO visual guide', (tester) async {
      await tester.pumpWidget(_wrap(CharacterTestCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (_) {},
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));

      expect(find.byKey(WordCardKeys.characterTypeHint), findsOneWidget);
      expect(find.text('Draw a consonant'), findsOneWidget);
      expect(find.text('GUIDE'), findsNothing);
      // Current slot in the preview should be hidden ('_'), not the glyph.
      expect(find.text('ສ'), findsOneWidget); // canvas only
    });

    testWidgets('type hint copy switches by character.type', (tester) async {
      await tester.pumpWidget(_wrap(CharacterTestCard(
        character: _allChars[1], // vowel
        allCharacters: _allChars,
        positionIndex: 1,
        onErrorAdded: (_) {},
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));
      expect(find.text('Draw a vowel'), findsOneWidget);

      await tester.pumpWidget(_wrap(CharacterTestCard(
        character: _allChars[2], // tone
        allCharacters: _allChars,
        positionIndex: 2,
        onErrorAdded: (_) {},
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));
      expect(find.text('Draw a tone mark'), findsOneWidget);
    });

    testWidgets('counts incorrect strokes and forwards complete callback',
        (tester) async {
      var errors = 0;
      var done = false;
      await tester.pumpWidget(_wrap(CharacterTestCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (n) => errors += n,
        onCharacterComplete: () => done = true,
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));

      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeCorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();
      expect(errors, 1);
      expect(done, isTrue);
    });

    testWidgets('show-hint reveals guide and adds penalty errors',
        (tester) async {
      var errors = 0;
      await tester.pumpWidget(_wrap(CharacterTestCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (n) => errors += n,
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
        hintErrorPenalty: 3,
      )));

      expect(find.text('GUIDE'), findsNothing);

      await tester.tap(find.byKey(WordCardKeys.showHintButton));
      await tester.pump();

      expect(errors, 3);
      expect(find.text('GUIDE'), findsOneWidget);

      // Tapping again is a no-op (button disabled, no extra penalty).
      await tester.tap(find.byKey(WordCardKeys.showHintButton),
          warnIfMissed: false);
      await tester.pump();
      expect(errors, 3);
    });
  });
}
