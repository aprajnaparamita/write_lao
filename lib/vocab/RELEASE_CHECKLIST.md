# Pre-Release Checklist — 500-Word Vocabulary Feature

Use this checklist before shipping the vocabulary feature.

## Automated Tests

- [ ] All unit tests pass (`flutter test test/vocab/domain/`)
- [ ] All widget tests pass (when Hive issue is resolved)
- [ ] All integration tests pass
- [ ] No analyzer errors or warnings (except pre-existing)

## Content Bundle

- [ ] Content JSON passes schema validation (`python scripts/validate_content_bundle.py`)
- [ ] All image files exist and are accessible
- [ ] All audio files exist and are accessible
- [ ] All character type tags are populated
- [ ] No dangling foreign keys
- [ ] Bundle size is acceptable (< 150 MB target)

## IAP Configuration

- [ ] Product ID `write_lao_vocabulary_500` configured in App Store Connect
- [ ] Product ID `write_lao_vocabulary_500` configured in Google Play Console
- [ ] Price tier set correctly ($0.99)
- [ ] Restore Purchases button is visible and functional

## App Store Assets

- [ ] App Store description updated to mention vocabulary feature
- [ ] New screenshots capturing vocabulary screens added
- [ ] Privacy policy updated (data stored locally, no network calls)
- [ ] Release notes written

## Manual QA — iOS

- [ ] Alphabet curriculum still works
- [ ] Vocabulary feature accessible from main menu
- [ ] Free preview lesson 1 is playable
- [ ] Paywall appears after preview lesson
- [ ] Purchase flow completes successfully
- [ ] Full course unlocks after purchase
- [ ] Restore Purchases works
- [ ] Lesson flow works end-to-end (intro → practice → test → outro)
- [ ] SRS review scheduling works
- [ ] Audio plays correctly
- [ ] Drawing works for practice and test
- [ ] Flag to deck works
- [ ] My Decks screen works
- [ ] Navigation between screens works

## Manual QA — Android

- [ ] Same as iOS checklist

## Accessibility

- [ ] VoiceOver / TalkBack navigation works
- [ ] Dynamic Type supported
- [ ] Color contrast meets WCAG AA

## Crash Reporting

- [ ] New code paths are covered by existing crash reporting (Sentry/Crashlytics)
- [ ] No new crash reports expected from vocab code

## Analytics (if enabled)

- [ ] Lesson start/complete events firing
- [ ] IAP events firing
- [ ] No PII being collected

## Staged Rollout

- [ ] Consider releasing to 10% of users first
- [ ] Monitor crash reports for 24-48 hours
- [ ] Expand rollout if no issues

## Post-Release Monitoring

Watch for:
- [ ] Crash reports referencing vocab feature
- [ ] IAP completion rate (should be high if upsell is effective)
- [ ] App Store reviews mentioning the feature
- [ ] Users who purchase but don't return within 7 days
