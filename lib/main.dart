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
  WidgetsFlutterBinding.ensureInitialized();

  // Lock phones to portrait before the first frame.
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  if (shortestSide < 600) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  await SentryFlutter.init(
    (options) {
      options
        ..dsn = SENTRY_DSN.isEmpty ? '' : SENTRY_DSN
        ..release = 'write_it_lao@1.0.3+1'
        ..environment = kDebugMode ? 'development' : 'production'
        ..attachStacktrace = true
        ..maxBreadcrumbs = 50
        ..tracesSampleRate = kDebugMode ? 0.0 : 0.2
        ..enableAutoPerformanceTracing = true
        ..attachScreenshot = false
        ..beforeSend = _beforeSend;
    },
    appRunner: _runApp,
  );
}

FutureOr<SentryEvent?> _beforeSend(SentryEvent event, Hint hint) {
  final isDebugTest = event.tags?['triggered_by'] == 'debug_settings_button';
  if (kDebugMode && !isDebugTest) return null;
  return event.copyWith(
    breadcrumbs: event.breadcrumbs
        ?.where((b) => b.category != 'http')
        .toList(),
  );
}

Future<void> _runApp() async {
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);

  Hive.registerAdapter(CharacterProgressAdapter());
  Hive.registerAdapter(LessonProgressAdapter());
  await Hive.openBox<CharacterProgress>('character_progress');
  await Hive.openBox<LessonProgress>('lesson_progress');

  registerVocabHiveAdapters();
  await openVocabBoxes();

  runApp(const ProviderScope(child: WriteItLaoApp()));
}
