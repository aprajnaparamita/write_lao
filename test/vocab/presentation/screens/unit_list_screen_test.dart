import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

import '../../fixtures/course_fixtures.dart';

void main() {
  late Directory tempDir;
  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_uls_test_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
    wordBox = await Hive.openBox<UserWord>('uls_words');
    progressBox = await Hive.openBox<UserVocabProgress>('uls_prog');
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

  void seedProgress({
    required bool iapUnlocked,
    String? currentLessonId = 'l_01_01',
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

  void seedWord(String wordId, WordStatus status) {
    final now = DateTime.utc(2026, 1, 1);
    final uw = UserWord(
      id: 'uw-$wordId',
      wordId: wordId,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
    wordBox.put(uw.id, uw);
  }

  Widget makeApp({void Function(String)? onOpenUnit}) {
    return ProviderScope(
      overrides: [
        courseContentDataSourceProvider.overrideWithValue(fixtureDataSource()),
        userWordRepositoryProvider
            .overrideWithValue(UserWordRepository(wordBox)),
        userVocabProgressRepositoryProvider
            .overrideWithValue(UserVocabProgressRepository(progressBox)),
      ],
      child: MaterialApp(home: UnitListScreen(onOpenUnit: onOpenUnit)),
    );
  }

  testWidgets('shows every unit in the bundle', (tester) async {
    seedProgress(iapUnlocked: true);
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(WordCardKeys.unitRow('u_01')), findsOneWidget);
    expect(find.byKey(WordCardKeys.unitRow('u_02')), findsOneWidget);
    expect(find.text('Greetings'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
  });

  testWidgets('locked units render a lock badge', (tester) async {
    seedProgress(iapUnlocked: true, currentLessonId: 'l_01_01');
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsOneWidget);
    expect(find.byKey(WordCardKeys.unitLockBadge('u_01')), findsNothing);
  });

  testWidgets('unit 1 is free, unit 2+ are locked when iap is not purchased',
      (tester) async {
    seedProgress(iapUnlocked: false, currentLessonId: 'l_01_01');
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(WordCardKeys.unitLockBadge('u_01')), findsNothing);
    expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsOneWidget);
  });

  testWidgets('tapping an unlocked unit fires onOpenUnit', (tester) async {
    seedProgress(iapUnlocked: true);
    String? opened;
    await tester.pumpWidget(makeApp(onOpenUnit: (id) => opened = id));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(WordCardKeys.unitRow('u_01')));
    await tester.pump();

    expect(opened, 'u_01');
  });

  testWidgets('tapping a locked unit does NOT fire onOpenUnit',
      (tester) async {
    seedProgress(iapUnlocked: true, currentLessonId: 'l_01_01');
    String? opened;
    await tester.pumpWidget(makeApp(onOpenUnit: (id) => opened = id));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(WordCardKeys.unitRow('u_02')));
    await tester.pump();

    expect(opened, isNull);
  });

  testWidgets('global mastered counter reflects mature/retired counts',
      (tester) async {
    seedProgress(iapUnlocked: true);
    seedWord('w_0001', WordStatus.mature);
    seedWord('w_0002', WordStatus.retired);
    seedWord('w_0003', WordStatus.learning);
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final counter =
        tester.widget<Text>(find.byKey(WordCardKeys.masteredCounter));
    expect(counter.data, '2 / 10 words mastered');
  });

  testWidgets('unit 1 shows FREE badge when not IAP purchased', (tester) async {
    seedProgress(iapUnlocked: false, currentLessonId: 'l_01_01');
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should NOT have lock on unit 1
    expect(find.byKey(WordCardKeys.unitLockBadge('u_01')), findsNothing);
    // Should show FREE badge text
    expect(find.text('FREE'), findsOneWidget);
  });

  testWidgets('locked units show "Unlock required" in subtitle',
      (tester) async {
    seedProgress(iapUnlocked: false, currentLessonId: 'l_01_01');
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Scroll to make sure unit 2 is visible
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Unit 2 should have a subtitle containing "Unlock required"
    final unit2Tile = find.byKey(WordCardKeys.unitRow('u_02'));
    expect(unit2Tile, findsOneWidget);

    // Find the Text widget that is a descendant of the unit 2 ListTile
    final subtitleFinder = find.descendant(
      of: unit2Tile,
      matching: find.byWidgetPredicate(
        (w) => w is Text && w.data != null && w.data!.contains('Unlock required'),
      ),
    );
    expect(subtitleFinder, findsOneWidget);
  });

  testWidgets('unit 1 does not show FREE badge when IAP is purchased',
      (tester) async {
    seedProgress(iapUnlocked: true);
    await tester.pumpWidget(makeApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Should show progress instead of FREE badge
    expect(find.text('FREE'), findsNothing);
    // Unit 1 should show lesson progress
    expect(find.text('0 / 2'), findsOneWidget);
  });
}
