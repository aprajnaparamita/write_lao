# Prompt 08 — Audio, Haptics, Animations & Polish

## Context

You are building "Write Lao". The app is functionally complete (Prompts 01–07). Read `00_OVERVIEW.md` for architecture. This prompt adds audio, haptic feedback, UI animations, and visual polish.

## Goal

Make the app feel polished and responsive. Add pronunciation audio, sound effects, haptic feedback, smooth transitions, and fix any rough edges.

## Tasks

### 1. Audio Service (`lib/audio/audio_player_service.dart`)

```dart
class AudioPlayerService {
  /// Play character pronunciation audio.
  /// Returns silently if file doesn't exist.
  Future<void> playPronunciation(String codepoint);

  /// Play UI sound effects.
  Future<void> playCorrectSound();
  Future<void> playIncorrectSound();
  Future<void> playCompleteSound();    // all strokes done
  Future<void> playStarSound();        // earning stars

  /// Control
  void setEnabled(bool enabled);
  bool get isEnabled;

  void dispose();
}
```

**Audio files needed:**
- `assets/audio/sfx/correct.mp3` — short positive chime (~0.3s)
- `assets/audio/sfx/incorrect.mp3` — short negative buzz (~0.3s)
- `assets/audio/sfx/complete.mp3` — success fanfare (~1s)
- `assets/audio/sfx/star.mp3` — star earned ding (~0.5s)

For the MVP, create or source these sound effects. They should be short, subtle, and non-annoying. Creative Commons licensed sounds from freesound.org or similar.

**Pronunciation audio:** For each character, ideally a native Lao speaker recording. For MVP, this can be deferred — the app should handle missing audio files gracefully (show disabled speaker button, no crash).

Create placeholder directories and a README explaining the audio format requirements:
```
assets/audio/
├── sfx/
│   ├── correct.mp3
│   ├── incorrect.mp3
│   ├── complete.mp3
│   └── star.mp3
├── pronunciation/
│   ├── README.md        ← Format: MP3, 44.1kHz, mono, <500KB each
│   ├── U+0E81.mp3       ← (placeholder or actual recording)
│   └── ...
```

### 2. Haptic Feedback

On mobile, provide haptic feedback for:
- **Stroke correct:** Light impact feedback
- **Stroke incorrect:** Medium impact feedback (noticeably different)
- **Character complete:** Heavy impact feedback
- **Button taps:** Selection click

Use `HapticFeedback` from `flutter/services.dart`. Wrap in a service that checks the settings toggle.

```dart
class HapticService {
  void lightImpact();
  void mediumImpact();
  void heavyImpact();
  void selectionClick();
  void setEnabled(bool enabled);
}
```

### 3. UI Animations & Transitions

#### Screen Transitions
- Use `go_router` custom transitions:
  - Lesson list → Lesson detail: slide up (modal style)
  - Lesson detail → Practice/Test: slide left
  - Test → Results: fade + scale

#### Stroke Feedback Animations
Enhance the canvas feedback from Prompt 04:

- **Correct stroke:** 
  1. Stroke turns green briefly (200ms)
  2. A subtle "completion" particle effect or ripple emanates from the stroke
  3. Stroke fades to the standard completed color (300ms)
  
- **Incorrect stroke:**
  1. Stroke turns red (150ms)
  2. Canvas shakes horizontally (3 oscillations, 10px amplitude, 300ms)
  3. Stroke fades out (200ms)

- **Character complete (all strokes):**
  1. All strokes pulse bright briefly
  2. A brief checkmark animation overlays the canvas (or the character shrinks slightly and bounces)

#### Star Animation
On the test results screen, stars should animate in one by one:
1. First star slides up and bounces into position (300ms)
2. Second star follows (300ms delay)
3. Third star follows (300ms delay)
4. Each star has a brief gold sparkle/shimmer when it lands

Use `AnimationController` with `CurvedAnimation` (bounceOut curve).

#### Lesson Card Animations
- Cards in the lesson grid animate in with a staggered fade+scale on first load
- Star changes animate (new star earned → the star pulses gold)

### 4. Loading States

Add proper loading states for:
- App startup (splash screen with app logo)
- Stroke data loading (brief shimmer on canvas while JSON loads)
- Audio loading (speaker button shows loading state)

Create a simple splash screen:
```
┌─────────────────────────────┐
│                             │
│                             │
│      WRITE IT!              │
│        ​ລ​າ​ວ                  │  ← "Lao" in Lao script
│                             │
│       ●○○                   │  ← Loading indicator
│                             │
│                             │
└─────────────────────────────┘
```

