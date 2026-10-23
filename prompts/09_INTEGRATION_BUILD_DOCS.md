# Prompt 09 — Integration Tests, Build Configuration & Stroke Authoring Guide

## Context

You are building "Write Lao". The app is feature-complete and polished (Prompts 01–08). Read `00_OVERVIEW.md` for architecture. This is the final prompt — integration tests, platform builds, and documentation for ongoing stroke data authoring.

## Goal

Write integration tests for critical user flows, configure platform-specific build settings, and create documentation for authoring stroke data for the remaining 57 characters.

## Tasks

### 1. Integration Tests

Create integration tests in `integration_test/` for the critical user flows:

#### `integration_test/full_lesson_flow_test.dart`
Test the complete flow: Launch → Select lesson → Practice all characters → Take test → View results

1. App launches and shows lesson list
2. Tap first lesson (Consonants 1)
3. Lesson detail shows with Practice and Test buttons
4. Tap Practice
5. Practice screen shows first character with canvas
6. Simulate drawing correct strokes (inject touch events matching reference data)
7. Character completes, advances to next
8. Complete all characters in lesson
9. Navigate back to lesson detail
10. Tap Test
11. Draw all characters correctly in test mode
12. Results screen shows with ≥1 star
13. Navigate back to lesson list
14. Lesson card now shows stars

#### `integration_test/stroke_matching_integration_test.dart`
Test stroke matching with realistic input:

1. Load stroke data for ກ
2. Simulate a correct stroke drawing → evaluate as correct
3. Simulate a reversed stroke → evaluate as wrongDirection
4. Simulate a random scribble → evaluate as wrongShape
5. Simulate a very short tap → evaluate as tooShort

#### `integration_test/progress_persistence_test.dart`
1. Complete a lesson with 3 stars
2. Kill and restart the app (close and reopen Hive boxes)
3. Verify progress is preserved (stars, best time)
4. Reset progress in settings
5. Verify progress is cleared

#### `integration_test/review_mode_test.dart`
1. Select specific characters for review
2. Practice the selected characters
3. Verify practice count increments

### 2. Platform Build Configuration

#### iOS (`ios/`)
- Set minimum deployment target: iOS 14.0
- Set bundle identifier: `com.maitrigroup.app`
- Set display name: "Write Lao"
- Configure app icon (use a placeholder or generated icon)
- Add Noto Lao font to iOS bundle if needed for offline use

#### Android (`android/`)
- Set `minSdkVersion`: 24
- Set `applicationId`: `com.maitrigroup.app`
- Set app name: "Write Lao"
- Configure signing (release keystore setup instructions in README)
- ProGuard rules for Hive if needed

#### macOS (`macos/`)
- Set minimum deployment target: macOS 12.0
- Set bundle identifier
- Enable full disk access for Hive storage path

#### Linux/Windows
- Basic desktop support should work out of the box
- Document any platform-specific issues

### 3. App Icon Generation

