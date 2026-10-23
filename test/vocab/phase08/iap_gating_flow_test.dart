import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
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

/// Phase 08 — IAP and content gating end-to-end behavior.
///
/// Covers: upsell triggers, purchase persists `iapUnlocked = true` to Hive,
/// restore flow persists similarly, repository's `markIapUnlocked` contract.
void main() {
  late Directory tempDir;
  late Box<UserWord> wordBox;
  late Box<UserVocabProgress> progressBox;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_p8_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
    wordBox = await Hive.openBox<UserWord>('p8_words');
    progressBox = await Hive.openBox<UserVocabProgress>('p8_prog');
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

  group('UserVocabProgressRepository.markIapUnlocked', () {
    test('creates singleton with iapUnlocked=true when missing', () {
      final repo = UserVocabProgressRepository(progressBox);
      final p = repo.markIapUnlocked();
      expect(p.iapUnlocked, isTrue);
      expect(progressBox.get('singleton')?.iapUnlocked, isTrue);
    });

    test('flips existing singleton to iapUnlocked=true', () {
      final repo = UserVocabProgressRepository(progressBox);
      repo.getOrCreate(); // persist a fresh record with iapUnlocked=false
      expect(progressBox.get('singleton')?.iapUnlocked, isFalse);

      repo.markIapUnlocked();
      expect(progressBox.get('singleton')?.iapUnlocked, isTrue);
    });

    test('is idempotent when already unlocked', () {
      final repo = UserVocabProgressRepository(progressBox);
      repo.markIapUnlocked();
      final first = progressBox.get('singleton')!;
      repo.markIapUnlocked();
      final second = progressBox.get('singleton')!;
      // Not a new updatedAt bump since we short-circuit.
      expect(second.updatedAt, equals(first.updatedAt));
    });
  });

  group('UpsellScreen purchase success persists iapUnlocked', () {
    CourseContentDataSource fixtureDataSource() => CourseContentDataSource(
          loadString: (_) async => validBundleJson,
          assetExists: (p) async => validBundleAssetPaths.contains(p),
        );

    Widget makeRouterApp(IapService iap) {
      final router = GoRouter(
        initialLocation: '/vocab/upsell',
        routes: [
          GoRoute(
            path: '/vocab/upsell',
            builder: (context, state) => Consumer(
              builder: (context, ref, _) {
                final repo = ref.read(userVocabProgressRepositoryProvider);
                return UpsellScreen(
                  iapService: iap,
                  onPurchaseComplete: () {
                    repo.markIapUnlocked();
                    ref.read(vocabStateRevProvider.notifier).state++;
                  },
                  onDismissed: () {},
                );
              },
            ),
          ),
        ],
      );
      return ProviderScope(
        overrides: [
          courseContentDataSourceProvider
              .overrideWithValue(fixtureDataSource()),
          userWordRepositoryProvider
              .overrideWithValue(UserWordRepository(wordBox)),
          userVocabProgressRepositoryProvider.overrideWithValue(
            UserVocabProgressRepository(progressBox),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets('Buy Now → IapSuccess → iapUnlocked persists',
        (tester) async {
      await tester.pumpWidget(
        makeRouterApp(const MockIapService(simulateSuccess: true)),
      );
      await tester.pump();

      expect(progressBox.get('singleton')?.iapUnlocked, isNot(isTrue));

      await tester.ensureVisible(find.byKey(WordCardKeys.upsellBuyNow));
      await tester.tap(find.byKey(WordCardKeys.upsellBuyNow));
      // MockIapService delays 100ms then returns IapSuccess.
      await tester.pump(const Duration(milliseconds: 200));

      expect(progressBox.get('singleton')?.iapUnlocked, isTrue);
    });

    testWidgets('Buy Now → IapCancelled → iapUnlocked stays false',
        (tester) async {
      await tester.pumpWidget(makeRouterApp(const MockIapService()));
      await tester.pump();

      await tester.ensureVisible(find.byKey(WordCardKeys.upsellBuyNow));
      await tester.tap(find.byKey(WordCardKeys.upsellBuyNow));
      await tester.pump(const Duration(milliseconds: 200));

      expect(progressBox.get('singleton')?.iapUnlocked ?? false, isFalse);
    });
  });

  group('RestorePurchasesScreen', () {
    Widget makeApp(IapService iap) => ProviderScope(
          overrides: [
            userVocabProgressRepositoryProvider.overrideWithValue(
              UserVocabProgressRepository(progressBox),
            ),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, _) {
                final repo = ref.read(userVocabProgressRepositoryProvider);
                return RestorePurchasesScreen(
                  iapService: iap,
                  onRestoreSuccess: () {
                    repo.markIapUnlocked();
                    ref.read(vocabStateRevProvider.notifier).state++;
                  },
                  onDismiss: () {},
                );
              },
            ),
          ),
        );

    testWidgets('Restore → IapRestored → iapUnlocked persists',
        (tester) async {
      await tester.pumpWidget(
        makeApp(const MockIapService(simulateRestored: true)),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Restore Purchases'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(progressBox.get('singleton')?.iapUnlocked, isTrue);
    });

    testWidgets('Restore → IapNotRestored → iapUnlocked stays false',
        (tester) async {
      await tester.pumpWidget(makeApp(const MockIapService()));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Restore Purchases'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(progressBox.get('singleton')?.iapUnlocked ?? false, isFalse);
    });
  });

  group('UnitListScreen upsell trigger', () {
    CourseContentDataSource fixtureDataSource() => CourseContentDataSource(
          loadString: (_) async => validBundleJson,
          assetExists: (p) async => validBundleAssetPaths.contains(p),
        );

    Widget makeApp({
      required VoidCallback onUpsell,
      void Function(String)? onOpenUnit,
    }) {
      return ProviderScope(
        overrides: [
          courseContentDataSourceProvider
              .overrideWithValue(fixtureDataSource()),
          userWordRepositoryProvider
              .overrideWithValue(UserWordRepository(wordBox)),
          userVocabProgressRepositoryProvider.overrideWithValue(
            UserVocabProgressRepository(progressBox),
          ),
        ],
        child: MaterialApp(
          home: UnitListScreen(
            onOpenUnit: onOpenUnit,
            onUpsell: onUpsell,
          ),
        ),
      );
    }

    testWidgets('free user tapping locked unit 2 fires onUpsell',
        (tester) async {
      // Don't seed progress — default has iapUnlocked=false.
      var triggered = 0;
      String? opened;
      await tester.pumpWidget(makeApp(
        onUpsell: () => triggered++,
        onOpenUnit: (id) => opened = id,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(WordCardKeys.unitRow('u_02')));
      await tester.pump();

      expect(triggered, 1);
      expect(opened, isNull);
    });

    testWidgets('free user can still tap unit 1 to reach preview',
        (tester) async {
      var triggered = 0;
      String? opened;
      await tester.pumpWidget(makeApp(
        onUpsell: () => triggered++,
        onOpenUnit: (id) => opened = id,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(WordCardKeys.unitRow('u_01')));
      await tester.pump();

      expect(opened, 'u_01');
      expect(triggered, 0);
    });
  });
}
