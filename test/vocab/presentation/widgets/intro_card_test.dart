import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/presentation/widgets/intro_card.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

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
      audioPath: 'audio/w_0001_word.m4a',
      examples: [
        WordExample(
          exampleId: 'w_0001_ex1',
          laoScript: 'ສະບາຍດີ',
          romanization: 'saʔ baːj diː',
          translations: {'en': 'Hello there'},
          audioPath: 'audio/w_0001_example1.m4a',
        ),
        WordExample(
          exampleId: 'w_0001_ex2',
          laoScript: 'ຂອບໃຈ',
          romanization: 'kʰɔːp tɕaj',
          translations: {'en': 'Thank you'},
          audioPath: 'audio/w_0001_example2.m4a',
        ),
      ],
    );

Widget _wrap(Widget child) {
  // Phone-sized viewport so the headword + play-button row fits without the
  // hit-test warning that fires when the button is laid out off-row.
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
  group('IntroCard', () {
    testWidgets('renders with correct word, gloss, and image', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () {},
      )));

      expect(find.text('ສະບາຍດີ'), findsWidgets); // headword (and example1)
      expect(find.text('hello'), findsOneWidget); // gloss
      expect(find.text('interjection'), findsOneWidget); // POS
      expect(find.byKey(WordCardKeys.image), findsOneWidget);
      expect(find.text('Hello there'), findsOneWidget); // example1 translation
      expect(find.text('Thank you'), findsOneWidget); // example2 translation
    });

    testWidgets('auto-plays headword audio on mount', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () {},
      )));
      // Settle the post-frame callback that kicks off the auto-play.
      await tester.pump();
      expect(audio.playedPaths, equals(['audio/w_0001_word.m4a']));
    });

    testWidgets('auto-plays example 1 audio after headword audio completes',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () {},
      )));
      await tester.pump();
      expect(audio.playedPaths, equals(['audio/w_0001_word.m4a']));

      // Simulate the headword audio finishing — example1 should chain after
      // the inter-clip gap (which keeps the next play out of the previous
      // clip's native completion teardown; see IntroCard._chainGap).
      audio.completeCurrent();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        audio.playedPaths,
        equals(['audio/w_0001_word.m4a', 'audio/w_0001_example1.m4a']),
      );
    });

    testWidgets('auto-plays example 2 audio after example 1 completes',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () {},
      )));
      await tester.pump();
      audio.completeCurrent(); // headword done → example1 plays
      await tester.pump(const Duration(milliseconds: 400));
      audio.completeCurrent(); // example1 done → example2 plays
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        audio.playedPaths,
        equals([
          'audio/w_0001_word.m4a',
          'audio/w_0001_example1.m4a',
          'audio/w_0001_example2.m4a',
        ]),
      );
    });

    testWidgets('Continue button stops audio playback and invokes callback',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      var continued = false;
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () => continued = true,
      )));
      await tester.pump();

      await tester.tap(find.byKey(WordCardKeys.continueButton));
      await tester.pump();

      expect(audio.stopCallCount, greaterThanOrEqualTo(1));
      expect(continued, isTrue);
    });

    testWidgets('shows muted indicator when device is muted', (tester) async {
      final audio = FakeVocabAudioPlayer(muted: true);
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () {},
      )));
      await tester.pump();
      expect(find.byKey(WordCardKeys.mutedIndicator), findsOneWidget);
    });

    testWidgets('stops audio when card is unmounted mid-playback',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(IntroCard(
        word: _word(),
        audio: audio,
        onContinue: () {},
      )));
      await tester.pump();

      await tester.pumpWidget(_wrap(const SizedBox()));
      expect(audio.stopCallCount, greaterThanOrEqualTo(1));
    });
  });
}
