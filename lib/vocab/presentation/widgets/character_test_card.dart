import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/domain/card_mode.dart';
import 'package:write_it_lao/vocab/presentation/i18n/character_strings.dart';
import 'package:write_it_lao/vocab/presentation/widgets/stroke_canvas_host.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_progress_strip.dart';

/// One character of a word in **test mode** — no guide, no headword, no
/// gloss. The user has only the character-type hint to go on. A "Show hint"
/// button reveals the guide at the cost of [hintErrorPenalty] errors and
/// keeps the guide on for the rest of this character.
///
/// Adapts layout automatically:
///  - **Portrait**: compact header row (progress + prompt + word image) then
///    the canvas fills the remaining height.
///  - **Landscape**: canvas on the left (larger flex), controls + image on the
///    right with the word image expanding to fill the gap between the prompt
///    and the progress strip.
class CharacterTestCard extends ConsumerStatefulWidget {
  final WordCharacter character;
  final List<WordCharacter> allCharacters;
  final int positionIndex; // 0-based
  final ValueChanged<int> onErrorAdded;
  final VoidCallback onCharacterComplete;
  final VoidCallback? onAbort;
  final StrokeCanvasHostBuilder canvasBuilder;
  final int hintErrorPenalty;

  /// Optional word-level image path (relative to `assets/vocab/`). When
  /// non-null and non-empty the image is shown beside the header text in
  /// portrait, and fills the right-panel gap in landscape.
  final String? imagePath;

  const CharacterTestCard({
    super.key,
    required this.character,
    required this.allCharacters,
    required this.positionIndex,
    required this.onErrorAdded,
    required this.onCharacterComplete,
    required this.canvasBuilder,
    this.onAbort,
    this.hintErrorPenalty = 3,
    this.imagePath,
  });

  @override
  ConsumerState<CharacterTestCard> createState() => _CharacterTestCardState();
}

