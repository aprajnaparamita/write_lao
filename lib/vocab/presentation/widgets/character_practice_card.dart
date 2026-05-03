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

/// One character of a word in **practice mode** — shows the stroke guide and
/// counts every non-correct stroke evaluation as one error against the word.
class CharacterPracticeCard extends ConsumerStatefulWidget {
  final WordCharacter character;
  final List<WordCharacter> allCharacters;
  final int positionIndex; // 0-based
  final ValueChanged<int> onErrorAdded;
  final VoidCallback onCharacterComplete;
  final VoidCallback? onAbort;
  final StrokeCanvasHostBuilder canvasBuilder;

  const CharacterPracticeCard({
    super.key,
    required this.character,
    required this.allCharacters,
    required this.positionIndex,
    required this.onErrorAdded,
    required this.onCharacterComplete,
    required this.canvasBuilder,
    this.onAbort,
  });

  @override
  ConsumerState<CharacterPracticeCard> createState() =>
      _CharacterPracticeCardState();
}

class _CharacterPracticeCardState extends ConsumerState<CharacterPracticeCard> {
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

  void _onCharacterComplete() {
    setState(() => _characterComplete = true);
    widget.onCharacterComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastCharacter = widget.positionIndex >= widget.allCharacters.length - 1;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
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
            ),
            const SizedBox(height: 8),
            Text(
              _characterComplete
                  ? (isLastCharacter ? 'All done!' : 'Great! Move to next')
                  : CharacterStrings.tracePrompt,
              style: theme.textTheme.titleMedium?.copyWith(
                color: _characterComplete ? Colors.green.shade700 : null,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: widget.canvasBuilder(
                  laoCharacter: widget.character.character,
                  mode: CardMode.practice,
                  onStrokeEvaluated: _onStrokeEvaluated,
                  onCharacterComplete: _characterComplete ? () {} : _onCharacterComplete,
                ),
              ),
            ),
            const SizedBox(height: 12),
            WordProgressStrip(
              characters: widget.allCharacters,
              currentIndex: widget.positionIndex,
              revealCurrent: true,
            ),
            const SizedBox(height: 16),
            // Large green Next button
            AnimatedOpacity(
              opacity: _characterComplete ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed: _characterComplete ? _onCharacterComplete : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(220, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLastCharacter ? Icons.check : Icons.arrow_forward,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isLastCharacter ? 'All done!' : 'Next',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Invisible spacer to maintain layout when button is hidden
            AnimatedOpacity(
              opacity: _characterComplete ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: const SizedBox(height: 80),
            ),
          ],
        ),
      ),
    );
  }
}
