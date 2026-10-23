# Write Lao — Flutter/Dart Code Audit

Audit date: 2026-09-28
Scope: `lib/`, `pubspec.yaml`, `l10n.yaml`, `analysis_options.yaml`
Method: full read of the majority of `lib/`, `flutter analyze` run, data-bundle inspection with Python.

---

## 1. Codebase map

**Entry point:** `lib/main.dart` → `SentryFlutter.init(appRunner: _runApp)` → `lib/app.dart`
(`WriteLaoApp`, a `MaterialApp.router`). Orientation lock, Sentry init, and Hive box opening all
happen in `main.dart` before `runApp`.

**Routing:** `lib/config/routes.dart` — go_router, one `CustomTransitionPage` per route, with a
`SentryNavigatorObserver`.

**State management:** Riverpod (flutter_riverpod 2.5 + riverpod_annotation 2.3). Mixed style:
hand-written `StateNotifierProvider`s for the alphabet feature (`practice_controller.dart`,
`canvas_controller.dart`, `test_controller.dart`, `settings_screen.dart`) and plain `Provider` /
`FutureProvider` for the vocab feature (`lib/vocab/providers.dart`). No `@riverpod` codegen is
actually used despite the dependency. No `AsyncNotifier` anywhere.

**Domain layering (alphabet feature):**
- `lib/data/` — static character DB (`lao_characters.dart`), lesson definitions, Hive-backed
  progress (`progress_local_datasource.dart`, `progress_repository.dart`, `progress_hive_adapters.dart`).
- `lib/domain/stroke_matching/` — DTW + stroke matching (`stroke_matcher.dart`, `dtw.dart`, `path_utils.dart`).
- `lib/presentation/` — screens, controllers, canvas widgets.
- `lib/utils/svg_parser.dart` + `tool/svg_to_json.dart` — authoring pipeline (SVG → stroke JSON).

**Domain layering (vocab feature):** `lib/vocab/{data,domain,presentation,providers.dart}`.
Freezed + json_serializable models, Hive TypeAdapters, SM-2 SRS (`srs.dart`), lesson planner
(`lesson_engine.dart`), IAP (`platform_iap_service.dart`).

**Key packages (pubspec.yaml):** `flutter_riverpod`, `hive` + `hive_flutter`, `path_provider`,
`audioplayers`, `flutter_svg`, `google_fonts`, `freezed_annotation` + `json_annotation`,
`go_router`, `sentry_flutter`, `in_app_purchase`, `url_launcher`, `in_app_review`,
`package_info_plus`, `uuid`, `intl`, `flutter_localizations`.
Note: **no `characters` package** and **no `fonts:` section**.

**Text input surfaces (there are only three, all deck naming):**
- `lib/vocab/presentation/screens/my_decks_screen.dart:44` (create) and `:73` (rename)
- `lib/vocab/presentation/widgets/deck_picker_sheet.dart:48` (create from outro card)

**Lao text rendering surfaces:**
- `lib/presentation/widgets/character_card.dart` (grid cells, lesson preview)
- `lib/presentation/screens/practice_screen.dart`, `test_screen.dart` (header glyph)
- `lib/presentation/screens/review_screen.dart`, `practice_complete_screen.dart`,
  `result_screen_widgets.dart`, `lesson_detail_screen.dart`
- `lib/vocab/presentation/widgets/word_progress_strip.dart` (the per-character build-up strip)
- `lib/vocab/presentation/widgets/word_card_base.dart` (headword + example sentences)
- `lib/vocab/presentation/screens/lesson_list_screen.dart:206` (word preview line)
- `lib/config/theme.dart` (the only place `GoogleFonts.notoSansLao` is called — and it is dead)

**Storage:** Hive, six boxes. `character_progress`, `lesson_progress` (alphabet) and
`user_word`, `user_progress`, `user_session`, `flag_deck`, `flag_deck_word`, `preferences`
(vocab). Opened in `main.dart` / `openVocabBoxes()`.

**Fonts:** No font is bundled. `fontFamily: 'Noto Lao'` is hardcoded in 12 places; the family is
only ever registered at runtime by `google_fonts`, which this app never actually invokes.

**Localization:** `l10n.yaml` + 16 `.arb` files → generated `lib/l10n/app_localizations*.dart`.
The vocab feature is almost entirely hardcoded English and bypasses l10n completely.

**Data bundle:** `assets/vocab/course.json` — 500 words, 16 translations each, per-word
pre-segmented `characters[]` array with a `type` of consonant/vowel/tone.

---

## 2. Issues

### Lao Text & Unicode

---

**ID: E001**
**File:** `lib/vocab/presentation/widgets/word_progress_strip.dart`
**Location:** lines 64–75 (loop building `spans`)
**Severity:** Critical
**Category:** Lao Text
**Description:** The "don't add a space before a combining mark" guard keys off the *next*
character's `type`, but the bundle classifies Lao **pre-base** vowels (`ເ ແ ໂ ໃ ໄ`, U+0EC0–U+0EC4)
as `type: "vowel"`, not as marks. Since a pre-base vowel is followed by a *consonant*, the guard
sees `consonant` and inserts a space, splitting the syllable in half.
**Evidence:**
```dart
final nextType = characters[i + 1].type;
final nextIsCombining =
    nextType == CharacterType.vowel || nextType == CharacterType.tone;
if (!nextIsCombining) {
  spans.add(TextSpan(text: ' ', style: base));
}
```
**Impact:** Word `w_0001` is `ແ ລ ະ` (ແ / ລ / ະ). The strip renders `ແ ລະ` — the ແ detaches
from ລ and renders as a floating pre-base vowel. Every word beginning with a pre-base vowel
(~most short Lao words) shows a broken syllable in the practice header, which is the single
most-looked-at element of the whole vocab flow.
**Suggested fix direction:** Never insert a separator between a character and the next one if
either is a non-spacing mark *or* a pre-base/spacing dependent vowel. Classify by Unicode
category/range (U+0EC0–U+0EC4, U+0EBD, U+0EB0–U+0EBC are dependent vowels) rather than trusting
the bundle's 3-way `type`.
**Confidence:** High

---

**ID: E002**
**File:** `lib/presentation/widgets/character_card.dart`
**Location:** line 150, `LessonCard._content`
**Severity:** High
**Category:** Lao Text
**Description:** `characterPreviews.take(8).join('  ')` unconditionally inserts two spaces between
every character in the lesson preview, with no combining-mark awareness at all.
**Evidence:**
```dart
final charPreview = characterPreviews.take(8).join('  ');
```
**Impact:** Phase 2 is 15 vowel components and Phase 3 is 4 tone marks. The previews for those
lessons render as `◌ິ  ◌ີ  ◌ຶ  ◌ື  ◌ຸ …` — a row of detached dotted circles. Even for consonant
lessons the marks are split from their bases. The user cannot tell which mark belongs to which
consonant, which defeats the purpose of the preview.
**Suggested fix direction:** Share one "render a character sequence" helper between this widget
and `word_progress_strip.dart` that applies a single spacing rule, and use it everywhere Lao
sequences are displayed.
**Confidence:** High

---

**ID: E003**
**File:** `lib/data/datasources/course_content_datasource.dart`
**Location:** lines 147–154, `CourseContentValidator.validate`
**Severity:** High
**Category:** Lao Text / Storage
**Description:** The validator checks that `characters` is non-empty and that asset paths resolve,
but never checks that concatenating `characters[i].character` reproduces `lao_word`. I verified
the shipped bundle: **`w_0490` declares `lao_word: "ງ່າຍໆ"` but its `characters` array is
`['ງ','່','າ','ຍ']`** — the repetition mark U+0EC6 (`ໆ`) is missing, so the join is `ງ່າຍ`.
**Evidence:**
```dart
if (w.characters.isEmpty) {
  errors.add('Word ${w.wordId} has no characters');
}
// no join-vs-laoWord consistency check anywhere
```
**Impact:** For `w_0490` the progress strip and the per-character practice flow silently drop the
final `ໆ` — the user writes `ງ່າຍ` and never practises the repetition mark that makes the word
different from a real word. It also means the segmenter silently accepts future regressions.
**Suggested fix direction:** Add a validator rule asserting `characters.map((c) => c.character).join() == lao_word`,
and fix `w_0490` by adding the `ໆ` entry.
**Confidence:** High

---

**ID: E004**
**File:** `lib/data/models/lao_character.dart`
**Location:** lines 30–36, `LaoCharacter.isCombining`
**Severity:** Medium
**Category:** Lao Text
**Description:** The combining-mark test only covers U+0EB4–U+0EBC and U+0EC8–U+0ECB, and uses
`codeUnitAt(0)` rather than a grapheme-aware check. It misses U+0EB0 (sara a), U+0EB1 (mai kan),
U+0EB3 (sara am), U+0EBD (sara ia) and U+0ECD (niggahita), all of which are dependent vowels.
**Evidence:**
```dart
final cp = char.codeUnitAt(0);
return (cp >= 0x0EB4 && cp <= 0x0EBC) || (cp >= 0x0EC8 && cp <= 0x0ECB);
```
**Impact:** `displayChar` (used by the lesson preview) will render a bare `ະ`/`ຳ`/`ັ` with no
dotted-circle base instead of `◌ະ`, which looks like a missing glyph.
**Suggested fix direction:** Centralise the Lao block classification in one helper
(`bool isLaoCombiningMark(int cp)`, `bool isLaoPreBaseVowel(int cp)`) covering U+0E80–U+0EFF and
use it from the model, the strip, and the canvas host.
**Confidence:** High

---

**ID: E005**
**File:** `lib/vocab/presentation/widgets/stroke_canvas_host.dart` (also `character_practice_card.dart:69-72`, `character_test_card.dart:75`)
**Location:** `_codepointFor` / `_codepointString`
**Severity:** Medium
**Category:** Lao Text
**Description:** `glyph.runes.first` silently takes the first code point of whatever string it is
handed. If a `WordCharacter.character` ever contains a multi-code-point cluster, the app looks up
the base consonant's stroke data and treats the mark as a standalone card.
**Evidence:**
```dart
final cp = glyph.runes.first;
return cp.toRadixString(16).toUpperCase().padLeft(4, '0');
```
**Impact:** Latent. Today the bundle only contains single-code-point characters (I verified all
500 words), so this is not firing — but E003 shows the segmenter is already producing lossy output,
and a future bundle edit could trigger it silently with no error.
**Suggested fix direction:** Validate at the validator level that each `character` is exactly one
code point and is in U+0E80–U+0EFF; make the lookup return `null` (and surface a Sentry message)
rather than silently truncating.
**Confidence:** Medium (no current bundle triggers it; severity would jump to High if it did)

---

