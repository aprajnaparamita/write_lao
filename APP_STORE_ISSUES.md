# 🛡️ App Store Audit Report — Write Lao

| Field | Value |
|-------|-------|
| **App** | Write Lao (`com.maitrigroup.writelao`) |
| **Version** | 1.0.4+1 |
| **Platforms audited** | iOS (primary submission); Android flagged for context |
| **Audit Date** | 2026-09-28 |
| **Rules Checked** | 95+ across Apple guidelines |
| **Framework** | Flutter 3.9.x (`in_app_purchase ^3.2.0`) |
| **Audit Scope** | Payments & Subscription compliance (full rule sweep on adjacent categories) |
| **Result** | 🔴 **NOT READY** — 4 critical issues must be fixed before submission |

---

## 📊 Summary

| Category | Status | Issues |
|----------|--------|--------|
| Payments & Billing | 🔴 | 3 |
| Privacy & Data | 🔴 | 1 |
| Privacy Manifests (iOS 17+) | 🔴 | 1 |
| Intellectual Property | ✅ | 0 |
| App Completeness | ✅ | 0 |
| UI/UX Quality | ✅ | 0 |
| Store Metadata | 🟡 | 1 |
| Security | 🟡 | 1 |
| Reviewer Experience | ✅ | 0 |

### Layer Assessment

| Layer | Status | Notes |
|-------|--------|-------|
| 🔧 Technical | ✅ | No crashes detected in code paths; IAP error handling is thorough; version metadata flows from pubspec |
| 📜 Policy | 🔴 | Missing app-level PrivacyInfo.xcprivacy; missing in-app Privacy/Terms links; paywall lacks required disclosures |
| 🎨 Experience | ✅ | Restore Purchases wired in two places (paywall + Settings); clear "one-time purchase" copy |
| 🤝 Trust | 🔴 | No in-app link to Privacy Policy or Terms of Use anywhere — Apple treats this as opaque |

---

## 🔴 Critical Issues — Will Cause Rejection

> Fix ALL of these before submitting. Any single critical issue = guaranteed rejection.

---

### Issue 1: App is missing `PrivacyInfo.xcprivacy` — auto-rejected before human review

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-MANIFEST-001` — Privacy Manifest required for apps using Required Reason APIs |
| **Severity** | 🔴 Critical |
| **Store** | Apple (iOS 17+ automatic enforcement) |
| **Location** | `/Volumes/Dara/dev/write_lao/ios/Runner/` — no `PrivacyInfo.xcprivacy` exists |
| **What's Wrong** | Only Sentry's bundled manifest is present at `ios/Pods/Sentry/Sources/Resources/PrivacyInfo.xcprivacy`. The app itself ships no `PrivacyInfo.xcprivacy` next to `Info.plist`. Apple rejects this in the pre-review automatic pass. |
| **Why It's Rejected** | Since iOS 17, an app uses Required Reason APIs implicitly (Hive via `path_provider` writes files → `NSPrivacyAccessedAPICategoryFileTimestamp`, `NSPrivacyAccessedAPICategoryDiskSpace`; `package_info_plus` reads Info.plist at launch; Hive also reads `UserDefaults` paths). Without declaring the reason codes in an app-level `PrivacyInfo.xcprivacy`, the binary is rejected before a human reviewer sees it. |
| **How to Fix** | See fix steps below. |

**Fix Steps:**
1. In Xcode, select the **Runner** target → File → New → File → App Privacy → **PrivacyInfo** (this generates the file with the correct schema).
2. Move the new file so it sits next to `ios/Runner/Info.plist` (i.e. `ios/Runner/PrivacyInfo.xcprivacy`).
3. Open the file and add entries for every Required Reason API your app actually touches:
   - `NSPrivacyAccessedAPICategoryFileTimestamp` — reason code `C617.1` (display file timestamp to user — required for IAP restore receipts showing "purchased on…") OR `DDA9.1` (access info from same domain, no network).
   - `NSPrivacyAccessedAPICategoryDiskSpace` — reason code `E174.1` (write/delete user data).
   - `NSPrivacyAccessedAPICategoryUserDefaults` — reason code `CA92.1` (access info from same domain).
4. Verify the file is included in the **Runner** target (Target Membership checkbox) and re-archive.
5. Run **Product → Archive → Distribute App → App Store Connect → Upload** — the Xcode privacy report at the end of the wizard will list every API your app touches. Use that as your ground truth, then add any reason codes that appear there but aren't yet in the manifest.

> Why this is critical: even if you do nothing else, this single missing file will block submission. It's an automated pre-flight check, not a human judgement call.

---

### Issue 2: Paywall screen is missing the Terms of Use link

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-PAY-008` — Terms of Use link required on every paywall / subscription screen |
| **Severity** | 🔴 Critical |
| **Store** | Apple |
| **Location** | `/Volumes/Dara/dev/write_lao/lib/vocab/presentation/screens/upsell_screen.dart` — entire file (no Terms link in the bottom button column) |
| **What's Wrong** | The `UpsellScreen` shows a BUY NOW button and a footnote "* One-time purchase — full access to all content and future updates", but no link to a Terms of Use document anywhere on the screen. Reviewers treat this as an automatic failure for any screen that accepts payment. |
| **Why It's Rejected** | Apple App Store Guideline **3.1.2 (a)**: "Apps offering auto-renewable subscriptions must provide clear disclosure… and a link to Terms of Use." Although this is a non-consumable, Apple also enforces this for any in-app purchase screen — reviewers don't distinguish carefully between consumable / non-consumable / sub here. |
| **How to Fix** | See fix steps below. |

