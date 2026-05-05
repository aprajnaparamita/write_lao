import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/datasources/progress_local_datasource.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';
import 'package:write_it_lao/data/repositories/progress_repository.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/screens/progress_screen.dart';

void main() {
  late Directory tempDir;
  late Box<CharacterProgress> charBox;
  late Box<LessonProgress> lessonBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_progress_screen_test_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CharacterProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LessonProgressAdapter());
    }
    charBox = await Hive.openBox<CharacterProgress>('ps_char');
    lessonBox = await Hive.openBox<LessonProgress>('ps_lesson');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() {
    for (final k in charBox.keys.toList()) {
      charBox.delete(k);
    }
    for (final k in lessonBox.keys.toList()) {
      lessonBox.delete(k);
    }
  });

  ProgressRepository makeProgressRepo() {
    final ds = ProgressLocalDataSource(
      characterBox: charBox,
      lessonBox: lessonBox,
    );
    return ProgressRepository(
      dataSource: ds,
      characterRepo: CharacterRepository(),
    );
  }

  Widget makeApp(ProgressRepository progressRepo) {
    final router = GoRouter(
      initialLocation: '/progress',
      routes: [
        GoRoute(
          path: '/progress',
          builder: (c, s) => const ProgressScreen(),
        ),
        GoRoute(path: '/review', builder: (c, s) => const Scaffold()),
        GoRoute(
          path: '/lessons/:id',
          builder: (c, s) => const Scaffold(),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        characterRepositoryProvider
            .overrideWithValue(CharacterRepository()),
        progressRepositoryProvider.overrideWithValue(progressRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('shows suggested next card for first incomplete lesson',
      (tester) async {
    final progressRepo = makeProgressRepo();
    await tester.pumpWidget(makeApp(progressRepo));
    await tester.pump();

    expect(find.byKey(const Key('progress.suggestedNext')), findsOneWidget);
    expect(find.text('Up Next: Consonants 1'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
  });

  testWidgets('shows review card when all lessons complete', (tester) async {
    final charRepo = CharacterRepository();
    final progressRepo = makeProgressRepo();
    // Mark every lesson with at least 1 star.
    for (final lesson in charRepo.getAllLessons()) {
      lessonBox.put(lesson.id, LessonProgress(lessonId: lesson.id, stars: 1));
    }
    await tester.pumpWidget(makeApp(progressRepo));
    await tester.pump();

    expect(find.byKey(const Key('progress.suggestedNext')), findsOneWidget);
    expect(find.text('Review Weak Characters'), findsOneWidget);
    // 'Review' appears both in the card button and the bottom nav tab
    expect(find.text('Review'), findsWidgets);
  });
}