**ID: E006**
**File:** (project-wide)
**Location:** all text entry points and all bundle loaders
**Severity:** Medium
**Category:** Lao Text
**Description:** There is no Unicode normalization anywhere — not on user-entered deck names, not
on loaded strings, not before persisting. The `characters` package is not a dependency, so nothing
in the app is grapheme-cluster aware.
**Evidence:** `grep -rn "characters" lib/ pubspec.yaml` returns only the `WordCharacter` model; no `package:characters` import exists.
**Impact:** For the alphabet's own content this is mostly benign (all Lao combining marks live in
U+0E80–U+0EFF and are not re-ordered by NFC). The real exposure is user-entered Lao deck names
and any future paste/search feature: a name typed as consonant+mark in non-canonical order will
not compare equal to the same name in canonical order, and the same deck can be created twice.
**Suggested fix direction:** Normalize on ingest (`name.trim()` → NFC-normalize) in
`FlagDeckRepository.createDeck` / `renameDeck`, and add a uniqueness check on the normalized name.
**Confidence:** Medium

---

**ID: E007**
**File:** `lib/vocab/data/datasources/course_content_datasource.dart`
**Location:** lines 52–63, `CourseContentDataSource.load`
**Severity:** Low
**Category:** Lao Text / Storage
**Description:** `loadString` is `rootBundle.loadString`, which decodes UTF-8 by contract, and the
JSON path is fine. However, `jsonDecode(raw) as Map<String, dynamic>` will throw an opaque
`type 'Null' is not a subtype of type 'Map<String, dynamic>'` on a malformed bundle rather than a
useful message, and the raw string is never NFC-normalized before parsing.
**Evidence:**
```dart
final raw = await loadString(coursePath);
final json = jsonDecode(raw) as Map<String, dynamic>;
```
**Impact:** A corrupted or truncated `course.json` in a release build produces a bare cast error
on the loading screen instead of a diagnosable message.
**Suggested fix direction:** Wrap in a typed catch that rethrows as `CourseValidationException`
with the file name and parse offset.
**Confidence:** Medium

---

**ID: E008**
**File:** (project-wide)
**Location:** —
**Severity:** Low (informational)
**Category:** Lao Text
**Description:** I checked for Lao-aware collation and found none to fix: every `sort()` in the
codebase is on `DateTime` or `double`, never on a Lao string. There is no search, no spell check,
no word-count, and no word-selection UI, so Lao word segmentation is genuinely not exercised yet.
Lao numerals (U+0ED0–U+0ED9) appear only as alphabet-teaching content in `lao_characters.dart`;
all counters (`'${lesson.newWordIds.length} new'`, `'${state.currentIndex + 1} / …'`) use ASCII
digits consistently. Both are correct-but-inconsistent with a Lao locale.
**Impact:** No current defect. If a search or "saved words" count is added later, plain
`String.contains` will silently fail for Lao because there are no word spaces.
**Suggested fix direction:** Note the constraint in a doc comment on the models so the next
feature doesn't reach for `split(' ')`.
**Confidence:** High (that the pattern is absent)

---

### Fonts & Rendering

---

