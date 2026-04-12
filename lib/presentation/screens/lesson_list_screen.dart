import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/character_card.dart';

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    final lessons = charRepo.getAllLessons();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WRITE IT! Lao'),
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
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final progress = progressRepo.getLessonProgress(lesson.id);
          final characters = charRepo.getCharactersForLesson(lesson.id);
          final firstChar = characters.isNotEmpty ? characters.first.char : '?';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LessonCard(
              title: lesson.title,
              subtitle: 'Lesson ${lesson.lessonNumber}',
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
              // Already on lessons
              break;
            case 1:
              context.push('/review');
              break;
            case 2:
              context.push('/progress');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'Review',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
