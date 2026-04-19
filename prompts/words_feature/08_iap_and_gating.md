# Phase 08 — IAP and Feature Gating

**Depends on:** `01` (user_progress.iap_unlocked), `07` (navigation)

## Objective

Integrate with the Write Lao app's existing in-app purchase flow to unlock the 500-word feature. Implement upsell prompts for free users. Persist and restore purchase state.

## Assumption

Write Lao already needs IAP infrastructure (either Apple IAP on iOS, Google Play billing on Android)

Define a new product ID for the 500-word feature (e.g., `write_lao_vocabulary_500`) and add it through whatever flow the existing app uses.

## IAP state

The `user_progress.iap_unlocked` column (Phase 01) is the source of truth for the vocabulary feature. 

- `0` (default) — feature locked, user sees free preview and upsell
- `1` — feature unlocked, full access

Set to `1` when:

- IAP completes successfully
- IAP restore succeeds (user reinstalled or got new device and ran "restore purchases")

Set to `0` only if:

- A refund/revocation is detected (if the platform surfaces this; otherwise leave as `1` and let platform handle)

Note: since v1 has no sync, a user who buys on Device A and installs on Device B will need to use "Restore Purchases" to transfer their entitlement. Their SRS progress does NOT transfer (that's a v2 feature). Make this clear in UI.

## Free user experience

Before purchase, what does a user see when they navigate to the vocabulary feature?

### Preview + upsell

- Unit 1 is partially accessible: lesson 1 can be played in full (5 words) to give a real taste
- After lesson 1, a paywall screen appears: "Like this? Unlock 495 more words for $1"
- All other units/lessons are visibly present in the unit list but locked with IAP icons
- Tapping a locked unit shows the purchase sheet

Tune the preview amount via a single config value (e.g., `FREE_PREVIEW_LESSONS = 1`) so you can adjust later.

## Upsell prompts

For users still in the free preview, occasional prompts encourage purchase:

- After completing lesson 1 (the preview), show a purchase prompt with "Not now" option
- If they dismiss, don't prompt again on the next app launch — give them breathing room
- Every 3rd practice or test of Write Lao alphabet practice/learning
  prompt for the purchase
- On later launches (e.g., every 3rd launch of the vocabulary section while unlocked=0), show prompt again
- Make the prompt a full-screen modal with:
  - Brief value prop ("Learn 500 Lao words with writing practice")
  - Social proof or feature highlights (optional)
  - Price and "Buy now" button
  - "Maybe later" dismiss

Don't spam. Spamming costs trust.

## Purchase flow

1. User taps "Buy now" or a locked unit
2. Purchase sheet (platform-specific, handled by existing IAP infra)
3. On success: set `iap_unlocked = 1`, show confirmation, navigate to unit 1
4. On failure or cancel: return to previous state, no changes
5. On error: show error message, preserve user's place in the app

## Restore purchases

There must be a "Restore Purchases" button somewhere (usually in settings). This is required by Apple IAP guidelines and is good practice on Android too. It re-queries the platform for entitlements and sets `iap_unlocked = 1` if an unexpired purchase is found.

## Tests (write these first)

1. Fresh install, no purchase → `iap_unlocked = 0`, units 1-20 all locked except preview
2. Completing preview lesson 1 triggers upsell modal
3. Dismissing upsell modal does not mark user as purchased
4. Successful purchase sets `iap_unlocked = 1` and unlocks all content
5. Cancelled purchase does not change `iap_unlocked`
6. Restore purchases with an active entitlement sets `iap_unlocked = 1`
7. Restore purchases with no entitlement leaves state unchanged
8. Preview lesson can be completed without purchase
9. Lessons beyond preview cannot be started without purchase

Mock the platform IAP in tests — don't hit actual Apple/Google infrastructure.

## Done when

- IAP purchase and restore both work end-to-end
- Free preview accurately limits content
- Upsell prompts appear at reasonable frequency
- Full unlock works after purchase
- All tests pass
- `DECISIONS.md` notes IAP product ID, preview configuration, prompt frequency

## Open questions to flag

- **Price tier selection.** $0.99 / $1.99 / $2.99 — final pricing decision. v1 default: $0.99. Change via App Store console, not code.
- **Refund handling.** If Apple/Google issues a refund, does the app auto-revoke? Some stores notify the app, others don't. Check what Write Lao's existing IAP does.
- **Promotional free periods.** If you want to give the feature away free for a launch period, handle via temporary server-side override (v2) or via app config flag (v1).
- **Educational discount.** If you support edu pricing, that's a separate product ID. Skip for v1.
