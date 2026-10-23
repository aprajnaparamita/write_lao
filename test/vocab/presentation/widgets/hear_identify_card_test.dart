import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/presentation/widgets/hear_identify_card.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

import '../../fakes/fake_vocab_audio_player.dart';

VocabWord _word(String id, String lao) => VocabWord(
      wordId: id,
      laoWord: lao,
      romanization: 'rom-$id',
      definitions: const {'en': 'gloss'},
      partOfSpeech: 'noun',
      characters: const [],
      imagePath: 'images/$id.webp',
      audioPath: 'audio/${id}_word.m4a',
      examples: const [],
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

final _correct = _word('w_a', 'ສະບາຍ');
final _options = [
  _correct,
  _word('w_b', 'ຂອບໃຈ'),
  _word('w_c', 'ສະບາຍດີ'),
  _word('w_d', 'ລາ'),
];

void main() {
  group('HearIdentifyCard', () {
    testWidgets('auto-plays the correct word audio on mount', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (_) {},
      )));
      await tester.pump();
      expect(audio.playedPaths, equals(['audio/w_a_word.m4a']));
    });

    testWidgets('replay button plays the same correct-word audio',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (_) {},
      )));
      await tester.pump();
      audio.completeCurrent();

      await tester.tap(find.byKey(WordCardKeys.hearIdentifyReplay));
      await tester.pump();
      expect(audio.playedPaths.last, 'audio/w_a_word.m4a');
    });

    testWidgets('correct tap reports true and reveals reinforcement',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      bool? reported;
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (v) => reported = v,
        correctReveal: const Duration(milliseconds: 50),
      )));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('vocab.hearIdentify.opt.w_a')));
      await tester.pump();
      // Reinforcement appears immediately (gloss + romanization).
      expect(find.byKey(WordCardKeys.hearIdentifyGloss), findsOneWidget);
      expect(find.byKey(WordCardKeys.hearIdentifyRomanization), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      expect(reported, isTrue);
    });

    testWidgets('wrong tap reports false and reveals reinforcement',
        (tester) async {
      final audio = FakeVocabAudioPlayer();
      bool? reported;
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (v) => reported = v,
        wrongReveal: const Duration(milliseconds: 50),
      )));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('vocab.hearIdentify.opt.w_b')));
      await tester.pump();
      expect(find.byKey(WordCardKeys.hearIdentifyGloss), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 60));
      expect(reported, isFalse);
    });

    testWidgets('second tap is ignored', (tester) async {
      final audio = FakeVocabAudioPlayer();
      var calls = 0;
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (_) => calls++,
        correctReveal: const Duration(milliseconds: 30),
        wrongReveal: const Duration(milliseconds: 30),
      )));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('vocab.hearIdentify.opt.w_a')));
      await tester.pump();
      // Try tapping a wrong one after — should be a no-op.
      await tester.tap(
        find.byKey(const ValueKey('vocab.hearIdentify.opt.w_b')),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(calls, 1);
    });

    testWidgets('renders all 4 options as tappable tiles', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (_) {},
      )));
      for (final w in _options) {
        expect(
          find.byKey(ValueKey('vocab.hearIdentify.opt.${w.wordId}')),
          findsOneWidget,
        );
      }
    });

    testWidgets('shows "Listen and choose" instruction label', (tester) async {
      final audio = FakeVocabAudioPlayer();
      await tester.pumpWidget(_wrap(HearIdentifyCard(
        correctWord: _correct,
        options: _options,
        audio: audio,
        onAnswered: (_) {},
      )));
      expect(find.text('Listen and choose'), findsOneWidget);
    });
  });
}
