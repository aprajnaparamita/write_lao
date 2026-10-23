import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/audio/audio_player_service.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/domain/card_mode.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_lao/vocab/presentation/widgets/word_outcome.dart';
import 'package:write_lao/vocab/presentation/widgets/word_practice_flow.dart';

import '../../fakes/fake_stroke_canvas.dart';

class _NoOpAudioService extends AudioPlayerService {
  @override
  Future<void> playPronunciation(String codepoint) async {}
}

const _word = VocabWord(
  wordId: 'w_0001',
  laoWord: 'ສະບາຍ',
  romanization: 'sa baai',
  definitions: {'en': 'well'},
  partOfSpeech: 'adj',
  characters: [
    WordCharacter(position: 0, character: 'ສ', type: CharacterType.consonant),
    WordCharacter(position: 1, character: 'ະ', type: CharacterType.vowel),
    WordCharacter(position: 2, character: 'ບ', type: CharacterType.consonant),
  ],
  imagePath: 'images/w_0001.webp',
  audioPath: 'audio/w_0001_word.m4a',
  examples: [],
);

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
  group('WordPracticeFlow', () {
    testWidgets('errors accumulate across all characters', (tester) async {
      WordOutcome? outcome;
      await tester.pumpWidget(_wrap(WordPracticeFlow(
        word: _word,
        mode: CardMode.practice,
        canvasBuilder: fakeStrokeCanvasBuilder,
        onWordCompleted: (o) => outcome = o,
      )));

      // Char 1: 2 errors → complete
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();

      // Char 2: 1 error → complete
      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();

      // Char 3: 0 errors → complete
      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();

      expect(outcome, isNotNull);
      expect(outcome!.wordId, 'w_0001');
      expect(outcome!.errorCount, 3);
      expect(outcome!.durationMs, greaterThanOrEqualTo(0));
    });

    testWidgets('progress label advances 1→2→3 across characters',
        (tester) async {
      await tester.pumpWidget(_wrap(WordPracticeFlow(
        word: _word,
        mode: CardMode.practice,
        canvasBuilder: fakeStrokeCanvasBuilder,
        onWordCompleted: (_) {},
      )));

      expect(find.text('Character 1 of 3'), findsOneWidget);
      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();
      expect(find.text('Character 2 of 3'), findsOneWidget);

      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();
      expect(find.text('Character 3 of 3'), findsOneWidget);
    });

    testWidgets('aborting mid-word does NOT emit a word completion',
        (tester) async {
      WordOutcome? outcome;
      var aborted = false;
      await tester.pumpWidget(_wrap(WordPracticeFlow(
        word: _word,
        mode: CardMode.practice,
        canvasBuilder: fakeStrokeCanvasBuilder,
        onWordCompleted: (o) => outcome = o,
        onAbort: () => aborted = true,
      )));

      await tester.tap(find.byKey(WordCardKeys.fakeStrokeIncorrect));
      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();

      await tester.tap(find.byKey(WordCardKeys.abortButton));
      await tester.pump();

      expect(aborted, isTrue);
      expect(outcome, isNull);
    });

    testWidgets('test mode hides the guide on every character', (tester) async {
      await tester.pumpWidget(_wrap(WordPracticeFlow(
        word: _word,
        mode: CardMode.test,
        canvasBuilder: fakeStrokeCanvasBuilder,
        onWordCompleted: (_) {},
      )));

      expect(find.text('GUIDE'), findsNothing);
      expect(find.text('Draw a consonant'), findsOneWidget);

      await tester.tap(find.byKey(WordCardKeys.fakeCharacterComplete));
      await tester.pump();
      expect(find.text('GUIDE'), findsNothing);
      expect(find.text('Draw a vowel'), findsOneWidget);
    });
  });
}
