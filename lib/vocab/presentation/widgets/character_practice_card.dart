import 'package:flutter/material.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/domain/card_mode.dart';
import 'package:write_it_lao/vocab/presentation/i18n/character_strings.dart';
import 'package:write_it_lao/vocab/presentation/widgets/stroke_canvas_host.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_progress_strip.dart';

/// One character of a word in **practice mode** — shows the stroke guide and
/// counts every non-correct stroke evaluation as one error against the word.
class CharacterPracticeCard extends StatelessWidget {
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

  void _onStrokeEvaluated(StrokeMatchResult r) {
    if (r != StrokeMatchResult.correct) onErrorAdded(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onAbort != null)
                  IconButton(
                    key: WordCardKeys.abortButton,
                    icon: const Icon(Icons.close),
                    onPressed: onAbort,
                  )
                else
                  const SizedBox(width: 48),
                Text(
                  CharacterStrings.progressLabel(
                    positionIndex + 1,
                    allCharacters.length,
                  ),
                  key: WordCardKeys.progressLabel,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CharacterStrings.tracePrompt,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Center(
                child: canvasBuilder(
                  laoCharacter: character.character,
                  mode: CardMode.practice,
                  onStrokeEvaluated: _onStrokeEvaluated,
                  onCharacterComplete: onCharacterComplete,
                ),
              ),
            ),
            const SizedBox(height: 12),
            WordProgressStrip(
              characters: allCharacters,
              currentIndex: positionIndex,
              revealCurrent: true,
            ),
          ],
        ),
      ),
    );
  }
}
