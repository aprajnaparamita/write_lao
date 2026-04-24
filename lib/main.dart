import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:write_it_lao/app.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
