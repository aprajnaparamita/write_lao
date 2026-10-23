import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_lao/data/models/stroke_data.dart';
import 'package:write_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_lao/presentation/widgets/canvas_painter.dart';

/// A touch/mouse-enabled drawing surface for stroke practice.
class WritingCanvas extends ConsumerStatefulWidget {
  final double size;
  final CharacterStrokeData? strokeData;
  final CanvasMode mode;
  final VoidCallback? onStrokeComplete;
  final ValueChanged<StrokeEvaluation>? onStrokeEvaluated;
  final VoidCallback? onCharacterComplete;

  const WritingCanvas({
    super.key,
    this.size = 512,
    this.strokeData,
    this.mode = CanvasMode.practice,
    this.onStrokeComplete,
    this.onStrokeEvaluated,
    this.onCharacterComplete,
  });

  @override
  ConsumerState<WritingCanvas> createState() => WritingCanvasState();
}

class WritingCanvasState extends ConsumerState<WritingCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.easeOut,
    );

    // Initialize with widget data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.strokeData != null) {
        ref.read(canvasControllerProvider.notifier).setCharacter(widget.strokeData!);
      }
      ref.read(canvasControllerProvider.notifier).setMode(widget.mode);
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WritingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Defer provider mutations to after the build phase to avoid
    // "Tried to modify a provider while the widget tree was building".
    if (widget.mode != oldWidget.mode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(canvasControllerProvider.notifier).setMode(widget.mode);
        }
      });
    }

    if (widget.strokeData != oldWidget.strokeData && widget.strokeData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(canvasControllerProvider.notifier).setCharacter(widget.strokeData!);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canvasControllerProvider);
    final controller = ref.read(canvasControllerProvider.notifier);

    // Check if character is complete
    ref.listen<CanvasState>(canvasControllerProvider, (previous, next) {
      if (previous != null &&
          !previous.isComplete &&
          next.isComplete) {
        widget.onCharacterComplete?.call();
      }
    });

    final isPractice = widget.mode == CanvasMode.practice;
    final ghostStroke = isPractice && state.showHint
        ? controller.ghostStroke?.pointsAsPoints
        : null;
    final startIndicator = isPractice && state.showHint
        ? controller.startIndicator
        : null;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: RepaintBoundary(
          child: GestureDetector(
            onPanStart: (details) => _onPanStart(details, controller),
            onPanUpdate: (details) => _onPanUpdate(details, controller),
            onPanEnd: (details) => _onPanEnd(controller),
            child: AnimatedBuilder(
              animation: _feedbackAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: CanvasPainter(
                    canvasSize: widget.size,
                    completedStrokes: state.drawnStrokes,
                    activeStroke: state.activeStroke,
                    ghostStroke: ghostStroke,
                    startIndicator: startIndicator,
                    showGuides: true,
                    referenceChar: widget.strokeData?.char,
                    feedbackColor: _feedbackColor,
                    showFeedback: _feedbackController.isAnimating,
                    feedbackAnimation: _feedbackAnimation,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onPanStart(
    DragStartDetails details,
    CanvasController controller,
  ) {
    final point = _widgetToCanvas(details.localPosition);
    controller.startStroke(point);
  }

  void _onPanUpdate(
    DragUpdateDetails details,
    CanvasController controller,
  ) {
    final point = _widgetToCanvas(details.localPosition);
    controller.addPoint(point);
  }

  void _onPanEnd(CanvasController controller) {
    final result = controller.endStroke();
    if (result != null) {
      widget.onStrokeEvaluated?.call(result);
      widget.onStrokeComplete?.call();
      _showFeedback(result.result);
    }
  }

  void _showFeedback(StrokeMatchResult result) {
    switch (result) {
      case StrokeMatchResult.correct:
        _feedbackColor = const Color(0xFF4CAF50); // Green
        break;
      case StrokeMatchResult.wrongDirection:
      case StrokeMatchResult.wrongShape:
      case StrokeMatchResult.wrongPosition:
        _feedbackColor = const Color(0xFFE53935); // Red
        _shakeCanvas();
        break;
      case StrokeMatchResult.tooShort:
        _feedbackColor = const Color(0xFFFFC107); // Yellow/warning
        break;
    }
    _feedbackController.forward(from: 0);
  }

  void _shakeCanvas() {
    // Shake animation would be applied to the container
    // For simplicity, we just show the feedback
  }

  Point<double> _widgetToCanvas(Offset position) {
    // Convert from widget (screen) coordinates to canvas (512-space) coordinates.
    // The painter scales points by (actualSize / canvasSize) when drawing,
    // so we need to do the inverse here to keep touch and paint aligned.
    final renderSize = context.size;
    if (renderSize == null) return Point(position.dx, position.dy);
    final scale = renderSize.width / widget.size;
    return Point(position.dx / scale, position.dy / scale);
  }

  /// Clear the canvas and reset drawn strokes.
  void clearCanvas() {
    ref.read(canvasControllerProvider.notifier).clearAll();
  }
}

/// Helper widget for AnimatedBuilder with Animation.
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
