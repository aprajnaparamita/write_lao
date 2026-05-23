import 'dart:async';

import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/i18n/translation_helper.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_audio_button.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

// ── Section accent colours ──────────────────────────────────────────────────

/// Orange — headword / word section.
const _wordColor = Color(0xFFF97316);

/// Sky blue — example 1 section.
const _ex1Color = Color(0xFF0284C7);

/// Emerald — example 2 section.
const _ex2Color = Color(0xFF059669);

// ── WordCardBase ─────────────────────────────────────────────────────────────

/// Visual shell shared by [IntroCard] and [OutroCard].
///
/// **Portrait** layout (top → bottom):
///   1. Word tile  — tinted, tappable; contains headword + meta + play button.
///   2. Image      — [Expanded]: fills every pixel left after the fixed tiles.
///   3. Example 1  — tinted tile, tappable.
///   4. Example 2  — tinted tile, tappable.
///   5. Action row — "I'm ready" or "Got it" button.
///
/// **Landscape** layout (left → right):
///   1. Image — fills the left column with contained aspect ratio.
///   2. Word tile + examples + action row — scrollable right column.
///
/// Tapping *anywhere* on a tinted tile plays / stops its audio — the large
/// play-button icon inside the tile provides visual feedback but is also an
/// independent tap target for precision taps.
class WordCardBase extends StatefulWidget {
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
  State<WordCardBase> createState() => _WordCardBaseState();
}

class _WordCardBaseState extends State<WordCardBase> {
  StreamSubscription<VocabAudioState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _stateSub = widget.audio.stateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  bool _isPlaying(String path) =>
      widget.audio.state == VocabAudioState.playing &&
      widget.audio.currentPath == path;

  bool get _wordPlaying => _isPlaying(widget.word.audioPath);

  bool get _ex1Playing =>
      widget.word.examples.isNotEmpty &&
      _isPlaying(widget.word.examples[0].audioPath);

  bool get _ex2Playing =>
      widget.word.examples.length >= 2 &&
      _isPlaying(widget.word.examples[1].audioPath);

  /// Whole-card background wash — very light tint of the active section colour.
  Color get _cardBg {
    if (_wordPlaying) return _wordColor.withValues(alpha: 0.06);
    if (_ex1Playing) return _ex1Color.withValues(alpha: 0.06);
    if (_ex2Playing) return _ex2Color.withValues(alpha: 0.06);
    return Colors.transparent;
  }

  /// Toggle play/stop for [path]. Called by tile-level [GestureDetector] and
  /// also wired to each [WordAudioButton.onPressed] independently.
  Future<void> _toggleAudio(String path) async {
    if (widget.audio.state == VocabAudioState.playing &&
        widget.audio.currentPath == path) {
      await widget.audio.stop();
    } else {
      await widget.audio.play(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final theme = Theme.of(context);
    final gloss = pickTranslation(
      widget.word.definitions,
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
    );

    return LayoutBuilder(builder: (context, constraints) {
      final isLandscape = constraints.maxWidth > constraints.maxHeight;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        color: _cardBg,
        child: SafeArea(
          child: isLandscape
              ? _buildLandscape(theme, gloss, locale)
              : _buildPortrait(theme, gloss, locale),
        ),
      );
    });
  }

  // ── Portrait ───────────────────────────────────────────────────────────────

  Widget _buildPortrait(ThemeData theme, String gloss, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.audio.isMuted)
            const Padding(
              key: WordCardKeys.mutedIndicator,
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.volume_off, size: 20),
            ),

          // 1. Word section tile
          _buildWordTile(theme, gloss),

          // 2. Image — expands to fill remaining vertical space
          const SizedBox(height: 8),
          Expanded(child: _buildImage()),
          const SizedBox(height: 8),

          // 3 & 4. Example tiles
          if (widget.word.examples.isNotEmpty) _buildExampleTile(0, locale),
          if (widget.word.examples.length >= 2) ...[
            const SizedBox(height: 8),
            _buildExampleTile(1, locale),
          ],

