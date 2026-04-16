import 'dart:math';
import 'package:flutter/material.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';

/// Animates reference strokes being drawn, for the "show me how" feature.
class StrokeAnimator extends StatefulWidget {
  final CharacterStrokeData strokeData;
  final Duration strokeDuration;
  final Duration pauseBetween;
  final bool loop;
  final VoidCallback? onComplete;
  final double size;

  const StrokeAnimator({
    super.key,
    required this.strokeData,
    this.strokeDuration = const Duration(milliseconds: 1000),
    this.pauseBetween = const Duration(milliseconds: 300),
    this.loop = false,
    this.onComplete,
    this.size = 512,
  });

  @override
  State<StrokeAnimator> createState() => _StrokeAnimatorState();
}

class _StrokeAnimatorState extends State<StrokeAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _strokeAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    final strokeCount = widget.strokeData.strokeCount;
    if (strokeCount == 0) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      _strokeAnimations = [];
      return;
    }

    final totalStrokeTime = widget.strokeDuration.inMilliseconds;
    final pauseTime = widget.pauseBetween.inMilliseconds;
    final totalTime = strokeCount * (totalStrokeTime + pauseTime);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalTime),
    );

    _strokeAnimations = [];
    for (var i = 0; i < strokeCount; i++) {
      final start = (i * (totalStrokeTime + pauseTime)) / totalTime;
      final end = ((i * (totalStrokeTime + pauseTime) + totalStrokeTime)) / totalTime;
      _strokeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeInOut),
          ),
        ),
      );
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
        if (widget.loop) {
          _controller.reset();
          _controller.forward();
        }
      }
    });

    _controller.forward();
  }

  @override
  void didUpdateWidget(StrokeAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.strokeData != widget.strokeData) {
      _controller.dispose();
      _setupAnimations();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _StrokeAnimationPainter(
            strokeData: widget.strokeData,
            strokeProgress: _strokeAnimations
                .map((a) => a.value)
                .toList(),
            scale: widget.size / 512,
          ),
        );
      },
    );
  }
}

class _StrokeAnimationPainter extends CustomPainter {
  final CharacterStrokeData strokeData;
  final List<double> strokeProgress;
  final double scale;

  _StrokeAnimationPainter({
    required this.strokeData,
    required this.strokeProgress,
    required this.scale,
  });

  static const Color strokeColor = Color(0xFF2B0071);
  static const Color strokeHintColor = Color(0xFFC4B0E8);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < strokeData.strokeCount; i++) {
      final stroke = strokeData.strokes[i];
      final progress = i < strokeProgress.length ? strokeProgress[i] : 1.0;

      // Draw the full stroke in hint color (ghost)
      _drawStroke(canvas, stroke, 1.0, strokeHintColor);

      // Draw the animated portion in the main color
      if (progress > 0) {
        _drawStroke(canvas, stroke, progress, strokeColor);
      }
    }
  }

  void _drawStroke(Canvas canvas, StrokeData stroke, double progress, Color color) {
    final points = stroke.pointsAsPoints;
    if (points.length < 2) return;

    final totalLength = _calculatePathLength(points);
    final targetLength = totalLength * progress;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 10 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    var currentLength = 0.0;

    path.moveTo(points.first.x * scale, points.first.y * scale);

    for (var i = 1; i < points.length; i++) {
      final segmentLength = _distance(points[i - 1], points[i]);

      if (currentLength + segmentLength <= targetLength) {
        path.lineTo(points[i].x * scale, points[i].y * scale);
        currentLength += segmentLength;
      } else {
        // Partial segment
        final remaining = targetLength - currentLength;
        final t = remaining / segmentLength;
        final x = points[i - 1].x + t * (points[i].x - points[i - 1].x);
        final y = points[i - 1].y + t * (points[i].y - points[i - 1].y);
        path.lineTo(x * scale, y * scale);
        break;
      }
    }

    canvas.drawPath(path, paint);
  }

  double _calculatePathLength(List<Point<double>> points) {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += _distance(points[i - 1], points[i]);
    }
    return total;
  }

  double _distance(Point<double> a, Point<double> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  bool shouldRepaint(_StrokeAnimationPainter old) {
    return old.strokeProgress != strokeProgress ||
        old.strokeData != strokeData;
  }
}