Create a simple app icon:
- Blue background (#4A7BCC)
- White Lao letter ກ centered
- Use `flutter_launcher_icons` package to generate all platform sizes:

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0

flutter_launcher_icons:
  android: true
  ios: true
  macos: true
  image_path: "assets/icon/app_icon.png"
```

Create the source icon image at 1024×1024px.

### 4. Stroke Authoring Guide (`docs/STROKE_AUTHORING.md`)

Write comprehensive documentation for creating stroke data for the remaining characters:

````markdown
# Stroke Authoring Guide

## Overview

Each Lao character needs hand-authored stroke data defining the center-line path
of each stroke in the correct writing order. This guide explains the full workflow.

## Prerequisites

- Inkscape 1.0+ (free, cross-platform SVG editor)
- Noto Lao font installed (for reference glyph rendering)
- Ruby (to run the SVG template generator)
- Dart SDK (to run the SVG-to-JSON converter)

## Step 1: Generate SVG Templates

```bash
ruby make_svgs.rb ./lao_svgs
```

This creates one SVG per character with a faint reference glyph and an empty strokes layer.

## Step 2: Draw Strokes in Inkscape

1. Open the SVG in Inkscape
2. In the Layers panel, LOCK the `reference` layer (so you don't accidentally move it)
3. Select the `strokes` layer as active
4. Use the Pencil tool (P) or Bezier tool (B) to draw each stroke:
   - Draw ONE path per stroke
   - Draw strokes IN WRITING ORDER (stroke 1 first, then stroke 2, etc.)
   - Draw each stroke in the correct DIRECTION (start where the pen starts)
   - Use a thin stroke (8px width, no fill) — the template has defaults set
   - Keep paths smooth — use as few nodes as possible
   - Stay within the dashed guide box (32px inset from edges)

### What Makes a Good Stroke Path

- **Clean curves:** Use smooth Bezier curves, not dozens of tiny straight segments
- **Center-line:** The path should follow the CENTER of the stroke, not the edge
- **Correct direction:** Start the path where the pen/finger starts writing
- **Minimal nodes:** 4-8 nodes per stroke is usually enough. Fewer = better.
- **No overlap:** Each stroke should be a separate, non-overlapping path

### Common Mistakes

- Drawing one continuous path for the whole character (should be separate strokes)
- Drawing with the freehand pencil tool (creates too many nodes — use Bezier tool)
- Starting the stroke from the wrong end
- Leaving the path outside the `strokes` layer

## Step 3: Add Stroke Metadata

For each path in the strokes layer, add a `data-stroke-index` attribute:
- Select the path
- XML editor (Edit > XML Editor)
- Add attribute: `data-stroke-index` = `1` (or 2, 3, etc.)

Also update `data-stroke-count` on the root `<svg>` element.

## Step 4: Convert to JSON

```bash
dart run tool/svg_to_json.dart ./lao_svgs/01_01_ko_U0E81.svg -o assets/stroke_data/
```

Or batch convert:
```bash
dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/ --verbose
```

## Step 5: Test in the App

1. Copy the JSON file to `assets/stroke_data/`
2. Run the app
3. Navigate to the character's lesson
4. Practice the character
5. Verify:
   - Ghost stroke looks correct
   - Start indicator is at the right position
   - Stroke animation draws in the right direction
   - A reasonably drawn stroke is accepted
   - A sloppy but directionally correct stroke is accepted
   - A reversed stroke is rejected
   - A completely wrong stroke is rejected

## Step 6: Tune if Needed

If the matching is too strict or too lenient for a specific character:
- Adjust the number of resample points (more = stricter)
- Adjust the similarity threshold in settings
- Re-draw the reference stroke if it's not representative

## Stroke Order Reference

For correct Lao stroke orders, consult:
- Lao primary school handwriting textbooks (ປຶ້ມຫັດຂຽນ)
- The Unicode chart annotations
- Native Lao writers

General Lao stroke order rules:
1. Top to bottom
2. Left to right
3. Loops/circles are drawn first, typically clockwise
4. Horizontal strokes before vertical strokes that cross them
5. Enclosing strokes before enclosed content (similar to Chinese/Thai)

## File Naming Convention

SVG files: `{phase}_{order}_{name}_{codepoint}.svg`
JSON files: `{codepoint}.json` (e.g., `U+0E81.json`)

## Quality Checklist

For each character, verify:
- [ ] Correct number of strokes
- [ ] Correct stroke order
- [ ] Correct stroke direction
- [ ] Clean, smooth paths (not noisy freehand)
- [ ] Paths are in the `strokes` layer
- [ ] `data-stroke-index` attributes are set
- [ ] JSON converts without errors
- [ ] Matching works in the app
````

### 5. Project README (`README.md`)

Create a comprehensive project README:

```markdown
# Write Lao

Learn to write the Lao alphabet through guided stroke-by-stroke practice.

## Features
- 58 Lao characters (consonants, vowels, tone marks, numerals)
- Stroke-by-stroke guided practice
- Timed test mode with star ratings
- Custom review mode
- Progress tracking
- Offline support

## Getting Started

### Prerequisites
- Flutter 3.22+ 
- Dart 3.4+

### Build & Run
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run

### Run Tests
flutter test                          # Unit & widget tests
flutter test integration_test/        # Integration tests

## Adding Stroke Data
See docs/STROKE_AUTHORING.md for the complete guide to authoring stroke data
for new characters.

## Architecture
See prompts/00_OVERVIEW.md for detailed architecture documentation.

## License
[Choose license]
```

### 6. CI/CD Setup (Optional but Recommended)

Create a GitHub Actions workflow (`.github/workflows/ci.yml`):

```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test
```

### 7. Write Final Tests

#### Smoke test (`test/app_smoke_test.dart`)
- App widget can be instantiated
- App shows lesson list on launch
- No exceptions on startup

#### Coverage check
- Run `flutter test --coverage`
- Aim for >80% coverage on `lib/domain/` (stroke matching, services)
- Aim for >60% coverage overall
- Document any intentionally uncovered code

## Acceptance Criteria

- [ ] Integration tests for full lesson flow pass
- [ ] Integration tests for progress persistence pass
- [ ] Platform build configurations are correct for iOS, Android, macOS
- [ ] App icon is generated for all platforms
- [ ] Stroke authoring guide is complete and accurate
- [ ] README documents build, run, and test procedures
- [ ] CI workflow runs tests on push
- [ ] Test coverage meets targets
- [ ] App builds without warnings on all target platforms