class _CharacterTestCardState extends ConsumerState<CharacterTestCard> {
  bool _hintRevealed = false;
  bool _characterComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playAudio();
    });
  }

  void _playAudio() {
    ref
        .read(audioPlayerServiceProvider)
        .playPronunciation(_codepointString(widget.character.character));
  }

  static String _codepointString(String glyph) {
    if (glyph.isEmpty) return '';
    return 'U+${glyph.runes.first.toRadixString(16).toUpperCase().padLeft(4, '0')}';
  }

  void _onStrokeEvaluated(StrokeMatchResult r) {
    if (r != StrokeMatchResult.correct) widget.onErrorAdded(1);
  }

  void _onShowHint() {
    if (_hintRevealed) return;
    widget.onErrorAdded(widget.hintErrorPenalty);
    setState(() => _hintRevealed = true);
  }

  void _onCharacterComplete() {
    setState(() => _characterComplete = true);
    widget.onCharacterComplete();
  }

  bool get _hasImage =>
      widget.imagePath != null && widget.imagePath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastCharacter =
        widget.positionIndex >= widget.allCharacters.length - 1;
    return LayoutBuilder(builder: (context, constraints) {
      final isLandscape = constraints.maxWidth > constraints.maxHeight;
      return SafeArea(
        child: isLandscape
            ? _buildLandscape(theme, isLastCharacter)
            : _buildPortrait(theme, isLastCharacter),
      );
    });
  }

  // ── Portrait ───────────────────────────────────────────────────────────────

  Widget _buildPortrait(ThemeData theme, bool isLastCharacter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildPortraitHeader(theme, isLastCharacter),
          const SizedBox(height: 8),
          Expanded(child: Center(child: _buildCanvas())),
          const SizedBox(height: 8),
          WordProgressStrip(
            characters: widget.allCharacters,
            currentIndex: widget.positionIndex,
            revealCurrent: false,
          ),
          const SizedBox(height: 8),
          if (!_characterComplete)
            TextButton.icon(
              key: WordCardKeys.showHintButton,
              onPressed: _hintRevealed ? null : _onShowHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(CharacterStrings.showHint),
            ),
          _buildNextButton(isLastCharacter, minSize: const Size(200, 56)),
          _buildNextSpacer(height: 56),
        ],
      ),
    );
  }

  // ── Landscape ──────────────────────────────────────────────────────────────

  Widget _buildLandscape(ThemeData theme, bool isLastCharacter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: canvas — larger flex gives more room for the square
          Expanded(
            flex: 6,
            child: Center(child: _buildCanvas()),
          ),

          const SizedBox(width: 12),

          // Right: header + prompt + hint + image + progress strip + next
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLandscapeHeaderRow(theme),
                const SizedBox(height: 4),
                _buildPrompt(theme, isLastCharacter),
                if (!_characterComplete) ...[
                  const SizedBox(height: 4),
                  TextButton.icon(
                    key: WordCardKeys.showHintButton,
                    onPressed: _hintRevealed ? null : _onShowHint,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(CharacterStrings.showHint),
                  ),
                ],
                const SizedBox(height: 8),

                // Word image between prompt/hint and controls — fills gap.
                if (_hasImage)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Image.asset(
                        'assets/vocab/${widget.imagePath}',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Spacer(),
                      ),
                    ),
                  )
                else
                  const Spacer(),

                WordProgressStrip(
                  characters: widget.allCharacters,
                  currentIndex: widget.positionIndex,
                  revealCurrent: false,
                ),
                const SizedBox(height: 8),
                _buildNextButton(isLastCharacter, minSize: const Size(180, 52)),
                _buildNextSpacer(height: 52),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared builders ────────────────────────────────────────────────────────

  /// Portrait-only: compact row combining progress, prompt, word image, audio.
  Widget _buildPortraitHeader(ThemeData theme, bool isLastCharacter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Abort button or placeholder
        if (widget.onAbort != null)
          IconButton(
            key: WordCardKeys.abortButton,
            icon: const Icon(Icons.close),
            onPressed: widget.onAbort,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          )
        else
          const SizedBox(width: 40),

        // Center: progress counter + type hint stacked
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                CharacterStrings.progressLabel(
                  widget.positionIndex + 1,
                  widget.allCharacters.length,
                ),
                key: WordCardKeys.progressLabel,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              Text(
                _characterComplete
                    ? (isLastCharacter ? 'All done!' : 'Great! Move to next')
                    : CharacterStrings.typeHint(widget.character.type),
                key: WordCardKeys.characterTypeHint,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _characterComplete ? Colors.green.shade700 : null,
                ),
              ),
            ],
          ),
        ),

        // Right: word image + audio button
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_hasImage)
              SizedBox(
                height: 52,
                width: 52,
                child: Image.asset(
                  'assets/vocab/${widget.imagePath}',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            IconButton(
              key: WordCardKeys.characterAudioButton,
              icon: const Icon(Icons.volume_up_outlined),
              onPressed: _playAudio,
              tooltip: 'Replay character name',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ],
        ),
      ],
    );
  }

  /// Landscape-only header: full-width row with abort / progress / audio.
  Widget _buildLandscapeHeaderRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.onAbort != null)
          IconButton(
            key: WordCardKeys.abortButton,
            icon: const Icon(Icons.close),
            onPressed: widget.onAbort,
          )
        else
          const SizedBox(width: 48),
        Text(
          CharacterStrings.progressLabel(
            widget.positionIndex + 1,
            widget.allCharacters.length,
          ),
          key: WordCardKeys.progressLabel,
          style: theme.textTheme.bodyMedium,
        ),
        IconButton(
          key: WordCardKeys.characterAudioButton,
          icon: const Icon(Icons.volume_up_outlined),
          onPressed: _playAudio,
          tooltip: 'Replay character name',
        ),
      ],
    );
  }

  Widget _buildPrompt(ThemeData theme, bool isLastCharacter) {
    return Text(
      _characterComplete
          ? (isLastCharacter ? 'All done!' : 'Great! Move to next')
          : CharacterStrings.typeHint(widget.character.type),
      key: WordCardKeys.characterTypeHint,
      style: theme.textTheme.titleMedium?.copyWith(
        color: _characterComplete ? Colors.green.shade700 : null,
      ),
    );
  }

  Widget _buildCanvas() {
    final mode = _hintRevealed ? CardMode.practice : CardMode.test;
    return widget.canvasBuilder(
      laoCharacter: widget.character.character,
      mode: mode,
      onStrokeEvaluated: _onStrokeEvaluated,
      onCharacterComplete:
          _characterComplete ? () {} : _onCharacterComplete,
    );
  }

  Widget _buildNextButton(bool isLastCharacter, {required Size minSize}) {
    return AnimatedOpacity(
      opacity: _characterComplete ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: _characterComplete ? _onCharacterComplete : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          minimumSize: minSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isLastCharacter ? Icons.check : Icons.arrow_forward, size: 26),
            const SizedBox(width: 8),
            Text(
              isLastCharacter ? 'All done!' : 'Next',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSpacer({required double height}) {
    return AnimatedOpacity(
      opacity: _characterComplete ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(height: height),
    );
  }
}
