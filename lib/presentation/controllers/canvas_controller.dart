import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_lao/data/models/stroke_data.dart';
import 'package:write_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_lao/domain/stroke_matching/stroke_matcher.dart';
import 'package:write_lao/presentation/screens/settings_screen.dart';

enum CanvasMode { practice, test }

class CanvasState {
  final int currentStrokeIndex;
  final List<List<Point<double>>> drawnStrokes;
  final List<Point<double>>? activeStroke;
  final CharacterStrokeData? referenceStrokes;
  final CanvasMode mode;
  final bool showHint;
  final StrokeEvaluation? lastResult;

  const CanvasState({
    required this.currentStrokeIndex,
    required this.drawnStrokes,
    required this.activeStroke,
    required this.referenceStrokes,
    required this.mode,
    required this.showHint,
    required this.lastResult,
  });

  CanvasState copyWith({
    int? currentStrokeIndex,
    List<List<Point<double>>>? drawnStrokes,
    List<Point<double>>? activeStroke,
    bool clearActiveStroke = false,
    CharacterStrokeData? referenceStrokes,
    CanvasMode? mode,
    bool? showHint,
    StrokeEvaluation? lastResult,
    bool clearLastResult = false,
  }) {
    return CanvasState(
      currentStrokeIndex: currentStrokeIndex ?? this.currentStrokeIndex,
      drawnStrokes: drawnStrokes ?? this.drawnStrokes,
      activeStroke: clearActiveStroke ? null : (activeStroke ?? this.activeStroke),
      referenceStrokes: referenceStrokes ?? this.referenceStrokes,
      mode: mode ?? this.mode,
      showHint: showHint ?? this.showHint,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
    );
  }

  bool get isComplete {
    if (referenceStrokes == null) return false;
    return currentStrokeIndex >= referenceStrokes!.strokeCount;
  }
}

class CanvasController extends StateNotifier<CanvasState> {
  final StrokeMatcher _strokeMatcher;

  CanvasController({double similarityThreshold = StrokeMatcher.defaultSimilarityThreshold})
      : _strokeMatcher = StrokeMatcher(similarityThreshold: similarityThreshold),
        super(const CanvasState(
          currentStrokeIndex: 0,
          drawnStrokes: [],
          activeStroke: null,
          referenceStrokes: null,
          mode: CanvasMode.practice,
          showHint: true,
          lastResult: null,
        ));

  /// Update the similarity threshold at runtime (e.g. when the user changes
  /// the stroke-tolerance slider in Settings).  Does NOT reset the canvas
  /// so the user can continue drawing with the new tolerance immediately.
  void setSimilarityThreshold(double value) {
    _strokeMatcher.setSimilarityThreshold(value);
  }

  /// Start a new stroke at the given point.
  void startStroke(Point<double> point) {
    if (state.referenceStrokes == null) return;
    if (state.currentStrokeIndex >= (state.referenceStrokes!.strokeCount)) return;

    state = state.copyWith(activeStroke: [point]);
  }

  /// Add a point to the currently active stroke.
  void addPoint(Point<double> point) {
    if (state.activeStroke == null) return;

    // Throttle: skip points that are too close together
    final lastPoint = state.activeStroke!.last;
    final distance = _distance(lastPoint, point);
    if (distance < 2.0) return;

    state = state.copyWith(activeStroke: [...state.activeStroke!, point]);
  }

  /// End the current stroke and evaluate it.
  StrokeEvaluation? endStroke() {
    if (state.referenceStrokes == null) return null;
    if (state.activeStroke == null) return null;
    if (state.currentStrokeIndex >= state.referenceStrokes!.strokeCount) return null;

    final drawnPoints = state.activeStroke!;
    final referenceStroke = state.referenceStrokes!.strokes[state.currentStrokeIndex];

    // Evaluate the stroke
    final result = _strokeMatcher.evaluate(drawnPoints, referenceStroke);

    state = state.copyWith(lastResult: result);

    if (result.result == StrokeMatchResult.correct) {
      // Add to completed strokes and advance
      final newDrawnStrokes = [...state.drawnStrokes, drawnPoints];
      final newIndex = state.currentStrokeIndex + 1;

      state = state.copyWith(
        drawnStrokes: newDrawnStrokes,
        activeStroke: null,
        clearActiveStroke: true,
        currentStrokeIndex: newIndex,
      );
    } else {
      // Incorrect stroke - clear active stroke but don't advance
      state = state.copyWith(activeStroke: null, clearActiveStroke: true);
    }

    return result;
  }

  /// Clear the current (active) stroke.
  void clearCurrentStroke() {
    state = state.copyWith(activeStroke: null, clearActiveStroke: true);
  }

  /// Clear all strokes and reset to the beginning.
  void clearAll() {
    state = state.copyWith(
      currentStrokeIndex: 0,
      drawnStrokes: [],
      activeStroke: null,
      clearActiveStroke: true,
      lastResult: null,
      clearLastResult: true,
    );
  }

  /// Toggle the hint visibility.
  void toggleHint() {
    state = state.copyWith(showHint: !state.showHint);
  }

  /// Set the character stroke data.
  void setCharacter(CharacterStrokeData data) {
    clearAll();
    state = state.copyWith(referenceStrokes: data);
  }

  /// Set the canvas mode.
  void setMode(CanvasMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Check if all strokes have been completed.
  bool get isComplete => state.isComplete;

  /// Get the current ghost stroke (next expected stroke) for display.
  StrokeData? get ghostStroke {
    if (state.referenceStrokes == null) return null;
    if (state.currentStrokeIndex >= state.referenceStrokes!.strokeCount) return null;
    return state.referenceStrokes!.strokes[state.currentStrokeIndex];
  }

  /// Get the start indicator point for the current stroke.
  Point<double>? get startIndicator {
    final ghost = ghostStroke;
    if (ghost == null) return null;
    final points = ghost.pointsAsPoints;
    if (points.isEmpty) return null;
    return points.first;
  }

  double _distance(Point<double> a, Point<double> b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return sqrt(dx * dx + dy * dy);
  }
}

final canvasControllerProvider = StateNotifierProvider<CanvasController, CanvasState>((ref) {
  // Read the initial tolerance from settings without subscribing, so the
  // controller is not recreated (and its state lost) when the user moves
  // the slider later.  Subsequent changes are pushed via ref.listen.
  final initialThreshold = ref
      .read(settingsControllerProvider)
      .strokeTolerance;
  final controller = CanvasController(similarityThreshold: initialThreshold);

  // Push tolerance changes into the existing controller (no recreation).
  ref.listen(
    settingsControllerProvider.select((s) => s.strokeTolerance),
    (_, next) => controller.setSimilarityThreshold(next),
  );

  return controller;
});
