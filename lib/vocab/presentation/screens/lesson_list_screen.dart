import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/vocab/data/models/vocab_lesson.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/content_access.dart';
import 'package:write_it_lao/vocab/domain/course_navigation.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Lesson list within a unit. Each lesson row shows word count, completion
/// state, and a small Lao preview of the new words. Locked lessons render
/// with a lock badge. For free users, lesson 1 of unit 1 is the preview
/// and remains tappable; tapping any other locked lesson fires [onUpsell].
class LessonListScreen extends ConsumerWidget {
  final String unitId;
  final void Function(String lessonId)? onOpenLesson;
  final VoidCallback? onUpsell;

  const LessonListScreen({
    super.key,
    required this.unitId,
    this.onOpenLesson,
    this.onUpsell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: avoid_print
    print('[VocabLessonListScreen] build() called for unitId=$unitId');
    final courseAsync = ref.watch(courseRepositoryProvider);
    return courseAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Lessons')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) {
        // ignore: avoid_print
        print('[VocabLessonListScreen] error: $e');
        return Scaffold(
          appBar: AppBar(title: const Text('Lessons')),
          body: Center(child: Text('Failed to load: $e')),
        );
      },
      data: (course) {
        // ignore: avoid_print
        print('[VocabLessonListScreen] data loaded, unitId=$unitId');
        return _LessonListBody(
          course: course,
          unitId: unitId,
          onOpenLesson: onOpenLesson,
          onUpsell: onUpsell,
        );
      },
    );
  }
}

class _LessonListBody extends ConsumerWidget {
  final CourseRepository course;
  final String unitId;
  final void Function(String lessonId)? onOpenLesson;
  final VoidCallback? onUpsell;

  const _LessonListBody({
    required this.course,
    required this.unitId,
    required this.onOpenLesson,
    required this.onUpsell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(vocabStateRevProvider);
    // Always watch preferences so we re-read Hive on every rebuild
    ref.watch(vocabPreferencesRepositoryRawProvider);
    final progress =
        ref.watch(userVocabProgressRepositoryProvider).getOrCreate();
    final nav = CourseNavigation(course: course, progress: progress);
    final access = ContentAccess(course: course, progress: progress);
    final unit = course.getUnit(unitId);
    final lessons = course.getLessonsInUnit(unitId);

    if (unit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lessons')),
        body: const Center(child: Text('Unit not found.')),
      );
    }

    final isUnit1 = unit.unitNumber == 1;
    final prefs = ref.watch(vocabPreferencesRepositoryRawProvider);
    // Watch the banner rev so this widget rebuilds when banner is dismissed
    ref.watch(vocabBannerDismissRevProvider);
    final showFreeBanner = isUnit1 && !access.hasPurchased && !prefs.unit1BannerDismissed;

    // Show an upsell card pinned below the lesson list only in unit 1 when
    // the rest of the content is still locked.
    final showUpsellCard = isUnit1 && !access.hasPurchased;
    final listItemCount = lessons.length + (showUpsellCard ? 1 : 0);

    final appBarTitle = 'Unit ${unit.unitNumber} · ${unit.title}';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Column(
        children: [
          if (showFreeBanner) _FreeUnitBanner(),
          Expanded(
            child: ListView.builder(
              key: WordCardKeys.lessonList,
              itemCount: listItemCount,
              itemBuilder: (context, i) {
                // Last item: upsell card.
                if (showUpsellCard && i == lessons.length) {
                  return _VocabUpsellCard(onUpgrade: onUpsell);
                }
                final lesson = lessons[i];
                return _LessonRow(
                  lesson: lesson,
                  nav: nav,
                  access: access,
                  course: course,
                  onOpen: onOpenLesson,
                  onUpsell: onUpsell,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeUnitBanner extends ConsumerWidget {
  const _FreeUnitBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch preferences so this widget rebuilds when Hive changes
    ref.watch(vocabPreferencesRepositoryRawProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unit 1 is free — no purchase needed',
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20, color: Colors.green.shade700),
                onPressed: () {
                  final repo = ref.read(vocabPreferencesRepositoryRawProvider);
                  repo.dismissUnit1Banner();
                  ref.read(vocabBannerDismissRevProvider.notifier).state++;
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Dismiss',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final VocabLesson lesson;
  final CourseNavigation nav;
  final ContentAccess access;
  final CourseRepository course;
  final void Function(String lessonId)? onOpen;
  final VoidCallback? onUpsell;

  const _LessonRow({
    required this.lesson,
    required this.nav,
    required this.access,
    required this.course,
    required this.onOpen,
    required this.onUpsell,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = nav.isLessonUnlocked(lesson.lessonId);
    final complete = nav.isLessonComplete(lesson.lessonId);
    final isCurrent = nav.isCurrentLesson(lesson.lessonId);
    final inPreview = access.isInFreePreview(lesson.lessonId);
    final tappable = unlocked || inPreview;

    final words = lesson.newWordIds
        .map(course.getWord)
        .whereType<VocabWord>()
        .toList();
    final preview = words.map((w) => w.laoWord).join(' · ');

    Widget? trailing;
    if (!unlocked) {
      trailing = Icon(
        Icons.lock_outline,
        key: WordCardKeys.lessonLockBadge(lesson.lessonId),
      );
    } else if (complete) {
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else if (isCurrent) {
      trailing = const Icon(Icons.play_circle_fill);
    } else {
      trailing = Text('${lesson.newWordIds.length} new');
    }

    return ListTile(
      key: WordCardKeys.lessonRow(lesson.lessonId),
      title: Text('Lesson ${lesson.lessonNumber}'),
      subtitle: Text(preview.isEmpty ? '—' : preview),
      trailing: trailing,
      onTap: () {
        // ignore: avoid_print
        print('[LessonRow] onTap: lessonId=${lesson.lessonId} tappable=$tappable');
        if (tappable) {
          onOpen?.call(lesson.lessonId);
          return;
        }
        if (!access.hasPurchased) {
          onUpsell?.call();
        }
      },
    );
  }
}

// ── _VocabUpsellCard ──────────────────────────────────────────────────────────

/// Upsell card shown as the last item in unit 1's lesson list while content
/// is still locked. Tapping anywhere on the card — or the UNLOCK button —
/// navigates to the purchase screen via [onUpgrade].
class _VocabUpsellCard extends StatelessWidget {
  final VoidCallback? onUpgrade;

  const _VocabUpsellCard({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: GestureDetector(
        onTap: onUpgrade,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accent, AppTheme.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + headline row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep going with 500 words',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Unlock all units — stroke-by-stroke practice, '
                            'spaced repetition, and one-time purchase.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Feature chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Chip(Icons.repeat_rounded, 'Spaced repetition'),
                    _Chip(Icons.edit_note_rounded, 'Stroke practice'),
                    _Chip(Icons.all_inclusive_rounded, 'All 10 units'),
                  ],
                ),

                const SizedBox(height: 16),

                // CTA button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onUpgrade,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'UNLOCK ALL CONTENT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
