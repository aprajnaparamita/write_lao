# Prompt 04 — Writing Canvas & Touch Input

## Context

You are building "Write Lao". Data models, stroke matching engine, and stroke data pipeline are complete (Prompts 01–03). Read `00_OVERVIEW.md` for architecture. This prompt builds the core drawing canvas widget.

## Goal

Create the `WritingCanvas` widget — a touch/mouse-enabled drawing surface that captures user strokes and renders reference characters, ghost strokes, and user ink. This is the most important UI component.

## Tasks

### 1. Canvas Controller (`lib/presentation/controllers/canvas_controller.dart`)

A Riverpod controller that manages canvas state. This separates logic from rendering.

```dart
@riverpod
class CanvasController extends _$CanvasController {
  // State:
  // - currentStrokeIndex: which stroke the user should draw next
  // - drawnStrokes: list of completed user strokes (point lists)
  // - activeStroke: the stroke currently being drawn (null if not drawing)
  // - referenceStrokes: the CharacterStrokeData for the current character
  // - mode: practice (with guides) or test (without guides)
  // - showHint: whether to show the ghost of the next stroke
  // - lastResult: the StrokeEvaluation from the last completed stroke

  void startStroke(Point<double> point);
  void addPoint(Point<double> point);
  StrokeEvaluation? endStroke();  // evaluates and returns result
  void clearCurrentStroke();
  void clearAll();
  void toggleHint();
  void setCharacter(CharacterStrokeData data);
  void setMode(CanvasMode mode);  // practice or test
  bool get isComplete;  // all strokes drawn correctly
}

enum CanvasMode { practice, test }
```

### 2. Writing Canvas Widget (`lib/presentation/widgets/writing_canvas.dart`)

```dart
class WritingCanvas extends ConsumerStatefulWidget {
  final double size;               // canvas size in logical pixels
  final CharacterStrokeData? strokeData;
  final CanvasMode mode;
  final VoidCallback? onStrokeComplete;
  final ValueChanged<StrokeEvaluation>? onStrokeEvaluated;
  final VoidCallback? onCharacterComplete;

  // ...
}
```

**Rendering layers (bottom to top):**

1. **Background:** White fill, light gray crosshair guides at center, dashed border inset box
2. **Reference character:** The full Lao character rendered as a semi-transparent glyph (use Noto Lao font, opacity 0.15, blue tint). This shows what the target character looks like.
3. **Completed strokes:** Previously drawn correct strokes, rendered in dark ink color
4. **Ghost stroke (practice mode only):** The next expected stroke shown as a light gray/blue dashed path. Only visible if `showHint` is true or in practice mode.
5. **Active stroke:** The stroke currently being drawn, rendered in real-time as the user moves their finger
6. **Stroke start indicator (practice mode):** A small circle at the starting point of the next expected stroke, showing the user where to begin

**Touch handling:**

- Use `GestureDetector` with `onPanStart`, `onPanUpdate`, `onPanEnd`
- On desktop, also handle mouse input (same GestureDetector works)
- Collect points during pan, throttle to ~60fps max (skip points if too close together, < 2px)
- On `onPanEnd`, evaluate the stroke against the expected reference
- If correct: add to completed strokes, advance to next stroke index
- If incorrect: show brief error feedback (red flash), clear the active stroke, let user retry

**Canvas sizing:**

- The reference stroke data is in a 512×512 coordinate system
- Scale all reference data to match the actual widget size
- Store drawn points in the widget's coordinate system, scale to 512 before matching

### 3. Custom Painter (`lib/presentation/widgets/canvas_painter.dart`)

Use `CustomPainter` for efficient rendering:

```dart
class CanvasPainter extends CustomPainter {
  final double canvasSize;
  final List<List<Point<double>>> completedStrokes;
  final List<Point<double>>? activeStroke;
  final StrokeData? ghostStroke;
  final Point<double>? startIndicator;
  final bool showGuides;
  final String? referenceChar;

  @override
  void paint(Canvas canvas, Size size);

  @override
  bool shouldRepaint(CanvasPainter old);
}
```

