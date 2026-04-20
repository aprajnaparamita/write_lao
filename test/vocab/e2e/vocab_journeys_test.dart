import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/domain/iap_service.dart';
import 'package:write_it_lao/vocab/presentation/screens/restore_purchases_screen.dart';
import 'package:write_it_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_it_lao/vocab/presentation/screens/upsell_screen.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

import '../fixtures/course_fixtures.dart';

/// Phase 10 — end-to-end journeys.
///
/// These tests drive the real GoRouter + UnitListScreen + UpsellScreen +
/// RestorePurchasesScreen stack against Hive-backed repositories using
/// the fixture course bundle. They cover:
///
///   * Journey 1 (partial): free user → upsell → purchase → all units
///     unlock. The lesson-flow half of Journey 1 (preview completion
///     drives SRS state) is deferred until the lesson runner is wired
///     at `/vocab/unit/:unitId/lesson/:lessonId`.
///   * Journey 5: Restore Purchases flips `iap_unlocked` and the unit
///     list re-renders without the lock badges.
///   * Journey 6: a fully-mastered course shows the 10/10 counter and
///     retired words count as mastered alongside mature ones.
///
/// Journeys 2, 3, 4 require the lesson flow (SRS mix, flag deck UI,
/// hear-and-identify widget) — tracked separately in DECISIONS.md.
void main() {
  late Directory tempDir;
  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_e2e_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
    wordBox = await Hive.openBox<UserWord>('e2e_words');
    progressBox = await Hive.openBox<UserVocabProgress>('e2e_prog');
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

  List<Override> baseOverrides(IapService iap) => [
        courseContentDataSourceProvider.overrideWithValue(fixtureDataSource()),
        userWordRepositoryProvider
            .overrideWithValue(UserWordRepository(wordBox)),
        userVocabProgressRepositoryProvider.overrideWithValue(
          UserVocabProgressRepository(progressBox),
        ),
        iapServiceProvider.overrideWithValue(iap),
      ];

  GoRouter buildRouter() => GoRouter(
        initialLocation: '/vocab',
        routes: [
          GoRoute(
            path: '/vocab',
            builder: (context, state) => UnitListScreen(
              onOpenUnit: (unitId) => context.push('/vocab/unit/$unitId'),
              onUpsell: () => context.push('/vocab/upsell'),
            ),
          ),
          GoRoute(
            path: '/vocab/unit/:unitId',
            builder: (context, state) =>
                const Scaffold(body: Text('unit-placeholder')),
          ),
          GoRoute(
            path: '/vocab/upsell',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) {
                final iap = ref.read(iapServiceProvider);
                final repo = ref.read(userVocabProgressRepositoryProvider);
                return UpsellScreen(
                  iapService: iap,
                  onPurchaseComplete: () {
                    repo.markIapUnlocked();
                    ref.read(vocabStateRevProvider.notifier).state++;
                    if (context.mounted) context.pop();
                  },
                  onDismissed: () => context.pop(),
                );
              },
            ),
          ),
          GoRoute(
            path: '/vocab/restore',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) {
                final iap = ref.read(iapServiceProvider);
                final repo = ref.read(userVocabProgressRepositoryProvider);
                return RestorePurchasesScreen(
                  iapService: iap,
                  onRestoreSuccess: () {
                    repo.markIapUnlocked();
                    ref.read(vocabStateRevProvider.notifier).state++;
                  },
                  onDismiss: () => context.pop(),
                );
              },
            ),
          ),
        ],
      );

  Widget makeApp(IapService iap) => ProviderScope(
        overrides: baseOverrides(iap),
        child: MaterialApp.router(routerConfig: buildRouter()),
      );

  group('Journey 1 (partial) — free user upsell → purchase → unlock', () {
    testWidgets(
      'locked unit 2 opens upsell, successful purchase persists '
      'iap_unlocked and the lock badge disappears',
      (tester) async {
        await tester
            .pumpWidget(makeApp(const MockIapService(simulateSuccess: true)));
        await tester.pumpAndSettle();

        // Free user: unit 2 shows a lock badge.
        expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsOneWidget);
        expect(progressBox.get('singleton')?.iapUnlocked ?? false, isFalse);

        // Tap locked unit 2 → routed to upsell.
        await tester.tap(find.byKey(WordCardKeys.unitRow('u_02')));
        await tester.pumpAndSettle();
        expect(find.byKey(WordCardKeys.upsellBuyNow), findsOneWidget);

        // Buy now → mock IAP returns success after 100 ms.
        await tester.tap(find.byKey(WordCardKeys.upsellBuyNow));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // Persisted to Hive.
        expect(progressBox.get('singleton')?.iapUnlocked, isTrue);

        // Back on UnitListScreen, unit 2's lock badge is gone.
        expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsNothing);
      },
    );

    testWidgets(
      'cancelling the purchase leaves iap_unlocked false and keeps the '
      'lock badge on unit 2',
      (tester) async {
        await tester.pumpWidget(makeApp(const MockIapService()));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(WordCardKeys.unitRow('u_02')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(WordCardKeys.upsellBuyNow));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // MockIapService defaults to cancelled → stay on upsell.
        expect(find.byKey(WordCardKeys.upsellBuyNow), findsOneWidget);
        expect(progressBox.get('singleton')?.iapUnlocked ?? false, isFalse);

        // Dismiss upsell → back on unit list, badge still there.
        await tester.tap(find.byKey(WordCardKeys.upsellMaybeLater));
        await tester.pumpAndSettle();
        expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsOneWidget);
      },
    );
  });

  group('Journey 5 — Restore Purchases', () {
    testWidgets(
      'a successful restore flips iap_unlocked and the unit list unlocks',
      (tester) async {
        // Start fresh on the restore screen.
        final router = GoRouter(
          initialLocation: '/vocab/restore',
          routes: [
            GoRoute(
              path: '/vocab',
              builder: (context, state) => UnitListScreen(
                onOpenUnit: (_) {},
                onUpsell: () {},
              ),
            ),
            GoRoute(
              path: '/vocab/restore',
              builder: (context, state) => Consumer(
                builder: (context, ref, _) {
                  final iap = ref.read(iapServiceProvider);
                  final repo = ref.read(userVocabProgressRepositoryProvider);
                  return RestorePurchasesScreen(
                    iapService: iap,
                    onRestoreSuccess: () {
                      repo.markIapUnlocked();
                      ref.read(vocabStateRevProvider.notifier).state++;
                    },
                    onDismiss: () => context.go('/vocab'),
                  );
                },
              ),
            ),
          ],
        );

        await tester.pumpWidget(ProviderScope(
          overrides:
              baseOverrides(const MockIapService(simulateRestored: true)),
          child: MaterialApp.router(routerConfig: router),
        ));
        await tester.pumpAndSettle();

        expect(progressBox.get('singleton')?.iapUnlocked ?? false, isFalse);

        await tester
            .tap(find.widgetWithText(FilledButton, 'Restore Purchases'));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        expect(progressBox.get('singleton')?.iapUnlocked, isTrue);

        // Continue button navigates back to the unit list with everything
        // unlocked.
        await tester.tap(find.byKey(WordCardKeys.restoreContinue));
        await tester.pumpAndSettle();
        expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsNothing);
      },
    );
  });

  group('Journey 6 — course completion', () {
    testWidgets(
      'seeding every fixture word as mature/retired shows 10/10 mastered '
      'and every unit reads complete',
      (tester) async {
        final now = DateTime.now().toUtc();
        // Paid user, course walked past the last lesson: engine sets
        // currentLessonId to null when the course is finished.
        progressBox.put(
          'singleton',
          UserVocabProgress(
            id: 'p1',
            iapUnlocked: true,
            currentUnitId: null,
            currentLessonId: null,
            unitsCompleted: 2,
            lessonsCompleted: 3,
            createdAt: now,
            updatedAt: now,
          ),
        );
        // Fixture has 10 words — half mature, half retired. Both count as
        // mastered per `masteredWordCount`.
        for (var i = 1; i <= 10; i++) {
          final id = 'uw_$i';
          final wordId = 'w_${i.toString().padLeft(4, '0')}';
          final status = i <= 5 ? WordStatus.mature : WordStatus.retired;
          wordBox.put(
            id,
            UserWord(
              id: id,
              wordId: wordId,
              status: status,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }

        await tester.pumpWidget(makeApp(const MockIapService()));
        await tester.pumpAndSettle();

        // "10 / 10 words mastered" — fixture totals.
        final counter = tester.widget<Text>(
          find.byKey(WordCardKeys.masteredCounter),
        );
        expect(counter.data, '10 / 10 words mastered');

        // Neither unit shows a lock badge — IAP is unlocked and both are
        // complete (current lesson is null, so every lesson's canonical
        // index is strictly less than "current"). Completion trailing icon
        // replaces the progress text.
        expect(find.byKey(WordCardKeys.unitLockBadge('u_01')), findsNothing);
        expect(find.byKey(WordCardKeys.unitLockBadge('u_02')), findsNothing);
        expect(find.byIcon(Icons.check_circle), findsNWidgets(2));
      },
    );
  });
}
