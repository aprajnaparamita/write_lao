# Prompt 02 — Stroke Matching Engine (Core Algorithm)

## Context

You are building "Write Lao". The project is scaffolded with data models and character database (Prompt 01). Read `00_OVERVIEW.md` for architecture. This prompt implements the stroke matching algorithm — the most critical piece of the app.

## Goal

Implement the stroke matching engine that compares a user's drawn stroke against a reference stroke and returns a match result. This is pure domain logic with zero UI dependencies. Everything in this prompt lives in `lib/domain/stroke_matching/` and is tested thoroughly.

## Algorithm Overview

The matching problem is constrained: we know which character the user is drawing, and we know which stroke they should be drawing next. We're not doing open-ended character recognition. We only need to answer: "Did the user draw something close enough to stroke N of character X?"

### Pipeline

```
Raw touch points → Resample → Normalize → Compare → Score
```

### Step 1: Point Resampling (`point_resampler.dart`)

Raw touch input gives irregular, unevenly-spaced points (clusters where the finger moves slowly, gaps where it moves fast). Resample to N evenly-spaced points along the path.

```dart
class PointResampler {
  /// Resample a list of raw points to exactly [targetCount] evenly-spaced points.
  /// Uses linear interpolation along the path length.
  List<Point<double>> resample(List<Point<double>> rawPoints, int targetCount);

  /// Calculate total path length of a point sequence.
  double pathLength(List<Point<double>> points);
}
```

**Algorithm:**
1. Compute total path length L
2. Spacing = L / (targetCount - 1)
3. Walk along path, placing a point every `spacing` distance
4. Interpolate between original points as needed

**Edge cases to handle:**
- Fewer than 2 raw points → return empty list
- All raw points are the same (zero length) → return list of that point repeated
- Very short paths (less than minimum threshold) → likely a tap, not a stroke

### Step 2: Path Utilities (`path_utils.dart`)

```dart
class PathUtils {
  /// Euclidean distance between two points.
  static double distance(Point<double> a, Point<double> b);

  /// Angle in degrees from point a to point b. 0=right, 90=down, 180=left, 270=up.
  static double angleBetween(Point<double> a, Point<double> b);

  /// Compute the bounding box of a point list.
  static Rect boundingBox(List<Point<double>> points);

  /// Translate points so the centroid is at the origin.
  static List<Point<double>> centerOnOrigin(List<Point<double>> points);

  /// Scale points to fit within a target size, preserving aspect ratio.
  static List<Point<double>> scaleToFit(List<Point<double>> points, double targetSize);

  /// Compute the average directed Hausdorff distance from A to B.
  /// For each point in A, find the closest point in B. Average those distances.
  static double averageDirectedHausdorff(List<Point<double>> a, List<Point<double>> b);

  /// Compute the symmetric average Hausdorff distance: max of both directed distances.
  static double averageHausdorffDistance(List<Point<double>> a, List<Point<double>> b);

  /// Sample points along an SVG-style cubic Bezier path string.
  /// Input: SVG path d attribute (M, C, L commands).
  /// Output: list of evenly-spaced points.
  static List<Point<double>> sampleSvgPath(String pathData, int sampleCount);

  /// Check if point sequence goes in roughly the same direction as reference.
  /// Compare start-to-end vector angles. Returns true if within tolerance degrees.
  static bool isSameDirection(
    List<Point<double>> drawn,
    List<Point<double>> reference,
    {double toleranceDegrees = 90}
  );
}
```

### Step 3: Stroke Evaluator (`stroke_evaluator.dart`)

```dart
enum StrokeMatchResult {
  correct,           // stroke matches reference well enough
  wrongDirection,    // shape is right but drawn backwards
  wrongShape,        // doesn't match reference shape
  tooShort,          // path is too short (likely a tap or incomplete stroke)
  wrongPosition,     // right shape but in the wrong area of the canvas
}

@freezed
class StrokeEvaluation with _$StrokeEvaluation {
  const factory StrokeEvaluation({
    required StrokeMatchResult result,
    required double similarity,        // 0.0–1.0, higher = better match
    required double distanceScore,     // average Hausdorff distance, normalized
    required bool directionCorrect,
    required bool positionCorrect,
  }) = _StrokeEvaluation;
}
```

### Step 4: Stroke Matcher (`stroke_matcher.dart`)

This is the main entry point for stroke matching.

```dart
class StrokeMatcher {
  final PointResampler _resampler;
  final double _canvasSize;

  /// Configuration
  static const int resamplePointCount = 48;
  static const double similarityThreshold = 0.70;       // minimum to pass
  static const double distanceToleranceFraction = 0.12;  // max avg distance as fraction of canvas
  static const double minPathLengthFraction = 0.05;      // minimum path length as fraction of canvas
  static const double directionToleranceDegrees = 90.0;
  static const double positionToleranceFraction = 0.25;  // center offset tolerance

  StrokeMatcher({double canvasSize = 512.0});

  /// Compare a user-drawn stroke against the expected reference stroke.
  ///
  /// [drawnPoints] - raw touch points from the canvas, in canvas coordinates
  /// [referenceStroke] - the StrokeData for the expected next stroke
  /// [canvasSize] - the actual canvas size (for scaling reference to match)
  StrokeEvaluation evaluate(
    List<Point<double>> drawnPoints,
    StrokeData referenceStroke,
  );
}
```

