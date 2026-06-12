import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Single source of truth for the running app's version metadata.
///
/// Backed by [PackageInfo.fromPlatform], which reads the values written into
/// the native Info.plist (iOS) / build.gradle (Android) at build time from
/// `pubspec.yaml`'s `version: 1.2.3+4` field.
///
/// This means bumping the version in `pubspec.yaml` automatically flows
/// through to the About screen, the Settings → Version row, and the Sentry
/// release tag — no hard-coded strings to keep in sync.
final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// Short, user-facing version string — e.g. `v1.2.3 (4)`.
///
/// Falls back to `…` while [PackageInfo] is loading, and to the literal
/// `v?` if for some reason the lookup fails entirely, so the UI never
/// renders a blank or null value.
String formatAppVersion(
  AsyncValue<PackageInfo> appInfo, {
  bool includeBuild = true,
}) {
  return appInfo.maybeWhen(
    data: (info) {
      final v = info.version.trim();
      final b = info.buildNumber.trim();
      if (v.isEmpty) return 'v?';
      if (!includeBuild || b.isEmpty || b == '1' && !v.contains('+')) {
        return 'v$v';
      }
      return 'v$v ($b)';
    },
    orElse: () => '…',
  );
}
