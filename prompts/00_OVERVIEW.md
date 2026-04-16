# Write Lao — Project Overview & Architecture

## What This Is

A mobile-first Flutter app that teaches users to write Lao script by hand. Users trace characters on a touch canvas and receive real-time feedback on stroke accuracy, order, and direction. The app is modeled after "Write It! Thai" by Jernung but covers the Lao alphabet.

## Target Platforms

- **Primary:** iOS and Android (mobile-first, touch input)
- **Secondary:** macOS, Windows, Linux desktop (mouse/stylus input)
- Web is NOT a target — Flutter web canvas performance is insufficient for smooth drawing.

## Core Feature Set

1. **Lesson system** — Characters grouped into lessons by phase (consonants, vowels, tone marks, numerals, ligatures). Each lesson contains 3–5 characters.
2. **Practice mode** — Stroke-by-stroke guided tracing. Shows a ghost stroke, user traces over it, app validates before revealing the next stroke. Includes: audio pronunciation, stroke animation playback, erase/retry, hint (eye icon shows the next stroke).
3. **Test mode** — Timed character writing without stroke guides. User must write the character from memory. Scored by accuracy and speed. Stars awarded (1–3) based on performance.
4. **Review mode** — Custom review of previously learned characters. User selects which characters/lessons to review.
5. **Progress tracking** — Lessons completed, stars earned, best times, per-character accuracy history.

## Architecture

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── theme.dart
│   ├── routes.dart
│   └── constants.dart
├── data/
│   ├── models/
│   │   ├── lao_character.dart          # Character metadata
│   │   ├── stroke_data.dart            # Stroke paths for a character
│   │   ├── lesson.dart                 # Lesson grouping
│   │   ├── user_progress.dart          # Per-character progress
│   │   └── quiz_result.dart            # Test mode results
│   ├── repositories/
│   │   ├── character_repository.dart   # Loads character/stroke data
│   │   ├── progress_repository.dart    # Reads/writes user progress
│   │   └── audio_repository.dart       # Audio file access
│   ├── datasources/
│   │   ├── character_json_datasource.dart
│   │   └── progress_local_datasource.dart
│   └── lao_characters.dart             # Static character database
├── domain/
│   ├── stroke_matching/
│   │   ├── stroke_matcher.dart         # Core matching algorithm
│   │   ├── stroke_evaluator.dart       # Scores a completed stroke
│   │   ├── point_resampler.dart        # Resample raw touch to N points
│   │   ├── path_utils.dart             # Bezier sampling, distance calcs
│   │   └── matching_result.dart        # Result enum + details
│   └── services/
│       ├── lesson_service.dart
│       ├── quiz_service.dart
│       └── progress_service.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── lesson_list_screen.dart
│   │   ├── lesson_detail_screen.dart
│   │   ├── practice_screen.dart
│   │   ├── test_screen.dart
│   │   ├── review_screen.dart
│   │   ├── progress_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── writing_canvas.dart         # Core drawing surface
│   │   ├── stroke_animator.dart        # Animates reference strokes
│   │   ├── character_card.dart         # Lesson grid card
│   │   ├── star_rating.dart
│   │   ├── timer_display.dart
│   │   └── progress_bar.dart
│   └── controllers/
│       ├── practice_controller.dart
│       ├── test_controller.dart
│       └── canvas_controller.dart
├── audio/
│   └── audio_player_service.dart
└── utils/
    ├── svg_parser.dart                 # Parse stroke SVGs → stroke data
    └── extensions.dart
```

## State Management

Use **Riverpod** (riverpod + flutter_riverpod). No BLoC, no Provider (legacy). Riverpod gives testability, compile-time safety, and doesn't require BuildContext for access.

## Local Storage

**Hive** for user progress data. It's fast, pure Dart, no native dependencies, works on all platforms. No server/backend — everything is local.

## Character & Stroke Data Format

Stroke data is stored as JSON, bundled as an asset. Each character has this structure:

```json
{
  "codepoint": "U+0E81",
  "char": "ກ",
  "name": "ko",
  "romanization": "k",
  "phase": 1,
  "order": 1,
  "notes": "mid class",
  "audio": "audio/ko.mp3",
  "strokeCount": 2,
  "strokes": [
    {
      "index": 0,
      "points": [
        [185, 160], [183, 155], [178, 148], ...
      ],
      "startAngle": 270,
      "direction": "clockwise"
    },
    {
      "index": 1,
      "points": [
        [230, 95], [232, 130], [235, 180], ...
      ],
      "startAngle": 180,
      "direction": "down"
    }
  ],
  "viewBox": [0, 0, 512, 512]
}
```

**Critical:** The points array for each stroke is a resampled center-line path with ~30–60 evenly-spaced points. NOT raw Bezier control points. NOT freehand trace data. These must be carefully hand-authored or extracted from clean SVG paths.

## Stroke Matching Algorithm

The app does NOT use ML/CNN for recognition. It uses geometric path matching, which is appropriate because:
- We know exactly which character the user is supposed to draw (it's not open-ended recognition)
- We know the expected stroke order
- We only need to validate similarity, not identify from a universe of characters

**Algorithm (per stroke):**

1. Capture raw touch points as the user draws
2. Resample to N evenly-spaced points (N = number of points in reference stroke)
3. Compare using a modified Hausdorff distance or DTW (Dynamic Time Warping):
   - Compute average point-to-point distance after alignment
   - Check stroke direction (start point near reference start point)
   - Check stroke doesn't deviate beyond a tolerance corridor (~40px at 512px canvas)
4. Return: correct / incorrect / close-but-wrong-direction

**Tolerance:** Be forgiving. The Write It! Thai review says "it's not too picky about thumb drawing being exactly correct but if it has the right directional movement they'll give it to you." Aim for ~85% similarity threshold on normalized distance.

## Lessons Structure

| Phase | Content | # Lessons |
|-------|---------|-----------|
| 1 | 27 Basic Consonants | 9 (3 chars each) |
| 2 | 15 Vowel Components | 5 (3 chars each) |
| 3 | 4 Tone Marks | 2 (2 chars each) |
| 4 | 10 Numerals | 4 (2-3 chars each) |
| 5 | 2 Ligatures | 1 (2 chars) |
| **Total** | **58 characters** | **21 lessons** |

## Audio

Each character needs a recorded pronunciation audio file (MP3/OGG). For MVP, use TTS or leave audio as a stub that can be filled in later. The UI should show a speaker icon but gracefully handle missing audio.

## Design Language

- Deep indigo (#2B0071) / white color scheme rooted in Lao culture
- Clean, minimal UI — focus on the writing canvas
- Large touch targets for mobile
- Noto Lao font for all Lao text display
- Canvas area: square, centered, with faint crosshair guides and dashed border (matching the SVG template design)

## Development Approach

- **Test-Driven Development (TDD)** — Write tests first for all domain logic (stroke matching, scoring, progress tracking). Widget tests for key screens. Integration tests for critical flows.
- **Prompt files are numbered 01–09** and should be executed in order.
- Each prompt is self-contained and produces a working, testable increment.

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0
  audioplayers: ^6.0.0
  flutter_svg: ^2.0.0
  google_fonts: ^6.0.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  freezed: ^2.5.0
  json_serializable: ^6.7.0
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.0
  mocktail: ^1.0.0
  golden_toolkit: ^0.15.0
```
