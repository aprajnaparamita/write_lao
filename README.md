# Write Lao

Learn to write the Lao alphabet through guided stroke-by-stroke practice, and build your vocabulary with an intelligent flashcard system.

<p align="center">
  <img src="assets/icon/app_icon.png" width="128" alt="Write Lao Icon">
</p>

## Download

Prebuilt apps live on the [GitHub Releases page](https://github.com/aprajnaparamita/write_lao/releases).
The links below are for **v1.0.6**. Each file name carries the platform and version. For older or newer versions, see the Releases page.

| Platform | Download | How to install |
|---|---|---|
| macOS | [write_lao-macos-1.0.6.dmg](https://github.com/aprajnaparamita/write_lao/releases/download/v1.0.6/write_lao-macos-1.0.6.dmg) | Open the .dmg, drag Write Lao into Applications. First launch: right-click the app, choose Open (the build is unsigned, so macOS blocks a plain double-click). |
| Windows | [write_lao-windows-setup-1.0.6.exe](https://github.com/aprajnaparamita/write_lao/releases/download/v1.0.6/write_lao-windows-setup-1.0.6.exe) | Run the installer. If SmartScreen warns: More info → Run anyway (the build is unsigned). |
| Windows (portable) | [write_lao-windows-1.0.6.zip](https://github.com/aprajnaparamita/write_lao/releases/download/v1.0.6/write_lao-windows-1.0.6.zip) | Unzip anywhere, run `write_lao.exe`. No install needed. |
| Linux | [write_lao-linux-1.0.6.tar.gz](https://github.com/aprajnaparamita/write_lao/releases/download/v1.0.6/write_lao-linux-1.0.6.tar.gz) | `tar xzf write_lao-linux-1.0.6.tar.gz` then run `./write_lao`. |
| Android | [write_lao-android-1.0.6.apk](https://github.com/aprajnaparamita/write_lao/releases/download/v1.0.6/write_lao-android-1.0.6.apk) | Sideload: open the APK and allow "install unknown apps" for your browser or file manager. With adb: `adb install write_lao-android-1.0.6.apk`. |

**What you get in these downloads.** These are the open-source builds: the
full 500-word vocabulary is unlocked, no purchase required. The App Store and
Play Store versions are the same app with the vocabulary sold as a one-time
in-app purchase. Buying there supports development.

Don't see your platform, or want to build from source? See
[Build a Release](#build-a-release-for-any-platform) below.

## Features

### Writing Practice
- **Lao characters** organized by lesson (consonants, vowels, tone marks, numerals, ligatures)
- **Stroke-by-stroke guided practice** with ghost stroke hints
- **Timed test mode** with star ratings (1-3 stars)
- **Custom review mode** - select specific characters to practice
- **Progress tracking** with Hive local storage
- **Offline support** - no internet required
- **Beautiful design** - deep indigo/purple theme with Noto Sans Lao font

### Vocabulary Learning
- **Unit-based vocabulary lessons** with progressive difficulty
- **SM-2 spaced repetition algorithm** for optimal retention
- **Hear-and-identify** listening comprehension practice
- **Custom flagged decks** for personalized study
- **In-app purchases** for unlocking additional vocabulary units

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

# Run the app (store variant: vocabulary behind IAP)
flutter run

# Run the open-source variant (full vocabulary unlocked)
flutter run --dart-define=APP_VARIANT=open
```

The `APP_VARIANT` flag is the only difference between the two products:
`open` unlocks the full vocabulary, `store` keeps it behind the in-app
purchase. It defaults to `store`, so a build without the flag never gives
paid content away.

### Run Tests

```bash
# Unit and widget tests
flutter test

# Integration tests
flutter test integration_test/
```

### Build a Release for Any Platform

One agent prompt builds a store-ready artifact on whatever machine you run
it on: [`prompts/BUILD_PLATFORM_RELEASE.md`](prompts/BUILD_PLATFORM_RELEASE.md).
It runs the tests, builds the right variant, and drops the artifact into
`outputs/` under its stable release name.

```
Run prompts/BUILD_PLATFORM_RELEASE.md for windows
Run prompts/BUILD_PLATFORM_RELEASE.md for macos
Run prompts/BUILD_PLATFORM_RELEASE.md for android
Run prompts/BUILD_PLATFORM_RELEASE.md for linux and publish
```

Example flow: push your changes on the Mac, then run the prompt on a
Windows box to get `outputs/write_lao-windows-setup-<version>.exe`, on a Linux
box for the `.tar.gz`, and so on. Add `publish` to the request and the
agent attaches the artifact to the matching GitHub release (needs `gh`
installed and authenticated) — that is what feeds the download links above.

Same builds by hand:

```bash
make dmg        # macOS  -> outputs/write_lao-macos-<version>.dmg
make apk        # Android open-source APK -> outputs/write_lao-android-<version>.apk
make aab        # Android Play Store bundle -> outputs/write_lao-android-play-<version>.aab
```

## Project Structure

```
lib/
├── main.dart                    # App entry point with Hive initialization
├── app.dart                     # App widget with routing and localization
├── config/
│   ├── theme.dart               # Deep indigo theme configuration
│   ├── routes.dart             # go_router navigation
│   ├── secrets.dart            # API keys and DSNs
│   └── sentry.dart             # Crash reporting setup
├── l10n/                        # Localization (20+ languages)
│   └── app_localizations_*.dart
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
│   ├── lao_characters.dart      # Character data
│   ├── lesson_definitions.dart  # Lesson definitions
│   └── repositories/
│       ├── character_repository.dart
│       └── progress_repository.dart
├── domain/
│   ├── stroke_matching/         # Core stroke matching algorithm
│   │   ├── stroke_matcher.dart  # Main matching logic with DTW
│   │   ├── path_utils.dart     # Geometric utilities
│   │   ├── point_resampler.dart
│   │   ├── dtw.dart            # Dynamic Time Warping
│   │   └── matching_result.dart # Match result model
│   └── services/
│       └── quiz_service.dart    # Star calculation
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── lesson_list_screen.dart
│   │   ├── lesson_detail_screen.dart
│   │   ├── practice_screen.dart
│   │   ├── practice_complete_screen.dart
│   │   ├── test_screen.dart
│   │   ├── test_result_screen.dart
│   │   ├── progress_screen.dart
│   │   ├── review_screen.dart
│   │   ├── settings_screen.dart
│   │   └── about_screen.dart
│   ├── widgets/
│   │   ├── writing_canvas.dart     # Main drawing canvas
│   │   ├── canvas_painter.dart     # Custom painter
│   │   ├── stroke_animator.dart   # Stroke animation
│   │   ├── star_rating.dart
│   │   ├── character_card.dart
│   │   ├── main_bottom_nav.dart  # Bottom navigation
│   │   └── result_screen_widgets.dart
│   └── controllers/
│       ├── canvas_controller.dart
│       ├── practice_controller.dart
│       └── test_controller.dart
├── vocab/                       # Vocabulary learning system
│   ├── providers.dart           # Riverpod providers
│   ├── audio/
│   │   └── vocab_audio_player.dart
│   ├── data/
│   │   ├── models/              # Freezed models
│   │   │   ├── course_content.dart
│   │   │   ├── vocab_lesson.dart
│   │   │   ├── vocab_unit.dart
│   │   │   ├── vocab_word.dart
│   │   │   └── vocab_user_state.dart
│   │   ├── datasources/
│   │   │   ├── course_content_datasource.dart
│   │   │   └── vocab_hive_adapters.dart
│   │   └── repositories/
│   │       ├── course_repository.dart
│   │       ├── vocab_preferences_repository.dart
│   │       └── vocab_user_state_repository.dart
│   ├── domain/
│   │   ├── lesson_engine.dart   # Lesson orchestration with SRS
│   │   ├── srs.dart            # SM-2 spaced repetition
│   │   ├── deck_study_planner.dart
│   │   ├── hear_identify_planner.dart
│   │   ├── iap_service.dart    # In-app purchase interface
│   │   └── platform_iap_service.dart # StoreKit/Play implementation
│   └── presentation/
│       ├── screens/
│       │   ├── unit_list_screen.dart
│       │   ├── lesson_list_screen.dart
│       │   ├── vocab_lesson_practice_screen.dart
│       │   ├── upsell_screen.dart
│       │   ├── restore_purchases_screen.dart
│       │   └── my_decks_screen.dart
│       └── widgets/
│           ├── word_card_base.dart
│           ├── character_practice_card.dart
│           ├── character_test_card.dart
│           ├── hear_identify_card.dart
│           └── word_practice_flow.dart
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
- **Crash Reporting:** Sentry
- **Typography:** Inter (UI), Noto Sans Lao (Lao script)

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter 3.22+ | UI Framework |
| Riverpod | State Management |
| Hive | Local Storage |
| go_router | Navigation |
| Freezed | Immutable Models |
| Sentry | Crash Reporting |
| google_fonts | Noto Sans Lao Typography |
| StoreKit / in_app_purchase | In-App Purchases |

## Localization

The app supports 20+ languages:

- English, French, Spanish, German, Portuguese
- Lao, Thai, Khmer, Vietnamese
- Japanese, Korean, Chinese (Simplified/Traditional)
- Hindi, Urdu, Nepali, Tagalog

## License

Proprietary - All rights reserved

## Contributing

This is a learning project for Lao script handwriting recognition and vocabulary building. Contributions for stroke data authoring are welcome!
