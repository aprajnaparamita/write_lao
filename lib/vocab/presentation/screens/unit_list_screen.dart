import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/vocab/data/models/vocab_unit.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/content_access.dart';
import 'package:write_it_lao/vocab/domain/course_navigation.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Top-level course screen — lists every unit with completion state and
/// the global "X / 500 mastered" counter. Tapping an unlocked unit fires
/// [onOpenUnit]; locked units either open the upsell ([onUpsell]) if the
/// user has not purchased, or flash a "complete previous unit" snackbar
/// if they have.
class UnitListScreen extends ConsumerWidget {
  final void Function(String unitId)? onOpenUnit;
  final VoidCallback? onUpsell;

  const UnitListScreen({super.key, this.onOpenUnit, this.onUpsell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: avoid_print
    print('[UnitListScreen] build() called');
    final courseAsync = ref.watch(courseRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary')),
      body: courseAsync.when(
        loading: () {
          // ignore: avoid_print
          print('[UnitListScreen] loading state');
          return const Center(child: CircularProgressIndicator());
        },
        error: (e, _) {
          // ignore: avoid_print
          print('[UnitListScreen] error: $e');
          return Center(child: Text('Failed to load: $e'));
        },
        data: (course) {
          // ignore: avoid_print
          print('[UnitListScreen] data loaded, units=${course.getAllUnits().length}');
          return _UnitListBody(
            course: course,
            onOpenUnit: onOpenUnit,
            onUpsell: onUpsell,
          );
        },
      ),
    );
  }
}

class _UnitListBody extends ConsumerWidget {
  final CourseRepository course;
  final void Function(String unitId)? onOpenUnit;
  final VoidCallback? onUpsell;

  const _UnitListBody({
    required this.course,
    required this.onOpenUnit,
    required this.onUpsell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(vocabStateRevProvider);
    final progress =
        ref.watch(userVocabProgressRepositoryProvider).getOrCreate();
    final allWords = ref.watch(userWordRepositoryProvider).getAll();
    final mastered = masteredWordCount(allWords);
    final totalWords = course.content.words.length;

    final nav = CourseNavigation(course: course, progress: progress);
    final access = ContentAccess(course: course, progress: progress);
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
                access: access,
                progress: progress,
                onOpenUnit: onOpenUnit,
                onUpsell: onUpsell,
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
  final ContentAccess access;
  final UserVocabProgress progress;
  final void Function(String unitId)? onOpenUnit;
  final VoidCallback? onUpsell;

  const _UnitRow({
    required this.unit,
    required this.nav,
    required this.access,
    required this.progress,
    required this.onOpenUnit,
    required this.onUpsell,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = nav.isUnitUnlocked(unit.unitId);
    final complete = nav.isUnitComplete(unit.unitId);
    final done = nav.completedLessonCount(unit.unitId);
    final total = nav.totalLessonCount(unit.unitId);

    // Free users can enter unit 1 to reach the preview lesson, even though
    // the unit as a whole shows a lock badge until purchase.
    final freePreviewEntry =
        !progress.iapUnlocked && access.hasAccessibleContent(unit.unitId);
    final tappable = unlocked || freePreviewEntry;

    Widget? trailing;
    if (!unlocked && !freePreviewEntry) {
      trailing = Icon(
        Icons.lock_outline,
        key: WordCardKeys.unitLockBadge(unit.unitId),
      );
    } else if (freePreviewEntry) {
      // Unit has preview lessons - show play icon
      trailing = const Icon(Icons.play_circle_outline, color: Colors.blue);
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
      onTap: () {
        // ignore: avoid_print
        print('[UnitRow] onTap: unitId=${unit.unitId} tappable=$tappable');
        if (tappable) {
          onOpenUnit?.call(unit.unitId);
          return;
        }
        if (!progress.iapUnlocked) {
          onUpsell?.call();
          return;
        }
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