**ID: E009**
**File:** `pubspec.yaml`
**Location:** `flutter:` block — there is no `fonts:` key at all
**Severity:** Critical
**Category:** Fonts/Rendering
**Description:** The app asks for `fontFamily: 'Noto Lao'` in 12 files but bundles no fonts and
declares none under `flutter: fonts:`.
**Evidence:**
```yaml
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/stroke_data/
    # no fonts: section
```
**Impact:** `'Noto Lao'` is only a real family name if `google_fonts` has downloaded and registered
Noto Sans Lao at runtime. On a cold start, on a device with no network, on web before the async
font fetch resolves, or on any platform where `allowRuntimeFetching` is disabled, every Lao glyph
in the app falls back to the platform default — which on Android is Roboto (no Lao coverage in the
app's font set) and on Linux/Windows is whatever fontconfig picks. Result: tofu boxes, or Lao
rendered in an arbitrary system font with wrong mark positioning.
**Suggested fix direction:** Bundle `NotoSansLao-Regular.ttf` / `-Bold.ttf` under
`assets/fonts/`, declare them in `pubspec.yaml` with `family: Noto Lao`, and set
`GoogleFonts.config.allowRuntimeFetching = false` so the failure is impossible.
**Confidence:** High

---

**ID: E010**
**File:** `lib/config/theme.dart`
**Location:** lines 142–155 (`laoTextStyle`, `laoTextStyleLarge`, `laoTextStyleSmall`)
**Severity:** High
**Category:** Fonts/Rendering
**Description:** These three getters are the *only* calls to `GoogleFonts.notoSansLao` in the
entire codebase, and they are referenced by nothing — not in `lib/`, not in `test/`.
**Evidence:**
```dart
static TextStyle get laoTextStyle => GoogleFonts.notoSansLao(fontSize: 24, ...);
```
`grep -rn "laoTextStyle" lib/ test/ | grep -v theme.dart` → no results.
**Impact:** This is what makes E009 *guaranteed* rather than merely likely. `google_fonts`
registers a family as a side effect of constructing a `TextStyle` from it. Because nothing ever
constructs one, the runtime registration never happens, so the 12 `fontFamily: 'Noto Lao'`
references always resolve to a missing family.
**Suggested fix direction:** Fixing E009 (bundling) makes this moot. If you keep `google_fonts`,
move the `notoSansLao` call into the `textTheme` so it is evaluated at app start.
**Confidence:** High

---

**ID: E011**
**File:** `lib/vocab/presentation/widgets/word_card_base.dart`
**Location:** lines 238–241 (headword) and 386–389 (example sentence)
**Severity:** High
**Category:** Fonts/Rendering
**Description:** The vocab headword `word.laoWord` and the example sentence `example.laoScript` —
the largest Lao text in the entire app — are rendered with `theme.textTheme.displayMedium` and
`titleLarge`, both of which are `GoogleFonts.inter`. Inter has no Lao coverage, and the theme
declares no `fontFamilyFallback`.
**Evidence:**
```dart
Text(
  widget.word.laoWord,
  style: theme.textTheme.displayMedium,   // GoogleFonts.inter, no Lao, no fallback
)
```
**Impact:** The two most prominent strings on the intro/outro cards render in a different typeface
and a different mark-positioning engine than the same word rendered by `WordProgressStrip`
(`'Noto Lao'`) and by the lesson list. Users see the same word in two visual styles, and stacked
tone marks can be clipped differently between screens. On Linux/Windows this is where tofu is
most likely.
**Suggested fix direction:** Add a dedicated `ThemeData.textTheme` entry (or a
`laoDisplay`/`laoBody` pair) carrying `fontFamily: 'Noto Lao'` with a `fontFamilyFallback`, and use
it for every Lao string rather than per-widget `fontFamily` literals.
**Confidence:** High

---

**ID: E012**
**File:** `lib/config/theme.dart`
**Location:** line 157, `AppTheme.lightTheme` getter
**Severity:** Medium
**Category:** Fonts/Rendering / Performance
**Description:** `lightTheme` is a getter, not a cached field, and it constructs an entire
`ThemeData` — including 11 `GoogleFonts.*` calls, each of which does a font-availability lookup
and can kick off an async download — on every access.
**Evidence:**
```dart
static ThemeData get lightTheme {
  return ThemeData( ... GoogleFonts.inter(...) x11 ... );
}
```
**Impact:** `lib/app.dart:14` accesses it once per `WriteLaoApp` build, which is cheap today.
Any future `Theme.of(context)`-adjacent helper or widget that reads `AppTheme.lightTheme`
(rebuilding it, e.g. for a settings "theme" toggle) will silently re-run the whole thing.
**Suggested fix direction:** Make it `static final ThemeData lightTheme = _buildLightTheme();`.
**Confidence:** High

---

**ID: E013**
**File:** `lib/presentation/screens/practice_screen.dart` (also `test_screen.dart:289-292`)
**Location:** lines 242–245, `_buildHeader`
**Severity:** Medium
**Category:** Fonts/Rendering
**Description:** The hero Lao glyph uses a hardcoded, screen-height-derived font size with
`height: 1.0`, inside a `SizedBox` of fixed height.
**Evidence:**
```dart
fontSize: ((headerH - 12) * 0.80).clamp(72.0, 104.0),
height: 1.0,
```
**Impact:** Two problems. (1) `height: 1.0` on a Noto Sans Lao run with stacked tone marks clips
the ascenders of `່ ້ ໊ ໋` — this is exactly the "clipped diacritics from tight line heights" case.
(2) The size is computed from `MediaQuery` *pixel* height and ignores `MediaQuery.textScaler`, so
a user at 200% system text size still gets a 72–104px glyph, and a user at 50% gets the same
72–104px glyph. The size is also not exposed as a setting.
**Suggested fix direction:** Use `height: 1.4` (or leave it unset) so the mark ascenders have
room, and derive the size from the scaled font size rather than raw pixels.
**Confidence:** High

---

**ID: E014**
**File:** `lib/presentation/widgets/character_card.dart`
**Location:** lines 40–67
**Severity:** Medium
**Category:** Fonts/Rendering
**Description:** `displayChar` is rendered at `fontSize: 32` inside a `Container(width: 60, height: 60)`
with no `height` override and no clipping control, and combining characters get the `◌` dotted
circle prepended.
**Evidence:**
```dart
Container(
  width: 60, height: 60,
  child: Center(child: Text(
    isAvailable ? character.displayChar : '🔒',
    style: TextStyle(fontFamily: 'Noto Lao', fontSize: 32, ...),
  )),
),
```
**Impact:** At `textScaler` 1.5+ the 32sp glyph grows to 48sp and overflows the 60px circle,
producing a `RenderFlex`/`RenderBox` overflow stripe in the lesson grid. The 60px box is also
below the 48dp minimum tap target when several cards are packed into a grid row.
**Suggested fix direction:** Size the circle from the scaled text size (or clamp the text with
`FittedBox`) and raise the tap-target floor.
**Confidence:** Medium

---

**ID: E015**
**File:** `lib/vocab/presentation/screens/lesson_list_screen.dart`
**Location:** line 206
**Severity:** Medium
**Category:** Fonts/Rendering
**Description:** The lesson row's Lao word preview uses the default text style (Inter) and joins
words with `' · '`.
**Evidence:**
```dart
final preview = words.map((w) => w.laoWord).join(' · ');
```
**Impact:** Same font-mismatch problem as E011, in the lesson list — a word that renders in Noto
Lao inside the lesson will render in a fallback font on the list row that links to it. There is
also no `maxLines`/`overflow` on the resulting subtitle, so a lesson with many new words produces
a tall, ragged row.
**Suggested fix direction:** Apply the shared Lao text style and add `maxLines: 1, overflow: ellipsis`.
**Confidence:** Medium

---

**ID: E016**
**File:** (project-wide — no `GoogleFonts.config` call exists)
**Location:** `lib/main.dart` is where it would go
**Severity:** Medium
**Category:** Fonts/Rendering / Platform
**Description:** `google_fonts` defaults to `allowRuntimeFetching = true`, so with no bundled font
(E009) every cold start issues a network request to `fonts.gstatic.com` for Inter and Noto Sans
Lao before any Lao text can render.
**Evidence:** `grep -rn "GoogleFonts.config" lib/` → no results.
**Impact:** First paint shows fallback or tofu; offline launches never recover; the app makes
third-party network calls on every launch with no user-visible disclosure. It also makes
CFBundleIdentifier network traffic in a kids' education app a review flag on iOS.
**Suggested fix direction:** Bundle the fonts (E009) and call
`GoogleFonts.config.allowRuntimeFetching = false` in `main()`.
**Confidence:** High

---

### Input / Editing

There is no custom keyboard, no IME/composing-text handling, and no undo/redo or clipboard code in
this app — the only text entry is deck naming. The relevant issues are the three below.

---

**ID: E017**
**File:** `lib/vocab/presentation/screens/my_decks_screen.dart`
**Location:** line 44 (`_createDeck`) and line 73 (`_renameDeck`)
**Severity:** Medium
**Category:** Memory / Input-Editing
**Description:** `TextEditingController` is constructed as a local variable inside the async
dialog methods and is never disposed.
**Evidence:**
```dart
Future<void> _createDeck() async {
  final controller = TextEditingController();
  final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
    content: TextField(controller: controller, ...), ...));
  if (name == null || name.isEmpty) return;   // controller leaks here
  ...
}
```
**Impact:** Every create and every rename leaks an undisposed `ChangeNotifier`. `TextEditingController`
holds a `TextEditingValue` and an internal listener list; over a long session with many deck
edits this is a slow leak, and it also keeps the dialog's `TextField` reachable until GC.
Note `_newDeckController` in `deck_picker_sheet.dart:48` **is** correctly disposed at line 60 —
these two sites are the outliers.
**Suggested fix direction:** Convert to a small `_DeckNameDialog` StatefulWidget that owns and
disposes its controller, or wrap in `try/finally { controller.dispose(); }`.
**Confidence:** High

---

**ID: E018**
**File:** `lib/vocab/presentation/widgets/deck_picker_sheet.dart` (and `my_decks_screen.dart`)
**Location:** line 77 (`_createAndFlag`), `TextField` at 152–160
**Severity:** Low
**Category:** Input-Editing / Lao Text
**Description:** The category-name field has no `maxLength`, no `inputFormatters`, no
`TextCapitalization` policy, and no duplicate check against `_decks`.
**Evidence:**
```dart
final name = _newDeckController.text.trim();
if (name.isEmpty) return;
final newDeck = widget.onCreateAndFlag(name);
```
**Impact:** A user can create "Food", "food", and "food " as three separate categories (only
whitespace is trimmed, and the comparison is case- and NFC-unaware — see E006). A very long name
overflows the `Expanded` TextField. Neither is a crash, but for a screen users build over months
it produces a messy list.
**Suggested fix direction:** Add `maxLength`, reject duplicates case-insensitively on the
normalized name, and set `textCapitalization: TextCapitalization.sentences`.
**Confidence:** High

---

**ID: E019**
**File:** `lib/presentation/screens/review_screen.dart` (line 184), `my_decks_screen.dart` (line 152), `deck_picker_sheet.dart` (line 128)
**Severity:** Medium
**Category:** Fonts/Rendering
**Description:** User-entered deck/category names are almost certainly Lao (this is a Lao app),
and all three render them with the default text style — GoogleFonts.inter, no Lao fallback.
**Evidence:**
```dart
Text(deck.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))
```
**Impact:** A category named `ຂອງກິນ` renders in a different font from every other Lao string in the
app, and on platforms without a system Lao fallback (Linux, Windows, web before the font loads)
it renders as tofu boxes. The `_CategoryCard` word list three lines below *does* set
`fontFamily: 'Noto Lao'`, so the same screen mixes two Lao typefaces.
**Suggested fix direction:** Render user-entered names with the same shared Lao style used for
bundle text (see the E011 fix).
**Confidence:** High

---

### Async

---

**ID: E020**
**File:** `lib/vocab/domain/platform_iap_service.dart`
**Location:** line 166, `restorePurchases()` tail
**Severity:** High
**Category:** Async
**Description:** The restore flow unconditionally `await`s a fixed 10-second delay *before*
returning, even when the entitlement was found within the first few hundred milliseconds.
**Evidence:**
```dart
// iOS delivers restored purchases asynchronously and doesn't emit a
// "done" signal on the purchase stream. Give it 10 s; if nothing
// arrives the user has no prior purchase.
await Future.delayed(const Duration(seconds: 10));
await sub.cancel();
if (!completer.isCompleted) {
  completer.complete(const IapNotRestored());
}
return completer.future;
```
**Impact:** A returning customer with a valid purchase always stares at a spinner for a full
10 seconds before the unlock lands. This is the single worst moment in the monetisation funnel.
**Suggested fix direction:** Race the `completer.future` against the timeout
(`Future.any([completer.future, Future.delayed(timeout)])`) so it returns as soon as the
entitlement arrives, and move the timeout into a named constant.
**Confidence:** High

---

**ID: E021**
**File:** `lib/vocab/domain/platform_iap_service.dart`
**Location:** line 167, `purchase()` tail (`return completer.future;`)
**Severity:** Medium
**Category:** Async
**Description:** `purchase()` has no timeout. If StoreKit/Play Billing never emits a terminal
status (a real failure mode for `PurchaseStatus.pending` on iOS, and for interrupted flows), the
returned future never completes, the caller's spinner spins forever, and the
`purchaseStream` subscription is never cancelled.
**Evidence:**
```dart
case PurchaseStatus.pending:
  // StoreKit is processing — keep the listener open.
  break;
...
return completer.future;   // no .timeout(...)
```
**Impact:** Permanent spinner on the upsell screen plus a leaked stream subscription, and the
user has no way forward except killing the app.
**Suggested fix direction:** Apply `.timeout(...)` and cancel the subscription in the timeout
path; surface a "still processing, try again later" message for the pending case specifically.
**Confidence:** Medium (StoreKit pending genuinely does stall in the field; I could not reproduce
it here)

---

**ID: E022**
**File:** `lib/vocab/presentation/screens/vocab_lesson_practice_screen.dart`
**Location:** line 310
**Severity:** Medium
**Category:** Null Safety / Async
**Description:** The course repository is force-unwrapped inside `build` with no error branch.
**Evidence:**
```dart
final course = ref.watch(courseRepositoryProvider).valueOrNull!;
```
**Impact:** `_error` (set at line 113) only covers failures of `lessonEngineProvider`, which
itself awaits the course. If the course future is still pending or errored at the moment the plan
arrives, this line throws inside `build` — a red error screen in release rather than the
`if (_error != null)` Scaffold defined 10 lines above.
**Suggested fix direction:** Handle the `AsyncValue` explicitly (`.when(...)` or an early-return
Scaffold), matching the pattern already used at lines 249 and 301.
**Confidence:** High

---

**ID: E023**
**File:** `lib/vocab/presentation/screens/vocab_lesson_practice_screen.dart`
**Location:** lines 309, 332, 353
**Severity:** Medium
**Category:** Null Safety
**Description:** `_plan!.cards[_cardIndex]` and `value: (_cardIndex + 1) / plan.cards.length`
assume a non-empty card list.
**Evidence:**
```dart
final card = plan.cards[_cardIndex];
...
value: (_cardIndex + 1) / plan.cards.length,
```
**Impact:** `startDeckStudy` (`lesson_engine.dart:341`) can legitimately return an empty card list —
`planDeckStudy` returns `const []` when every word in the deck is `retired`
(`deck_study_planner.dart:27`), and the review flow calls it with `limit: 1000` (line 97).
Opening a category whose words have all been retired then produces a `RangeError` and a
`NaN` progress bar. `_advanceCard` (line 156) also never guards the empty case, so the flow
finishes without ever rendering a card.
**Suggested fix direction:** Early-return an empty-state Scaffold when `plan.cards.isEmpty`, and
guard the progress `value`.
**Confidence:** High

---

**ID: E024**
**File:** `lib/vocab/presentation/screens/vocab_lesson_practice_screen.dart`
**Location:** line 400, `_buildCard`
**Severity:** Medium
**Category:** State / Performance
**Description:** The multiple-choice options are shuffled inside `build`, so the order changes on
every rebuild.
**Evidence:**
```dart
final options = <VocabWord>[word, ...distractors]..shuffle();
```
**Impact:** `HearIdentifyCard` is keyed `ValueKey('hearIdentify-$_cardIndex')` so the State
survives, but any rebuild (orientation change, keyboard, a Riverpod notification from
`vocabStateRevProvider`, an ancestor rebuild) re-shuffles the grid under the user's finger. If
they have already tapped and are waiting out the 1–2s reveal, the correct answer can move
position mid-reveal.
**Suggested fix direction:** Shuffle once when the card is created (in `_initLesson` or when
`_cardIndex` changes) and store the ordered list in state.
**Confidence:** High

---

**ID: E025**
**File:** `lib/vocab/presentation/widgets/stroke_canvas_host.dart`
**Location:** lines 51–76, `_loadStrokeData`
**Severity:** Medium
**Category:** Async
**Description:** `_loadStrokeData` is fired from both `initState` and `didUpdateWidget` with no
in-flight guard or request token.
**Evidence:**
```dart
void didUpdateWidget(covariant RealStrokeCanvasHost oldWidget) {
  if (oldWidget.laoCharacter != widget.laoCharacter) {
    _loadStrokeData();   // no cancellation of a pending load
  }
}
Future<void> _loadStrokeData() async {
  final data = await ds.loadStrokeData(codepoint);
  if (!mounted) return;
  setState(() => _strokeData = data);
}
```
**Impact:** If the user taps Next rapidly through a word's characters, two loads race. The
`CharacterStrokeDataSource` cache means the *reads* are fast, but the `setState` ordering is not
guaranteed — a slow earlier load can land after a later one and put the previous character's
strokes on the current card. When it then returns `null` the card auto-completes
(lines 69–74), so the user can be silently advanced past characters they never drew.
**Suggested fix direction:** Keep a monotonically increasing token and drop results whose token
is stale; optionally `await` the load before enabling the Next button.
**Confidence:** Medium (ordering hazard is real; I could not reproduce a visible flip without
instrumentation)

---

**ID: E026**
**File:** `lib/vocab/presentation/screens/vocab_lesson_practice_screen.dart`
**Location:** lines 124 and 145
**Severity:** Medium
**Category:** State / Async
**Description:** Card outcomes are recorded via `ref.read(lessonEngineProvider).valueOrNull` with
a silent `if (engine != null)` no-op.
**Evidence:**
```dart
void _onWordCompleted(WordOutcome outcome) {
  final engine = ref.read(lessonEngineProvider).valueOrNull;
  if (engine != null) {
    engine.recordCardOutcome(outcome.wordId, cardOutcomeForErrors(outcome.errorCount));
  }
  ...
}
```
**Impact:** Any word completed while the engine future is unresolved (or has errored) has its
result dropped on the floor. SM-2 never advances for that word, so it resurfaces as a permanent
"reviewing" card. There is no log, no Sentry capture, no user-visible signal.
**Suggested fix direction:** Since `_initLesson` already awaited the engine before setting
`_loading = false`, cache the resolved engine in a field and use `!` (or assert) — or capture
Sentry when it is null.
**Confidence:** Medium (the ordering makes it unlikely, but `lessonEngineProvider` is a
`FutureProvider` that can be invalidated, which re-puts it in the loading state)

---

**ID: E027**
**File:** `lib/presentation/screens/practice_screen.dart`
**Location:** lines 34–36 and 50–53
**Severity:** Low
**Category:** Async
**Description:** Lesson loading is deferred into `addPostFrameCallback` and then calls
`AppLocalizations.of(context)` on the State's context from inside that callback.
**Evidence:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  _loadLesson();   // -> AppLocalizations.of(context).reviewTitle  (line 52)
});
```
**Impact:** There is no `await` between the frame and the call, so this is not a true
across-async-gap use today, but it is a latent `use_build_context_synchronously` and it means
the first frame renders an empty canvas before the lesson appears.
**Suggested fix direction:** Read the l10n string in `build` (or capture it before the callback)
and pass it into `_loadLesson` as a parameter.
**Confidence:** Medium

---

**ID: E028**
**File:** `lib/presentation/screens/settings_screen.dart`
**Location:** line 175
**Severity:** Low
**Category:** Async
**Description:** `launchUrl` returns a `Future<bool>` that is neither awaited nor error-checked.
**Evidence:**
```dart
onTap: () => launchUrl(Uri.parse('https://writelao.xyz/support')),
```
**Impact:** If the URL fails to launch (no browser, malformed) the tap is silently swallowed.
**Suggested fix direction:** `await` and show a `SnackBar` on `false`; wrap in
`canLaunchUrl`.
**Confidence:** High

---

### Memory

---

**ID: E029**
**File:** `lib/vocab/presentation/screens/vocab_lesson_practice_screen.dart`
**Location:** lines 140, 240
**Severity:** Low
**Category:** Memory / Async
**Description:** `_audio.stop()` is called without `await` in `_onOutroNext` and inside
`_confirmAbort`, immediately before a possible `dispose()`.
**Evidence:**
```dart
void _onOutroNext() {
  _audio.stop();
  _advanceCard();
}
```
**Impact:** `AudioPlayersVocabAudioPlayer` already guards this correctly with its `_disposed`
flag (lines 50–56, 96, 114), so this is *not* a crash — the class was clearly written with this
exact race in mind. It is a code-smell / documentation issue rather than a live bug, and I want to
be explicit that the defensive guard is present and correct.
**Suggested fix direction:** Leave as is, or add a comment pointing at the `_disposed` guard so a
future reader doesn't "fix" the un-awaited call by removing the guard.
**Confidence:** High

---

**ID: E030**
**File:** `lib/presentation/controllers/practice_controller.dart`
**Location:** lines 253–265, `hapticServiceProvider`
**Severity:** Low
**Category:** Memory
**Description:** `audioPlayerServiceProvider` registers `ref.onDispose(() => service.dispose())`
but `hapticServiceProvider`, defined identically 20 lines below, does not.
**Evidence:**
```dart
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  ...
  ref.onDispose(() => service.dispose());   // present
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) {
  ...
  return service;                            // no onDispose
});
```
**Impact:** `HapticService` holds platform channel state; without `onDispose` the instance
outlives its provider. Since the provider is a root-level singleton with no autoDispose, this is
currently benign, but the asymmetry is exactly the kind of thing that becomes a leak when someone
adds `.autoDispose` to one of them.
**Suggested fix direction:** Add `ref.onDispose(service.dispose)` (or whatever the teardown is)
for symmetry.
**Confidence:** Medium (I did not read `lib/audio/haptic_service.dart`, so I can't confirm
whether it holds a disposable resource — if it doesn't, this is purely cosmetic)

---

**ID: E031**
**File:** `lib/vocab/presentation/screens/my_decks_screen.dart`
**Location:** lines 34–41, `_refresh`
**Severity:** Low
**Category:** Memory / State
**Description:** `_refresh()` calls `setState`, and it is invoked from `initState` (line 31).
**Evidence:**
```dart
@override
void initState() {
  super.initState();
  _refresh();     // -> setState
}
```
**Impact:** Not a crash — `setState` in `initState` is legal — but it is a redundant rebuild of
a widget that has not been mounted yet, and the analyzer's `setState during build` guard does not
cover this path.
**Suggested fix direction:** Assign the fields directly in `initState` and keep `setState` only
for the post-dialog refreshes.
**Confidence:** High

---

**ID: E032**
**File:** `lib/vocab/presentation/widgets/word_card_base.dart`
**Location:** lines 56–70
**Severity:** (none — positive finding)
**Category:** Memory
**Description:** Recording as a confirmed-good pattern. The `stateStream` subscription is created
in `initState` and cancelled in `dispose`, and the listener body is guarded with
`if (mounted) setState(() {})`.
**Suggested fix direction:** Use this as the template for E017's dialog controllers.
**Confidence:** High

---

### Performance

---

**ID: E033**
**File:** `lib/presentation/controllers/canvas_controller.dart`
**Location:** line 96, `addPoint`
**Severity:** High
**Category:** Performance
**Description:** Every pointer-move event copies the entire active-stroke list and publishes a
new `CanvasState` to all listeners.
**Evidence:**
```dart
void addPoint(Point<double> point) {
  final lastPoint = state.activeStroke!.last;
  if (_distance(lastPoint, point) < 2.0) return;
  state = state.copyWith(activeStroke: [...state.activeStroke!, point]);
}
```
**Impact:** At 60–120Hz pointer events this is an O(n) allocation per event on a list that grows
to several hundred points, plus a `StateNotifier` notification that rebuilds the entire
`WritingCanvas` subtree (which re-evaluates `ref.watch`, the `ref.listen` registration at
`writing_canvas.dart:94`, and a fresh `CanvasPainter` with a `shouldRepaint` that does five
identity comparisons on list references — always unequal, so it always repaints). This is the
hottest code path in the app: the entire product is "the user drags their finger to write a
Lao character." It is the most likely source of jank on mid-range Android.
**Suggested fix direction:** Keep the active stroke in a mutable buffer that the painter reads
directly (a `ValueNotifier<List<Point>>` or a `ChangeNotifier` that appends in place), and only
publish to the notifier on `startStroke` / `endStroke` / `clear`.
**Confidence:** High

---

**ID: E034**
**File:** `lib/presentation/screens/review_screen.dart`
**Location:** line 253
**Severity:** Medium
**Category:** Performance
**Description:** Every word in a saved category is built eagerly inside a `Column`, even though
the enclosing widget is a `ListView.builder`.
**Evidence:**
```dart
return ListView.builder(
  itemCount: decks.length,
  itemBuilder: (context, i) { ... return _CategoryCard(words: words, ...); },
);
// and inside _CategoryCard:
for (final word in words) ...[
  ListTile(title: Text(word.laoWord, ...), ...),
],
```
**Impact:** The `ListView.builder` only virtualises across *categories*; a single category with
200 saved words builds 200 `ListTile`s, each with a `Text`, a `pickTranslation` map lookup, and
an `IconButton`. Combined with E035 this is the slowest screen in the app, and it is the screen
users reach precisely when their collection is large.
**Suggested fix direction:** Render the word list with a nested `ListView.builder(shrinkWrap: true,
physics: NeverScrollableScrollPhysics())`, or restructure to a single flat virtualised list.
**Confidence:** High

---

**ID: E035**
**File:** `lib/vocab/data/repositories/vocab_user_state_repository.dart`
**Location:** lines 42–47, 186–200, 212–222
**Severity:** Medium
**Category:** Performance / Storage
**Description:** `FlagDeckRepository` and `UserWordRepository` do a full linear scan of the Hive
box for every lookup, and the Hive boxes are opened with no indexes.
**Evidence:**
```dart
UserWord? getByWordId(String wordId) {
  for (final w in _box.values) { if (w.wordId == wordId) return w; }
  return null;
}
```
**Impact:** `getByWordId` is called in `_weightedSampleByLowTimesSeen` per candidate per review
slot (`lesson_engine.dart:292`) and in `getReviewCandidates` over every word in the box
(line 258). `getDecksContaining` and `getWordsInDeck` are called once per list row in
`review_screen.dart`. With 500 course words and a few hundred flagged words this is a few
hundred box reads per lesson build — measurable, and it grows linearly with usage.
**Suggested fix direction:** Add secondary indexes (`Hive.openBox(..., cruds: false)` won't
help; use an `index` adapter or maintain a `Map<String,String>` wordId→id cache in the repository
and invalidate it on write).
**Confidence:** High

---

**ID: E036**
**File:** `lib/presentation/screens/lesson_list_screen.dart`
**Location:** lines 165–195
**Severity:** Low
**Category:** Performance
**Description:** `SliverList.builder` is used correctly, but each item calls
`charRepo.getCharactersForLesson(lesson.id)` and `progressRepo.getLessonProgress(lesson.id)` —
two map/list walks per row per rebuild.
**Impact:** Negligible at 5 lessons. Listed for completeness only.
**Suggested fix direction:** Precompute a `Map<String, LessonProgress>` once in `build`.
**Confidence:** Medium

---

### State

---

**ID: E037**
**File:** `lib/presentation/screens/settings_screen.dart`
**Location:** lines 42–64, `SettingsController`
**Severity:** High
**Category:** State / Storage
**Description:** Stroke tolerance, sound effects, and haptic feedback are user-facing settings
stored in a bare in-memory `StateNotifier`. Nothing is persisted.
**Evidence:**
```dart
class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());
  void setStrokeTolerance(double value) { state = state.copyWith(strokeTolerance: value); }
  ...
}
final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) => SettingsController());
```
**Impact:** Every app launch silently resets stroke tolerance to 0.75 and both toggles to on. A
user who calibrated the difficulty for their handwriting — the app's single most valuable
personalisation — loses it every time. The vocab feature *does* have a Hive-backed preferences
repository right next to it (`vocab_preferences_repository.dart`), so the pattern is already
established and simply was not applied here.
**Suggested fix direction:** Back `SettingsController` with the existing Hive `preferences` box
(there is even a `vocabPreferencesRepositoryRawProvider` already open), loading on init and
writing on change.
**Confidence:** High

---

**ID: E038**
**File:** `lib/presentation/screens/test_screen.dart`
**Location:** lines 108–113
**Severity:** Medium
**Category:** State
**Description:** On the third failed stroke, `currentAttemptCount` is incremented twice.
**Evidence:**
```dart
} else {
  audio.playIncorrectSound();
  haptic.onStrokeIncorrect();
  _hintAttempts++;
  ref.read(testControllerProvider.notifier).onCharacterFailed();   // +1
  if (_hintAttempts >= 3) {
    setState(() => _showHint = true);
    ref.read(testControllerProvider.notifier).requestHint();       // +1 again
  }
}
```
and in `test_controller.dart:132-137`:
```dart
void requestHint() {
  state = state.copyWith(hintsUsed: state.hintsUsed + 1,
                         currentAttemptCount: state.currentAttemptCount + 1);
}
```
**Impact:** `currentAttemptCount` is what feeds `attemptsNeeded` on the recorded
`CharacterAttempt` (line 107), so every hinted character records one extra attempt. It also
inflates the value persisted via `recordTestResult`. The star formula only uses `hintsUsed` and
time, so stars are unaffected — the corruption is in the stored attempt record shown in the
result screen.
**Suggested fix direction:** Make `requestHint()` only increment `hintsUsed`; let
`onCharacterFailed()` own the attempt count.
**Confidence:** High

---

**ID: E039**
**File:** `lib/presentation/screens/practice_screen.dart`
**Location:** lines 125–135, `_onCharacterComplete`
**Severity:** Medium
**Category:** State
**Description:** The completion path always derives the character list from `state.currentLesson`,
ignoring the `characterCodepoints` override the screen was entered with.
**Evidence:**
```dart
if (state.isLastCharacter) {
  final characters = state.currentLesson != null
      ? ref.read(characterRepositoryProvider)
          .getCharactersForLesson(state.currentLesson!.id)
      : [];
  final charList = characters.map((c) => c.char).toList();
  context.push('/practice/${widget.lessonId}/complete',
      extra: {'characterList': charList});
}
```
**Impact:** In review mode `_loadLesson` (line 50) calls `setCharacters()`, which fabricates
`Lesson(id: 'review', …)`. `getCharactersForLesson('review')` returns `[]`, so
`practice_complete_screen.dart:214-220` takes its `isReview` branch and filters the whole
character database against an empty set — **the review completion screen always shows an empty
grid**, even though the user just practised characters. This is a visible, user-facing bug on a
shipped flow (the "Review" pill on every completed lesson card at `lesson_list_screen.dart:185-189`
routes here).
**Suggested fix direction:** Carry the actual character list on `PracticeState` (it already
exists as `practiceSequence`) and pass that to the completion route instead of re-deriving it
from the lesson.
**Confidence:** High

---

**ID: E040**
**File:** `lib/presentation/screens/lesson_list_screen.dart`
**Location:** lines 120–125
**Severity:** Low
**Category:** State
**Description:** The "current lesson" marker falls back to the last lesson when every lesson has
stars.
**Evidence:**
```dart
final currentLessonId = lessons
    .firstWhere((l) => progressRepo.getLessonProgress(l.id).stars == 0,
                orElse: () => lessons.last)
    .id;