**Matching algorithm detail:**

1. **Filter short paths:** If drawn path length < `minPathLengthFraction * canvasSize`, return `tooShort`.

2. **Resample both:** Resample drawn points and reference points to `resamplePointCount` points each.

3. **Check direction:** Compare the angle of the drawn start→end vector vs reference start→end vector. If they differ by more than `directionToleranceDegrees` AND the reverse direction is within tolerance, flag as `wrongDirection`.

4. **Check position:** Compare centroids of drawn vs reference. If the centroid offset is > `positionToleranceFraction * canvasSize`, flag as `wrongPosition`.

5. **Normalize for comparison:** Center both point sets on their centroids. Scale both to the same bounding box size.

6. **Compute distance:** Use DTW (Dynamic Time Warping) distance between the two normalized, resampled sequences. DTW is better than Hausdorff here because stroke order matters — point 1 should match near point 1, not jump around.

   DTW implementation:
   ```
   Create matrix D[n+1][m+1], initialize D[0][j] = D[i][0] = infinity, D[0][0] = 0
   For i=1..n, j=1..m:
     cost = euclidean_distance(drawn[i-1], reference[j-1])
     D[i][j] = cost + min(D[i-1][j], D[i][j-1], D[i-1][j-1])
   DTW_distance = D[n][m] / max(n, m)
   ```

7. **Compute similarity:** `similarity = 1.0 - (dtw_distance / canvasSize).clamp(0.0, 1.0)`

8. **Decision:**
   - If similarity >= threshold AND direction correct AND position correct → `correct`
   - If similarity >= threshold AND direction wrong → `wrongDirection`
   - If similarity >= threshold AND position wrong → `wrongPosition`
   - Otherwise → `wrongShape`

## Tasks

### 1. Write Tests First

#### `test/domain/stroke_matching/point_resampler_test.dart`
- Resample a straight horizontal line of 100 points to 10 points → expect 10 evenly spaced points
- Resample 2 points to 10 points → expect linear interpolation
- Resample 1 point → expect empty list
- Resample to same count as input → points should be similar (within floating point tolerance)
- Resample an L-shaped path → verify corner is preserved
- Empty input → empty output

#### `test/domain/stroke_matching/path_utils_test.dart`
- `distance()` between (0,0) and (3,4) → 5.0
- `angleBetween()` (0,0)→(1,0) → 0.0 degrees
- `angleBetween()` (0,0)→(0,1) → 90.0 degrees (down in screen coords)
- `boundingBox()` of known points → correct rect
- `centerOnOrigin()` → centroid should be at (0,0) ± epsilon
- `scaleToFit()` → bounding box should fit within target
- `averageHausdorffDistance()` of identical point sets → 0.0
- `averageHausdorffDistance()` of shifted point sets → expected offset
- `isSameDirection()` of same-direction paths → true
- `isSameDirection()` of reversed paths → false

#### `test/domain/stroke_matching/stroke_matcher_test.dart`
- **Exact match:** drawn points = reference points → `correct`, similarity ~1.0
- **Close match:** reference + small random noise (±5px) → `correct`
- **Reversed stroke:** same points but reversed order → `wrongDirection`
- **Wrong position:** correct shape but shifted 200px right → `wrongPosition`
- **Wrong shape:** random scribble → `wrongShape`
- **Too short:** 3 pixels of movement → `tooShort`
- **Scaled match:** drawn at 80% size but same shape → `correct` (should still pass)
- **Rotated slightly:** ~15° rotation of correct shape → `correct` (tolerance)
- **Grossly rotated:** 90° rotation → `wrongShape`

### 2. Implement the Classes

Implement `PointResampler`, `PathUtils`, `StrokeEvaluation`, and `StrokeMatcher` to pass all tests. Keep constants configurable so tolerance can be tuned later.

### 3. Create a DTW Implementation

Implement Dynamic Time Warping in `lib/domain/stroke_matching/dtw.dart`:

```dart
class DTW {
  /// Compute DTW distance between two point sequences.
  /// Returns the normalized DTW distance (total cost / alignment length).
  static double distance(List<Point<double>> a, List<Point<double>> b);
}
```

Write tests for DTW:
- Two identical sequences → distance 0
- Sequence vs itself shifted by 1 index → small distance
- Completely different sequences → large distance
- Sequences of different lengths → should still work

## Acceptance Criteria

- [ ] All stroke matching tests pass
- [ ] DTW implementation is correct and handles edge cases
- [ ] PointResampler produces evenly-spaced points
- [ ] StrokeMatcher correctly classifies: correct, wrongDirection, wrongShape, tooShort, wrongPosition
- [ ] No UI code in this prompt — pure domain logic
- [ ] `flutter test` passes with 0 failures
