import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/presentation/controllers/canvas_controller.dart';

void main() {
  group('CanvasState', () {
    test('copyWith creates new state with updated values', () {
      final state = CanvasState(
        currentStrokeIndex: 0,
        drawnStrokes: const [],
        activeStroke: null,
        referenceStrokes: null,
        mode: CanvasMode.practice,
        showHint: true,
        lastResult: null,
      );

      final newState = state.copyWith(
        currentStrokeIndex: 1,
        showHint: false,
      );

      expect(newState.currentStrokeIndex, 1);
      expect(newState.showHint, false);
      expect(newState.mode, CanvasMode.practice); // unchanged
    });

    test('copyWith with clearActiveStroke sets activeStroke to null', () {
      final state = CanvasState(
        currentStrokeIndex: 0,
        drawnStrokes: const [],
        activeStroke: [const Point(0.0, 0.0)],
        referenceStrokes: null,
        mode: CanvasMode.practice,
        showHint: true,
        lastResult: null,
      );

      final newState = state.copyWith(clearActiveStroke: true);
      expect(newState.activeStroke, isNull);
    });

    test('copyWith with clearLastResult sets lastResult to null', () {
      final state = CanvasState(
        currentStrokeIndex: 0,
        drawnStrokes: const [],
        activeStroke: null,
        referenceStrokes: null,
        mode: CanvasMode.practice,
        showHint: true,
        lastResult: null,
      );

      final newState = state.copyWith(clearLastResult: true);
      expect(newState.lastResult, isNull);
    });
  });

  group('CanvasMode', () {
    test('has correct values', () {
      expect(CanvasMode.values.length, 2);
      expect(CanvasMode.values.contains(CanvasMode.practice), true);
      expect(CanvasMode.values.contains(CanvasMode.test), true);
    });
  });

  group('CanvasController logic', () {
    // Note: Full controller tests would require Riverpod testing setup
    // These are basic unit tests for the state management logic

    test('CanvasState initial values are correct', () {
      final state = CanvasState(
        currentStrokeIndex: 0,
        drawnStrokes: const [],
        activeStroke: null,
        referenceStrokes: null,
        mode: CanvasMode.practice,
        showHint: true,
        lastResult: null,
      );

      expect(state.currentStrokeIndex, 0);
      expect(state.drawnStrokes, isEmpty);
      expect(state.activeStroke, isNull);
      expect(state.referenceStrokes, isNull);
      expect(state.mode, CanvasMode.practice);
      expect(state.showHint, true);
      expect(state.lastResult, isNull);
    });

    test('CanvasState drawnStrokes can be updated', () {
      final stroke = [const Point(0.0, 0.0), const Point(100.0, 100.0)];
      final state = CanvasState(
        currentStrokeIndex: 0,
        drawnStrokes: const [],
        activeStroke: null,
        referenceStrokes: null,
        mode: CanvasMode.practice,
        showHint: true,
        lastResult: null,
      );

      final newState = state.copyWith(
        drawnStrokes: [stroke],
        currentStrokeIndex: 1,
      );

      expect(newState.drawnStrokes.length, 1);
      expect(newState.currentStrokeIndex, 1);
    });
  });
}
