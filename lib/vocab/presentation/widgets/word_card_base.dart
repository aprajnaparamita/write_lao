import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/i18n/translation_helper.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_audio_button.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Visual shell shared by [IntroCard] and [OutroCard]. Renders the headword,
/// metadata, image, and two example rows. Auto-play sequencing and the
/// trailing action row are added by the host card.
class WordCardBase extends StatelessWidget {
  final VocabWord word;
  final VocabAudioPlayer audio;
  final Widget actionRow;

  const WordCardBase({
    super.key,
    required this.word,
    required this.audio,
    required this.actionRow,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final gloss = pickTranslation(
      word.definitions,
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (audio.isMuted)
              const Padding(
                key: WordCardKeys.mutedIndicator,
                padding: EdgeInsets.only(bottom: 8),
                child: Icon(Icons.volume_off, size: 20),
              ),
            // Headword + headword play button.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      word.laoWord,
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                WordAudioButton(
                  key: WordCardKeys.headwordPlayButton,
                  audioPath: word.audioPath,
                  audio: audio,
                  iconSize: 36,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(word.romanization, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(gloss, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              word.partOfSpeech,
              style: theme.textTheme.labelMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset(
                      key: WordCardKeys.image,
                      'assets/vocab/${word.imagePath}',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox(width: 220, height: 220),
                    ),
                    const SizedBox(height: 16),
                    if (word.examples.isNotEmpty)
                      _ExampleRow(
                        example: word.examples[0],
                        audio: audio,
                        playButtonKey: WordCardKeys.example1PlayButton,
                        locale: locale,
                      ),
                    if (word.examples.length >= 2) ...[
                      const SizedBox(height: 12),
                      _ExampleRow(
                        example: word.examples[1],
                        audio: audio,
                        playButtonKey: WordCardKeys.example2PlayButton,
                        locale: locale,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            actionRow,
          ],
        ),
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  final WordExample example;
  final VocabAudioPlayer audio;
  final Key playButtonKey;
  final Locale locale;

  const _ExampleRow({
    required this.example,
    required this.audio,
    required this.playButtonKey,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = pickTranslation(
      example.translations,
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                example.laoScript,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            WordAudioButton(
              key: playButtonKey,
              audioPath: example.audioPath,
              audio: audio,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(translation, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
