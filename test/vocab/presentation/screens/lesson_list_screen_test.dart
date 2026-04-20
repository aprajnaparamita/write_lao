import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/presentation/screens/lesson_list_screen.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

import '../../fixtures/course_fixtures.dart';

void main() {
  late Directory tempDir;
  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_lls_test_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
    wordBox = await Hive.openBox<UserWord>('lls_words');
    progressBox = await Hive.openBox<UserVocabProgress>('lls_prog');
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() {
    for (final k in wordBox.keys.toList()) {
      wordBox.delete(k);
    }
    progressBox.delete('singleton');
  });

  CourseContentDataSource fixtureDataSource() => CourseContentDataSource(
        loadString: (_) async => validBundleJson,
        assetExists: (p) async => validBundleAssetPaths.contains(p),
      );

  void seedProgress({String? currentLessonId = 'l_01_01'}) {
    final now = DateTime.utc(2026, 1, 1);
    progressBox.put(
      'singleton',
      UserVocabProgress(
        id: 'p',
        currentUnitId: 'u_01',
        currentLessonId: currentLessonId,
        iapUnlocked: true,
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
}
