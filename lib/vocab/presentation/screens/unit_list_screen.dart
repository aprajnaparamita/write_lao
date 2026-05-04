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
/// the global mastered counter in the AppBar. Tapping an unlocked unit fires
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
    ref.watch(vocabStateRevProvider);
    final allWords = ref.watch(userWordRepositoryProvider).getAll();
    final mastered = masteredWordCount(allWords);

    return courseAsync.when(
      loading: () {
        // ignore: avoid_print
        print('[UnitListScreen] loading state');
        return Scaffold(
          appBar: AppBar(title: const Text('Vocabulary')),
          body: const Center(child: CircularProgressIndicator()),
        );
      },
      error: (e, _) {
        // ignore: avoid_print
        print('[UnitListScreen] error: $e');
        return Scaffold(
          appBar: AppBar(title: const Text('Vocabulary')),
          body: Center(child: Text('Failed to load: $e')),
        );
      },
      data: (course) {
        // ignore: avoid_print
        print('[UnitListScreen] data loaded, units=${course.getAllUnits().length}');
        final total = course.content.words.length;
        return Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Vocabulary · 500 Words'),
                Text(
                  '$mastered / $total words mastered',
                  key: WordCardKeys.masteredCounter,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          body: VocabUnitListBody(
            course: course,
            onOpenUnit: onOpenUnit,
            onUpsell: onUpsell,
          ),
        );
      },
    );
  }
}

/// Unit list body — embeddable in a tab or a standalone Scaffold.
/// Displays every unit with lock/complete state. Does not include the
/// mastered-words counter (that lives in the AppBar of [UnitListScreen]).
class VocabUnitListBody extends ConsumerWidget {
  final CourseRepository course;
  final void Function(String unitId)? onOpenUnit;
  final VoidCallback? onUpsell;

  const VocabUnitListBody({
    super.key,
    required this.course,
    this.onOpenUnit,
    this.onUpsell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(vocabStateRevProvider);
    final progress =
        ref.watch(userVocabProgressRepositoryProvider).getOrCreate();

    final nav = CourseNavigation(course: course, progress: progress);
    final access = ContentAccess(course: course, progress: progress);
    final units = course.getAllUnits();

    return ListView.builder(
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

    final tappable = unlocked;
    final isUnit1 = unit.unitNumber == 1;
    // Show FREE badge only for unit 1, when unlocked and IAP not purchased
    final showFreeBadge = isUnit1 && unlocked && !progress.iapUnlocked && !complete;

    Widget? trailing;
    if (!unlocked) {
      trailing = Icon(
        Icons.lock_outline,
        key: WordCardKeys.unitLockBadge(unit.unitId),
      );
    } else if (complete) {
      trailing = const Icon(Icons.check_circle, color: Colors.green);
    } else if (showFreeBadge) {
      trailing = Chip(
        label: const Text(
          'FREE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    } else {
      trailing = Text('$done / $total');
    }

    // Build subtitle text with optional "Unlock required" hint for locked units
    TextStyle? subtitleStyle;
    String? subtitleText;
    if (!unlocked && unit.description.isNotEmpty) {
      subtitleText = '${unit.description} · Unlock required';
      subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          );
    }

    return ListTile(
      key: WordCardKeys.unitRow(unit.unitId),
      leading: CircleAvatar(child: Text('${unit.unitNumber}')),
      title: Text(unit.title),
      subtitle: subtitleText != null
          ? Text(subtitleText, style: subtitleStyle)
          : unit.description.isEmpty
              ? null
              : Text(unit.description),
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
