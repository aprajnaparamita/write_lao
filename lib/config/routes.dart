import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/presentation/screens/lesson_list_screen.dart';
import 'package:write_it_lao/presentation/screens/lesson_detail_screen.dart';
import 'package:write_it_lao/presentation/screens/practice_screen.dart';
import 'package:write_it_lao/presentation/screens/practice_complete_screen.dart';
import 'package:write_it_lao/presentation/screens/test_screen.dart';
import 'package:write_it_lao/presentation/screens/test_result_screen.dart';
import 'package:write_it_lao/presentation/screens/progress_screen.dart';
import 'package:write_it_lao/presentation/screens/review_screen.dart';
import 'package:write_it_lao/presentation/screens/settings_screen.dart';
import 'package:write_it_lao/presentation/screens/about_screen.dart';
import 'package:write_it_lao/vocab/presentation/screens/lesson_list_screen.dart'
    as vocab_lesson_list;
import 'package:write_it_lao/vocab/presentation/screens/restore_purchases_screen.dart';
import 'package:write_it_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_it_lao/vocab/presentation/screens/upsell_screen.dart';
import 'package:write_it_lao/vocab/providers.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LessonListScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ProgressScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/review',
      name: 'review',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const ReviewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
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
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: UnitListScreen(
          onOpenUnit: (unitId) => context.push('/vocab/unit/$unitId'),
          onUpsell: () => context.push('/vocab/upsell'),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
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
              // Lesson flow wiring is future work; for now pop back.
              // A real host can navigate to /vocab/unit/:unitId/lesson/:lessonId.
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
      path: '/vocab/upsell',
      name: 'vocabUpsell',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: Consumer(
          builder: (context, ref, _) {
            final iap = ref.read(iapServiceProvider);
            final progressRepo =
                ref.read(userVocabProgressRepositoryProvider);
            return UpsellScreen(
              iapService: iap,
              onPurchaseComplete: () {
                progressRepo.markIapUnlocked();
                ref.read(vocabStateRevProvider.notifier).state++;
                if (context.mounted) context.pop();
              },
              onDismissed: () => context.pop(),
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