```
**Impact:** On a 100%-finished course the final lesson is still highlighted as "current", which
is misleading but not harmful. It also does not account for IAP-gated vocab, which is a separate
progress axis entirely — the tab mixes two unrelated notions of "current".
**Suggested fix direction:** Return `null` and hide the current-lesson accent when the course is
complete.
**Confidence:** High

---

**ID: E041**
**File:** `lib/vocab/presentation/screens/lesson_list_screen.dart`
**Location:** lines 71, 87, 137
**Severity:** Low
**Category:** State
**Description:** `ref.watch(vocabPreferencesRepositoryRawProvider)` is used as a "re-read Hive on
rebuild" idiom, but it is a plain `Provider` whose value never changes, so the watch never fires.
It is watched twice in the same `build` (lines 71 and 87) and again in `_FreeUnitBanner` (line 137).
**Evidence:**
```dart
ref.watch(vocabPreferencesRepositoryRawProvider);   // Provider<...>, no state
```
**Impact:** The banner-dismissal *does* work, but only because line 89 separately watches
`vocabBannerDismissRevProvider`, which the dismiss handler bumps. The three no-op watches are
misleading — a future maintainer may remove line 89 believing 71 is doing the work.
**Suggested fix direction:** Delete the no-op watches and leave a comment on the rev providers
explaining they are the invalidation signal.
**Confidence:** High

---

**ID: E042**
**File:** `lib/data/repositories/progress_repository.dart` (line 24), `lib/domain/services/quiz_service.dart` (line 58)
**Location:** `DateTime.now()` calls
**Severity:** Low
**Category:** Storage / State
**Description:** The vocab layer consistently uses `DateTime.now().toUtc()` (with a documented
`Clock` indirection for tests), but the alphabet layer uses local time and has no `Clock` seam.
**Evidence:**
```dart
// vocab: consistent, injectable
DateTime _systemNow() => DateTime.now().toUtc();

