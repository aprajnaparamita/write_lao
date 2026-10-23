# BUILD_PLATFORM_RELEASE — Agent Prompt

Build the latest Write Lao checkout on THIS machine for one platform,
with the correct unlock variant, and leave the artifact in `outputs/`
under its stable release name.

## Usage

Run this file as a prompt, naming the platform:

> Run `prompts/BUILD_PLATFORM_RELEASE.md` for windows
> Run `prompts/BUILD_PLATFORM_RELEASE.md` for macos and publish
> Run `prompts/BUILD_PLATFORM_RELEASE.md` (platform = this machine)

Valid platforms: `macos`, `windows`, `linux`, `android`, `ios`.
No platform named → detect from the host OS and say which one you picked.

Optional second request: `publish` → also attach artifacts to the GitHub
release (see step 5). Never publish without that explicit request.

## Rules

- Build only. Do not change app code. A failing build: quote the decisive
  error line, stop, report. Never "fix" product code to make a build pass.
- Version comes from `pubspec.yaml` (`version: X.Y.Z+BUILD`). Report it.
- Variant flag decides paid behavior. Getting it wrong ships the wrong product:
  - macos / windows / linux / android-open: `--dart-define=APP_VARIANT=open`
    (full vocabulary unlocked — the open-source build)
  - android-play / ios: `--dart-define=APP_VARIANT=store`
    (vocabulary behind in-app purchase)
- Artifact names are STABLE (no version) — README download links point at
  `releases/latest/download/<name>`. Names must match the table exactly.
- All artifacts go to `outputs/`. Overwrite freely (`--clobber` semantics).
- Flutter: use `flutter` from PATH, or `$FLUTTER` / `%FLUTTER%` if set.

## Steps

1. `flutter pub get`
2. `flutter test` — all tests must pass. On failure, stop and report.
3. Build with the commands for the platform below.
4. Verify: artifact exists in `outputs/`, name exact, size plausible
   (APK/DMG/EXE > 20 MB, tar/zip > 10 MB), then run a smoke check if the
   platform supports it (see below).
5. Only on `publish` request and if `gh` is installed + authenticated:
   - Tag: `v` + pubspec version (e.g. `v1.0.5`).
   - If release exists: `gh release upload <tag> outputs/<artifact> --clobber`
   - If not: `gh release create <tag> outputs/<artifact> --title "<tag>" --notes "..."`
   - One machine uploads its own platform artifact(s); never delete other
     platforms' assets from the release.
6. Report, tersely: version, git SHA, platform, artifact name + size +
   path, publish result (or "local only").

## Artifact names (exact)

| Platform | Artifact | Variant |
|---|---|---|
| macOS | `outputs/write_lao-macos.dmg` | open |
| Windows | `outputs/write_lao-windows-setup.exe` | open |
| Windows (portable fallback) | `outputs/write_lao-windows.zip` | open |
| Linux | `outputs/write_lao-linux.tar.gz` | open |
| Android (sideload) | `outputs/write_lao-android.apk` | open |
| Android (Play Store) | `outputs/write_lao-android-play.aab` | store |
| iOS | handled by `make archive` (App Store, store variant) | store |

## Platform build commands

### macOS (bash)

```bash
bash scripts/build_macos_dmg.sh
```

Does everything: builds release with `APP_VARIANT=open`, stages the .app,
wraps it in a .dmg. Smoke check: `hdiutil attach outputs/write_lao-macos.dmg`
then confirm `Write Lao.app` inside, `hdiutil detach`.

### Android (bash — macOS/Linux/Windows-with-bash)

```bash
bash scripts/build_android.sh apk   # → outputs/write_lao-android.apk   (open)
bash scripts/build_android.sh aab   # → outputs/write_lao-android-play.aab (store)
```

Build both unless user asked for one. Smoke check: `unzip -t outputs/write_lao-android.apk`.

### Windows (PowerShell)

```powershell
flutter pub get
flutter test
flutter build windows --release --dart-define=APP_VARIANT=open
```

Release output: `build\windows\x64\runner\Release\` (exe + DLLs + `data\`).

Portable zip (always):

```powershell
New-Item -ItemType Directory -Force outputs | Out-Null
if (Test-Path outputs\write_lao-windows.zip) { Remove-Item outputs\write_lao-windows.zip }
Compress-Archive -Path build\windows\x64\runner\Release\* `
  -DestinationPath outputs\write_lao-windows.zip
```

Installer EXE (preferred — this is "the .exe"):

```powershell
$ver = (Select-String -Path pubspec.yaml '^version: *([\d.]+)').Matches[0].Groups[1].Value
iscc /DAppVersion=$ver windows\installer\setup.iss
```

`iscc` = Inno Setup compiler. Not installed → install with
`winget install JRSoftware.InnoSetup` (needs user OK), or build the zip only
and say the setup exe is missing. Smoke check: zip → `Expand-Archive` to a
temp dir and confirm `write_lao.exe` inside.

### Linux (bash)

```bash
flutter pub get
flutter test
flutter build linux --release --dart-define=APP_VARIANT=open
tar czf outputs/write_lao-linux.tar.gz -C build/linux/x64/runner/Release .
```

Smoke check: `tar tzf outputs/write_lao-linux.tar.gz | grep write_lao`.

### iOS (macOS only, App Store)

`make archive` — existing flow, store variant, unchanged by this prompt.
Do not produce an ad-hoc iOS build.

## Notes

- Signed builds only where signing already configured (iOS via Xcode
  accounts). macOS/Windows artifacts are unsigned: the report must mention
  Gatekeeper / SmartScreen "run anyway" caveat.
- Windows repo has `windows\installer\setup.iss` — do not edit it unless the
  build fails because of it.
- If `flutter test` fails from an unrelated pre-existing failure, report the
  failure and ask: build anyway or stop.
