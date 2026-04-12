# Write Lao

Learn to write the Lao alphabet through guided stroke-by-stroke practice.

<p align="center">
  <img src="assets/icon/app_icon.png" width="128" alt="Write Lao Icon">
</p>

## Features

- **58 Lao characters** organized by phase (consonants, vowels, tone marks, numerals, ligatures)
- **Stroke-by-stroke guided practice** with ghost stroke hints
- **Timed test mode** with star ratings (1-3 stars)
- **Custom review mode** - select specific characters to practice
- **Progress tracking** with Hive local storage
- **Offline support** - no internet required
- **Beautiful design** - blue/white theme with Noto Lao font

## Getting Started

### Prerequisites

- Flutter 3.22+
- Dart 3.4+

### Build & Run

```bash
# Clone and navigate to project
cd write_lao

# Install dependencies
flutter pub get

# Generate code (Freezed models, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Run Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test/
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App widget with routing
├── config/
│   ├── theme.dart               # Blue/white theme configuration
│   └── routes.dart             # go_router navigation
├── data/
│   ├── models/                  # Freezed data models
│   │   ├── lao_character.dart   # Lao character data
│   │   ├── lesson.dart          # Lesson definitions
│   │   ├── stroke_data.dart     # Stroke paths
│   │   ├── user_progress.dart  # Progress tracking
│   │   └── quiz_result.dart     # Test results
│   ├── datasources/             # Data loading
│   │   ├── character_stroke_datasource.dart
│   │   ├── progress_local_datasource.dart
│   │   └── progress_hive_adapters.dart
│   └── repositories/
│       ├── character_repository.dart
│       └── progress_repository.dart
├── domain/
│   ├── stroke_matching/         # Core stroke matching algorithm
│   │   ├── stroke_matcher.dart  # Main matching logic
│   │   ├── path_utils.dart     # Geometric utilities
│   │   ├── point_resampler.dart
│   │   └── dtw.dart            # Dynamic Time Warping
│   └── services/
│       └── quiz_service.dart    # Star calculation
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── lesson_list_screen.dart
│   │   ├── lesson_detail_screen.dart
│   │   ├── practice_screen.dart
│   │   ├── test_screen.dart
│   │   ├── test_result_screen.dart
│   │   ├── progress_screen.dart
│   │   ├── review_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── writing_canvas.dart     # Main drawing canvas
│   │   ├── canvas_painter.dart     # Custom painter
│   │   ├── stroke_animator.dart   # Stroke animation
│   │   ├── star_rating.dart
│   │   └── character_card.dart
│   └── controllers/
│       ├── canvas_controller.dart
│       ├── practice_controller.dart
│       └── test_controller.dart
├── audio/
│   ├── audio_player_service.dart
│   └── haptic_service.dart
└── utils/
    └── svg_parser.dart             # SVG to JSON converter

assets/
├── stroke_data/                  # Stroke JSON files
│   └── U+0E81.json              # One file per character
├── audio/
│   ├── sfx/                     # Sound effects
│   └── pronunciation/           # Character audio
└── icon/
    └── app_icon.png             # App icon (1024x1024)
```

## Character Data

Each Lao character has stroke data in `assets/stroke_data/`:

```json
{
  "codepoint": "U+0E81",
  "char": "ກ",
  "name": "ko",
  "strokeCount": 2,
  "strokes": [
    {
      "index": 0,
      "points": [[185, 160], [183, 155], ...],
      "startAngle": 270,
      "direction": "clockwise"
    }
  ]
}
```

### Adding New Characters

See [docs/STROKE_AUTHORING.md](docs/STROKE_AUTHORING.md) for the complete guide.

## Architecture

- **State Management:** Riverpod
- **Local Storage:** Hive
- **Navigation:** go_router
- **Data Models:** Freezed (immutable classes)

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter 3.22+ | UI Framework |
| Riverpod | State Management |
| Hive | Local Storage |
| go_router | Navigation |
| Freezed | Immutable Models |
| google_fonts | Noto Lao Typography |

## License

Proprietary - All rights reserved

## Contributing

This is a learning project for Lao script handwriting recognition. Contributions for stroke data authoring are welcome!
