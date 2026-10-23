import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_lao/data/models/stroke_data.dart';
import 'package:write_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/presentation/screens/settings_screen.dart';
import 'package:write_lao/presentation/widgets/writing_canvas.dart';
import 'package:write_lao/vocab/domain/card_mode.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Builder signature used by the practice/test cards. Production wires this
/// to [RealStrokeCanvasHost]; tests inject a fake widget that exposes
/// buttons to simulate stroke events deterministically.
typedef StrokeCanvasHostBuilder = Widget Function({
  Key? key,
  required String laoCharacter,
  required CardMode mode,
  required ValueChanged<StrokeMatchResult> onStrokeEvaluated,
  required VoidCallback onCharacterComplete,
});

/// Production host. Wraps the existing [WritingCanvas] in its own
/// [ProviderScope] so each card has an isolated [canvasControllerProvider]
/// — without this, two cards in the widget tree would share state.
class RealStrokeCanvasHost extends ConsumerStatefulWidget {
  final String laoCharacter;
  final CardMode mode;
  final ValueChanged<StrokeMatchResult> onStrokeEvaluated;
  final VoidCallback onCharacterComplete;

  const RealStrokeCanvasHost({
    super.key,
    required this.laoCharacter,
    required this.mode,
    required this.onStrokeEvaluated,
    required this.onCharacterComplete,
  });

  @override
  ConsumerState<RealStrokeCanvasHost> createState() =>
      _RealStrokeCanvasHostState();
}

class _RealStrokeCanvasHostState extends ConsumerState<RealStrokeCanvasHost> {
  CharacterStrokeData? _strokeData;

  @override
  void initState() {
    super.initState();
    _loadStrokeData();
  }

  @override
  void didUpdateWidget(covariant RealStrokeCanvasHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.laoCharacter != widget.laoCharacter) {
      _loadStrokeData();
    }
  }

  Future<void> _loadStrokeData() async {
    final ds = ref.read(characterStrokeDataSourceProvider);
    final codepoint = _codepointFor(widget.laoCharacter);
    final data = await ds.loadStrokeData(codepoint);
    if (!mounted) return;
    if (data == null) {
      // No stroke data for this character (e.g. a vowel mark not in the set).
      // Auto-complete so the flow isn't stuck.
      widget.onCharacterComplete();
      return;
    }
    setState(() => _strokeData = data);
  }

  /// Convert a single Lao glyph to the asset codepoint format used by
  /// [CharacterStrokeDataSource] (uppercase 4-digit hex, no `U+` prefix).
  static String _codepointFor(String glyph) {
    if (glyph.isEmpty) return '';
    final cp = glyph.runes.first;
    return cp.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  @override
  Widget build(BuildContext context) {
    // Read the current stroke-tolerance setting so the vocab cards also
    // respect the user's difficulty preference.
    final tolerance = ref.watch(
      settingsControllerProvider.select((s) => s.strokeTolerance),
    );
    return ProviderScope(
      overrides: [
        canvasControllerProvider.overrideWith(
          (_) => CanvasController(similarityThreshold: tolerance),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Match the original practice screen: fill available square space so
          // the painter scale (renderSize / 512) stays consistent and stroke
          // reference coordinates (authored in 512-space) land correctly.
          final size = min(constraints.maxWidth, constraints.maxHeight);
          return SizedBox(
            width: size,
            height: size,
            child: WritingCanvas(
              key: WordCardKeys.strokeCanvas,
              size: 512, // authoring coordinate space; SizedBox constrains visual size
              strokeData: _strokeData,
              mode: widget.mode == CardMode.practice
                  ? CanvasMode.practice
                  : CanvasMode.test,
              onStrokeEvaluated: (eval) =>
                  widget.onStrokeEvaluated(eval.result),
              onCharacterComplete: widget.onCharacterComplete,
            ),
          );
        },
      ),
    );
  }
}

/// Default builder for production — `Widget`-typed function literal so the
/// card constructors can take a single typedef param.
Widget defaultStrokeCanvasHostBuilder({
  Key? key,
  required String laoCharacter,
  required CardMode mode,
  required ValueChanged<StrokeMatchResult> onStrokeEvaluated,
  required VoidCallback onCharacterComplete,
}) {
  return RealStrokeCanvasHost(
    key: key,
    laoCharacter: laoCharacter,
    mode: mode,
    onStrokeEvaluated: onStrokeEvaluated,
    onCharacterComplete: onCharacterComplete,
  );
}
