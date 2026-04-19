import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_it_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/writing_canvas.dart';
import 'package:write_it_lao/vocab/domain/card_mode.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

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
  final double size;

  const RealStrokeCanvasHost({
    super.key,
    required this.laoCharacter,
    required this.mode,
    required this.onStrokeEvaluated,
    required this.onCharacterComplete,
    this.size = 320,
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
    if (mounted) setState(() => _strokeData = data);
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
    return ProviderScope(
      overrides: [
        canvasControllerProvider
            .overrideWith((_) => CanvasController()),
      ],
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: WritingCanvas(
          key: WordCardKeys.strokeCanvas,
          size: widget.size,
          strokeData: _strokeData,
          mode: widget.mode == CardMode.practice
              ? CanvasMode.practice
              : CanvasMode.test,
          onStrokeEvaluated: (eval) =>
              widget.onStrokeEvaluated(eval.result),
          onCharacterComplete: widget.onCharacterComplete,
        ),
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
