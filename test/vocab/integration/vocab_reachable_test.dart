import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/screens/lesson_list_screen.dart'
    as alphabet_home;
import 'package:write_it_lao/presentation/screens/settings_screen.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_it_lao/vocab/presentation/screens/vocab_settings_section.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

import '../fixtures/course_fixtures.dart';

/// Phase 09 integration — the vocab feature is reachable from the existing
/// Write Lao surfaces (home screen, settings screen) via real go_router
/// navigation.
void main() {
  late Directory tempDir;
  late Box<CharacterProgress> charBox;
  late Box<LessonProgress> lessBox;
  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_vocab_reach_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CharacterProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LessonProgressAdapter());
    }
    registerVocabHiveAdapters();
    charBox = await Hive.openBox<CharacterProgress>('character_progress');
    lessBox = await Hive.openBox<LessonProgress>('lesson_progress');
    wordBox = await Hive.openBox<UserWord>('reach_words');
    progressBox = await Hive.openBox<UserVocabProgress>('reach_prog');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() {
    for (final k in charBox.keys.toList()) {
      charBox.delete(k);
    }
    for (final k in lessBox.keys.toList()) {
      lessBox.delete(k);
    }
    for (final k in wordBox.keys.toList()) {
      wordBox.delete(k);
    }
    progressBox.delete('singleton');
  });

  CourseContentDataSource fixtureDataSource() => CourseContentDataSource(
        loadString: (_) async => validBundleJson,
        assetExists: (p) async => validBundleAssetPaths.contains(p),
      );

  GoRouter makeRouter(Widget home) => GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (c, s) => home),
          GoRoute(
            path: '/vocab',
            builder: (c, s) => UnitListScreen(
              onOpenUnit: (_) {},
              onUpsell: () {},
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (c, s) => const SettingsScreen(),
          ),
        ],
      );

  Widget pumpWith(Widget home) {
    return ProviderScope(
      overrides: [
        courseContentDataSourceProvider.overrideWithValue(fixtureDataSource()),
        userWordRepositoryProvider
            .overrideWithValue(UserWordRepository(wordBox)),
        userVocabProgressRepositoryProvider
            .overrideWithValue(UserVocabProgressRepository(progressBox)),
      ],
      child: MaterialApp.router(
        routerConfig: makeRouter(home),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  testWidgets('home screen renders the vocab entry tile', (tester) async {
    await tester.pumpWidget(
      pumpWith(const alphabet_home.LessonListScreen()),
    );
    await tester.pump();

    expect(find.byKey(alphabet_home.homeVocabEntryKey), findsOneWidget);
    expect(find.text('Vocabulary — 500 Words'), findsOneWidget);
  });

  testWidgets('tapping the vocab tile navigates to the unit list',
      (tester) async {
    await tester.pumpWidget(
      pumpWith(const alphabet_home.LessonListScreen()),
    );
    await tester.pump();

    await tester.tap(find.byKey(alphabet_home.homeVocabEntryKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(WordCardKeys.unitList), findsOneWidget);
  });

  testWidgets('settings screen hosts the vocab restore tile',
      (tester) async {
    await tester.pumpWidget(pumpWith(const SettingsScreen()));
    await tester.pump();

    expect(find.byKey(VocabSettingsSection.restoreTileKey), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
  });
}
