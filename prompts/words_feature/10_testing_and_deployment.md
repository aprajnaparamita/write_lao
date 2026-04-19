# Phase 10 — Testing and Deployment

**Depends on:** all prior phases

## Objective

End-to-end testing, content bundle packaging, and release preparation.

## End-to-end test scenarios

Automated E2E tests should cover these user journeys at minimum:

### Journey 1: Free user previews, purchases, completes first lesson

1. Install app, open vocabulary section
2. Unit 1 lesson 1 is accessible as preview
3. Complete all 3 words in lesson 1 with 0 errors
4. Upsell modal appears
5. Tap purchase, IAP sheet appears, simulate successful purchase
6. Entire course unlocks
7. Lesson 1 shows as complete, lesson 2 becomes current

### Journey 2: Returning user, SRS review

1. User with some completed progress opens the app
2. Navigates to current lesson
3. Lesson contains the expected mix of new + review words
4. Review words are correctly drawn from SRS candidates
5. Completing the lesson updates SRS state correctly

### Journey 3: Flag-and-study flow

1. User completes a word, taps "Flag to deck" on outro
2. Creates a new deck named "Test deck"
3. Word is added to the deck
4. User navigates to My Decks, sees the new deck
5. Starts a study session, word appears
6. Completes the study, SRS state updates

### Journey 4: Hear-and-identify card

1. User in a lesson with eligible review pool
2. Hear-and-identify card appears (force via test harness rather than relying on probability)
3. User hears audio, sees 4 options
4. User picks correct answer
5. SRS updates, card advances

### Journey 5: Purchase restoration

1. Fresh install, no local purchase state
2. User taps "Restore Purchases"
3. Platform returns an active entitlement
4. `iap_unlocked` flips to 1, full course available

### Journey 6: Course completion

1. Simulate a user who has completed all 500 words
2. All units show complete
3. Progress counter shows 500/500
4. Retired words are excluded from SRS review queue

Tests can use fixture content (smaller than 500 words) but the content loading path should be the same as production.

## Content bundle packaging

Before shipping:

1. Content JSON passes schema validation
2. All referenced image files exist and are accessible
3. All referenced audio files exist and are accessible
4. Total bundle size is within target (flag if over 150 MB)
5. Character type tags are populated for every character of every word
6. No dangling foreign keys (every lesson's word references resolve, every unit's lesson references resolve)

Create a `build_content_bundle.py` (or equivalent) that:

- Reads content from the review tool's export format
- Validates everything
- Compresses audio (Opus or equivalent)
- Compresses images (WebP at quality 80)
- Outputs a zipped bundle ready to include in the app

## Pre-release checklist

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All E2E tests pass
- [ ] Manual smoke test on iOS physical device
- [ ] Manual smoke test on Android physical device (if applicable)
- [ ] Manual smoke test with VoiceOver / TalkBack (accessibility)
- [ ] Bundle size acceptable (< 150 MB or whatever Write Lao's target is)
- [ ] IAP product configured in App Store Connect / Play Console
- [ ] Restore Purchases button visible and working
- [ ] Privacy policy updated (data stored locally, no network calls)
- [ ] App Store description updated to mention new feature
- [ ] Screenshots updated
- [ ] Release notes written

## Analytics (optional)

Write Lao may already have analytics. If so, instrument the vocabulary feature with the same system:

- Lesson start / complete events
- IAP purchase / cancel / restore events
- Error counts per word (for identifying difficulty hot spots)
- Feature usage (how often users open the vocabulary feature)

Do NOT instrument:

- User-identifying information
- Content of drawings
- Individual word errors (aggregates are fine)

Respect the app's existing privacy posture.

## Rollout

Consider a phased rollout:

1. **Internal testing.** You use it yourself, find obvious bugs.
2. **Beta.** A small group tests via TestFlight / Play Console testing tracks.
3. **Staged release.** Release to 10% of users first, watch for crash reports and reviews, then expand.

## Post-release monitoring

Watch for:

- Crash reports referencing vocabulary feature code
- IAP completion rate (should be high if the sheet is shown)
- App Store reviews mentioning the feature
- Users who purchase but don't return within 7 days (indicator of UX issue)

## Done when

- All tests pass in CI
- Content bundle builds cleanly from source
- Manual QA on real devices is clean
- Release checklist is complete
- First production release is shipped

## Open questions to flag

- **Beta audience.** Who tests this? You + a few friends + the Lao teacher? Recruit before feature-complete, not after.
- **Analytics vendor.** If Write Lao already has one (Mixpanel, Amplitude, Firebase), use it. If not, skip analytics for v1 — add them in v2.
- **Crash reporting.** Should be in Write Lao already (Sentry, Crashlytics). Make sure new code is covered.
