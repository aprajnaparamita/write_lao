import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Convenience wrappers around the Sentry SDK.
///
/// Use these in `catch` blocks for errors that are recoverable but worth
/// tracking (e.g. an asset fails to load, a Hive read throws, etc.).
///
/// Example:
/// ```dart
/// try {
///   await riskyOperation();
/// } catch (e, stack) {
///   SentryHelper.captureException(e, stack, hint: 'riskyOperation failed');
/// }
/// ```
class SentryHelper {
  SentryHelper._();

  /// Capture a non-fatal exception. In debug mode the exception is only
  /// printed; in release/profile it is sent to Sentry.
  ///
  /// [context] is an optional map of structured key→value data attached to
  /// the event under the key `'app_context'` in the Sentry event viewer.
  static Future<void> captureException(
    Object exception,
    StackTrace stackTrace, {
    String? hint,
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Sentry DEBUG] ${hint ?? ''} — $exception\n$stackTrace');
      return;
    }
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint != null ? Hint.withMap({'message': hint}) : null,
      withScope: context == null
          ? null
          : (scope) => scope.setContexts('app_context', context),
    );
  }

  /// Capture a plain message (no exception) — useful for notable events that
  /// are not errors but deserve attention (e.g. IAP flow unexpected state).
  ///
  /// [context] is attached under `'app_context'` in the Sentry event viewer.
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.warning,
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[Sentry DEBUG] ${level.name.toUpperCase()} — $message');
      return;
    }
    await Sentry.captureMessage(
      message,
      level: level,
      withScope: context == null
          ? null
          : (scope) => scope.setContexts('app_context', context),
    );
  }

  /// Set the current user context (call after any authentication / profile load).
  /// Pass null values to clear a field; call [clearUser] to remove entirely.
  static Future<void> setUser({
    String? id,
    String? email,
    String? username,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: id, email: email, username: username));
    });
  }

  /// Clear the current Sentry user context (e.g. on sign-out).
  static Future<void> clearUser() async {
    await Sentry.configureScope((scope) => scope.setUser(null));
  }
}
