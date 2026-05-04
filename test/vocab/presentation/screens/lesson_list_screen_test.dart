import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_preferences_repository.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/presentation/screens/lesson_list_screen.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

import '../../fixtures/course_fixtures.dart';

void main() {
  late Directory tempDir;
  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;
  late Box<dynamic> prefsBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_lls_test_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
    wordBox = await Hive.openBox<UserWord>('lls_words');
    progressBox = await Hive.openBox<UserVocabProgress>('lls_prog');
    prefsBox = await Hive.openBox<dynamic>('lls_prefs');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() {
    for (final k in wordBox.keys.toList()) {
      wordBox.delete(k);
    }
    progressBox.delete('singleton');
    prefsBox.clear();
  });

  CourseContentDataSource fixtureDataSource() => CourseContentDataSource(
        loadString: (_) async => validBundleJson,
        assetExists: (p) async => validBundleAssetPaths.contains(p),
      );

  void seedProgress({
    String? currentLessonId = 'l_01_01',
    bool iapUnlocked = true,
  }) {
    final now = DateTime.utc(2026, 1, 1);
    progressBox.put(
      'singleton',
      UserVocabProgress(
        id: 'p',
        currentUnitId: 'u_01',
        currentLessonId: currentLessonId,
        iapUnlocked: iapUnlocked,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Widget makeApp({
    required String unitId,
    void Function(String)? onOpenLesson,
  }) {
    return ProviderScope(
      overrides: [
        courseContentDataSourceProvider.overrideWithValue(fixtureDataSource()),
        userWordRepositoryProvider
            .overrideWithValue(UserWordRepository(wordBox)),
        userVocabProgressRepositoryProvider
            .overrideWithValue(UserVocabProgressRepository(progressBox)),
        vocabPreferencesRepositoryRawProvider
            .overrideWithValue(VocabPreferencesRepository(prefsBox)),
      ],
      child: MaterialApp(
        home: LessonListScreen(unitId: unitId, onOpenLesson: onOpenLesson),
      ),
    );
  }

  testWidgets('shows every lesson in the unit', (tester) async {
    seedProgress();
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(WordCardKeys.lessonRow('l_01_01')), findsOneWidget);
    expect(find.byKey(WordCardKeys.lessonRow('l_01_02')), findsOneWidget);
  });

  testWidgets('lesson 1 of an unlocked unit is unlocked', (tester) async {
    seedProgress(currentLessonId: 'l_01_01');
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(WordCardKeys.lessonLockBadge('l_01_01')), findsNothing);
  });

  testWidgets('lesson 2 is locked until lesson 1 is complete', (tester) async {
    seedProgress(currentLessonId: 'l_01_01');
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(WordCardKeys.lessonLockBadge('l_01_02')),
      findsOneWidget,
    );
  });

  testWidgets('lesson 2 unlocks once lesson 1 is complete', (tester) async {
    seedProgress(currentLessonId: 'l_01_02');
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(WordCardKeys.lessonLockBadge('l_01_02')), findsNothing);
  });

  testWidgets('completed lessons remain tappable for re-study',
      (tester) async {
    seedProgress(currentLessonId: 'l_02_01');
    String? opened;
    await tester.pumpWidget(
      makeApp(unitId: 'u_01', onOpenLesson: (id) => opened = id),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(WordCardKeys.lessonRow('l_01_01')));
    await tester.pump();

    expect(opened, 'l_01_01');
  });

  testWidgets('tapping an unlocked lesson fires onOpenLesson', (tester) async {
    seedProgress(currentLessonId: 'l_01_01');
    String? opened;
    await tester.pumpWidget(
      makeApp(unitId: 'u_01', onOpenLesson: (id) => opened = id),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(WordCardKeys.lessonRow('l_01_01')));
    await tester.pump();

    expect(opened, 'l_01_01');
  });

  testWidgets('tapping a locked lesson does NOT fire onOpenLesson',
      (tester) async {
    seedProgress(currentLessonId: 'l_01_01');
    String? opened;
    await tester.pumpWidget(
      makeApp(unitId: 'u_01', onOpenLesson: (id) => opened = id),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(WordCardKeys.lessonRow('l_01_02')));
    await tester.pump();

    expect(opened, isNull);
  });

  testWidgets('shows free banner on unit 1 when IAP not purchased',
      (tester) async {
    seedProgress(currentLessonId: 'l_01_01', iapUnlocked: false);
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Unit 1 is free — no purchase needed'), findsOneWidget);
  });

  testWidgets('free banner is dismissible', (tester) async {
    seedProgress(currentLessonId: 'l_01_01', iapUnlocked: false);
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Banner should be visible
    expect(find.text('Unit 1 is free — no purchase needed'), findsOneWidget);
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);

    // Tap dismiss button
    await tester.tap(closeButton);
    // Process microtasks and rebuilds
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify close button is gone
    expect(find.byIcon(Icons.close), findsNothing);
    // Verify banner text is gone
    expect(find.text('Unit 1 is free — no purchase needed'), findsNothing);
  });

  testWidgets('free banner state is persisted in preferences',
      (tester) async {
    seedProgress(currentLessonId: 'l_01_01', iapUnlocked: false);

    // First session: dismiss the banner
    await tester.pumpWidget(makeApp(unitId: 'u_01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Simulate a new test session by creating a new ProviderScope with same box
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseContentDataSourceProvider.overrideWithValue(fixtureDataSource()),
          userWordRepositoryProvider
              .overrideWithValue(UserWordRepository(wordBox)),
          userVocabProgressRepositoryProvider
              .overrideWithValue(UserVocabProgressRepository(progressBox)),
          vocabPreferencesRepositoryRawProvider
              .overrideWithValue(VocabPreferencesRepository(prefsBox)),
        ],
        child: MaterialApp(
          home: LessonListScreen(unitId: 'u_01'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Banner should still be dismissed (preference persisted)
    expect(find.text('Unit 1 is free — no purchase needed'), findsNothing);
  });

  testWidgets('no free banner on unit 2', (tester) async {
    seedProgress(currentLessonId: 'l_02_01');
    await tester.pumpWidget(makeApp(unitId: 'u_02'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Banner should not appear for unit 2
    expect(find.text('Unit 1 is free — no purchase needed'), findsNothing);
  });
}
