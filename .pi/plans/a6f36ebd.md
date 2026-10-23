{
  "id": "a6f36ebd",
  "title": "Fix App Store submission blockers for Write Lao iOS",
  "status": "completed",
  "created_at": "2026-10-06T02:10:49.935Z",
  "assigned_to_session": "df47d471-0e7b-4024-99e3-0dd34c2b2a63",
  "steps": [
    {
      "id": 1,
      "text": "Create ios/Runner/PrivacyInfo.xcprivacy with required reason codes (C617.1, E174.1, CA92.1) and wire into project.pbxproj Runner target Resources build phase",
      "done": true
    },
    {
      "id": 2,
      "text": "Add Privacy + Terms URL TextButtons to UpsellScreen _buildBottomButton() in lib/vocab/presentation/screens/upsell_screen.dart",
      "done": true
    },
    {
      "id": 3,
      "text": "Add Privacy + Terms ListTiles to Settings screen above the Reset All Progress tile in lib/presentation/screens/settings_screen.dart",
      "done": true
    },
    {
      "id": 4,
      "text": "Add Privacy + Terms OutlinedButtons to About screen below Contact Us in lib/presentation/screens/about_screen.dart",
      "done": true
    },
    {
      "id": 5,
      "text": "Plumb localized StoreKit price: add iapPriceLabelProvider, read in /vocab UpsellScreen route Consumer, pass as priceLabel; also show price in the footnote line",
      "done": true
    },
    {
      "id": 6,
      "text": "Add privacyPolicy and termsOfUse keys to app_en.arb plus English fallbacks to all 16 non-English ARB files in lib/l10n/",
      "done": true
    },
    {
      "id": 7,
      "text": "Run flutter gen-l10n to regenerate lib/l10n/app_localizations*.dart",
      "done": true
    },
    {
      "id": 8,
      "text": "Verify build: flutter clean && flutter build ios --release; confirm PrivacyInfo.xcprivacy bundled in Runner.app",
      "done": true
    },
    {
      "id": 9,
      "text": "Re-deploy to iPhone (make deploy-phone) and manually verify all 3 surfaces open URLs + paywall shows price",
      "done": true
    },
    {
      "id": 10,
      "text": "Run flutter test to confirm no widget test regressions",
      "done": true
    }
  ]
}

