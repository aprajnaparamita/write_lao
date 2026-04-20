import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/vocab/data/models/vocab_lesson.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/course_navigation.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Lesson list within a unit. Each lesson row shows word count, completion
/// state, and a small Lao preview of the new words. Locked lessons render
/// with a lock badge and don't trigger [onOpenLesson].
class LessonListScreen extends ConsumerWidget {
  final String unitId;
  final void Function(String lessonId)? onOpenLesson;

  const LessonListScreen({
    super.key,
    required this.unitId,
    this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (course) => _LessonListBody(
          course: course,
          unitId: unitId,
          onOpenLesson: onOpenLesson,
        ),
      ),
    );
  }
}

class _LessonListBody extends ConsumerWidget {
  final CourseRepository course;
  final String unitId;
  final void Function(String lessonId)? onOpenLesson;

  const _LessonListBody({
    required this.course,
    required this.unitId,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress =
        ref.watch(userVocabProgressRepositoryProvider).getOrCreate();
    final nav = CourseNavigation(course: course, progress: progress);
    final unit = course.getUnit(unitId);
    final lessons = course.getLessonsInUnit(unitId);

    if (unit == null) {
      return const Center(child: Text('Unit not found.'));
    }

    return ListView.builder(
      key: WordCardKeys.lessonList,
      itemCount: lessons.length,
      itemBuilder: (context, i) {
        final lesson = lessons[i];
        return _LessonRow(
          lesson: lesson,
          nav: nav,
          course: course,
          onOpen: onOpenLesson,
        );
      },
    );
  }
}

class _LessonRow extends StatelessWidget {
  final VocabLesson lesson;
  final CourseNavigation nav;
  final CourseRepository course;
  final void Function(String lessonId)? onOpen;

  const _LessonRow({
    required this.lesson,
    required this.nav,
    required this.course,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = nav.isLessonUnlocked(lesson.lessonId);
    final complete = nav.isLessonComplete(lesson.lessonId);
    final isCurrent = nav.isCurrentLesson(lesson.lessonId);
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
      enabled: unlocked,
      onTap: unlocked ? () => onOpen?.call(lesson.lessonId) : null,
    );
  }
}
