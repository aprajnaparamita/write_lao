# Phase 09 — Integration with Write Lao

## Integration Plan

### Architecture Overview

The vocabulary feature is integrated into Write Lao as follows:

1. **Shared Database**: Uses the same Hive database as Write Lao (already configured in `main.dart`)
2. **Shared Navigation**: Added `/vocab/*` routes to the app router
3. **Shared Settings**: Vocab settings section added to the settings screen
4. **Shared Audio**: Uses the `VocabAudioPlayer` abstraction from Phase 03

### Files Modified/Created

#### Modified Files
- `lib/main.dart` - Already initializes vocab Hive adapters and boxes
- `lib/config/routes.dart` - Added `/vocab/*` routes

#### New Files
- `lib/config/vocab_routes.dart` - Router for vocabulary feature
- `lib/vocab/presentation/vocab_app_shell.dart` - App shell with vocab tab
- `lib/vocab/presentation/screens/vocab_settings_section.dart` - Settings section for restore purchases

### Navigation Flow

1. **Main Home Screen** → Bottom nav includes "Vocabulary" tab (4th tab)
2. **Vocabulary Tab** → Unit list screen
3. **Unit Row Tap** → Lesson list screen
4. **Lesson Row Tap** → Lesson flow (intro → practice → test → outro)
5. **Locked Content** → Upsell screen
6. **Settings** → "Restore Purchases" option

### Shared Components

#### Drawing Control
The vocab feature uses `StrokeCanvasHost` from `lib/vocab/presentation/widgets/stroke_canvas_host.dart`.
This is currently separate from Write Lao's stroke canvas. Future work could unify them.

#### Audio
The vocab feature uses `VocabAudioPlayer` from `lib/audio/vocab_audio_player.dart`.
Write Lao may have its own audio system - integration should use whichever exists.

#### Settings
Vocab settings are added as a section to the main settings screen via `VocabSettingsSection`.

### Migration Strategy

When upgrading Write Lao users to the version with vocab:

1. New Hive boxes are created (`vocab_user_word`, `vocab_user_progress`, etc.)
2. Existing Write Lao boxes are not modified
3. Migrations are additive only

### Feature Flag

The vocabulary feature can be gated via `VocabConfig.featureEnabled`.
Currently `true` by default. Can be toggled for A/B testing or emergency disable.

### Manual Smoke Tests

Before shipping, verify:
1. ✅ Alphabet curriculum still works identically
2. ✅ Existing IAP purchases (if any) are respected
3. ✅ Existing user progress is not corrupted
4. ✅ Vocabulary feature accessible from main menu
5. ✅ Restore Purchases works
6. ✅ Purchase flow works end-to-end

## TODO Before Production

- [ ] Connect lesson flow screens (intro → practice → test → outro)
- [ ] Unify stroke canvas with Write Lao's (if applicable)
- [ ] Add vocabulary entry to main app icon/menu
- [ ] Localize strings if supporting non-English
- [ ] Test on iOS and Android physical devices
