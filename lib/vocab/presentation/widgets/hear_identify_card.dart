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
///
/// Adapts layout automatically:
///  - **Portrait**: prompt + audio button stacked above a 2×2 square grid.
///  - **Landscape**: narrow info panel (audio button + answer) on the left,
///    2×2 grid scaled to fill the available height on the right.
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
    return LayoutBuilder(builder: (context, constraints) {
      final isLandscape = constraints.maxWidth > constraints.maxHeight;
      return SafeArea(
        child: isLandscape
            ? _buildLandscape(context, theme, locale)
            : _buildPortrait(context, theme, locale),
      );
    });
  }

  // ── Portrait ───────────────────────────────────────────────────────────────

  Widget _buildPortrait(BuildContext context, ThemeData theme, Locale locale) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Listen and choose',
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
              children: _buildOptionTiles(theme),
            ),
          ),
          if (_selectedWordId != null) ...[
            const SizedBox(height: 8),
            _buildAnswerReveal(theme, locale),
          ],
        ],
      ),
    );
  }

  // ── Landscape ──────────────────────────────────────────────────────────────

  /// In landscape the info panel lives on the left and the 2×2 grid fills
  /// the right side. A nested [LayoutBuilder] computes the exact cell aspect
  /// ratio so the grid tiles fill the available height without any scrolling.
  Widget _buildLandscape(BuildContext context, ThemeData theme, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left: audio replay + prompt + answer reveal ─────────────────
          SizedBox(
            width: 148,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Listen\nand choose',
                  key: WordCardKeys.hearIdentifyPrompt,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                WordAudioButton(
                  key: WordCardKeys.hearIdentifyReplay,
                  audioPath: widget.correctWord.audioPath,
                  audio: widget.audio,
                  iconSize: 40,
                ),
                if (_selectedWordId != null) ...[
                  const SizedBox(height: 16),
                  _buildAnswerReveal(theme, locale),
                ],
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── Right: 2×2 grid, scaled to fill available height ────────────
          Expanded(
            child: LayoutBuilder(builder: (context, gridConstraints) {
              // Compute cell aspect ratio so the 2×2 grid fills the column.
              final w = gridConstraints.maxWidth;
              final h = gridConstraints.maxHeight.isFinite
                  ? gridConstraints.maxHeight
                  : 300.0;
              final cellW = (w - 12) / 2;
              final cellH = (h - 12) / 2;
              final ratio = cellH > 0 ? cellW / cellH : 1.0;
              return GridView.count(
                crossAxisCount: 2,
                childAspectRatio: ratio,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                physics: const NeverScrollableScrollPhysics(),
                children: _buildOptionTiles(theme),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Shared builders ────────────────────────────────────────────────────────

  List<Widget> _buildOptionTiles(ThemeData theme) {
    return [
      for (final opt in widget.options)
        _OptionTile(
          key: ValueKey('vocab.hearIdentify.opt.${opt.wordId}'),
          word: opt,
          background: _bgFor(opt, theme.colorScheme),
          onTap: _selectedWordId == null ? () => _onTap(opt) : null,
        ),
    ];
  }

  Widget _buildAnswerReveal(ThemeData theme, Locale locale) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.correctWord.romanization,
          key: WordCardKeys.hearIdentifyRomanization,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        Text(
          pickTranslation(
            widget.correctWord.definitions,
            languageCode: locale.languageCode,
            scriptCode: locale.scriptCode,
          ),
          key: WordCardKeys.hearIdentifyGloss,
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
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