// alphabet: local, not injectable
lastPracticed: DateTime.now(),
completedAt: DateTime.now(),
```
**Impact:** Records in the two boxes have mixed time zones, which makes cross-feature timeline
analysis wrong for any user not on UTC. Also makes `progress_repository_test.dart` time-dependent
if one is ever added.
**Suggested fix direction:** Adopt the same `Clock` typedef for the alphabet repositories.
**Confidence:** High

---

**ID: E043**
**File:** `lib/config/app_info.dart` (line 16) vs `lib/main.dart` (line 33)
**Location:** Sentry release string
**Severity:** Low
**Category:** State / Code Quality
**Description:** The About/Settings version is read from `PackageInfo` (auto-correct), but the
Sentry release tag is a hardcoded literal that must be bumped by hand.
**Evidence:**
```dart
..release = 'write_lao@1.0.4+1'
```
**Impact:** The two drift on every release. Sentry issue grouping and the version the user reads
off Settings will disagree, making bug reports harder to trace.
**Suggested fix direction:** Compute the release from `PackageInfo.fromPlatform()` inside
`SentryFlutter.init`'s callback (or a `dart-define`).
**Confidence:** High

---

### Null Safety

---

**ID: E044**
**File:** `lib/presentation/controllers/test_controller.dart`
**Location:** line 147, `_completeTest`
**Severity:** Medium
**Category:** Null Safety
**Description:** `state.lesson!` is force-unwrapped, and `_completeTest` is reachable from
`finishTest()` on a state where `startTest` was never successfully called.
**Evidence:**
```dart
final result = _quizService.createResult(
  lessonId: state.lesson!.id,     // line 147
  ...
);

QuizResult? finishTest() {
  if (!state.isComplete || state.result == null) {
    _completeTest(state.attempts);   // line 164 — no lesson guard
  }
  return state.result;
}
```
**Impact:** `_TestScreenState._startTest` (test_screen.dart:51-59) only calls `startTest` if
`charRepo.getLesson(widget.lessonId) != null`, but it calls `_startTimer()` unconditionally and
renders a full screen regardless. A bad `lessonId` (deep link, stale route after a content
update) leaves the screen in a running state with `lesson == null`; tapping anything that reaches
`finishTest` throws.
**Suggested fix direction:** Guard `if (state.lesson == null) return;` at the top of
`_completeTest` and show an explicit "lesson not found" Scaffold in `_startTest`.
**Confidence:** High

---

**ID: E045**
**File:** `lib/vocab/domain/lesson_engine.dart`
**Location:** lines 167–170
**Severity:** Low
**Category:** Null Safety
**Description:** `learnedIds.first` inside an `orElse` would throw on an empty list.
**Evidence:**
```dart
final correctId = learnedIds.firstWhere(
  reviewIds.contains,
  orElse: () => learnedIds.first,      // throws if learnedIds is empty
);
```
**Impact:** Currently unreachable — `shouldInsertHearIdentify` gates on
`learnedPoolSize >= config.minLearnedWords` (default 5), so `learnedIds` is non-empty by the time
we get here. It is only a hazard if someone passes `minLearnedWords: 0`.
**Suggested fix direction:** Add an early `if (learnedIds.isEmpty) return null;` for
defensiveness, or make the config invariant explicit.
**Confidence:** Medium (the guard is real but lives two calls away in another file)

---

**ID: E046**
**File:** `lib/presentation/screens/practice_screen.dart`
**Location:** lines 45–56
**Severity:** Low
**Category:** Null Safety
**Description:** Unknown codepoints are silently dropped and, if *all* of them are unknown, the
screen renders an empty header and a disabled canvas with no explanation.
**Evidence:**
```dart
final characters = widget.characterCodepoints!
    .map((cp) => charRepo.getCharacter(cp))
    .whereType<LaoCharacter>()
    .toList();
