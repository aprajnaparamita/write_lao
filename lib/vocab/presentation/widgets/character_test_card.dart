import 'package:flutter/material.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
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
class CharacterTestCard extends StatefulWidget {
  final WordCharacter character;
  final List<WordCharacter> allCharacters;
  final int positionIndex; // 0-based
  final ValueChanged<int> onErrorAdded;
  final VoidCallback onCharacterComplete;
  final VoidCallback? onAbort;
  final StrokeCanvasHostBuilder canvasBuilder;
  final int hintErrorPenalty;

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
  });

  @override
  State<CharacterTestCard> createState() => _CharacterTestCardState();
}

class _CharacterTestCardState extends State<CharacterTestCard> {
  bool _hintRevealed = false;

  void _onStrokeEvaluated(StrokeMatchResult r) {
    if (r != StrokeMatchResult.correct) widget.onErrorAdded(1);
  }

  void _onShowHint() {
    if (_hintRevealed) return;
    widget.onErrorAdded(widget.hintErrorPenalty);
    setState(() => _hintRevealed = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mode = _hintRevealed ? CardMode.practice : CardMode.test;
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
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CharacterStrings.typeHint(widget.character.type),
              key: WordCardKeys.characterTypeHint,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: widget.canvasBuilder(
                  laoCharacter: widget.character.character,
                  mode: mode,
                  onStrokeEvaluated: _onStrokeEvaluated,
                  onCharacterComplete: widget.onCharacterComplete,
                ),
              ),
            ),
            const SizedBox(height: 12),
            WordProgressStrip(
              characters: widget.allCharacters,
              currentIndex: widget.positionIndex,
              revealCurrent: false,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: WordCardKeys.showHintButton,
              onPressed: _hintRevealed ? null : _onShowHint,
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(CharacterStrings.showHint),
            ),
          ],
        ),
      ),
    );
  }
}
