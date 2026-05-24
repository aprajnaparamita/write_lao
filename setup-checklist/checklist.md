# Write Lao — Setup Checklist

- [ ] **Prerequisites**
  - [ ] Flutter 3.9+ installed (`flutter --version`)
  - [ ] `flutter doctor` — all checks pass
  - [ ] Inkscape 1.4+ installed
  - [ ] Xcode 15+ (iOS/macOS targets)
  - [ ] Android Studio + SDK 34+ (Android target)

- [ ] **Secrets / Environment**
  - [ ] Copy `.env.example` to `.env` and fill in `SENTRY_DSN` (and any other keys)
  - [ ] `bash scripts/setup_secrets.sh` — generates `lib/config/secrets.dart` (gitignored)
  - [ ] Confirm `lib/config/secrets.dart` exists and contains the correct DSN

- [ ] **Project Setup**
  - [ ] `flutter pub get`
  - [ ] `dart run build_runner build --delete-conflicting-outputs`
  - [ ] `flutter test` — 200+ tests pass
  - [ ] `flutter analyze` — 0 errors

- [ ] **Stroke Authoring (per character)**
  - [ ] Open SVG template in Inkscape (`lao_svgs/XX_YY_name_UXXXX.svg`)
  - [ ] Create `strokes` layer/group
  - [ ] Draw each stroke as a separate `<path>` in writing order
  - [ ] Keep reference/background in separate groups
  - [ ] Save SVG
  - [ ] Convert: `dart run tool/svg_to_json.dart <file.svg> -o assets/stroke_data/U+XXXX.json`
  - [ ] Verify in app: ghost strokes render, matching works, order correct

- [ ] **Batch Convert All SVGs**
  - [ ] `dart run tool/svg_to_json.dart ./lao_svgs/ -o assets/stroke_data/ --verbose`
  - [ ] All 58 JSON files created in `assets/stroke_data/`

- [ ] **Audio Files**
  - [ ] Pronunciation MP3s in `assets/audio/pronunciation/`
  - [ ] File names match romanization field (e.g., `ko.mp3`)

- [ ] **App Icon & Splash**
  - [ ] App icon at `assets/icon/app_icon.png`
  - [ ] `dart run flutter_launcher_icons`

- [ ] **iOS Build**
  - [ ] `cd ios && pod install && cd ..`
  - [ ] Bundle ID set in Xcode
  - [ ] Signing team configured
  - [ ] `flutter build ios --release` succeeds

- [ ] **Android Build**
  - [ ] `android/key.properties` configured with keystore
  - [ ] `flutter build appbundle --release` succeeds

- [ ] **macOS Build (optional)**
  - [ ] `flutter build macos --release` succeeds

- [ ] **Manual Testing**
  - [ ] App launches to lesson list (21 lessons visible)
  - [ ] Lesson detail shows correct characters
  - [ ] Practice mode: ghost strokes + stroke matching works
  - [ ] Test mode: timed, stars calculated correctly
  - [ ] Progress persists across app restart (Hive)
  - [ ] Settings reset clears all progress
  - [ ] Review screen shows all characters

- [ ] **Error Tracking (Sentry)**
  - [ ] Sentry project created at sentry.io
  - [ ] DSN copied into `.env` as `SENTRY_DSN=https://...`
  - [ ] `bash scripts/setup_secrets.sh` run to regenerate `lib/config/secrets.dart`
  - [ ] Release build sent to device — verify events appear in Sentry dashboard
  - [ ] `SentryHelper.captureException` / `captureMessage` used in `catch` blocks for recoverable errors

- [ ] **App Store Submission**
  - [ ] Version number updated in `pubspec.yaml`
  - [ ] App Store Connect app record created
  - [ ] Metadata: name, description, keywords, screenshots
  - [ ] Privacy policy URL
  - [ ] Archive → Upload → Submit for review

- [ ] **Play Store Submission**
  - [ ] Google Play Console app created
  - [ ] Store listing: title, description, screenshots, feature graphic
  - [ ] Privacy policy URL
  - [ ] Content rating questionnaire completed
  - [ ] Upload `.aab` → Submit for review
