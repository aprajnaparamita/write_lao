import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/character_card.dart';
import 'package:write_it_lao/vocab/presentation/screens/unit_list_screen.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Key used by integration tests to locate the Vocabulary tab on the home screen.
const homeVocabEntryKey = Key('home.vocabEntry');

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // ignore: avoid_print
    print('[LessonList] build() called');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/settings'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Writing'),
              Tab(key: homeVocabEntryKey, text: 'Vocabulary'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _WritingTabBody(),
            _VocabTabBody(),
          ],
        ),
        bottomNavigationBar: Builder(
          builder: (context) => BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  // ignore: avoid_print
                  print('[LessonList] Review tab pressed');
                  context.push('/review');
                  break;
                case 2:
                  // ignore: avoid_print
                  print('[LessonList] Progress tab pressed');
                  context.push('/progress');
                  break;
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
          ),
        ),
      ),
    );
  }
}

class _WritingTabBody extends ConsumerWidget {
  const _WritingTabBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    final lessons = charRepo.getAllLessons();

    // ignore: avoid_print
    print('[LessonList] _WritingTabBody build, lessons.length=${lessons.length}');

    final currentLessonId = lessons
        .firstWhere(
          (l) => progressRepo.getLessonProgress(l.id).stars == 0,
          orElse: () => lessons.last,
        )
        .id;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        // ignore: avoid_print
        print('[LessonList] itemBuilder index=$index lessonId=${lesson.id}');
        final progress = progressRepo.getLessonProgress(lesson.id);
        final characters = charRepo.getCharactersForLesson(lesson.id);
        final firstChar =
            characters.isNotEmpty ? characters.first.displayChar : '?';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LessonCard(
            title: lesson.title,
            subtitle: l10n.lessonNumber(lesson.lessonNumber),
            characterPreview: firstChar,
            stars: progress.stars,
            isCurrent: lesson.id == currentLessonId,
            onTap: () {
              // ignore: avoid_print
              print('[LessonList] LessonCard onTap fired: id=${lesson.id}');
              context.push('/lessons/${lesson.id}');
            },
          ),
        );
      },
    );
  }
}

class _VocabTabBody extends ConsumerWidget {
  const _VocabTabBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseRepositoryProvider);
    return courseAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load: $e')),
      data: (course) => VocabUnitListBody(
        course: course,
        onOpenUnit: (unitId) {
          // ignore: avoid_print
          print('[VocabTab] Unit tapped: $unitId');
          context.push('/vocab/unit/$unitId');
        },
        onUpsell: () {
          // ignore: avoid_print
          print('[VocabTab] Upsell triggered');
          context.push('/vocab/upsell');
        },
      ),
    );
  }
}