Fix the 4 critical App Store rejection blockers (Issues 1–4) in `APP_STORE_ISSUES.md` so the app can be submitted. Verified post-URL-check: `/support`, `/privacy_policy.html`, `/tos.html` all return 200 (the audit doc's no-extension URLs were wrong — use `.html` in app links).

## Verified upfront (no fix needed)
- **Warning 2 (Reset doesn't clear IAP):** `resetAllProgress()` only calls `_dataSource.clearAllProgress()` on `character_progress` and `lesson_progress` boxes (`lib/data/datasources/progress_local_datasource.dart:70-71`). The `iapUnlocked` flag lives in a separate `vocab_user_state` box (`lib/vocab/data/datasources/vocab_hive_adapters.dart:143`). Confirmed safe.
- **Warning 1 (/support URL):** live curl returns 200.

## Critical fixes (all 4)

### Step 1 — Create `ios/Runner/PrivacyInfo.xcprivacy` (Issue 1, ~30 min)
Auto-rejected pre-review. Create the manifest file with all Required Reason APIs this app actually touches:
- `NSPrivacyAccessedAPICategoryFileTimestamp` → reason `C617.1` (display file timestamp to user) — used by Hive/`path_provider`
- `NSPrivacyAccessedAPICategoryDiskSpace` → reason `E174.1` (write/delete user data) — used by Hive storage
- `NSPrivacyAccessedAPICategoryUserDefaults` → reason `CA92.1` (access info from same domain) — used by `package_info_plus`

**File:** `ios/Runner/PrivacyInfo.xcprivacy` (new). Also add to `Runner.xcodeproj/project.pbxproj` so it's in the Runner target's Resources build phase — without target membership Xcode won't bundle it. Use a `PBXFileReference` + add to the existing Runner group + add to the Runner target's `PBXResourcesBuildPhase`. Verify with `flutter clean && flutter build ios --release && ls Runner.app/PrivacyInfo.xcprivacy`.

### Step 2 — Add Privacy Policy + Terms of Use links to 3 surfaces (Issues 2+3, ~45 min)
All three files use `launchUrl(Uri.parse(...), mode: LaunchMode.externalApplication)`. Confirmed live URLs:
- `https://writelao.xyz/privacy_policy.html`
- `https://writelao.xyz/tos.html`

**2a. UpsellScreen** (`lib/vocab/presentation/screens/upsell_screen.dart`):
Add a Row of two TextButtons below the existing "One-time purchase — full access…" footnote in `_buildBottomButton()`. Center-aligned, white60 color, 12pt, with a " • " separator between them.

**2b. Settings screen** (`lib/presentation/screens/settings_screen.dart`): Add two `ListTile`s above the existing "Reset All Progress" tile (currently at line ~190), one for Privacy (`Icons.privacy_tip_outlined`) and one for Terms (`Icons.gavel`).

**2c. About screen** (`lib/presentation/screens/about_screen.dart`): Add two more `OutlinedButton.icon` buttons below the existing Contact Us button at line ~80. Same external-launch behavior.

### Step 3 — Plumb localized StoreKit price into UpsellScreen (Issue 4, ~30 min)
`UpsellScreen` already accepts `priceLabel` and shows "BUY NOW — \$X.XX" — but `routes.dart:337` never passes it. Need to:
- Add a `FutureProvider<String?>` (e.g. `iapPriceLabelProvider`) that calls `iapService.queryProductDetails()` and returns the first product's `.price` (already currency-formatted by StoreKit).
- In the route's `Consumer`, `ref.watch` that provider; show a small `CircularProgressIndicator` placeholder while loading; pass the value to `priceLabel:`.
- Also update the footnote "* One-time purchase — full access…" to include the localized price (e.g. `* One-time purchase — \$X.XX`). Read `platform_iap_service.dart:64-69` for the existing queryProductDetails call to reuse.

### Step 4 — Add l10n strings + regenerate (~30 min)
Add `privacyPolicy` and `termsOfUse` keys to `lib/l10n/app_en.arb`. Since the 16 other locale ARB files each have their own strings, add the English fallback to each non-English `.arb` (mark "untranslated — to be localized" in a TODO comment for translators). Then run `flutter gen-l10n` to regenerate `lib/l10n/app_localizations*.dart`.

Files: 17 `.arb` files (en, de, es, fr, hi, ja, km, ko, lo, ne, pt, th, tl, ur, vi, zh, zh_Hant).

### Step 5 — Verification (post-fix, ~20 min)
- `flutter clean && flutter pub get && flutter build ios --release`
- Inspect `Runner.app/PrivacyInfo.xcprivacy` is bundled: `unzip -l build/ios/iphoneos/Runner.app/PrivacyInfo.xcprivacy`
- Open `build/ios/archive/Runner.xcarchive` in Xcode Organizer → Validate App; the privacy report should list no missing APIs
- Re-deploy to iPhone (`make deploy-phone`) and confirm:
  - Settings → Privacy + Terms tiles open the website
  - About → Privacy + Terms buttons open the website
  - Upsell shows "BUY NOW — \$X.XX" instead of plain "BUY NOW"
- Run `flutter test` to confirm widget tests still pass

## Out of scope (manual, not blocking)
- **Warning 3:** iPad 13" landscape screenshots — generate via Xcode simulator + Cmd-S, upload to App Store Connect
- **Warning 4:** Move build-time API keys from `.env` to Cloudflare Worker secrets — post-launch hygiene
- **Cleanup:** Delete `aboutVersion` and `aboutVersionAuthor` strings from 17 ARB files (dead code) — optional follow-up

## Estimated total: ~2.5 hours of code work + manual App Store Connect actions (privacy report, store listing URLs)