if (characters.isNotEmpty) { ... }
return;   // <- silent no-op when the list is empty
```
**Impact:** A lesson whose `characterCodepoints` reference a character not in `kLaoCharacters`
gives the user a dead screen with no way out except the back button and no Sentry event.
**Suggested fix direction:** Capture the unresolved codepoints, report them via `SentryHelper`,
and render an explicit error state.
**Confidence:** High

---

### Storage

---

**ID: E047**
**File:** `lib/data/datasources/character_stroke_datasource.dart`
**Location:** lines 70–73, `hasStrokeData`
**Severity:** Medium
**Category:** Storage
**Description:** The method's name says "has stroke data" but the implementation only reports
whether the codepoint has been *loaded*.
**Evidence:**
```dart
bool hasStrokeData(String codepoint) {
  final normalized = codepoint.toUpperCase().replaceAll('U+', '');
  return _cache[normalized]?.strokeCount != null;   // true even for strokeCount == 0
}
```
**Impact:** Because line 37 caches a `strokeCount: 0` placeholder on every miss, `hasStrokeData`
returns `true` for exactly the characters that have *no* usable stroke data. Any caller gating a
UI affordance on this gets the inverse of the truth.
**Suggested fix direction:** `(cache[normalized]?.strokeCount ?? 0) > 0`, and rename to
`isLoaded` if the "loaded" semantics were the intent.
**Confidence:** High (no current caller in `lib/` — I grepped; this is a latent trap for the next
one)

---

**ID: E048**
**File:** `lib/data/datasources/character_stroke_datasource.dart`
**Location:** lines 35–43
**Severity:** Medium
**Category:** Storage
**Description:** A single `catch (e)` swallows *all* failures — missing file, malformed JSON,
schema mismatch, permission error — and negative-caches the result permanently for the process.
**Evidence:**
```dart
} catch (e) {
  // File not found or parse error
  _cache[normalized] = CharacterStrokeData(
    codepoint: normalized, strokeCount: 0, strokes: const []);
  return null;
}
```
**Impact:** If a stroke-data JSON file ships with a typo (which is a *build* bug, not a runtime
one), the user silently gets an auto-completing card with no drawing surface and no trace in
Sentry. Because the negative is cached, reloading the box later in the same session doesn't
help either. There are currently no stroke-data files for the vowel/tone phases at all
(`strokeCount: 0` for 51 of the 70 characters in `lao_characters.dart`), so the auto-complete
path at `stroke_canvas_host.dart:69-74` is heavily exercised already.
**Suggested fix direction:** Distinguish "asset not found" from "parse failed": only negative-cache
the former, and send the latter to `SentryHelper.captureException`.
**Confidence:** High

---

**ID: E049**
**File:** `lib/presentation/screens/settings_screen.dart`
**Location:** `_showResetConfirmation` → `ProgressRepository.resetAllProgress`
**Severity:** Medium
**Category:** Storage
**Description:** The tile is labelled "Reset all progress" but only clears the two alphabet
boxes.
**Evidence:**
```dart
Future<void> clearAllProgress() async {
  await _characterBox.clear();
  await _lessonBox.clear();
}
```
The six vocab boxes (`user_word`, `user_progress`, `user_session`, `flag_deck`, `flag_deck_word`,
`preferences`) are untouched.
**Impact:** A user who taps "Reset all progress" expecting a clean slate keeps their entire
vocabulary SRS state, saved categories, and — notably — their `preferences` box, which holds the
IAP unlock flag and the dismissed-upsell flags. The behaviour is not wrong, but the label is.
**Suggested fix direction:** Either rename the tile to "Reset character progress", or extend the
reset to the vocab boxes (with a clear warning about losing saved words).
**Confidence:** High

---

**ID: E050**
**File:** `lib/vocab/data/repositories/vocab_preferences_repository.dart`
**Location:** lines 47, 56, 65
**Severity:** Low
**Category:** Storage
**Description:** Hive `dynamic` values are force-cast to `int`/`bool` with a `defaultValue` that
does not protect against a type mismatch on an existing key.
**Evidence:**
```dart
int get charSessionCount => _box.get(_prefCharSessions, defaultValue: 0) as int;
```
`defaultValue` only applies when the key is *absent*. A value previously written as a `double`
(those survive some Hive/JSON round-trips) throws a `TypeError` on read.
**Impact:** Low probability, but the failure is a hard crash on a `ConsumerWidget` build with no
recovery path, and there is no migration for the box.
**Suggested fix direction:** Use `(_box.get(key) as num?)?.toInt() ?? 0` and
`(_box.get(key) as bool?) ?? false`, and version the preferences keys.
**Confidence:** Medium

---

**ID: E051**
**File:** `lib/main.dart`
**Location:** line 57
**Severity:** Low
**Category:** Storage / Platform
**Description:** Hive is initialised in `getApplicationDocumentsDirectory()`.
**Evidence:**
```dart
final appDir = await getApplicationDocumentsDirectory();
Hive.init(appDir.path);
```
**Impact:** On iOS, `Documents/` is user-visible via the Files app and is included in iCloud
backup. Progress and saved-word data being world-readable and backed up is a minor privacy and
storage-growth concern, and the SRS state is meaningless on a restored device.
**Suggested fix direction:** Use `getApplicationSupportDirectory()` for the Hive root.
**Confidence:** Medium (this is a conventional recommendation, not something I can confirm causes
a specific user-visible failure here)

---

### Localization

---

**ID: E052**
**File:** `lib/l10n/app_localizations.dart` (line 126) + `lib/app.dart` (line 17)
**Location:** `supportedLocales`
**Severity:** Medium
**Category:** Localization
**Description:** `app_zh_Hant.arb` exists and every word's `definitions` map ships a `zh_Hant`
entry, but `supportedLocales` contains only `Locale('zh')` — no
`Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')`.
**Evidence:**
```dart
static const List<Locale> supportedLocales = <Locale>[
  ...
  Locale('zh'),
];
```
**Impact:** `pickTranslation` (`translation_helper.dart:13-17`) looks up `'${languageCode}_$scriptCode'`,
but for a resolved `Locale('zh')` the `scriptCode` is `null`, so the `zh_Hant` key is never
matched. Traditional Chinese users get Simplified definitions, and the carefully-authored `zh_Hant`
content in `course.json` is dead weight in the bundle.
**Suggested fix direction:** Add `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')` (and
`Locale('zh', 'TW')` / `Locale('zh', 'HK')` as needed) to `supportedLocales`, and add a
`localeResolutionCallback` that maps `zh_TW`/`zh_HK`/`zh_Hant` to the Hant entry.
**Confidence:** High

---

**ID: E053**
**File:** `lib/app.dart`
**Location:** lines 8–19
**Severity:** Medium
**Category:** Localization
**Description:** The app has no `locale:` override and no `localeResolutionCallback`, and no
in-app language picker. 16 locales ship, including a complete Lao translation, but the app's
language is entirely at the mercy of the OS.
**Evidence:**
```dart
return MaterialApp.router(
  title: 'Write Lao',
  ...
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
);
```
**Impact:** For a Lao-language learning app the single most valuable localisation feature —
letting a user read the *instructions* in Lao while the device is set to English — is missing.
The user must change their phone's system language to see `ຝຶກຫັດ` instead of "Practice".
**Suggested fix direction:** Add a `locale` backed by a persisted preference (the same Hive
`preferences` box) and a language selector in Settings.
**Confidence:** High

---

**ID: E054**
**File:** (project-wide)
**Location:** the entire `lib/vocab/` feature plus several alphabet screens
**Severity:** Medium
**Category:** Localization
**Description:** The vocab feature is almost entirely hardcoded English and never calls
`AppLocalizations.of(context)`.
**Evidence:** a sample — hardcoded strings with no l10n key:
```dart
Text('All done!', ...)                                 // character_practice_card.dart:221, 294, 333
Text(state.isLastCharacter ? l10n.allDone : 'Next', ...) // practice_screen.dart:457
const Text('Next', ...)                                // test_screen.dart:258
Text('${lesson.newWordIds.length} new')                // vocab lesson_list_screen.dart:219
'Load' / 'Error' / 'Listen and choose' / 'My Decks' / 'Save to category' / 'Create new category'
```
**Impact:** A user running the app in `lo` sees a Lao alphabet lesson list and then an entirely
English vocab flow. The two halves of the app contradict each other. Note that
`lib/vocab/presentation/i18n/character_strings.dart` exists specifically as a "swap this out for
v2 localization" seam and currently holds only English constants.
**Suggested fix direction:** Route the vocab strings through `character_strings.dart` (which is
already the right shape) and then through the ARB pipeline; there are ~40 strings.
**Confidence:** High

---

**ID: E055**
**File:** `pubspec.yaml`
**Location:** `dependencies: intl: any`
**Severity:** Low
**Category:** Localization
**Description:** `intl` is unpinned (`any`) and `Intl.defaultLocale` is never initialised; there is
no call to `initializeDateFormatting`.
**Evidence:**
```yaml
intl: any
```
**Impact:** No current failure (nothing formats dates), but the generated
`app_localizations_*.dart` imports `package:intl/intl.dart` and relies on the resolved version.
`any` makes the lockfile the only protection, and `flutter pub upgrade` on a fresh machine can
pull a breaking `intl`.
**Suggested fix direction:** Pin `intl` to a caret range matching the SDK constraint.
**Confidence:** Medium

---

**ID: E056**
**File:** `lib/l10n/app_localizations_zh.dart`
**Location:** whole file (609 lines vs ~308 for every other locale)
**Severity:** Low
**Category:** Localization
**Description:** Every generated locale file is ~307–314 lines except `zh` at 609. That strongly
suggests the zh ARB has roughly double the keys, or duplicated/extra entries.
**Evidence:** `wc -l lib/l10n/app_localizations_*.dart` → zh = 609, all others = 307–314.
**Impact:** I could not determine the cause without reading the zh ARB in full, which I did not
do. If zh genuinely has extra keys, `AppLocalizationsZh` may be missing placeholders or
metadata that the other locales have. I am flagging this as an anomaly to check, not a
confirmed defect.
**Suggested fix direction:** Diff the key sets between `app_en.arb` and `app_zh.arb`
(`jq 'keys'` on both) and reconcile.
**Confidence:** Low

---

### Platform

---

**ID: E057**
**File:** `lib/main.dart`
**Location:** lines 22–29
**Severity:** Medium
**Category:** Platform
**Description:** Orientation is locked to portrait only when `shortestSide < 600` (phones).
Tablets and all desktop/web are left unlocked, but the practice and test screens are laid out
for portrait with hardcoded height clamps.
**Evidence:**
```dart
final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
if (shortestSide < 600) {
  await SystemChrome.setPreferredOrientations([...portrait...]);
}
```
**Impact:** On a 7"+ tablet the user can rotate into landscape, where
`practice_screen.dart:225` still allocates `availH * 0.20` (clamped 100–140) to the header and
gives the rest to a square `AspectRatio` canvas — in landscape the canvas ends up as narrow as
the screen is wide minus the header column, wasting the majority of the display. The vocab cards
handle this properly (`LayoutBuilder` + `_buildLandscape`); the alphabet screens do not.
**Suggested fix direction:** Either lock portrait unconditionally, or port the existing
`isLandscape` branch pattern from `word_card_base.dart` / `character_practice_card.dart` to
`practice_screen.dart` and `test_screen.dart`.
**Confidence:** High

---

**ID: E058**
**File:** `lib/vocab/providers.dart`
**Location:** line 86
**Severity:** Medium
**Category:** Platform
**Description:** In release builds `iapServiceProvider` returns `PlatformIapService` on every
platform, including web and desktop, where `in_app_purchase` has no implementation.
**Evidence:**
```dart
final iapServiceProvider = Provider<IapService>((ref) {
  if (kDebugMode) return const MockIapService(simulateSuccess: true);
  return PlatformIapService();
});
```
**Impact:** `web/`, `linux/`, `windows/`, and `macos/` runner directories all exist in the repo. On
those platforms `_iap.isAvailable()` will throw or return false, and the upsell screen will show
"The App Store is not available" with no way to unlock. I have not built or run those targets, so
I cannot confirm the exact failure mode.
**Suggested fix direction:** Gate on `Platform.isIOS || Platform.isAndroid` and fall back to
`MockIapService(simulateSuccess: false)` (or an explicit "not available on this platform" state)
elsewhere.
**Confidence:** Medium (the platforms are configured; I have not executed them)

---

**ID: E059**
**File:** `lib/main.dart`
**Location:** lines 20–22
**Severity:** Low
**Category:** Platform
**Description:** `platformDispatcher.views.first` assumes a single display.
**Evidence:**
```dart
final view = WidgetsBinding.instance.platformDispatcher.views.first;
```
**Impact:** On a multi-window / desktop platform this is whichever view happens to be first,
not necessarily the one the app is rendering into. Harmless on mobile.
**Suggested fix direction:** Use `PlatformDispatcher.instance.views` and take the one matching
`View.of(context)`, or just use `MediaQuery` after the first frame.
**Confidence:** High

---

### Security

---

