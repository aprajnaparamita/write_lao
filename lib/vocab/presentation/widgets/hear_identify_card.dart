import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/i18n/translation_helper.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_audio_button.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// "Which word did you hear?" — auto-plays the correct word's audio on
/// mount, lays out 4 options (Lao + image only, no romanization or gloss)
/// in a 2×2 grid, then reveals the answer on tap and advances after a
/// short reinforcement delay. Result is binary (correct / wrong) — the
/// engine maps that to SM-2 Good/Again.
class HearIdentifyCard extends StatefulWidget {
  final VocabWord correctWord;
  final List<VocabWord> options; // includes correctWord; pre-shuffled
  final VocabAudioPlayer audio;
  final ValueChanged<bool> onAnswered; // true = correct
  final Duration correctReveal;
  final Duration wrongReveal;

  const HearIdentifyCard({
    super.key,
    required this.correctWord,
    required this.options,
    required this.audio,
    required this.onAnswered,
    this.correctReveal = const Duration(seconds: 1),
    this.wrongReveal = const Duration(seconds: 2),
  });

  @override
  State<HearIdentifyCard> createState() => _HearIdentifyCardState();
}

class _HearIdentifyCardState extends State<HearIdentifyCard> {
  String? _selectedWordId;
  bool _advanced = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.audio.play(widget.correctWord.audioPath);
    });
  }

  @override
  void dispose() {
    widget.audio.stop();
    super.dispose();
  }

  void _onTap(VocabWord chosen) {
    if (_selectedWordId != null) return; // single-shot
    setState(() => _selectedWordId = chosen.wordId);
    final isCorrect = chosen.wordId == widget.correctWord.wordId;
    final delay = isCorrect ? widget.correctReveal : widget.wrongReveal;
    Future.delayed(delay, () {
      if (!mounted || _advanced) return;
      _advanced = true;
      widget.onAnswered(isCorrect);
    });
  }

  Color? _bgFor(VocabWord opt, ColorScheme c) {
    if (_selectedWordId == null) return null;
    final isCorrect = opt.wordId == widget.correctWord.wordId;
    final isChosen = opt.wordId == _selectedWordId;
    if (isCorrect) return c.primaryContainer;
    if (isChosen) return c.errorContainer;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Which word did you hear?',
              key: WordCardKeys.hearIdentifyPrompt,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            WordAudioButton(
              key: WordCardKeys.hearIdentifyReplay,
              audioPath: widget.correctWord.audioPath,
              audio: widget.audio,
              iconSize: 40,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (final opt in widget.options)
                    _OptionTile(
                      key: ValueKey('vocab.hearIdentify.opt.${opt.wordId}'),
                      word: opt,
                      background: _bgFor(opt, theme.colorScheme),
                      onTap: _selectedWordId == null
                          ? () => _onTap(opt)
                          : null,
                    ),
                ],
              ),
            ),
            if (_selectedWordId != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.correctWord.romanization,
                key: WordCardKeys.hearIdentifyRomanization,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                pickTranslation(
                  widget.correctWord.definitions,
                  languageCode: locale.languageCode,
                  scriptCode: locale.scriptCode,
                ),
                key: WordCardKeys.hearIdentifyGloss,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final VocabWord word;
  final Color? background;
  final VoidCallback? onTap;

  const _OptionTile({
    super.key,
    required this.word,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: background ?? theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  'assets/vocab/${word.imagePath}',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word.laoWord,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
