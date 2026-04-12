import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/presentation/widgets/stroke_animator.dart';

void main() {
  group('StrokeAnimator', () {
    late CharacterStrokeData testStrokeData;

    setUp(() {
      testStrokeData = CharacterStrokeData(
        codepoint: 'U+0E81',
        char: 'A',
        strokeCount: 2,
        strokes: [
          StrokeData(
            index: 0,
            points: [
              [100.0, 100.0],
              [200.0, 200.0],
              [300.0, 300.0],
            ],
            startAngle: 45.0,
            direction: 'down-right',
          ),
          StrokeData(
            index: 1,
            points: [
              [300.0, 100.0],
              [300.0, 200.0],
              [300.0, 300.0],
            ],
            startAngle: 90.0,
            direction: 'down',
          ),
        ],
      );
    });

    testWidgets('renders CustomPaint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: testStrokeData,
              size: 300,
            ),
          ),
        ),
      );

      final customPaint = find.byType(CustomPaint);
      expect(customPaint, findsWidgets);
    });

    testWidgets('renders with default size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: testStrokeData,
            ),
          ),
        ),
      );

      expect(find.byType(StrokeAnimator), findsOneWidget);
    });

    testWidgets('renders with custom stroke duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: testStrokeData,
              strokeDuration: const Duration(milliseconds: 2000),
              size: 300,
            ),
          ),
        ),
      );

      expect(find.byType(StrokeAnimator), findsOneWidget);
    });

    testWidgets('renders with empty stroke data', (tester) async {
      final emptyStrokeData = CharacterStrokeData(
        codepoint: 'U+0E82',
        char: 'B',
        strokeCount: 0,
        strokes: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: emptyStrokeData,
              size: 300,
            ),
          ),
        ),
      );

      expect(find.byType(StrokeAnimator), findsOneWidget);
    });

    testWidgets('onComplete callback is optional', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: testStrokeData,
              size: 300,
              // No onComplete callback
            ),
          ),
        ),
      );

      expect(find.byType(StrokeAnimator), findsOneWidget);
    });

    testWidgets('animation runs without immediate errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: testStrokeData,
              strokeDuration: const Duration(milliseconds: 100),
              pauseBetween: const Duration(milliseconds: 50),
              size: 300,
              onComplete: () {},
            ),
          ),
        ),
      );

      // Pump some frames to verify animation doesn't crash
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(StrokeAnimator), findsOneWidget);
    });

    testWidgets('non-looping animation can complete', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StrokeAnimator(
              strokeData: testStrokeData,
              strokeDuration: const Duration(milliseconds: 50),
              pauseBetween: const Duration(milliseconds: 25),
              loop: false,
              size: 300,
              onComplete: () {},
            ),
          ),
        ),
      );

      // Pump through the entire animation
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify no crashes during animation
      expect(find.byType(StrokeAnimator), findsOneWidget);
    });
  });
}
