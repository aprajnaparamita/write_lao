import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:write_lao/config/app_variant.dart';
import 'package:write_lao/presentation/screens/lesson_list_screen.dart';
import 'package:write_lao/presentation/screens/lesson_detail_screen.dart';
import 'package:write_lao/presentation/screens/practice_screen.dart';
import 'package:write_lao/presentation/screens/practice_complete_screen.dart';
import 'package:write_lao/presentation/screens/test_screen.dart';
import 'package:write_lao/presentation/screens/test_result_screen.dart';
import 'package:write_lao/presentation/screens/progress_screen.dart';
import 'package:write_lao/presentation/screens/review_screen.dart';
import 'package:write_lao/presentation/screens/settings_screen.dart';
import 'package:write_lao/presentation/screens/about_screen.dart';
import 'package:write_lao/vocab/presentation/screens/lesson_list_screen.dart'
    as vocab_lesson_list;
import 'package:write_lao/vocab/presentation/screens/restore_purchases_screen.dart';
import 'package:write_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_lao/vocab/presentation/screens/upsell_screen.dart';
import 'package:write_lao/vocab/presentation/screens/vocab_lesson_practice_screen.dart';
import 'package:write_lao/vocab/providers.dart';

final router = GoRouter(
  initialLocation: '/',
  // SentryNavigatorObserver records every route change as a navigation
  // breadcrumb and a Sentry transaction so you can track screen-level
  // performance and reproduce the user's path before a crash.
  observers: [SentryNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const LessonListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/lessons/:lessonId',
      name: 'lessonDetail',
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: LessonDetailScreen(lessonId: lessonId),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/practice/:lessonId',
      name: 'practice',
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        final characterCodepoints = (extra?['characterCodepoints'] as List?)?.cast<String>();
        return CustomTransitionPage(
          key: state.pageKey,
          child: PracticeScreen(
            lessonId: lessonId,
            characterCodepoints: characterCodepoints,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/practice/:lessonId/complete',
      name: 'practiceComplete',
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        final characterList = (extra?['characterList'] as List?)?.cast<String>() ?? [];

        return CustomTransitionPage(
          key: state.pageKey,
          child: PracticeCompleteScreen(
            lessonId: lessonId,
            characterList: characterList,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/test/:lessonId',
      name: 'test',
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: TestScreen(
            lessonId: lessonId,
            onComplete: () {
              context.push('/test/$lessonId/result');
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/test/:lessonId/result',
      name: 'testResult',
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';

        return CustomTransitionPage(
          key: state.pageKey,
          child: TestResultScreen(
            lessonId: lessonId,
            onPracticePressed: () => context.go('/practice/$lessonId'),
            onTestAgainPressed: () => context.go('/test/$lessonId'),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                ),
                child: child,
              ),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/progress',
      name: 'progress',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ProgressScreen(),
      ),
    ),
    GoRoute(
      path: '/review',
      name: 'review',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ReviewScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/vocab',
      name: 'vocab',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: UnitListScreen(
            onOpenUnit: (unitId) {
              context.push('/vocab/unit/$unitId');
            },
            onUpsell: () {
              context.push('/vocab/upsell');
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/vocab/unit/:unitId',
      name: 'vocabUnit',
      pageBuilder: (context, state) {
        final unitId = state.pathParameters['unitId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: vocab_lesson_list.LessonListScreen(
            unitId: unitId,
            onOpenLesson: (lessonId) {
              context.push('/vocab/unit/$unitId/lesson/$lessonId');
            },
            onUpsell: () => context.push('/vocab/upsell'),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/vocab/unit/:unitId/lesson/:lessonId',
      name: 'vocabLesson',
      pageBuilder: (context, state) {
        final unitId = state.pathParameters['unitId'] ?? '';
        final lessonId = state.pathParameters['lessonId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: VocabLessonPracticeScreen(
            unitId: unitId,
            lessonId: lessonId,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/vocab/review/:deckId',
      name: 'vocabReview',
      pageBuilder: (context, state) {
        final deckId = state.pathParameters['deckId'] ?? '';
        return CustomTransitionPage(
          key: state.pageKey,
          child: Consumer(
            builder: (context, ref, _) {
              final deck =
                  ref.read(flagDeckRepositoryProvider).getDeck(deckId);
              return VocabLessonPracticeScreen.deckReview(
                deckId: deckId,
                title: deck?.name ?? 'Review',
              );
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/vocab/upsell',
      name: 'vocabUpsell',
      // Open-source builds ship everything unlocked; there is nothing
      // to buy, so the paywall is unreachable.
      redirect: kVocabUnlockedByDefault ? (context, state) => '/vocab' : null,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Consumer(
          builder: (context, ref, _) {
            final iap = ref.read(iapServiceProvider);
            final progressRepo =
                ref.read(userVocabProgressRepositoryProvider);
            // Localized StoreKit price; null while loading or unreachable.
            final priceLabel =
                ref.watch(iapPriceLabelProvider).valueOrNull;
            return UpsellScreen(
              iapService: iap,
              priceLabel: priceLabel,
              onPurchaseComplete: () {
                progressRepo.markIapUnlocked();
                ref.read(vocabStateRevProvider.notifier).state++;
                if (context.mounted) context.pop();
              },
              onDismissed: () => context.pop(),
              onRestore: () => context.push('/vocab/restore'),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/vocab/restore',
      name: 'vocabRestore',
      // Nothing to restore in open-source builds.
      redirect:
          kVocabUnlockedByDefault ? (context, state) => '/settings' : null,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Consumer(
          builder: (context, ref, _) {
            final iap = ref.read(iapServiceProvider);
            final progressRepo =
                ref.read(userVocabProgressRepositoryProvider);
            return RestorePurchasesScreen(
              iapService: iap,
              onRestoreSuccess: () {
                progressRepo.markIapUnlocked();
                ref.read(vocabStateRevProvider.notifier).state++;
              },
              onDismiss: () => context.pop(),
            );
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/about',
      name: 'about',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const AboutScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ),
  ],
);
