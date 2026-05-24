# Write Lao — Setup & Build Guide

Complete these steps to set up the stroke authoring pipeline, build the app, and deploy to devices.

---

## 1. Prerequisites

### 1.1 Flutter SDK

Install Flutter 3.9+ with the Dart SDK:

```bash
# Verify installation
flutter --version
# Expected: Flutter 3.9.x, Dart 3.9.x

flutter doctor
# All checks should pass for your target platforms
```

### 1.2 Inkscape

Install [Inkscape](https://inkscape.org/) 1.4+ for authoring stroke SVGs:

```bash
# macOS (Homebrew)
brew install --cask inkscape

# Verify
inkscape --version
```

### 1.3 Platform Toolchains

| Platform | Requirement |
|----------|-------------|
| iOS | Xcode 15+, CocoaPods |
| Android | Android Studio, SDK 34+, NDK |
| macOS | Xcode 15+ |

---

## 2. Project Setup

### 2.1 Clone & Install Dependencies

```bash
git clone <repo-url> write_lao
cd write_lao
flutter pub get
```

### 2.2 Configure Secrets

The app reads sensitive keys (Sentry DSN, API keys) from a **gitignored** file
`lib/config/secrets.dart` that is generated from a `.env` file. **Never commit
either file.**

```bash
# Copy the template
cp .env.example .env

# Edit .env and fill in your values:
#   SENTRY_DSN=https://<key>@<org>.ingest.sentry.io/<project>

# Generate lib/config/secrets.dart
bash scripts/setup_secrets.sh
```

The script writes `lib/config/secrets.dart` which is listed in `.gitignore`.
If you skip this step the app still builds — Sentry simply won't report events
(the DSN defaults to an empty string, which disables the SDK).

> **What lives in `.env`**
>
> | Key | Purpose |
> |-----|---------|
> | `SENTRY_DSN` | Error-reporting endpoint (bundled in app, safe to expose) |
> | Other keys | Audio/AI APIs — extracted only on demand by server-side tooling, never bundled |

### 2.3 Run Code Generation

Freezed models and Hive adapters require build_runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2.4 Verify Tests Pass

```bash
flutter test
# Expected: 200+ tests pass, 0 failures
```

### 2.5 Verify Analyzer

```bash
flutter analyze
# Expected: 0 errors (some infos for tool/ prints are OK)
```

---

## 3. Stroke Authoring Pipeline

This is the core content pipeline. Each of the 58 Lao characters needs an SVG with stroke paths, which gets converted to JSON for the app.

### 3.1 SVG Template Structure

SVG templates live in `lao_svgs/` and are named by phase, order, and codepoint:

```
lao_svgs/
  01_01_ko_U0E81.svg       # Phase 1, Order 1: ກ
  01_02_kho_sung_U0E82.svg  # Phase 1, Order 2: ຂ
  02_01_sara_i_U0EB4.svg    # Phase 2, Order 1: ິ
  ...
```

Each SVG has metadata in `data-lao-*` attributes on the `<svg>` element:

```xml
<svg
  width="512" height="512" viewBox="0 0 512 512"
  data-lao-char="ກ"
  data-lao-codepoint="U+0E81"
  data-lao-name="ko"
  data-lao-romanization="k"
  data-lao-phase="1"
  data-lao-order="1"
  data-lao-notes="mid class">
```

### 3.2 Drawing Strokes in Inkscape

1. **Open the SVG template** in Inkscape
2. **Create a layer/group** named `strokes` (the converter looks for this group first)
3. **Draw each stroke as a separate `<path>`** using the Bezier/Pen tool
   - Draw strokes in the order they should be written
   - Each path = one stroke the user will trace
   - Use the 512x512 canvas area
4. **Do NOT include** background, reference images, or labels in the `strokes` group — put those in separate groups named `background`, `reference`, or `label` (these are excluded by the converter)

**Tips:**
- Keep strokes as simple paths (lines, cubic beziers)
- The converter supports M, L, H, V, C, S, Q, Z commands
- Paths shorter than 20px are filtered out by default
- Verify stroke order visually: the first `<path>` in the `strokes` group = stroke 1

### 3.3 Converting SVGs to JSON

The converter tool is at `tool/svg_to_json.dart`.

**Convert a single file:**
```bash
dart run tool/svg_to_json.dart lao_svgs/01_01_ko_U0E81.svg -o assets/stroke_data/U+0E81.json
```

**Convert all SVGs in a directory:**
```bash
dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/
```

**With verbose output (shows stroke details):**
```bash
dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/ --verbose
```

**Converter options:**

| Option | Default | Description |
|--------|---------|-------------|
| `--resample N` | 48 | Points per stroke after resampling |
| `--canvas-size N` | 512 | Reference canvas size |
| `--min-length N` | 20 | Minimum stroke length (px) to include |
| `--verbose` | off | Print per-stroke details |

### 3.4 Output JSON Format

Each converted file lands in `assets/stroke_data/` named by codepoint:

```json
{
  "codepoint": "U+0E81",
  "char": "ກ",
  "name": "ko",
  "romanization": "k",
  "phase": 1,
  "order": 1,
  "notes": "mid class, 2 strokes",
  "strokeCount": 2,
  "strokes": [
    {
      "index": 0,
      "points": [[180, 200], [175, 185], ...],
      "startAngle": 230.2,
      "direction": "clockwise"
    },
    {
      "index": 1,
      "points": [[210, 108], [215, 130], ...],
      "startAngle": 88.9,
      "direction": "down"
    }
  ],
  "viewBox": [0, 0, 512, 512]
}
```

### 3.5 Verifying Stroke Data

After conversion, verify in the app:

1. Run the app: `flutter run`
2. Navigate to the lesson containing the character
3. Enter Practice mode
4. Check that ghost strokes render correctly
5. Trace each stroke — confirm matching works
6. Check stroke order matches expected writing order

### 3.6 Authoring Status

58 SVG templates exist in `lao_svgs/`. Currently 3 have been converted to JSON:

| Phase | Characters | SVGs | JSONs |
|-------|-----------|------|-------|
| 1: Consonants | 27 | 27 | 3 (ກ, ຂ, ຄ) |
| 2: Vowels | 15 | 15 | 0 |
| 3: Tone marks | 4 | 4 | 0 |
| 4: Digits | 10 | 10 | 0 |
| 5: Special | 2 | 2 | 0 |

To convert all remaining:

```bash
dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/ --verbose
```

Then verify each character's stroke data in the app.

---

## 4. Audio Files (Optional)

Pronunciation audio files go in `assets/audio/pronunciation/`:

```
assets/audio/pronunciation/
  ko.mp3      # ກ
  kho.mp3     # ຂ
  ...
```

The app uses the `audioplayers` package. File names match the `romanization` field from the character database.

---

## 5. Building the App

### 5.1 iOS

```bash
# Install CocoaPods dependencies
cd ios && pod install && cd ..

# Debug build (simulator)
flutter run -d iPhone

# Release build
flutter build ios --release

# Open in Xcode for signing and archiving
open ios/Runner.xcworkspace
```

**Xcode configuration:**
- Set Bundle Identifier (e.g., `com.yourname.writelao`)
- Configure signing team
- Set deployment target to iOS 14.0+

### 5.2 Android

```bash
# Debug build
flutter run -d <device-id>

# Release APK
flutter build apk --release

# Release App Bundle (for Play Store)
flutter build appbundle --release
```

**Signing configuration:** Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore.jks>
```

### 5.3 macOS

```bash
# Debug build
flutter run -d macos

# Release build
flutter build macos --release
```

---

## 6. Error Tracking (Sentry)

### 6.1 Overview

Sentry is integrated via `sentry_flutter`. It is initialised in `lib/main.dart`
before the Flutter engine starts, giving it full coverage:

| What is captured | How |
|-----------------|-----|
| Unhandled exceptions | `SentryFlutter.init` zone wrapper |
| Flutter framework errors | `FlutterError.onError` (auto-wired) |
| Navigation breadcrumbs | `SentryNavigatorObserver` on GoRouter |
| Recoverable errors | `SentryHelper.captureException(e, stack)` in `catch` blocks |
| Notable non-error events | `SentryHelper.captureMessage(msg)` |

Events are **dropped entirely in debug mode** (`kDebugMode`) — check the
console instead. In release/profile mode, 20 % of sessions are traced for
performance (`tracesSampleRate: 0.2`).

### 6.2 First-Time Sentry Setup

1. Create a project at [sentry.io](https://sentry.io) → Platform: Flutter
2. Copy the DSN from *Project Settings → Client Keys*
3. Add to `.env`:
   ```
   SENTRY_DSN=https://<key>@<org>.ingest.sentry.io/<project>
   ```
4. Regenerate secrets: `bash scripts/setup_secrets.sh`
5. Do a **release build** (`flutter build ios --release` / `flutter build apk --release`)
6. Install on a device and force a test error (or just run the app)
7. Confirm events appear in the Sentry dashboard under the `production` environment

### 6.3 Using `SentryHelper` in Code

```dart
import 'package:write_it_lao/config/sentry.dart';

// In a catch block — non-fatal, recoverable error
try {
  await riskyOperation();
} catch (e, stack) {
  SentryHelper.captureException(e, stack,
    hint: 'riskyOperation failed',
    context: {'lessonId': lessonId},
  );
}

// For notable state (e.g. unexpected IAP flow)
SentryHelper.captureMessage(
  'IAP receipt validation returned unexpected status',
  level: SentryLevel.warning,
  context: {'productId': productId, 'status': status},
);

// After user profile loads
SentryHelper.setUser(id: userId, email: email);

// On sign-out
SentryHelper.clearUser();
```

Context is attached under `app_context` in the Sentry event viewer.

### 6.4 Release Configuration

The `release` tag in Sentry is set to `write_it_lao@<version>+<build>` —
update this in `lib/main.dart` whenever you bump `pubspec.yaml`:

```dart
..release = 'write_it_lao@1.0.0+1'
```

---

## 7. App Store / Play Store Submission

### 7.1 App Store (iOS)

1. Create App ID in Apple Developer portal
2. Create app record in App Store Connect
3. Fill in metadata:
   - App name: Write Lao
   - Category: Education
   - Description, keywords, screenshots
   - Privacy policy URL
4. Archive in Xcode → Upload to App Store Connect
5. Submit for review

### 7.2 Google Play Store (Android)

1. Create app in Google Play Console
2. Upload signed App Bundle (`.aab`)
3. Fill in store listing:
   - Title: Write Lao
   - Category: Education
   - Description, screenshots, feature graphic
   - Privacy policy URL
   - Content rating questionnaire
4. Set up pricing (free)
5. Submit for review

### 7.3 Pre-Submission Checklist

- [ ] All 58 characters have stroke data JSONs
- [ ] All pronunciation audio files present
- [ ] App icon set (`flutter_launcher_icons`)
- [ ] Splash screen configured
- [ ] Version number updated in `pubspec.yaml` **and** `..release` in `lib/main.dart`
- [ ] `bash scripts/setup_secrets.sh` run with correct `SENTRY_DSN` in `.env`
- [ ] `flutter test` passes
- [ ] `flutter analyze` clean
- [ ] Tested on physical iOS device
- [ ] Tested on physical Android device
- [ ] All 21 lessons load and display correctly
- [ ] Practice mode works with stroke matching
- [ ] Test mode calculates stars correctly
- [ ] Progress persists across app restarts
- [ ] Settings reset clears Hive data
- [ ] Sentry dashboard shows events from a test release build
