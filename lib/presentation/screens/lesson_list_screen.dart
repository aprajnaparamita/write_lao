import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_lao/config/app_variant.dart';
import 'package:write_lao/config/theme.dart';
import 'package:write_lao/l10n/app_localizations.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/presentation/widgets/character_card.dart';
import 'package:write_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_lao/presentation/widgets/main_bottom_nav.dart';
import 'package:write_lao/vocab/providers.dart';

/// Key used by integration tests to locate the Vocabulary tab on the home screen.
const homeVocabEntryKey = Key('home.vocabEntry');

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          title: Text(l10n.appTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.push('/settings'),
            ),
          ],
          bottom: _PillTabBar(),
        ),
        body: const TabBarView(
          children: [
            _CharactersTabBody(),
            _VocabTabBody(),
          ],
        ),
        bottomNavigationBar: const MainBottomNav(currentIndex: 0),
      ),
    );
  }
}

class _PillTabBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: TabBar(
          indicator: BoxDecoration(
            color: AppTheme.accent,
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'CHARACTERS'),
            Tab(key: homeVocabEntryKey, text: 'VOCABULARY'),
          ],
        ),
      ),
    );
  }
}

class _CharactersTabBody extends ConsumerStatefulWidget {
  const _CharactersTabBody();

  @override
  ConsumerState<_CharactersTabBody> createState() => _CharactersTabBodyState();
}

class _CharactersTabBodyState extends ConsumerState<_CharactersTabBody> {
  bool _bannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuild when persisted progress changes (e.g. after a test) so stars
    // update immediately instead of only after switching tabs.
    ref.watch(progressRevProvider);
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    final lessons = charRepo.getAllLessons();


    bool iapUnlocked = false;
    try {
      iapUnlocked =
          ref.watch(userVocabProgressRepositoryProvider).getOrCreate().iapUnlocked;
    } catch (_) {}

    final currentLessonId = lessons
        .firstWhere(
          (l) => progressRepo.getLessonProgress(l.id).stars == 0,
          orElse: () => lessons.last,
        )
        .id;

    final showBanner = !_bannerDismissed && !iapUnlocked;

    final lessonsCompleted = progressRepo.totalLessonsCompleted();
    final totalLessons = charRepo.getAllLessons().length;
    final starsEarned = progressRepo.totalStarsEarned();
    final maxStars = progressRepo.maxPossibleStars();

    return CustomScrollView(
      slivers: [
        if (showBanner)
          SliverToBoxAdapter(
            child: _UpsellBanner(
              onHide: () => setState(() => _bannerDismissed = true),
              onUpgrade: () => context.push('/vocab/upsell'),
            ),
          ),
        SliverToBoxAdapter(
          child: _ProgressCard(
            lessonsCompleted: lessonsCompleted,
            totalLessons: totalLessons,
            starsEarned: starsEarned,
            maxStars: maxStars,
            onViewAll: () => context.go('/progress'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.tabLessons,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverList.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final progress = progressRepo.getLessonProgress(lesson.id);
              final characters = charRepo.getCharactersForLesson(lesson.id);
              final previews = characters.map((c) => c.displayChar).toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LessonCard(
                  title: lesson.title,
                  characterPreviews: previews,
                  stars: progress.stars,
                  isCurrent: lesson.id == currentLessonId,
                  onTap: () {
                    context.push('/lessons/${lesson.id}');
                  },
                  // Review is fully unlocked in the open-source build —
                  // every lesson can be reviewed at any time. Store builds
                  // offer review once the lesson has at least one star.
                  onReview: kVocabUnlockedByDefault || progress.stars > 0
                      ? () => context.push(
                            '/practice/${lesson.id}',
                            extra: {'characterCodepoints': lesson.characterCodepoints},
                          )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UpsellBanner extends StatelessWidget {
  final VoidCallback onHide;
  final VoidCallback onUpgrade;

  const _UpsellBanner({required this.onHide, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Practice characters while learning 500 words.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Upgrade to get access to vocabulary lessons.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onHide,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('HIDE'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onUpgrade,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'UPGRADE',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int lessonsCompleted;
  final int totalLessons;
  final int starsEarned;
  final int maxStars;
  final VoidCallback onViewAll;

  const _ProgressCard({
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.starsEarned,
    required this.maxStars,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final lessonFraction = totalLessons > 0 ? lessonsCompleted / totalLessons : 0.0;
    final starFraction = maxStars > 0 ? starsEarned / maxStars : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'VIEW ALL >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressRow(
              icon: Icons.school_outlined,
              label: '$lessonsCompleted / $totalLessons lessons',
              fraction: lessonFraction,
            ),
            const SizedBox(height: 8),
            _ProgressRow(
              icon: Icons.star_outline,
              label: '$starsEarned / $maxStars stars',
              fraction: starFraction,
              barColor: AppTheme.starGold,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double fraction;
  final Color barColor;

  const _ProgressRow({
    required this.icon,
    required this.label,
    required this.fraction,
    this.barColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 7,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _VocabTabBody extends ConsumerWidget {
  const _VocabTabBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseRepositoryProvider);
    // Material (not ColoredBox): ListTile paints its background/ink splashes
    // on the nearest Material ancestor — a colored box in between hides them.
    return Material(
      color: Colors.white,
      child: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (course) => VocabUnitListBody(
          course: course,
          onOpenUnit: (unitId) {
            context.push('/vocab/unit/$unitId');
          },
          onUpsell: () {
            context.push('/vocab/upsell');
          },
        ),
      ),
    );
  }
}

