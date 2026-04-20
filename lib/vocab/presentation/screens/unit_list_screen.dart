import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/vocab/data/models/vocab_unit.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/course_navigation.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Top-level course screen — lists every unit with completion state and
/// the global "X / 500 mastered" counter. Tapping an unlocked unit fires
/// [onOpenUnit]; locked units flash a brief snackbar.
class UnitListScreen extends ConsumerWidget {
  final void Function(String unitId)? onOpenUnit;

  const UnitListScreen({super.key, this.onOpenUnit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary')),
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (course) => _UnitListBody(
          course: course,
          onOpenUnit: onOpenUnit,
        ),
      ),
    );
  }
}

class _UnitListBody extends ConsumerWidget {
  final CourseRepository course;
  final void Function(String unitId)? onOpenUnit;

  const _UnitListBody({required this.course, required this.onOpenUnit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userVocabProgressRepositoryProvider).getOrCreate();
    final allWords = ref.watch(userWordRepositoryProvider).getAll();
    final mastered = masteredWordCount(allWords);
    final totalWords = course.content.words.length;

    final nav = CourseNavigation(course: course, progress: progress);
    final units = course.getAllUnits();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$mastered / $totalWords words mastered',
            key: WordCardKeys.masteredCounter,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            key: WordCardKeys.unitList,
            itemCount: units.length,
            itemBuilder: (context, i) {
              final unit = units[i];
              return _UnitRow(
                unit: unit,
                nav: nav,
                onOpenUnit: onOpenUnit,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UnitRow extends StatelessWidget {
  final VocabUnit unit;
  final CourseNavigation nav;
  final void Function(String unitId)? onOpenUnit;

  const _UnitRow({
    required this.unit,
    required this.nav,
    required this.onOpenUnit,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = nav.isUnitUnlocked(unit.unitId);
    final complete = nav.isUnitComplete(unit.unitId);
    final done = nav.completedLessonCount(unit.unitId);
    final total = nav.totalLessonCount(unit.unitId);

    Widget? trailing;
    if (!unlocked) {
      trailing = Icon(
        Icons.lock_outline,
        key: WordCardKeys.unitLockBadge(unit.unitId),
      );
    } else if (complete) {
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else {
      trailing = Text('$done / $total');
    }

    return ListTile(
      key: WordCardKeys.unitRow(unit.unitId),
      leading: CircleAvatar(child: Text('${unit.unitNumber}')),
      title: Text(unit.title),
      subtitle: unit.description.isEmpty ? null : Text(unit.description),
      trailing: trailing,
      enabled: unlocked,
      onTap: unlocked
          ? () => onOpenUnit?.call(unit.unitId)
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Complete unit ${unit.unitNumber - 1} to unlock.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
    );
  }
}
