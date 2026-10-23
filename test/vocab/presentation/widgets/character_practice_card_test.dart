import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/audio/audio_player_service.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/presentation/widgets/character_practice_card.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

import '../../fakes/fake_stroke_canvas.dart';

const _allChars = [
  WordCharacter(position: 0, character: 'ສ', type: CharacterType.consonant),
  WordCharacter(position: 1, character: 'ະ', type: CharacterType.vowel),
  WordCharacter(position: 2, character: 'ບ', type: CharacterType.consonant),
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
  group('CharacterPracticeCard', () {
    testWidgets('renders character + visual guide + progress label',
        (tester) async {
      await tester.pumpWidget(_wrap(CharacterPracticeCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (_) {},
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));

      expect(find.text('ສ'), findsWidgets);
      expect(find.text('GUIDE'), findsOneWidget);
      expect(find.byKey(WordCardKeys.progressLabel), findsOneWidget);
      expect(find.text('Character 1 of 3'), findsOneWidget);
      expect(find.byKey(WordCardKeys.wordPreview), findsOneWidget);
    });

    testWidgets('counts every non-correct stroke as one error',
        (tester) async {
      var errors = 0;
      await tester.pumpWidget(_wrap(CharacterPracticeCard(
        character: _allChars[1],
        allCharacters: _allChars,
        positionIndex: 1,
        onErrorAdded: (n) => errors += n,
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));

      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeCorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.pump();
      expect(errors, 3);
    });

    testWidgets('forwards character-complete callback', (tester) async {
      var done = false;
      await tester.pumpWidget(_wrap(CharacterPracticeCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (_) {},
        onCharacterComplete: () => done = true,
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));

      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();
      expect(done, isTrue);
    });

    testWidgets('renders abort button only when onAbort is non-null',
        (tester) async {
      await tester.pumpWidget(_wrap(CharacterPracticeCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (_) {},
        onCharacterComplete: () {},
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));
      expect(find.byKey(WordCardKeys.abortButton), findsNothing);

      var aborted = false;
      await tester.pumpWidget(_wrap(CharacterPracticeCard(
        character: _allChars[0],
        allCharacters: _allChars,
        positionIndex: 0,
        onErrorAdded: (_) {},
        onCharacterComplete: () {},
        onAbort: () => aborted = true,
        canvasBuilder: fakeStrokeCanvasBuilder,
      )));
      await tester.tap(find.byKey(WordCardKeys.abortButton));
      await tester.pump();
      expect(aborted, isTrue);
    });
  });
}
