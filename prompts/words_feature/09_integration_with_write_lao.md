# Phase 09 — Integration with Write Lao

**Depends on:** `01` through `08`

## Objective

Land the vocabulary feature cleanly inside the existing Write Lao app. Preserve existing functionality. Share code where natural, isolate where not. Avoid regressions in the alphabet section.

## Before implementing

Spend time understanding the existing Write Lao codebase:

1. **Architecture.** What pattern does it use (MVC, MVVM, Redux-style, etc.)? What navigation library? What testing framework?
2. **Styling.** Color palette, typography, spacing. The vocabulary feature should feel like part of the same app.
3. **Drawing control.** Already covered in Phase 04. Confirm you understand its API before extending it.
4. **IAP.** Already covered in Phase 08. Confirm you understand the existing purchase flow.
5. **Persistence.** Is there already a local database? Are user preferences stored somewhere? Don't create a parallel storage if an existing one can be extended.
6. **Navigation.** Where does the new vocabulary entry point live? (Probably the main menu or home screen, alongside the alphabet curriculum.)

Produce a written integration plan covering the above **before writing code** in this phase.

## Integration points

### Main menu / home screen

Add an entry point for the vocabulary feature. Label: "Vocabulary" or "500 Words" (match Write Lao's naming conventions). Icon that matches the app's visual language.

### Shared drawing control

Reuse, don't fork. If the existing control needs extension (e.g., a "no-guide test mode"), extend it and cover the extension with tests. The alphabet section should continue to work identically.

### Shared audio subsystem

If Write Lao has its own audio player (for letter sound reinforcement?), reuse it. Otherwise, use the `AudioPlayer` abstraction from Phase 03.

### Shared settings screen

If Write Lao has a settings screen, add vocabulary-related settings to it:

- Enable/disable listening practice (Phase 05)
- Maybe enable/disable upsell prompts (for users who bought)
- Restore purchases button (Phase 08)

### Shared user state

Write Lao likely already stores some user state (alphabet progress, preferences). Add the vocabulary feature's tables alongside — don't make a separate database file unless there's a compelling reason.

### Database migration strategy

When the vocabulary feature is added via app update, existing Write Lao users get new tables added to their existing database. Migrations must:

- Be additive (don't alter or drop existing tables)
- Be idempotent (safe to run twice)
- Not require data from the alphabet section (the two features are isolated at the data level)

### Shared localization infrastructure

If Write Lao uses a localization framework, use it. All user-facing strings in the vocabulary feature go through that system. English-only content for v1, but structured for future localization.

## Regression testing

Before merging the vocabulary feature:

- All existing Write Lao tests must pass
- Manual smoke test: alphabet curriculum still works identically
- Manual smoke test: existing IAP purchases (if any) are respected
- Manual smoke test: existing user data is not corrupted by the new migrations

## Bundle size impact

Course content is ~500 images + ~1500 audio files. Approximate bundle impact:

- Images: 500 × 50KB (WebP) = ~25 MB
- Audio: 1500 × 50KB (Opus or compressed WAV) = ~75 MB

Total: ~100 MB added to app download.

For Write Lao (which may be smaller currently), this is significant. Consider:

- Audio compression: Opus at low bitrate is fine for speech. Convert WAV to Opus in the content pipeline.
- Image compression: WebP at quality 80 for flat illustrations. Already planned.
- On-demand download: if the content is very large, consider downloading it on first feature open rather than bundling. Complicates offline-first promise. Flag this for discussion.

**For v1 recommendation:** bundle everything. Keep it simple. Optimize later if bundle size is an issue.

## Feature flag

Consider wrapping the vocabulary feature in a feature flag (enabled by default in v1, but flag exists). This allows:

- A/B testing upsell variations later
- Emergency disable if a critical bug ships

Just a simple boolean config, not a full feature-flag system.

## Tests

1. All existing Write Lao tests pass unchanged
2. The vocabulary feature's tables are created on upgrade
3. The vocabulary feature is reachable from the main menu
4. Entering the vocabulary feature doesn't break the alphabet section
5. Navigating back from vocabulary to alphabet works
6. User can close the app mid-lesson and return to the same state (launching goes to last-used section)

## Done when

- The feature lands in Write Lao without regressing the existing experience
- Integration plan is documented in `DECISIONS.md`
- All existing and new tests pass
- Manual smoke tests confirm no regressions

## Open questions to flag

- **Navigation between alphabet and vocabulary.** Does the user have a clear path to switch between them? Is there a unified "home" or separate sections? Match whatever pattern Write Lao already uses.
- **Shared progress display.** Should the home screen show overall progress across both features, or separate progress for each? Probably separate for v1 (they're distinct curricula).
- **Onboarding.** If a new user buys the vocabulary IAP before completing the alphabet curriculum, what happens? Gating: require alphabet completion? Or allow parallel study? Probably allow parallel — but surface a warning ("We recommend completing the alphabet first").
