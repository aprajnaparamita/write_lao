import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:write_lao/l10n/app_localizations.dart';

/// Shared bottom navigation bar for the three main screens (Lessons, Review, Progress).
/// Pass [currentIndex] 0, 1, or 2 for the active tab.
class MainBottomNav extends StatelessWidget {
  final int currentIndex;

  const MainBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
          case 1:
            context.go('/review');
          case 2:
            context.go('/progress');
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.menu_book),
          label: l10n.tabLessons,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.refresh),
          label: l10n.tabReview,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: l10n.tabProgress,
        ),
      ],
    );
  }
}