          // 5. Action row
          const SizedBox(height: 8),
          widget.actionRow,
        ],
      ),
    );
  }

  // ── Landscape ──────────────────────────────────────────────────────────────

  Widget _buildLandscape(ThemeData theme, String gloss, Locale locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: image fills the column height
          Expanded(flex: 4, child: _buildImage()),

          const SizedBox(width: 16),

          // Right: scrollable word info + examples + action
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.audio.isMuted)
                    const Padding(
                      key: WordCardKeys.mutedIndicator,
                      padding: EdgeInsets.only(bottom: 6),
                      child: Icon(Icons.volume_off, size: 20),
                    ),
                  _buildWordTile(theme, gloss),
                  if (widget.word.examples.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _buildExampleTile(0, locale),
                  ],
                  if (widget.word.examples.length >= 2) ...[
                    const SizedBox(height: 8),
                    _buildExampleTile(1, locale),
                  ],
                  const SizedBox(height: 12),
                  widget.actionRow,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared tile builders ───────────────────────────────────────────────────

  Widget _buildImage() => Image.asset(
        key: WordCardKeys.image,
        'assets/vocab/${widget.word.imagePath}',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.expand(),
      );

  Widget _buildWordTile(ThemeData theme, String gloss) {
    return _SectionTile(
      color: _wordColor,
      isPlaying: _wordPlaying,
      onTap: () => _toggleAudio(widget.word.audioPath),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.word.laoWord,
                    style: theme.textTheme.displayMedium,
                  ),
                ),
                const SizedBox(height: 2),
                Text(widget.word.romanization,
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: 4),
                Text(gloss, style: theme.textTheme.titleMedium),
                Text(
                  widget.word.partOfSpeech,
                  style: theme.textTheme.labelMedium
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          WordAudioButton(
            key: WordCardKeys.headwordPlayButton,
            audioPath: widget.word.audioPath,
            audio: widget.audio,
            iconSize: 52,
            activeColor: _wordColor,
          ),
        ],
      ),
    );
  }

  Widget _buildExampleTile(int index, Locale locale) {
    final example = widget.word.examples[index];
    return _ExampleRow(
      example: example,
      audio: widget.audio,
      playButtonKey: index == 0
          ? WordCardKeys.example1PlayButton
          : WordCardKeys.example2PlayButton,
      locale: locale,
      sectionColor: index == 0 ? _ex1Color : _ex2Color,
      isPlaying: index == 0 ? _ex1Playing : _ex2Playing,
      onTap: () => _toggleAudio(example.audioPath),
    );
  }
}

// ── _SectionTile ─────────────────────────────────────────────────────────────

/// Tinted rounded tile that pops when [isPlaying] is true.
///
/// The entire tile is a tap target via [onTap].  Child [WordAudioButton]s
/// inside the tile remain independently tappable — Flutter's gesture arena
/// routes button taps to the button, and all other tile taps to [onTap].
class _SectionTile extends StatelessWidget {
  final Color color;
  final bool isPlaying;
  final Widget child;
  final VoidCallback? onTap;

  const _SectionTile({
    required this.color,
    required this.isPlaying,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isPlaying ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 280),
      curve: isPlaying ? Curves.easeOutBack : Curves.easeOut,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPlaying
                ? color.withValues(alpha: 0.18)
                : color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? color.withValues(alpha: 0.75)
                  : color.withValues(alpha: 0.28),
              width: isPlaying ? 2.0 : 1.0,
            ),
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.28),
                      blurRadius: 16,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : const [],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── _ExampleRow ──────────────────────────────────────────────────────────────

class _ExampleRow extends StatelessWidget {
  final WordExample example;
  final VocabAudioPlayer audio;
  final Key playButtonKey;
  final Locale locale;
  final Color sectionColor;
  final bool isPlaying;
  final VoidCallback? onTap;

  const _ExampleRow({
    required this.example,
    required this.audio,
    required this.playButtonKey,
    required this.locale,
    required this.sectionColor,
    required this.isPlaying,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = pickTranslation(
      example.translations,
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
    );
    return _SectionTile(
      color: sectionColor,
      isPlaying: isPlaying,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  example.laoScript,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(translation, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          WordAudioButton(
            key: playButtonKey,
            audioPath: example.audioPath,
            audio: audio,
            iconSize: 52,
            activeColor: sectionColor,
          ),
        ],
      ),
    );
  }
}
