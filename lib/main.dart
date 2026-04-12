import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:write_it_lao/app.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/models/user_progress.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(CharacterProgressAdapter());
  Hive.registerAdapter(LessonProgressAdapter());
  await Hive.openBox<CharacterProgress>('character_progress');
  await Hive.openBox<LessonProgress>('lesson_progress');

  runApp(
    const ProviderScope(
      child: WriteItLaoApp(),
    ),
  );
}