**Paint styles:**
- Completed strokes: `stroke-width: 8px` (at 512 scale), black (#333333), round caps and joins
- Active stroke: same as completed but slightly different color (#555555 or blue)
- Ghost stroke: `stroke-width: 10px`, light blue (#B0D4F1), dashed pattern
- Start indicator: filled circle, radius 12px, green (#4CAF50), with a subtle pulse animation
- Reference character: rendered via `TextPainter` with Noto Lao font
- Background guides: 1px light gray lines

### 4. Stroke Animation (`lib/presentation/widgets/stroke_animator.dart`)

Animate a reference stroke being drawn, for the "show me how" feature:

```dart
class StrokeAnimator extends StatefulWidget {
  final CharacterStrokeData strokeData;
  final Duration strokeDuration;  // time to animate one stroke
  final Duration pauseBetween;    // pause between strokes
  final bool loop;
  final VoidCallback? onComplete;
}
```

Uses `AnimationController` to progressively reveal each stroke's path over time. Each stroke animates in sequence. The animation should feel like someone smoothly writing the character.

**Implementation:** Compute path metrics from the stroke points. Use `PathMetric.extractPath()` to draw a progressively longer portion of each path on each animation frame.

### 5. Feedback Animations

Brief visual feedback when a stroke is evaluated:

- **Correct stroke:** The drawn stroke briefly flashes green, then fades to the standard completed color. A subtle checkmark or sparkle animation plays (keep it simple — a green overlay that fades).
- **Wrong stroke:** The drawn stroke flashes red and fades out (disappears). A brief shake animation on the canvas.
- **Wrong direction:** Show a brief arrow animation indicating the correct direction.

### 6. Responsive Sizing

The canvas must work on different screen sizes:

```dart
class CanvasContainer extends StatelessWidget {
  // Computes the largest square that fits in the available space
  // with padding. On mobile, typically fills width minus padding.
  // On desktop/tablet, caps at a reasonable max size (e.g., 500px).
}
```

### 7. Write Tests

#### `test/presentation/controllers/canvas_controller_test.dart`
- Initial state: no strokes, currentStrokeIndex = 0
- `startStroke` + `addPoint` + `endStroke` with correct stroke → advances to next stroke
- `endStroke` with wrong stroke → does not advance, returns wrongShape result
- `clearAll` → resets everything
- `isComplete` → true when all strokes drawn correctly
- `toggleHint` → toggles showHint
- Setting a new character resets all state

#### `test/presentation/widgets/writing_canvas_test.dart` (widget tests)
- Canvas renders at the correct size
- Canvas shows reference character text
- Canvas shows guide lines
- Simulated pan gesture creates visible stroke
- Canvas shows ghost stroke in practice mode
- Canvas does NOT show ghost stroke in test mode
- `onCharacterComplete` callback fires when last stroke is correct

#### `test/presentation/widgets/stroke_animator_test.dart`
- Animation completes within expected duration
- `onComplete` callback fires after all strokes animate
- Looping animation restarts after completion

## Design Notes

- **The canvas MUST feel responsive.** There should be zero perceptible lag between finger movement and ink appearing. Use `RepaintBoundary` to isolate canvas repaints from the rest of the widget tree.
- **Stroke smoothing:** Apply minimal Catmull-Rom or Bezier smoothing to the drawn stroke for display purposes. But evaluate the raw resampled points, not the smoothed ones.
- **The canvas painter should use `shouldRepaint` efficiently** — only repaint when stroke data actually changes.

## Acceptance Criteria

- [ ] WritingCanvas renders with all visual layers
- [ ] Touch/mouse input captures strokes in real time
- [ ] Strokes are evaluated on pan end using the StrokeMatcher from Prompt 02
- [ ] Correct strokes advance to next stroke, incorrect strokes allow retry
- [ ] Practice mode shows ghost strokes and start indicators
- [ ] Test mode hides all guides
- [ ] StrokeAnimator plays smooth writing animation
- [ ] Canvas scales correctly on different screen sizes
- [ ] All controller unit tests pass
- [ ] All widget tests pass
