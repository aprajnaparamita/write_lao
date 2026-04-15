import 'package:flutter/material.dart';
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
        return CustomTransitionPage(
          key: state.pageKey,
          child: PracticeScreen(lessonId: lessonId),
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
        // Get results from test controller state passed via extra
        final extra = state.extra as Map<String, dynamic>?;
        final stars = extra?['stars'] as int? ?? 0;
        final characterList = (extra?['characterList'] as List?)?.cast<String>() ?? [];

        return CustomTransitionPage(
          key: state.pageKey,
          child: TestResultScreen(
            lessonId: lessonId,
            stars: stars,
            characterList: characterList,
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
