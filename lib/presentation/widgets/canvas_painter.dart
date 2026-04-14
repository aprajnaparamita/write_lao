import 'dart:math';
import 'package:flutter/material.dart';

/// Custom painter for the writing canvas.
class CanvasPainter extends CustomPainter {
  final double canvasSize;
  final List<List<Point<double>>> completedStrokes;
  final List<Point<double>>? activeStroke;
  final List<Point<double>>? ghostStroke;
  final Point<double>? startIndicator;
  final bool showGuides;
  final String? referenceChar;
  final Color? feedbackColor;
  final bool showFeedback;
  final Animation<double>? feedbackAnimation;

  CanvasPainter({
    required this.canvasSize,
    required this.completedStrokes,
    this.activeStroke,
    this.ghostStroke,
    this.startIndicator,
    required this.showGuides,
    this.referenceChar,
    this.feedbackColor,
    this.showFeedback = false,
    this.feedbackAnimation,
  });

  // Colors
  static const Color completedStrokeColor = Color(0xFF333333);
  static const Color activeStrokeColor = Color(0xFF555555);
  static const Color ghostStrokeColor = Color(0xFFB0D4F1);
  static const Color startIndicatorColor = Color(0xFF4CAF50);
  static const Color guideColor = Color(0xFFE0E0E0);
  static const Color referenceCharColor = Color(0xFF4A7BCC);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / canvasSize;

    // Draw background
    _drawBackground(canvas, size);

    // Draw guide lines
    if (showGuides) {
      _drawGuides(canvas, size, scale);
    }

    // Draw reference character
    if (referenceChar != null && referenceChar!.isNotEmpty) {
      _drawReferenceCharacter(canvas, size, scale);
    }

    // Draw ghost stroke
    if (ghostStroke != null && ghostStroke!.isNotEmpty) {
      _drawGhostStroke(canvas, scale);
    }

    // Draw completed strokes
    _drawCompletedStrokes(canvas, scale);

    // Draw active stroke
    if (activeStroke != null && activeStroke!.isNotEmpty) {
      _drawActiveStroke(canvas, scale);
    }

    // Draw start indicator
    if (startIndicator != null) {
      _drawStartIndicator(canvas, scale);
    }

    // Draw feedback overlay
    if (showFeedback && feedbackColor != null && feedbackAnimation != null) {
      _drawFeedback(canvas, size);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _drawGuides(Canvas canvas, Size size, double scale) {
    final paint = Paint()
      ..color = guideColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Crosshair guides
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.drawLine(
      Offset(centerX, 0),
      Offset(centerX, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint,
    );

    // Inset dashed border
    final inset = 32 * scale;
    final borderRect = Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset);
    final dashPaint = Paint()
      ..color = guideColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    _drawDashedRect(canvas, borderRect, dashPaint);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;

    // Top
    var startX = rect.left;
    while (startX < rect.right) {
      canvas.drawLine(
        Offset(startX, rect.top),
        Offset((startX + dashWidth).clamp(rect.left, rect.right), rect.top),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Right
    var startY = rect.top;
    while (startY < rect.bottom) {
      canvas.drawLine(
        Offset(rect.right, startY),
        Offset(rect.right, (startY + dashWidth).clamp(rect.top, rect.bottom)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // Bottom
    startX = rect.left;
    while (startX < rect.right) {
      canvas.drawLine(
        Offset(startX, rect.bottom),
        Offset((startX + dashWidth).clamp(rect.left, rect.right), rect.bottom),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Left
    startY = rect.top;
    while (startY < rect.bottom) {
      canvas.drawLine(
        Offset(rect.left, startY),
        Offset(rect.left, (startY + dashWidth).clamp(rect.top, rect.bottom)),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  void _drawReferenceCharacter(Canvas canvas, Size size, double scale) {
    // The ghost stroke provides the tracing guide, so the reference text
    // is purely decorative context. We don't draw it — it can never align
    // perfectly with the strokes unless we bundle the exact SVG authoring
    // font, and two overlapping guides are more confusing than helpful.
  }

  void _drawCompletedStrokes(Canvas canvas, double scale) {
    final paint = Paint()
      ..color = completedStrokeColor
      ..strokeWidth = 8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in completedStrokes) {
      if (stroke.length < 2) continue;
      final path = _createPath(stroke, scale);
      canvas.drawPath(path, paint);
    }
  }

  void _drawActiveStroke(Canvas canvas, double scale) {
    final paint = Paint()
      ..color = activeStrokeColor
      ..strokeWidth = 8 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (activeStroke!.length < 2) {
      // Draw a dot for a single point
      final point = activeStroke!.first;
      canvas.drawCircle(
        Offset(point.x * scale, point.y * scale),
        4 * scale,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = _createPath(activeStroke!, scale);
    canvas.drawPath(path, paint);
  }

  void _drawGhostStroke(Canvas canvas, double scale) {
    final paint = Paint()
      ..color = ghostStrokeColor
      ..strokeWidth = 10 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (ghostStroke!.length < 2) return;

    // Create dashed path
    final path = _createPath(ghostStroke!, scale);
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    const dashLength = 12.0;
    const dashGap = 6.0;

    for (final metric in pathMetrics) {
      var distance = 0.0;
      var draw = true;

      while (distance < metric.length) {
        final length = draw ? dashLength : dashGap;
        if (draw) {
          final extractPath = metric.extractPath(
            distance,
            (distance + length).clamp(0, metric.length),
          );
          canvas.drawPath(extractPath, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  void _drawStartIndicator(Canvas canvas, double scale) {
    final center = Offset(
      startIndicator!.x * scale,
      startIndicator!.y * scale,
    );

    // Outer circle (pulse effect)
    final outerPaint = Paint()
      ..color = startIndicatorColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 16 * scale, outerPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = startIndicatorColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10 * scale, innerPaint);

    // White center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4 * scale, dotPaint);
  }

  void _drawFeedback(Canvas canvas, Size size) {
    final opacity = (feedbackAnimation?.value ?? 1.0);
    final color = feedbackColor?.withValues(alpha: opacity * 0.3) ?? Colors.transparent;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paint);
  }

  Path _createPath(List<Point<double>> points, double scale) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.x * scale, points.first.y * scale);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].x * scale, points[i].y * scale);
    }
    return path;
  }

  @override
  bool shouldRepaint(CanvasPainter old) {
    return old.completedStrokes != completedStrokes ||
        old.activeStroke != activeStroke ||
        old.ghostStroke != ghostStroke ||
        old.startIndicator != startIndicator ||
        old.showGuides != showGuides ||
        old.referenceChar != referenceChar ||
        old.feedbackColor != feedbackColor ||
        old.showFeedback != showFeedback;
  }
}
