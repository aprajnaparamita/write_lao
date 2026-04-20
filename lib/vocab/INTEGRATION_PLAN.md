# Phase 09 — Integration with Write Lao

This document describes how the vocabulary feature lands inside the
existing Write Lao app. Written against the actual codebase as of
2026-04-20.

## Host app architecture (audited)

- **State management:** `flutter_riverpod` (existing
  `characterRepositoryProvider`, `progressRepositoryProvider`, plus vocab's
  providers in `lib/vocab/providers.dart`).
- **Navigation:** `go_router`. Routes are declared in
  `lib/config/routes.dart` and consumed by `MaterialApp.router` in
  `lib/app.dart`. There is no nested shell — every screen is a top-level
  route.
- **Theming:** `lib/config/theme.dart`. Vocab screens inherit
  `Theme.of(context)`; no custom theme.
- **Localization:** `lib/l10n/app_localizations.dart` (`flutter_gen` from
  ARB files). Vocab strings are English-only in v1; future work can pipe
  them through `AppLocalizations`.
- **Persistence:** Hive. Alphabet state lives in `character_progress` and
  `lesson_progress` boxes (adapters 0, 1). Vocab boxes are registered in
  `openVocabBoxes()` alongside at app startup (`lib/main.dart`). Adapter
  IDs 12–16 are reserved for vocab.
- **Drawing control:** `WritingCanvas` from the alphabet section. Vocab
  wraps it via `RealStrokeCanvasHost` (see D25) so each card gets an
  isolated `canvasControllerProvider`.
- **Audio:** `VocabAudioPlayer` abstraction (`lib/vocab/audio/`) wraps
  `audioplayers`. The alphabet section uses its own audio stack; no
  shared player in v1.

## Files changed in Phase 09

| File | Change |
|------|--------|
| `lib/vocab/domain/vocab_config.dart` | Adds `featureEnabled` flag |
| `lib/config/routes.dart` | Adds `/vocab`, `/vocab/unit/:unitId`, `/vocab/upsell`, `/vocab/restore` |
| `lib/presentation/screens/lesson_list_screen.dart` | Adds a "Vocabulary" tile (guarded by `featureEnabled`) |
| `lib/presentation/screens/settings_screen.dart` | Mounts `VocabSettingsSection` |
| `lib/vocab/presentation/screens/vocab_settings_section.dart` | Switched to go_router navigation for restore |
| `lib/vocab/presentation/screens/unit_list_screen.dart` | Locked-unit tap navigates to `/vocab/upsell` for free users |
| `test/vocab/integration/vocab_reachable_test.dart` | New — proves the entry point |

No existing alphabet code is functionally modified. The tile on the
alphabet home screen is additive; settings mount is additive.

## Navigation flow

```
/ (alphabet home)
  └── "Vocabulary" tile → /vocab
                           ├── UnitListScreen
                           │     └── tap unit → /vocab/unit/:unitId
                           │                    └── LessonListScreen
                           │                          └── tap lesson → (lesson flow, future)
                           │     └── tap locked unit (free user) → /vocab/upsell
                           └── (entry also via settings Restore Purchases)

/settings
  └── VocabSettingsSection
        └── Restore Purchases → /vocab/restore
```

## Database migration

Additive. Vocab boxes are opened on every launch — if they didn't
exist on the previous install, Hive creates them empty. No migration
needed. Alphabet boxes are untouched.

## Feature flag

`VocabConfig.featureEnabled` — compile-time constant, default `true`.
When false:
- The "Vocabulary" tile on the home screen is not rendered.
- `VocabSettingsSection` is not rendered.
- The `/vocab*` routes still exist (harmless — nothing navigates to
  them from the UI when the flag is off).

This is enough for an emergency disable without needing a full
feature-flag service.

## Regression testing

- `flutter test` passes unchanged for the alphabet suite.
- Manual smoke: alphabet curriculum still works (home → lessons →
  practice → test). Not automated; verified by running the app.
- Bundle: no new runtime dependencies added.

## Open items deferred

- Full per-lesson flow (intro → practice → test → outro) is not wired
  into `/vocab/unit/:unitId/lesson/:lessonId`. The screens exist as
  widgets but routing to them is future work.
- Launch-counter logic for the "every 3rd launch re-prompt" rule in
  `VocabConfig.upsellLaunchCooldown` is not implemented. The constants
  are defined; consumers are not.
- Shared settings like "enable hear-and-identify" are not surfaced
  yet — the config exists but has no UI toggle.