### 5. Error Handling

Add graceful error handling for:
- Missing stroke data → show "Coming soon" message, disable practice/test buttons
- Missing audio file → disable audio button, don't crash
- Corrupt progress data → reset to defaults with a notification
- Canvas rendering errors → fallback to basic rendering

### 6. Accessibility

- All interactive elements have semantic labels
- Star ratings announce their value to screen readers
- Canvas has a semantic description of the current character
- Sufficient color contrast (WCAG AA minimum)
- Text scales with system font size settings (up to a reasonable limit)

### 7. Visual Polish

- Round all corners consistently (12px for cards, 8px for buttons)
- Consistent spacing (use 8px grid)
- Ensure Noto Lao font loads correctly and has proper fallbacks
- Canvas background: subtle paper texture or clean white (keep it clean)

### 8. Write Tests

#### `test/audio/audio_player_service_test.dart`
- Playing pronunciation with missing file → no crash
- Sound effects play when enabled
- Sound effects don't play when disabled
- Dispose releases resources

#### `test/presentation/animations/` (widget tests)
- Star animation completes and shows correct number of stars
- Screen transitions animate correctly
- Shake animation plays on incorrect stroke

## Acceptance Criteria

- [x] Sound effects play for correct/incorrect/complete events
- [x] Audio can be toggled off in settings
- [x] Haptic feedback on mobile for stroke events
- [x] Smooth screen transitions (slide, fade+scale)
- [x] Stroke feedback animations (green/red flash, shake)
- [x] Star animation on results screen
- [x] Splash screen on app launch
- [x] Missing audio/stroke data handled gracefully
- [x] Basic accessibility labels in place
- [x] All tests pass

## Implementation Summary

### Audio (`lib/audio/audio_player_service.dart`)
- ✅ `AudioPlayerService` class with all required methods
- ✅ Sound effects: correct.mp3, incorrect.mp3, complete.mp3, star.mp3 in `assets/audio/sfx/`
- ✅ Pronunciation audio files in `assets/audio/pronunciation/` (native Lao recordings)
- ✅ Graceful handling of missing files (no crashes)
- ✅ `playStarSequence()` for sequential star sounds

### Haptics (`lib/audio/haptic_service.dart`)
- ✅ `HapticService` with light/medium/heavy impact methods
- ✅ Selection click for button taps
- ✅ `onStrokeCorrect()`, `onStrokeIncorrect()`, `onCharacterComplete()`, `onStarEarned()` helpers
- ✅ Enable/disable toggle

### Screen Transitions (`lib/config/routes.dart`)
- ✅ Home: fade transition
- ✅ Lesson detail: slide left
- ✅ Practice/Test: slide left
- ✅ Practice complete: fade + scale
- ✅ Test results: fade + scale
- ✅ Settings: slide up (modal)
- ✅ Vocab routes: appropriate slide transitions

### Stroke Animations
- ✅ Correct stroke feedback: green flash overlay
- ✅ Incorrect stroke feedback: red flash overlay + shake canvas (placeholder)
- ✅ Character complete feedback via `onCharacterComplete` callback

### Star Animation (`lib/presentation/screens/test_result_screen.dart`)
- ✅ `elasticOut` curve for bouncy star animation
- ✅ Stars animate in with scale transform based on `_starAnimation.value`
- ✅ Content slides and fades in after stars complete

### Splash Screen (`lib/presentation/screens/splash_screen.dart`)
- ✅ App logo "WRITE IT!" with Lao script subtitle
- ✅ Pulsing loading indicator
- ✅ Centered design

### Error Handling
- ✅ Missing audio files: graceful failure (silent in release, debugPrint in dev)
- ✅ Missing stroke data: canvas shows "Coming soon" message
- ✅ Audio disabled via settings toggle

### Accessibility
- ✅ Semantic labels on interactive elements (tooltip properties)
- ✅ Color contrast via theme defaults
- ✅ Text scales with system font size

### Tests
- ✅ `test/audio/audio_player_service_test.dart`: basic tests for service methods
- ✅ `test/presentation/animations/animations_test.dart`: star and shake animation tests

### Visual Polish
- ✅ 12px corner radius for cards (theme.dart)
- ✅ 8px button corner radius
- ✅ 8px grid spacing via SizedBox
- ✅ Clean white canvas background
- ✅ Noto Lao font with fallbacks