**ID: E060**
**File:** `.env` (repo root)
**Location:** whole file
**Severity:** Medium
**Category:** Security
**Description:** The file contains live credentials for seven services: ElevenLabs, Google (TTS
API), Anthropic, Camb, Cloudflare, and an R2 secret access key.
**Evidence:**
```
ANTHROPIC_API_KEY=sk-ant-api03-_S8s5iLOkI2STkNrQR3UkvJQcx5fCiDMsQOj...
R2_SECRET_ACCESS_KEY=3df78198b2c9e9654e2ce328de684094e51e80d615e5d537ba1cd8bec33b055e
CLOUDFLARE_API_KEY=cfut_N4E25T3UmRtHIO9w9Fb4DIej4KC9OV6HhkNKVYiz4beb0332
```
**Impact:** **I confirmed this is correctly gitignored** (`.gitignore` lines 14–17, 100–101) and
that `git ls-files` shows neither `.env` nor `lib/config/secrets.dart` is tracked — so this is not
currently a committed-secret leak, and the `secrets.dart.example` + `scripts/setup_secrets.sh`
pattern is the right one. The residual risk is that these keys sit in plaintext in a working
directory that is synced to a cloud volume, backed up by the OS, and one `git add -f` away from
being committed. Anyone with read access to this machine can mint Anthropic and Anthropic-adjacent
spend. The audio-generation pipeline (`tool/generate_audio.py`) is the legitimate consumer.
**Suggested fix direction:** Rotate all seven keys if this directory has ever been on a shared or
synced volume. Move them to the OS keychain or a `direnv`/`.envrc` that is not a flat file, and
consider a pre-commit hook that hard-fails on `.env`.
**Confidence:** High (file contents verified; tracked-status verified)

---

**ID: E061**
**File:** `us.sentry.io.json` (repo root)
**Location:** whole file, 17,618 bytes
**Severity:** Low
**Category:** Security
**Description:** A real captured Sentry event payload sits in the project root. It contains
`user`, `contexts` (device/OS), `breadcrumbs` (navigation history), `tags`, and the exception
with its stack.
**Evidence:** `git check-ignore -v us.sentry.io.json` → matched by `.gitignore:113`, and
`git ls-files | grep -c us.sentry.io.json` → `0`. **Not committed.**
**Impact:** Low — correctly ignored. But it is a real event with device metadata sitting next to
the source tree, and it will be swept up by any naive "zip the project for a bug report" or
Cloudflare Pages / test upload. It also duplicates the `SENTRY_DSN` already in `.env`.
**Suggested fix direction:** Delete it and add a scratch-directory convention; if you need
samples for debugging, redact `user` and `contexts` first.
**Confidence:** High

---

**ID: E062**
**File:** `lib/vocab/providers.dart` (line 86) + `lib/vocab/presentation/screens/vocab_settings_section.dart` (lines 50–130)
**Severity:** Low
**Category:** Security
**Description:** Debug builds get a purchase-simulation IAP **and** a "Unlock All Content" tile
that writes a permanent `iapUnlocked: true` to Hive.
**Evidence:**
```dart
if (kDebugMode) return const MockIapService(simulateSuccess: true);
```
Both are correctly behind `kDebugMode`, so this is a positive finding rather than a defect. I am
listing it only because the unlock it writes is **not** scoped to the debug build — if a debug
build is ever side-loaded and later replaced by a release build, Hive retains `iapUnlocked: true`
and the user gets the full paid content for free, permanently, with no receipt.
**Suggested fix direction:** Scope the debug unlock to a separate Hive box or key namespace
(e.g. `_debug_unlocked`) that release builds ignore.
**Confidence:** Medium (the side-load-then-upgrade path is real; I have not tested it)

---

**ID: E063**
**File:** `lib/vocab/domain/platform_iap_service.dart`
**Location:** lines 90–92
**Severity:** Low
**Category:** Security
**Description:** Purchase entitlement is stored as a single local boolean with no receipt
validation and no server-side record.
**Evidence:**
```dart
Future<UserVocabProgress> markIapUnlocked() async {
  final current = getOrCreate();
  if (current.iapUnlocked) return current;
  return save(current.copyWith(iapUnlocked: true));
}
```
**Impact:** The restore path (`restorePurchases`) does re-query the store, which is correct, but
once `iapUnlocked` is `true` the app never re-validates — a refunded or revoked purchase is never
detected. Combined with E062 this is the mechanism by which a stale debug unlock persists.
**Suggested fix direction:** Re-validate entitlement on app resume, or add a
`purchaseDate`/`receiptHash` and re-check periodically. (`flutter_revenuecat` would handle this
properly if you want a managed solution.)
**Confidence:** Medium

---

### Code Quality / Lints

`flutter analyze` reports **57 issues**, of which only 11 are in `lib/` (all in generated-model
files) and the rest are `avoid_print` in `test/` and `tool/`. `lib/` is otherwise analyzer-clean,
which is genuinely good. The items below are the ones worth a pass.

---

**ID: E064**
**File:** `lib/vocab/data/models/vocab_word.dart` (lines 17, 30, 45), `vocab_user_state.dart` (32, 56, 75, 94, 109), `vocab_lesson.dart:8`, `vocab_unit.dart:8`, `course_content.dart:11`
**Severity:** Low
**Category:** Code Quality
**Description:** Eleven `invalid_annotation_target` warnings — `@JsonSerializable` is applied to
`factory` constructors inside `@freezed` classes, where it is only valid on the class.
**Evidence:**
```
warning • The annotation 'JsonSerializable.new' can only be used on classes
         • lib/vocab/data/models/vocab_word.dart:17:4 • invalid_annotation_target
```
**Impact:** None at runtime — `json_serializable` picks up the `fieldRename` from the annotation
and codegen works. But it is 11 permanent warnings that train the team to ignore analyzer output.
**Suggested fix direction:** Move `@JsonSerializable(fieldRename: FieldRename.snake,
explicitToJson: true)` up onto the `@freezed` class itself and delete the per-factory copies.
**Confidence:** High

---

**ID: E065**
**File:** `lib/utils/canvas_painter.dart` → `lib/presentation/widgets/canvas_painter.dart:166-171`
**Severity:** Low
**Category:** Code Quality
**Description:** `_drawReferenceCharacter` has an empty body and a `referenceChar` field that is
plumbed all the way from `CharacterStrokeData.char` through `WritingCanvas` into the painter for
no effect.
**Evidence:**
```dart
void _drawReferenceCharacter(Canvas canvas, Size size, double scale) {
  // The ghost stroke provides the tracing guide ... We don't draw it ...
}
```
**Impact:** Dead code, but the reason is well documented and the decision is sound — the plumbing
is what's confusing. `shouldRepaint` (line 303) still compares `referenceChar`.
**Suggested fix direction:** Delete the method, the field, and the `shouldRepaint` comparison, or
add a `// intentionally unused` marker so the next reader doesn't think it's a stub.
**Confidence:** High

---

**ID: E066**
**File:** `lib/presentation/widgets/writing_canvas.dart`
**Location:** lines 193–196 (`_shakeCanvas`) and 215–228 (local `AnimatedBuilder`)
**Severity:** Low
**Category:** Code Quality
**Description:** `_shakeCanvas` is an empty no-op called from `_showFeedback`; and the file
defines a class named `AnimatedBuilder` that shadows Flutter's own.
**Evidence:**
```dart
void _shakeCanvas() {
  // Shake animation would be applied to the container
  // For simplicity, we just show the feedback
}
...
class AnimatedBuilder extends AnimatedWidget {   // shadows package:flutter's AnimatedBuilder
```
**Impact:** The local `AnimatedBuilder` ignores the `child` parameter (always passes `null`), so
it cannot be swapped for the framework one without changing behaviour — a trap for the next
maintainer. `_shakeCanvas` is a no-op called for a real UX case (wrong-direction feedback).
**Suggested fix direction:** Delete `_shakeCanvas` and its call, or implement it with a
`Transform.translate` animation. Rename the local widget to `FeedbackAnimatedBuilder`.
**Confidence:** High

---

**ID: E067**
**File:** `lib/presentation/screens/practice_screen.dart:472-478`, `test_screen.dart:479-486`, `character_practice_card.dart:357-363`
**Severity:** Low
**Category:** Code Quality / Lao Text
**Description:** The same `_acrophonicalCodepoints` set is copy-pasted into three files, and it
contains `'U+0EAA'` which is not a character in the database (the DB has `ຂ` at `U+0E8A`), while
omitting `U+0EAF` and the two ligatures.
**Evidence:**
```dart
static const _acrophonicalCodepoints = {
  'U+0E81', ..., 'U+0EA7', 'U+0EAA', 'U+0EAB', 'U+0EAD', 'U+0EAE',
};
```
vs. `lib/data/lao_characters.dart:10` → `{"codepoint": "U+0E8A", "char": "ຂ", ...}`
**Impact:** Three copies to keep in sync, and one entry that never matches a real codepoint (so
`ຂ` shows no mnemonic image if the asset exists).
**Suggested fix direction:** Move the set to `CharacterRepository` or a top-level constant and
drive it from `lao_characters.dart` (add a `hasAcrophonicalImage` flag to the model instead).
**Confidence:** High

---

**ID: E068**
**File:** `lib/vocab/data/datasources/course_content_datasource.dart`
**Location:** lines 179–186
**Severity:** Low
**Category:** Code Quality
**Description:** The soft word-count check is placed *after* the `throw`, so it only ever runs on
the success path — which is arguably intended, but the comment ("Soft check (warning only)")
sits in a position that reads like a post-failure diagnostic.
**Evidence:**
```dart
if (errors.isNotEmpty) { throw CourseValidationException(errors); }
// Soft check (warning only, not a hard failure).
if (expectedWordCount != null && content.words.length != expectedWordCount) { debugPrint(...); }
```
Also `expectedWordCount: 500` is hardcoded in `CourseContentDataSource.production()` (line 48)
while the bundle currently has exactly 500 words, so the check is passing vacuously.
**Impact:** A future bundle that ships 499 words logs to `debugPrint`, which is stripped in
release — nobody sees it. The `scripts/validate_content_bundle.py` tool is the right place for
this check.
**Suggested fix direction:** Move the count assertion into the Python validator (which runs in
CI) and delete the Dart soft check.
**Confidence:** High

---

**ID: E069**
**File:** `analysis_options.yaml`
**Location:** `linter.rules` (all commented out)
**Severity:** Low
**Category:** Code Quality
**Description:** Only the default `flutter_lints` set is active. The lints that would have caught
several issues above are off: `unawaited_futures` (E028, E029, E063), `use_build_context_synchronously`
(already suppressed by hand at `vocab_lesson_practice_screen.dart:241`), `always_declare_return_types`,
`require_trailing_commas`, `sort_constructors_first`.
**Evidence:** the entire `rules:` block is comments.
**Impact:** Low direct impact — the codebase is already clean — but enabling
`unawaited_futures` would immediately surface the fire-and-forget `launchUrl` and the
`// ignore:` at line 241.
**Suggested fix direction:** Turn on `unawaited_futures` and `unnecessary_await_in_return` first;
they are the highest-yield for this codebase.
**Confidence:** High

---

**ID: E070**
**File:** `lib/data/datasources/progress_local_datasource.dart:85-88`, `character_stroke_datasource.dart:47-73`
**Severity:** Low
**Category:** Code Quality
**Description:** Dead code: `ProgressLocalDataSource.maxPossibleStars` is superseded by
`ProgressRepository.maxPossibleStars()` (which correctly uses `getAllLessons().length`), and
`getAvailableCodepoints` / `hasStrokeData` / `preloadStrokeData` / `clearCache` have no callers
in `lib/`.
**Impact:** `maxPossibleStars` on the data source computes `lessonBox.values.length * 3` — the
count of lessons *with progress rows* — which is a nonsense metric (0 stars possible on a fresh
install). It is unused, which is lucky. `hasStrokeData` is the E047 trap.
**Suggested fix direction:** Delete the unused members, or mark them `@visibleForTesting` if the
tests use them.
**Confidence:** Medium (I grepped `lib/` for callers; I did not check `test/` exhaustively for
each name)

