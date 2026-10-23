/// Compile-time build variant, selected with
/// `--dart-define=APP_VARIANT=open` or `--dart-define=APP_VARIANT=store`.
///
/// - `open`: open-source distribution (macOS .dmg, sideloaded Android APK).
///   Ships the full vocabulary unlocked by default.
/// - `store`: App Store / Play Store distribution. The vocabulary sits
///   behind the one-time in-app purchase.
///
/// Defaults to `store` so a build that forgets the flag fails closed
/// behind the paywall instead of giving paid content away.
enum AppVariant { open, store }

const String _variantName = String.fromEnvironment(
  'APP_VARIANT',
  defaultValue: 'store',
);

/// The variant this binary was compiled for.
const AppVariant appVariant = _variantName == 'open'
    ? AppVariant.open
    : AppVariant.store;

/// True when the full vocabulary ships unlocked in this build.
const bool kVocabUnlockedByDefault = appVariant == AppVariant.open;
