import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/character_card.dart';
import 'package:write_it_lao/vocab/domain/vocab_config.dart';

/// Key used by the Phase 09 integration test to locate the vocabulary tile.
const homeVocabEntryKey = Key('home.vocabEntry');

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    final lessons = charRepo.getAllLessons();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length + (VocabConfig.featureEnabled ? 1 : 0),
        itemBuilder: (context, index) {
          if (VocabConfig.featureEnabled && index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: ListTile(
                  key: homeVocabEntryKey,
                  leading: const CircleAvatar(
                    child: Icon(Icons.menu_book_outlined),
                  ),
                  title: const Text('Vocabulary — 500 Words'),
                  subtitle: const Text('Learn everyday Lao with writing practice'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/vocab'),
                ),
              ),
            );
          }
          final lessonIndex =
              VocabConfig.featureEnabled ? index - 1 : index;
          final lesson = lessons[lessonIndex];
          final progress = progressRepo.getLessonProgress(lesson.id);
          final characters = charRepo.getCharactersForLesson(lesson.id);
          final firstChar = characters.isNotEmpty ? characters.first.displayChar : '?';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LessonCard(
              title: lesson.title,
              subtitle: l10n.lessonNumber(lesson.lessonNumber),
              characterPreview: firstChar,
              stars: progress.stars,
              onTap: () => context.push('/lessons/${lesson.id}'),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              context.push('/review');
              break;
            case 2:
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
    );
  }
}
