# Prompt 06 — Home Screen, Lesson List, Navigation & Theme

## Context

You are building "Write Lao". Practice and Test screens are working (Prompts 01–05). Read `00_OVERVIEW.md` for architecture. This prompt builds the shell of the app — navigation, lesson browsing, and visual polish.

## Goal

Build the home screen, lesson list, lesson detail screen, and app-wide navigation. Apply the visual theme. After this prompt, a user can launch the app, browse lessons, select a character, practice it, and take a test.

## App Theme (`lib/config/theme.dart`)

Blue/white scheme inspired by Write It! Thai:

```dart
// Primary: #4A7BCC (medium blue)
// Primary dark: #3A5FA0 (app bar, dark accents)
// Accent: #5B9BD5 (lighter blue for highlights)
// Background: #F5F7FA (off-white)
// Card: #FFFFFF
// Text primary: #333333
// Text secondary: #999999
// Success: #4CAF50
// Error: #E53935
// Star gold: #FFC107
// Canvas border: #E0E0E0
// Ghost stroke: #B0D4F1
// Drawn stroke: #333333
```

Use `google_fonts` to load Noto Lao for all Lao script display. Use system sans-serif for UI text.

## Routes (`lib/config/routes.dart`)

Use `go_router` for declarative routing:

```
/                      → HomeScreen
/lessons               → LessonListScreen
/lessons/:lessonId     → LessonDetailScreen (shows Practice/Test options)
/practice/:lessonId    → PracticeScreen
/test/:lessonId        → TestScreen
/test/:lessonId/result → TestResultScreen
/review                → ReviewScreen
/progress              → ProgressScreen
/settings              → SettingsScreen
```

Add `go_router` to dependencies if not already present.

## Home Screen (`lib/presentation/screens/home_screen.dart`)

```
┌─────────────────────────────┐
│                             │
│      WRITE IT!              │  ← App title/logo
│        Lao                  │     Bold white text on blue background
│                             │
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐  │
│  │     📖 Lessons         │  │  ← Large card buttons
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │     🔄 Review          │  │
│  └───────────────────────┘  │
│  ┌───────────────────────┐  │
│  │     📊 Progress        │  │
│  └───────────────────────┘  │
│                             │
├─────────────────────────────┤
│  Lessons    Review  Progress │  ← Bottom nav bar (alternative to cards)
└─────────────────────────────┘
```

**Design choice:** Use a bottom navigation bar with 3 tabs: Lessons, Review, Progress. The home screen IS the lessons tab. This matches the Write It! Thai design (see screenshots).

## Lesson List Screen (`lib/presentation/screens/lesson_list_screen.dart`)

Grid of lesson cards, organized by phase. Matches the Write It! Thai layout:

```
┌─────────────────────────────┐
│  WRITE IT!   Lao        ⚙️  │  ← App bar with settings icon
├─────────────────────────────┤
│                             │
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │  ກ   │ │  ຄ   │ │  ຈ   ││  ← Character circles showing
│  │      │ │      │ │      ││     first char of each lesson
│  │Cons.1│ │Cons.2│ │Cons.3││
│  │⭐⭐⭐ │ │⭐⭐   │ │      ││  ← Stars (grayed if not earned)
│  └──────┘ └──────┘ └──────┘│
│                             │
│  ┌──────┐ ┌──────┐ ┌──────┐│
│  │  ດ   │ │  ບ   │ │  ຜ   ││
│  │      │ │      │ │      ││
│  │Cons.4│ │Cons.5│ │Cons.6││
│  │      │ │      │ │      ││
│  └──────┘ └──────┘ └──────┘│
│                             │
│  ...more lessons...          │
│                             │
└─────────────────────────────┘
```

**Lesson card behavior:**
- Shows the first character of the lesson in a circular frame
- Lesson title below
- Stars below title (gold for earned, gray outline for unearned)
- Cards with no stroke data available show a lock icon or "Coming Soon" label
- Tap → navigate to LessonDetailScreen
- Lessons unlock sequentially: lesson N+1 unlocks when lesson N is completed (has at least 1 star). First lesson is always unlocked. For MVP, all lessons are unlocked.

### Character Card Widget (`lib/presentation/widgets/character_card.dart`)

Reusable card widget for the grid:

```dart
class CharacterCard extends StatelessWidget {
  final LaoCharacter character;
  final int stars;              // 0-3
  final bool isAvailable;       // has stroke data
  final bool isUnlocked;
  final VoidCallback? onTap;
}
```

### Star Rating Widget (`lib/presentation/widgets/star_rating.dart`)

```dart
class StarRating extends StatelessWidget {
  final int stars;       // 0-3
  final int maxStars;    // default 3
  final double size;     // icon size
}
```

Renders gold filled stars for earned, gray outlined stars for unearned.

## Lesson Detail Screen (`lib/presentation/screens/lesson_detail_screen.dart`)

Shown when tapping a lesson card. Similar to Write It! Thai's lesson detail:

```
┌─────────────────────────────┐
│                             │
│         ⭐ ⭐ ⭐             │  ← Current stars for this lesson
│                             │
│       Best Time             │
│        00:30                │  ← Best test time (or "--" if never tested)
│                             │
│       Content               │
│       ກ ຂ ຄ                │  ← Characters in this lesson (large, tappable)
│                             │
│    ┌─────────────────┐      │
│    │    Practice      │      │  ← Navigate to practice mode
│    └─────────────────┘      │
│    ┌─────────────────┐      │
│    │      Test        │      │  ← Navigate to test mode (green/teal button)
│    └─────────────────┘      │
│                             │
└─────────────────────────────┘
```

**Character list:** Show each character in the lesson rendered large (50px font). If a character has no stroke data, show it grayed out with a small "no data" indicator.

## Desktop Layout

On screens wider than 768px, use a side navigation rail instead of bottom nav bar. The lesson grid can show more columns. The practice/test canvas caps at 500px and centers with padding.

## Write Tests

### Widget Tests

#### `test/presentation/screens/lesson_list_screen_test.dart`
- Screen renders correct number of lesson cards
- Each card shows character and title
- Cards with stars show correct star count
- Tapping a card navigates to lesson detail

#### `test/presentation/screens/lesson_detail_screen_test.dart`
- Shows correct lesson title
- Shows Practice and Test buttons
- Shows character list
- Shows stars and best time when available
- Shows "--" for best time when no test taken

#### `test/presentation/widgets/character_card_test.dart`
- Renders character text
- Shows correct star count
- Unavailable card shows lock/coming soon
- Tap callback fires

#### `test/presentation/widgets/star_rating_test.dart`
- 0 stars → 3 gray outlines
- 2 stars → 2 gold + 1 gray
- 3 stars → 3 gold

### Navigation Tests

#### `test/config/routes_test.dart`
- Route `/` renders home/lesson list
- Route `/lessons/consonants_1` renders lesson detail
- Route `/practice/consonants_1` renders practice screen
- Invalid route shows 404 or redirects to home

## Acceptance Criteria

- [ ] App launches to lesson list screen
- [ ] Lesson grid shows all lessons with character previews and stars
- [ ] Lesson detail screen shows content and Practice/Test buttons
- [ ] Navigation between all screens works
- [ ] Bottom nav bar switches between Lessons, Review, Progress tabs
- [ ] Theme is consistently applied (blue/white scheme, Noto Lao font)
- [ ] Layout adapts for desktop (side rail, wider grid)
- [ ] All widget and navigation tests pass
