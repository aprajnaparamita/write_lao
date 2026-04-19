import 'package:flutter/material.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_it_lao/vocab/domain/card_mode.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Test stand-in for the real stroke canvas. Renders the requested character
/// (and a guide marker when in practice mode) plus three buttons that drive
/// the host card's callbacks deterministically.
class FakeStrokeCanvas extends StatelessWidget {
  final String laoCharacter;
  final CardMode mode;
  final ValueChanged<StrokeMatchResult> onStrokeEvaluated;
  final VoidCallback onCharacterComplete;

  const FakeStrokeCanvas({
    super.key,
    required this.laoCharacter,
    required this.mode,
    required this.onStrokeEvaluated,
    required this.onCharacterComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: WordCardKeys.strokeCanvas,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(laoCharacter),
          if (mode == CardMode.practice)
            const Text('GUIDE', key: ValueKey('vocab.fakeCanvas.guide')),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                key: WordCardKeys.fakeStrokeIncorrect,
                onPressed: () =>
                    onStrokeEvaluated(StrokeMatchResult.wrongShape),
                child: const Text('err'),
              ),
              TextButton(
                key: WordCardKeys.fakeStrokeCorrect,
                onPressed: () =>
                    onStrokeEvaluated(StrokeMatchResult.correct),
                child: const Text('ok'),
              ),
              TextButton(
                key: WordCardKeys.fakeCharacterComplete,
                onPressed: onCharacterComplete,
                child: const Text('done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Builder closure matching [StrokeCanvasHostBuilder] for tests.
Widget fakeStrokeCanvasBuilder({
  Key? key,
  required String laoCharacter,
  required CardMode mode,
  required ValueChanged<StrokeMatchResult> onStrokeEvaluated,
  required VoidCallback onCharacterComplete,
}) {
  return FakeStrokeCanvas(
    key: key,
    laoCharacter: laoCharacter,
    mode: mode,
    onStrokeEvaluated: onStrokeEvaluated,
    onCharacterComplete: onCharacterComplete,
  );
}
