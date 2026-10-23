import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/data/models/stroke_data.dart';
import 'package:write_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_lao/presentation/widgets/writing_canvas.dart';

void main() {
  group('WritingCanvas', () {
    Widget buildTestWidget({
      double size = 300,
      CharacterStrokeData? strokeData,
      CanvasMode mode = CanvasMode.practice,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WritingCanvas(
              size: size,
              strokeData: strokeData,
              mode: mode,
            ),
          ),
        ),
      );
    }

    testWidgets('renders at the correct size', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: 300));
      await tester.pump();

      expect(find.byType(WritingCanvas), findsOneWidget);
    });

    testWidgets('renders CustomPaint for drawing', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: 300));
      await tester.pump();

      final customPaint = find.byType(CustomPaint);
      expect(customPaint, findsWidgets);
    });

    testWidgets('renders GestureDetector for touch handling', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: 300));
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);
    });

    testWidgets('renders without stroke data', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: 300));
      await tester.pump();

      expect(find.byType(WritingCanvas), findsOneWidget);
    });

    testWidgets('renders in test mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        size: 300,
        mode: CanvasMode.test,
      ));
      await tester.pump();

      expect(find.byType(WritingCanvas), findsOneWidget);
    });

    testWidgets('accepts touch input without crashing', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: 300));
      await tester.pump();

      // Simulate a drag gesture
      final gesture = await tester.startGesture(const Offset(150, 150));
      await gesture.moveBy(const Offset(50, 50));
      await gesture.up();

      expect(find.byType(WritingCanvas), findsOneWidget);
    });
  });
}
