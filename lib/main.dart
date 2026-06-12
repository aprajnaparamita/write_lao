import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:write_it_lao/app.dart';
import 'package:write_it_lao/config/secrets.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';

Future<void> main() async {
  // SentryFlutter.init wraps everything, providing:
  //  • Automatic unhandled exception capture via the zone
  //  • FlutterError.onError → Sentry.captureException
  //  • PlatformDispatcher.instance.onError for isolate errors
  //  • Native crash reporting on iOS / Android
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = SENTRY_DSN.isEmpty ? '' : SENTRY_DSN
        // Release is read from pubspec version at build time by Sentry.
        // Explicitly pass it so it shows correctly in the dashboard.
        ..release = 'write_it_lao@1.0.1+1'
        // Tag events so you can filter debug vs production in Sentry.
        ..environment = kDebugMode ? 'development' : 'production'
        // Attach a stack-trace to every captured message, not just exceptions.
        ..attachStacktrace = true
        // Capture breadcrumbs for HTTP requests (debug mode only to avoid
        // leaking sensitive data that might appear in response bodies).
        ..maxBreadcrumbs = 50
        // Don't send events when Sentry is not configured (empty DSN).
        ..tracesSampleRate = kDebugMode ? 0.0 : 0.2   // 20 % of sessions in prod
        // Enable automatic performance tracing for app start and navigation.
        ..enableAutoPerformanceTracing = true
        // Auto-set user context from device info.
        ..attachScreenshot = false  // enable later if desired
        // Filter out low-signal noise:
        ..beforeSend = _beforeSend;
    },
    appRunner: _runApp,
  );
}

/// Called for every event before it is sent to Sentry.
/// Return null to drop the event, return the (optionally mutated) event to send.
FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
  // Allow through events explicitly tagged as debug test buttons so the
  // "Send test error to Sentry" button in Settings actually works.
  final isDebugTest = event.tags?['triggered_by'] == 'debug_settings_button';

  // Drop events in debug mode — rely on the console instead.
  // …unless it's the explicit debug test button.
  if (kDebugMode && !isDebugTest) return null;

  // Scrub any breadcrumb data that might contain user-identifiable paths.
  final cleaned = event.copyWith(
    breadcrumbs: event.breadcrumbs
        ?.where((b) => b.category != 'http')  // drop raw HTTP breadcrumbs
        .toList(),
  );
  return cleaned;
}

Future<void> _runApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Portrait lock for phones ──────────────────────────────────────────────
  // Detect phone vs tablet by shortest side in logical pixels.
  // Phones are typically < 600 dp; tablets are >= 600 dp.
  // All screens are designed for portrait on phones; landscape causes overflow
  // on the canvas-based practice/test screens and on fixed-height detail screens.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  if (shortestSide < 600) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // === DIAGNOSTIC START ===
  final stopwatch = Stopwatch()..start();
  int step = 0;
  void log(String msg) {
    final elapsed = stopwatch.elapsed;
    // ignore: avoid_print
    print('[${elapsed.inMilliseconds}ms] STEP ${step++}: $msg');
  }

  log('Entry point');

  // Initialize Hive
  log('Getting app documents directory');
  final appDir = await getApplicationDocumentsDirectory();
  log('Got app dir: ${appDir.path}');

  log('Initializing Hive');
  Hive.init(appDir.path);
  log('Hive initialized');

  log('Registering character/lesson adapters');
  Hive.registerAdapter(CharacterProgressAdapter());
  Hive.registerAdapter(LessonProgressAdapter());
  log('Registered character/lesson adapters');

  log('Opening character_progress box');
  await Hive.openBox<CharacterProgress>('character_progress');
  log('Opened character_progress');

  log('Opening lesson_progress box');
  await Hive.openBox<LessonProgress>('lesson_progress');
  log('Opened lesson_progress');

  log('Registering vocab Hive adapters');
  registerVocabHiveAdapters();
  log('Registered vocab adapters');

  log('Opening vocab boxes');
  await openVocabBoxes();
  log('Opened vocab boxes');

  log('About to call runApp');
  stopwatch.stop();
  // === DIAGNOSTIC END ===

  runApp(
    const ProviderScope(
      child: WriteItLaoApp(),
    ),
  );
}
