import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/widgets/outro_card.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

import '../../fakes/fake_vocab_audio_player.dart';

VocabWord _word() => const VocabWord(
      wordId: 'w_0001',
      laoWord: 'ສະບາຍດີ',
      romanization: 'saʔ baːj diː',
      definitions: {'en': 'hello'},
      partOfSpeech: 'interjection',
      characters: [
        WordCharacter(position: 0, character: 'ສ', type: CharacterType.consonant),
      ],
      imagePath: 'images/w_0001.webp',
      audioPath: 'audio/w_0001_word.wav',
      examples: [
        WordExample(
          exampleId: 'w_0001_ex1',
          laoScript: 'ສະບາຍດີ',
          romanization: 'saʔ baːj diː',
          translations: {'en': 'Hello there'},
          audioPath: 'audio/w_0001_example1.wav',
        ),
        WordExample(
          exampleId: 'w_0001_ex2',
          laoScript: 'ຂອບໃຈ',
          romanization: 'kʰɔːp tɕaj',
          translations: {'en': 'Thank you'},
          audioPath: 'audio/w_0001_example2.wav',
        ),
      ],
    );

Widget _wrap(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 400, height: 760, child: child),
      ),
    ),
  );
}

void main() {
  group('OutroCard', () {
    testWidgets('renders with correct word and all three audio buttons',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(OutroCard(
        word: _word(),
        audio: audio,
        onNext: () {},
        onFlag: () {},
      )));

      expect(find.text('ສະບາຍດີ'), findsWidgets);
      expect(find.byKey(WordCardKeys.headwordPlayButton), findsOneWidget);
      expect(find.byKey(WordCardKeys.example1PlayButton), findsOneWidget);
      expect(find.byKey(WordCardKeys.example2PlayButton), findsOneWidget);
    });

    testWidgets('auto-plays only the headword audio on mount', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(OutroCard(
        word: _word(),
        audio: audio,
        onNext: () {},
        onFlag: () {},
      )));
      await tester.pump();
      expect(audio.playedPaths, equals(['audio/w_0001_word.wav']));

      // Even when the headword finishes, no further auto-play should fire.
      audio.completeCurrent();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(audio.playedPaths, equals(['audio/w_0001_word.wav']));
    });

    testWidgets('each play button plays its own audio path', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(OutroCard(
        word: _word(),
        audio: audio,
        onNext: () {},
        onFlag: () {},
      )));
      await tester.pump();
      audio.completeCurrent(); // clear the auto-played headword

      await tester.tap(find.byKey(WordCardKeys.example1PlayButton));
      await tester.pump();
      expect(audio.playedPaths.last, 'audio/w_0001_example1.wav');
      audio.completeCurrent();

      await tester.tap(find.byKey(WordCardKeys.example2PlayButton));
      await tester.pump();
      expect(audio.playedPaths.last, 'audio/w_0001_example2.wav');
      audio.completeCurrent();

      await tester.tap(find.byKey(WordCardKeys.headwordPlayButton));
      await tester.pump();
      expect(audio.playedPaths.last, 'audio/w_0001_word.wav');
    });

    testWidgets('Flag button invokes the flag callback', (tester) async {
      final audio = FakeVocabAudioPlayer();
      var flagged = false;
      await tester.pumpWidget(_wrap(OutroCard(
        word: _word(),
        audio: audio,
        onNext: () {},
        onFlag: () => flagged = true,
      )));
      await tester.pump();

      await tester.tap(find.byKey(WordCardKeys.flagButton));
      await tester.pump();
      expect(flagged, isTrue);
    });

    testWidgets('Next button stops audio and invokes callback',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      var advanced = false;
      await tester.pumpWidget(_wrap(OutroCard(
        word: _word(),
        audio: audio,
        onNext: () => advanced = true,
        onFlag: () {},
      )));
      await tester.pump();

      await tester.tap(find.byKey(WordCardKeys.nextButton));
      await tester.pump();
      expect(advanced, isTrue);
      expect(audio.stopCallCount, greaterThanOrEqualTo(1));
    });
  });
}