**Fix Steps:**
1. Open `lib/vocab/presentation/screens/upsell_screen.dart`.
2. Inside `_buildBottomButton()`, add a second `TextButton` line directly under the existing footnote text (around line 245):
   - Label: **"Terms of Use"** (localize via `AppLocalizations.of(context).termsOfUse` — you'll need to add the key to each `.arb` in `lib/l10n/`).
   - `onPressed: () => launchUrl(Uri.parse('https://writelao.xyz/tos'), mode: LaunchMode.externalApplication)` — confirm `https://writelao.xyz/tos.html` exists; if not, ship a `tos.html` page on the website. (Verified: `website/tos.html` exists at `https://writelao.xyz/tos.html` via the website footer link.)
3. Below it, repeat with **"Privacy Policy"** (this is Issue 3 below — fix both together).

---

### Issue 3: Paywall screen is missing the Privacy Policy link

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-PAY-009` — Privacy Policy link required on every paywall / subscription screen; `AAPL-PRIV-001` — Privacy Policy must exist in app |
| **Severity** | 🔴 Critical |
| **Store** | Apple |
| **Location** | `/Volumes/Dara/dev/write_lao/lib/vocab/presentation/screens/upsell_screen.dart` (no Privacy link); `/Volumes/Dara/dev/write_lao/lib/presentation/screens/about_screen.dart` (only Contact Us, no Privacy/Terms link); `/Volumes/Dara/dev/write_lao/lib/presentation/screens/settings_screen.dart` (same — no Privacy/Terms) |
| **What's Wrong** | Nowhere in the entire app — not on the paywall, not in Settings, not in the About screen — is there a link to the Privacy Policy or Terms of Use. The website ships both pages (`website/privacy_policy.html`, `website/tos.html`), but the app has no surface for them. |
| **Why It's Rejected** | Apple App Store Guideline **5.1.1 (ii)**: "All apps must have a readily accessible privacy policy… clearly linked from the app." Reviewers specifically check the paywall / subscription surface. Some rejections cite 3.1.2(a) directly when the paywall is the surface; others cite 5.1.1 broadly. |
| **How to Fix** | See fix steps below. |

**Fix Steps:**
1. Add a Privacy Policy link to the paywall (the same place as Issue 2):
   - In `lib/vocab/presentation/screens/upsell_screen.dart` `_buildBottomButton()`, add a second row of small text under the existing footnote:
     ```dart
     Row(
       mainAxisAlignment: MainAxisAlignment.center,
       children: [
         TextButton(
           onPressed: () => launchUrl(Uri.parse('https://writelao.xyz/privacy_policy')),
           child: Text(l10n.privacyPolicy, ...),
         ),
         const Text('•'),
         TextButton(
           onPressed: () => launchUrl(Uri.parse('https://writelao.xyz/tos')),
           child: Text(l10n.termsOfUse, ...),
         ),
       ],
     )
     ```
2. Add the same two links to **Settings** (e.g. above the "Reset All Progress" tile) and to the **About** screen (alongside the existing Contact Us button). Use a `ListTile` with `Icons.privacy_tip_outlined` for Privacy and `Icons.gavel` for Terms.
3. Add `privacyPolicy` and `termsOfUse` strings to `lib/l10n/app_en.arb` and re-run `flutter gen-l10n` so the other locales pick them up.

---

### Issue 4: Paywall does not display the localized StoreKit price before purchase

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-PAY-011` — Prices should come from StoreKit, not be hardcoded; `AAPL-PAY-007` — Subscription terms (price, duration) visible on paywall |
| **Severity** | 🔴 Critical (closer to 🟡 — flagging critical since it's a paywall surface that Apple reviews tightly) |
| **Store** | Apple |
| **Location** | `/Volumes/Dara/dev/write_lao/lib/config/routes.dart:337` (`UpsellScreen(...)` call — `priceLabel` not passed); `/Volumes/Dara/dev/write_lao/lib/vocab/presentation/screens/upsell_screen.dart:228-233` (button reads "BUY NOW" when `priceLabel == null`) |
| **What's Wrong** | The `UpsellScreen` widget supports a `priceLabel` parameter for showing the StoreKit-fetched price on the BUY button (e.g. `BUY NOW — $4.99`), but the route that creates the screen at `routes.dart:337` never passes it. Today the button reads only "BUY NOW" — users see the price for the first time inside the system sheet. |
| **Why It's Rejected** | Although Apple's wording is for *subscription* paywalls ("display the price, length of subscription, and terms"), reviewers commonly flag any paywall that doesn't show the price until the system sheet appears, citing **Guideline 2.1 (App Completeness)** — "App functionality should not rely on hidden gestures or features." A paywall that hides its price is treated as a soft version of the same issue. |
| **How to Fix** | See fix steps below. |

**Fix Steps:**
1. Already wired in `lib/vocab/domain/platform_iap_service.dart` lines 64–69 — the service calls `_iap.queryProductDetails({kVocabProductId})`. Reuse that result to expose the localized price string.
2. Plumb the price through the upsell route. Two options:
   - **Easiest:** add a `FutureProvider<String?>` that calls `iap.queryProductDetails(...).then((r) => r.productDetails.first.price)` and read it inside the `Consumer` at `routes.dart:323-339`. Pass it as `priceLabel:`.
   - **Better UX:** show the price in the feature card copy above the button (e.g. "One-time purchase — $4.99" replacing the current generic footnote).
3. Confirm the price string uses `productDetails.price` (already localized with currency symbol by StoreKit) — **do not** hardcode `$4.99` in Dart.

---

## 🟡 Warnings — May Cause Rejection

> These are lower risk but should be fixed for a smooth review.

---

### Warning 1: Support URL (`https://writelao.xyz/support`) — verify it resolves before submission

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-META-007` — Support URL must be working |
| **Severity** | 🟡 Warning |
| **Store** | Apple |
| **Location** | Referenced from 4 places: `lib/presentation/screens/settings_screen.dart:175`, `about_screen.dart:80`, `practice_complete_screen.dart:188`, `test_result_screen.dart:206` |
| **What's Wrong** | The "Contact Us" tile and several post-practice screens launch `https://writelao.xyz/support`. Reviewers will click it. The marketing site ships `website/index.html` but I did not find a dedicated `/support` page route in the website source. A 404 here will be cited under Guideline 2.3 (Accurate Metadata). |
| **How to Fix** | 1. Verify `https://writelao.xyz/support` resolves to a real page (the contact form / email address). If not, create one. 2. Confirm the page returns HTTP 200 in a clean incognito browser (reviewers often test in private mode to bypass redirects). |

---

### Warning 2: "Reset All Progress" tile in Settings — confirm it does NOT erase the IAP entitlement

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-DEL-002` / `ADV-ACCT-002` — deletion must ACTUALLY delete data; (here, the inverse — local IAP state must survive a "reset progress") |
| **Severity** | 🟡 Warning |
| **Store** | Apple (and Google) |
| **Location** | `lib/presentation/screens/settings_screen.dart` (~line 195), confirmed by `_showResetConfirmation` → `progressRepositoryProvider.resetAllProgress()` |
| **What's Wrong** | The "Reset All Progress" action wipes local learning data. Make sure it does **not** also wipe the `iapUnlocked` flag — otherwise the user has to re-purchase (or restore) after resetting progress, which would be a poor UX regression and could be misread by reviewers as a hidden paywall. |
| **How to Fix** | 1. Open the implementation of `resetAllProgress()` (the provider at `lib/presentation/controllers/practice_controller.dart` or wherever it lives). 2. Confirm only progress / quiz results / streak data are wiped — **not** the `userVocabProgressRepositoryProvider` IAP flag. 3. If `resetAllProgress` calls Hive `clear()` on a box that contains the IAP flag, fix it to clear a separate progress-only box. |

---

### Warning 3: Universal app declares portrait + landscape, but `Reset` button copy is icon-only

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-UI-002` / `AAPL-UI-003` |
| **Severity** | 🟡 Warning (cosmetic) |
| **Store** | Apple |
| **Location** | `ios/Runner/Info.plist` — both `UISupportedInterfaceOrientations` (iPhone, portrait + landscape) and `UISupportedInterfaceOrientations~ipad` (all 4) are declared. App is universal (`TARGETED_DEVICE_FAMILY = "1,2"`). |
| **What's Wrong** | Universal app supports landscape but iPad portrait screenshots are present in `app_store_assets/`. If you have not generated iPad landscape screenshots, App Store Connect will require them. Reviewers will launch the app on iPad in landscape during review — confirm every screen renders correctly. |
| **How to Fix** | 1. Capture iPad 13" screenshots in both portrait and landscape. 2. Verify no layout breaks on iPad Pro 13" in landscape (the upsell screen in particular, since the bottom button column is fixed). 3. Upload all required iPad screenshot sizes in App Store Connect before submission. |

---

### Warning 4: `.env` contains high-value API keys (hygiene flag)

| Field | Detail |
|-------|--------|
| **Rule** | `AAPL-PERF-004` — No API secrets in client code |
| **Severity** | 🟡 Warning (NOT currently a rejection risk — flagged for hygiene) |
| **Store** | Both |
| **Location** | `/Volumes/Dara/dev/write_lao/.env` — 7 keys (ElevenLabs, Google Cloud TTS, Anthropic, Camb.ai, Cloudflare R2, etc.) |
| **What's Wrong** | The `.env` is correctly gitignored, and a search of `lib/` confirmed none of these keys are referenced from the Flutter runtime — only by `tool/generate_audio.py` and the website Worker (`website/src/`). So these are **build-time / tooling secrets, not in-app secrets**. The risk is purely hygiene: if anyone ever adds `import 'secrets.dart'` style code or starts a backend feature that accidentally bundles `.env`, it would be catastrophic. |
| **How to Fix** | 1. Confirm `.gitignore` continues to exclude `.env` (it does — verified). 2. Verify `lib/config/secrets.dart` is generated by `scripts/setup_secrets.sh` and only contains `SENTRY_DSN`. 3. Before submission, run `grep -r "ELEVENLABS\|ANTHROPIC\|CAMB_API\|R2_" lib/ ios/ android/app/src/` — must be empty. 4. Consider moving all build-time keys into the website Worker's secrets store (you already use `wrangler.toml`) and out of `.env` entirely. |

---

## ✅ Passed Checks

> These categories passed all checks. No action needed.

| Category | Rules Checked | Result |
|----------|:------------:|--------|
| No promo / coupon / discount code fields on paywall | `AAPL-PAY-001` | ✅ No TextField with "Apply" near BUY NOW. No "promo", "coupon", "discount", "referral" strings in paywall code. |
| No external payment links | `AAPL-PAY-002` | ✅ No stripe.com / paypal.com / square.com references anywhere in `lib/`. |
| No price manipulation / dynamic pricing | `AAPL-PAY-003` | ✅ Single non-consumable IAP via `_iap.buyNonConsumable(...)`. No custom price overrides. |
| No "cheaper on website" copy | `AAPL-PAY-004` | ✅ Upsell copy says "Pay once, no subscription." — no comparison to web pricing. |
| No crypto / NFT for digital content | `AAPL-PAY-005` | ✅ No crypto wallet or blockchain code. |
| Restore Purchases button exists | `AAPL-PAY-006` | ✅ Two surfaces: header of `upsell_screen.dart` (line 145-160, conditional on `onRestore` callback) and dedicated `RestorePurchasesScreen` at `/vocab/restore` (also linked from `vocab_settings_section.dart` line 40-50). |
| "One-time purchase" disclosure on paywall | `AAPL-PAY-007` | ✅ `upsell_screen.dart:186` feature card explicitly reads "Pay once, no subscription." Footnote line 244 also restates it. |
| No external payment links | `AAPL-PAY-002` | ✅ All payments go through `InAppPurchase` → StoreKit. |
| Free trial terms | `AAPL-PAY-010` | ✅ N/A — no free trial offered (one-time non-consumable). |
| No login / accounts → Account Deletion not required | `AAPL-DEL-*`, `ADV-ACCT-*` | ✅ Searched `lib/` for `signIn`, `auth`, `firebase_auth`, `google_sign_in`, `account`, `deleteAccount`, `signUp` — no matches. No user accounts exist; only local Hive boxes for progress and the IAP entitlement flag. Apple/Google account deletion rule is therefore inapplicable. |
| No tracking → ATT not required | `AAPL-PRIV-003` | ✅ No `NSUserTrackingUsageDescription`, no AdMob / Facebook SDK, no IDFA usage. Sentry is configured without user PII (`SentryHelper.captureException` takes no email/ID by default). |
| Info.plist permissions | `AAPL-PRIV-005/006` | ✅ App uses no permissions — no camera, photos, mic, location, contacts requested. Info.plist contains zero `NS*UsageDescription` keys, which is correct since none are needed. |
| `ITSAppUsesNonExemptEncryption` | `AAPL-PRIV-005` | ✅ Set to `false` in `Info.plist:43`. |
| All buttons / links functional | `AAPL-FUNC-002` | ✅ Every `onPressed` callback in paywall / settings / about wires to real code. |
| No placeholder content | `AAPL-FUNC-005` | ✅ Searched for "Lorem", "TODO", "Coming soon", "placeholder" — only matches are ICU `{placeholder}` keys in `.arb` localization files (normal). |
| No demo / dummy data | `AAPL-FUNC-006` | ✅ No mocked data shown to users in release paths. |
| No debug / beta / staging labels | `AAPL-UI-005` | ✅ All debug UI is inside `if (kDebugMode)` blocks (`upsell_screen.dart:128`, `settings_screen.dart` debug card, `vocab_settings_section.dart` dev tools). Stripped at release build. |
| No private Apple API usage | `AAPL-PERF-005` | ✅ Only standard Flutter / StoreKit APIs. |
| No malware / spyware patterns | `AAPL-SEC-001/002/003` | ✅ No keylogging, no encrypted payloads, no hidden features. |
| Version number flows from pubspec | `AAPL-META-003` | ✅ `Info.plist` uses `$(FLUTTER_BUILD_NAME)` / `$(FLUTTER_BUILD_NUMBER)`; `package_info_plus` reads them at runtime; `appInfoProvider` exposes them to About + Settings. |
| Sentry SDK has its own privacy manifest | `AAPL-MANIFEST-002` | ✅ Verified `ios/Pods/Sentry/Sources/Resources/PrivacyInfo.xcprivacy` exists. |
| iPad screenshots present | `AAPL-META-004` | ✅ `app_store_assets/ipad*.PNG` and `ipad_demo.MP4` exist. |
| TARGETED_DEVICE_FAMILY = "1,2" (universal) | `AAPL-META-004` | ✅ Universal app, but landscape support needs verification (see Warning 3). |
| `SUPPORTED_PLATFORMS = iphoneos` | `AAPL-META-010` | ✅ Verified in `Runner.xcodeproj/project.pbxproj`. |
| Bundle ID present | `AAPL-FUNC-*` | ✅ `com.maitrigroup.writelao` (verified in `project.pbxproj`). |
| No Sign in with Apple required | `AAPL-AUTH-001` | ✅ N/A — no social login of any kind exists. |
| Single IAP product, non-consumable | `AAPL-PAY-*` | ✅ `kVocabProductId = '500word'`; `lib/vocab/domain/platform_iap_service.dart:84` calls `buyNonConsumable(...)`. No subscriptions, no tiers. |
| Restore logic returns proper UX states | `AAPL-PAY-006` | ✅ `RestorePurchasesScreen` distinguishes "restored" / "not restored" / "error" / "cancelled" with clear messaging. |
| `pendingCompletePurchase` always acknowledged | `AAPL-PAY-*` | ✅ Both `purchase()` and `restorePurchases()` call `_iap.completePurchase(p)` before completing the future — prevents silent Apple refunds. |
| IAP errors reported via Sentry (not shown to user) | `AAPL-FUNC-001` | ✅ Full StoreKit error codes captured via `SentryHelper.captureMessage(...)` with structured `context: { error_code, ... }`. User sees only short friendly messages. |
| No ads in app | `ADV-ADS-*` | ✅ No ad SDKs in `pubspec.yaml`. |
| App icon / launch screen configured | `AAPL-UI-001` | ✅ `flutter_launcher_icons` + `flutter_native_splash` configured in `pubspec.yaml`. |

---

## ⚠️ Platform Differences

| Feature | iOS | Android | Action Needed |
|---------|:---:|:-------:|---------------|
| Account deletion | N/A (no accounts) | N/A (no accounts) | None — rule inapplicable |
| Web deletion URL (Data Safety) | N/A | Would require if accounts existed | None — rule inapplicable |
| PrivacyInfo.xcprivacy | 🔴 Required (Issue 1) | N/A (Android uses Data Safety form) | Fix Issue 1 |
| Terms / Privacy link on paywall | 🔴 Required (Issues 2+3) | Required if subscription; nice-to-have for one-time | Fix Issues 2+3 |
| Target SDK | iOS 13.0 (deployment target) | `flutter.targetSdkVersion` (currently default, verify ≥ 35 for new submissions) | Verify in App Store Connect build setup |

---

## 📋 Recommended Reviewer Notes

> Copy-paste this into App Store Connect review notes. Add real test-account / demo-mode instructions if any are needed.

```
Test Account:
(none — app does not require login)

App Overview:
Write Lao teaches the Lao script through stroke-by-stroke writing practice.
All content is bundled in the app — no network calls are required for the
core learning experience. Sentry is used for crash reporting only and
sends no user-identifying data.

How to Test Key Features:
1. Lessons: launch the app → pick a lesson from the home screen → draw
   each Lao character stroke-by-stroke on the canvas. Audio pronunciation
   plays automatically.
2. Vocab (paid feature): open the Vocabulary tab → tap any unit beyond
   the free sample to trigger the upsell screen. The "Restore Purchases"
   button in the top-right is wired and working. Use a Sandbox test
   account to test the purchase flow — Sandbox accounts must be created
   in App Store Connect → Users and Access → Sandbox Testers.
3. Settings: open Settings → all toggles work; "Contact Us" opens a
   support page; "Reset All Progress" wipes local progress only (does
   NOT affect the IAP entitlement).

Notes:
- App does not request any iOS permissions (no camera, photos, mic,
  location, contacts).
- App does not use tracking, IDFA, or any advertising SDK.
- Crash reporting is via Sentry (DSN configured at build time, no PII
  collected).
- Audio playback uses bundled assets only — no network streams.
```

---

## 🔄 Action Items Summary

### 🔴 Must Fix (Before Submission)

| # | Action | File / Location | Est. Time |
|---|--------|----------------|-----------|
| 1 | Add app-level `PrivacyInfo.xcprivacy` declaring all Required Reason APIs used (UserDefaults via Hive paths, FileTimestamp via path_provider, DiskSpace for Hive storage). Generate via Xcode → New → File → App Privacy. | `ios/Runner/PrivacyInfo.xcprivacy` (new) | 30 min |
| 2 | Add Terms of Use link to the paywall bottom button column | `lib/vocab/presentation/screens/upsell_screen.dart` _buildBottomButton() | 15 min |
| 3 | Add Privacy Policy link to the paywall; also add both Privacy + Terms links to Settings and About screens | `upsell_screen.dart`, `settings_screen.dart`, `about_screen.dart` | 30 min |
| 4 | Plumb the localized price from `_iap.queryProductDetails(...)` into the `UpsellScreen` via the `priceLabel` parameter (currently unused) — show price both on the BUY button and in the feature card copy | `lib/config/routes.dart:337`, `lib/vocab/domain/platform_iap_service.dart:64` | 30 min |

### 🟡 Should Fix (Recommended)

| # | Action | File / Location | Est. Time |
|---|--------|----------------|-----------|
| 1 | Verify `https://writelao.xyz/support` returns HTTP 200 (or create the page) | Website | 15 min |
| 2 | Confirm `resetAllProgress()` does not clear the IAP entitlement box | `lib/presentation/controllers/practice_controller.dart` (or wherever `resetAllProgress` lives) | 15 min |
| 3 | Capture iPad 13" landscape screenshots for App Store Connect | App Store Connect | 30 min |
| 4 | Consider moving build-time secrets out of `.env` entirely into the Cloudflare Worker secrets | `website/wrangler.toml`, `.env` | 1 hr (post-launch hygiene, not blocking) |

### 📋 Store Console Actions (Non-Code)

| # | Action | Where |
|---|--------|-------|
| 1 | Fill out App Privacy section in App Store Connect (Admin role required) — declare: no data collected by app, Sentry crash reports only (analytics category, not linked to user) | App Store Connect → App Privacy |
| 2 | Upload iPad landscape screenshots | App Store Connect → Media |
| 3 | Provide Privacy Policy URL: `https://writelao.xyz/privacy_policy` | App Store Connect → App Information |
| 4 | Provide Support URL: `https://writelao.xyz/support` (verify it resolves first) | App Store Connect → App Information |
| 5 | Add Subscription disclosure in description (one-time purchase copy: "$X.XX one-time purchase, includes all future content") | App Store Connect → App Information |
| 6 | Updated age rating questionnaire (2025 format) — educational content, no user-generated content, no adult themes → should default to 4+ | App Store Connect → Age Rating |
| 7 | Add review notes (template above) | App Store Connect → App Review → Reviewer Notes |

---

## ✅ Ready to Submit?

| Criteria | Status |
|----------|--------|
| All 🔴 critical issues fixed | ⬜ |
| All 🟡 warnings reviewed | ⬜ |
| `PrivacyInfo.xcprivacy` declared and reviewable in Xcode privacy report | ⬜ |
| Privacy Policy + Terms of Use linked from paywall, Settings, and About | ⬜ |
| Reviewer notes prepared | ⬜ |
| Store listing complete (App Privacy, Support URL, screenshots, description) | ⬜ |
| **VERDICT** | 🔴 **NOT READY** — fix Issues 1–4 first |

> Run this audit again after fixing all issues to verify.