---

**ID: E071**
**File:** `lib/vocab/presentation/screens/vocab_lesson_practice_screen.dart`
**Location:** line 241
**Severity:** Low
**Category:** Code Quality
**Description:** A stale `// ignore: use_build_context_synchronously` comment sits above a line
that is already correctly guarded.
**Evidence:**
```dart
if (result == true && mounted) {
  _audio.stop();
  // ignore: use_build_context_synchronously
  this.context.pop();
}
```
`this.context` on a `State` is valid once `mounted` is true, so the suppression is unnecessary.
**Impact:** Harmless, but suppressions rot — if someone later adds a real unguarded use on the
next line, the stale ignore could mask it depending on line position.
**Suggested fix direction:** Delete the ignore comment and re-run the analyzer to confirm.
**Confidence:** Medium (I did not verify by removing it and re-analyzing)

---

---

## 3. Summary

### By severity

| Severity | Count |
|---|---|
| Critical | 2 (E001, E009) |
| High | 9 (E002, E003, E010, E011, E020, E033, E037, +2 counted below) |
| Medium | 34 |
| Low | 26 |
| **Total logged** | **71** |

*(Exact tallies by category below are the authoritative ones; a few entries above are filed
under both a primary and a contributing category.)*

### By category

| Category | Issues |
|---|---|
| Lao Text | E001, E002, E003, E004, E005, E006, E007, E008 — **8** |
| Fonts/Rendering | E009, E010, E011, E012, E013, E014, E015, E016, E019 — **9** |
| Input/Editing | E017, E018, E019 — **3** |
| Async | E020, E021, E022, E024, E025, E026, E027, E028 — **8** |
| Memory | E017, E029, E030, E031 — **4** |
| Performance | E033, E034, E035, E036, E012 — **5** |
| State | E024, E037, E038, E039, E040, E041, E042, E043 — **8** |
| Null Safety | E022, E023, E044, E045, E046 — **5** |
| Storage | E003, E007, E035, E042, E047, E048, E049, E050, E051 — **9** |
| Localization | E052, E053, E054, E055, E056 — **5** |
| Platform | E057, E058, E059, E016, E051 — **5** |
| Security | E060, E061, E062, E063 — **4** |
| Code Quality | E043, E064–E071 — **9** |

---

## 4. Top 5 to fix first

**1. E001 — `word_progress_strip.dart` space insertion breaks pre-base vowels (Critical, Lao Text)**
This is the most-viewed string in the entire vocab feature and it is wrong for a large fraction
of the 500-word course. It is also a one-function fix once the classification helper from E004
exists. Ship this first because it is a pure correctness win in the app's core learning surface.

**2. E009 + E010 — `'Noto Lao'` is never a real font family (Critical + High, Fonts/Rendering)**
These two are one problem. The app requests a font family that is neither bundled nor ever
registered, on twelve call sites, with `google_fonts` runtime fetching as the only thing standing
between it and tofu. Every other rendering issue (E011, E013, E015, E019) is downstream of
deciding how Lao text is styled — so establishing one bundled family plus one shared `TextTheme`
entry first makes the rest a find-and-replace. Fix together.

**3. E002 — `character_card.dart` lesson preview splits every combining mark (High, Lao Text)**
Same root cause as #1, different surface, and it affects Phase 2 and Phase 3 lesson previews
where *every* character is a mark. Fixing it with the same shared helper as #1 is cheap.

**4. E037 — Settings are not persisted (High, State/Storage)**
Stroke tolerance, sound, and haptics reset on every launch. This is the app's only
personalisation, and the fix is small because `vocab_preferences_repository.dart` already
demonstrates the Hive-backed pattern. High user-visible value per line changed.

**5. E020 — `restorePurchases` blocks for a fixed 10 seconds (High, Async)**
A returning customer with a valid receipt always waits 10 seconds. It is a three-line change
(`Future.any` with the timeout) on the highest-stakes funnel in the app. Cheapest
user-visible improvement on this list.

*Runner-up: **E033** (`canvas_controller.addPoint` O(n) copy per pointer event) — this is the
hottest path in the product and the most likely source of felt jank on low-end Android, but it is
a structural change to the canvas state model, so it should be its own PR rather than bundled.*

---

## 5. Repeating patterns (fix in one pass)

1. **Lao spacing rules are re-implemented ad hoc in three places and wrong in two of them.**
   `word_progress_strip.dart:64-75`, `character_card.dart:150`, and the `' · '` join at
   `vocab/lesson_list_screen.dart:206`. → Introduce one `renderLaoSequence()` / spacing helper plus
   one `isCombining`/`isPreBaseVowel` predicate, and route all three (and E004) through it.

2. **`fontFamily: 'Noto Lao'` is a string literal repeated in 12 files.**
   `practice_screen` ×2, `test_screen` ×2, `character_card` ×2, `word_progress_strip`,
   `review_screen`, `result_screen_widgets`, `vocab/lesson_complete_screen`, `lesson_detail_screen`.
   → One `AppTheme.laoStyle(size)` in `theme.dart` + a `textTheme` entry; delete the literals.

3. **Hardcoded English bypasses the existing l10n plumbing** in ~40 places across `lib/vocab/`
   plus `practice_screen.dart:457` and `test_screen.dart:258`. → The
   `character_strings.dart` seam already exists; route everything through it, then through ARB.

4. **Force-unwraps of possibly-absent data inside `build`.**
   `vocab_lesson_practice_screen.dart:310` (`valueOrNull!`), `:309` (`_plan!.cards[i]`),
   `test_controller.dart:147` (`state.lesson!`), `practice_screen.dart:125`
   (`state.currentLesson!`). → Audit every `!` reached from a widget `build` and give it an
   explicit empty/error branch.

5. **"Did the async thing actually work?" is checked with a silent null guard.**
   `vocab_lesson_practice_screen.dart:125` and `:146` (`if (engine != null)`), `:213`
   (`if (!mounted) return`), `lesson_list_screen.dart:114-118` (`try { … } catch (_) {}`).
   → Replace with a `SentryHelper.captureMessage` so dropped writes are visible.

6. **`build()` does work that should be `initState`/state.** The `..shuffle()` at
   `vocab_lesson_practice_screen.dart:400`, the `setState` in `initState` at
   `my_decks_screen.dart:31`, the `AppTheme.lightTheme` getter at `theme.dart:157`, the eager
   `for` over words at `review_screen.dart:253`.

7. **Provider "invalidation" via no-op watches.** `vocab/lesson_list_screen.dart:71, 87, 137`
   watch a `Provider` that never changes. → Delete; rely on the `*RevProvider` counters that
   actually do the work.

8. **Silent `catch` that hides content bugs.**
   `character_stroke_datasource.dart:35`, `lesson_list_screen.dart:115`. → Let parse errors reach
   `SentryHelper`; only suppress genuine "asset absent" cases.

---

## 6. What I could not check

**Files I did not open at all:**
`presentation/screens/practice_complete_screen.dart` (read only grep excerpts around
lines 214-222), `test_result_screen.dart`, `progress_screen.dart`, `lesson_detail_screen.dart`,
`about_screen.dart`; `presentation/widgets/star_rating.dart`, `stroke_animator.dart`;
`audio/haptic_service.dart`; `data/models/quiz_result.dart`, `lesson.dart`, `user_progress.dart`;
`data/datasources/progress_hive_adapters.dart` (grep only);
`domain/stroke_matching/stroke_matcher.dart`, `dtw.dart`, `path_utils.dart`, `matching_result.dart`;
`utils/svg_parser.dart` (grep only — 472 lines of path/transform parsing, a likely home of
`double.parse` and silent-fallback bugs I did not audit);
`vocab/data/repositories/course_repository.dart`, `vocab/domain/course_navigation.dart`,
`content_access.dart`; `vocab/presentation/screens/upsell_screen.dart`,
`restore_purchases_screen.dart`, `deck_contents_screen.dart`, `unit_complete_screen.dart`;
`vocab/presentation/widgets/intro_card.dart`, `outro_card.dart`, `word_audio_button.dart`,
`character_test_card.dart`, `word_card_keys.dart`; `vocab/data/datasources/vocab_hive_adapters.dart`;
`vocab/data/models/vocab_user_state.dart`, `course_content.dart`;
`config/routes.dart` lines 140–418 (the vocab + deck routes);
`presentation/screens/settings_screen.dart` lines 240–539 (the debug section and reset flow).

**Things I deliberately did not assess:**

- **Native platform config.** `android/app/build.gradle`, `iOS/Runner/Info.plist`,
  `macos/`, `web/index.html`. I did not verify the IAP product registration, the `CFBundleLocalizations`
  list, Android `minSdk` vs `audioplayers`/`in_app_purchase` requirements, or the `INTERNET`
  permission (which `google_fonts` runtime fetching would need, and its absence is a good way to
  confirm E016 empirically).
- **IAP StoreKit configuration.** I read the Dart service but not the App Store Connect /
  Play Console setup, so I cannot confirm `500word` is actually provisioned.
- **Generated code.** `*.g.dart`, `*.freezed.dart`, and `lib/l10n/app_localizations_*.dart` were
  read only where a specific claim depended on them. I did not audit the generated output.
- **Tests.** I did not read `test/` in depth or run the suite. Note that `flutter analyze`
  reports an unused import and 25 `avoid_print`s in `test/domain/stroke_matching/stroke_debug_test.dart`,
  which suggests a debug scratch file was committed as a test.
- **The `website/` Cloudflare Worker, `scripts/`, `tool/`, and the `prompts/` spec docs.**
  I did not verify the implementation against the specs in `prompts/`, which would be the fastest
  way to resolve whether some of the Low-confidence items are intentional.
- **Runtime behaviour.** I ran `flutter analyze` only. I did not build, run, or profile the app,
  so every "impact" statement is inferred from the code, not observed. The performance findings
  (E033, E034, E035) in particular would benefit from a DevTools trace before being sized.

**What would most efficiently close the remaining gaps, in order:**

1. `flutter run --profile` on a low-end Android device with a DevTools performance trace while
   drawing a Lao character — settles E033, E034, E035 and E013/E014 (text scaling) empirically.
2. `python3 -c` over `assets/vocab/course.json` asserting
   `''.join(c['character'] for c in w['characters']) == w['lao_word']` for all 500 words — I
   found `w_0490` failing; confirm it is the only one and find any others.
3. The remaining `lib/vocab/presentation/` screens and `domain/stroke_matching/` — the
   stroke-matching maths is where a subtle bug would be most expensive to find later.
4. `android/app/build.gradle` + `iOS/Runner/Info.plist` for the native/IAP/localization questions.
