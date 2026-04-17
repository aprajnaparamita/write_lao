import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final progressRepo = ref.watch(progressRepositoryProvider);
    final charRepo = ref.watch(characterRepositoryProvider);

    final lessonsCompleted = progressRepo.totalLessonsCompleted();
    final totalLessons = charRepo.getAllLessons().length;
    final starsEarned = progressRepo.totalStarsEarned();
    final maxStars = progressRepo.maxPossibleStars();

    final phases = [
      (l10n.phaseConsonants, 1, 9),
      (l10n.phaseVowels, 2, 5),
      (l10n.phaseToneMarks, 3, 2),
      (l10n.phaseNumerals, 4, 4),
      (l10n.phaseLigatures, 5, 1),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: l10n.lessonsCompleted,
                          value: '$lessonsCompleted / $totalLessons',
                          icon: Icons.school_outlined,
                        ),
                        _StatItem(
                          label: l10n.starsEarned,
                          value: '$starsEarned / $maxStars',
                          icon: Icons.star_outline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note,
                  size: 64,
                  color: AppTheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              l10n.phaseProgress,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            ...phases.map((phase) {
              final progress = progressRepo.getPhaseProgress(phase.$2);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PhaseProgressBar(
                  phase: phase.$1,
                  phaseNumber: phase.$2,
                  completed: progress['completed'] ?? 0,
                  total: progress['total'] ?? phase.$3,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: AppTheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PhaseProgressBar extends StatelessWidget {
  final String phase;
  final int phaseNumber;
  final int completed;
  final int total;

  const _PhaseProgressBar({
    required this.phase,
    required this.phaseNumber,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            phase,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                completed == total ? AppTheme.success : AppTheme.primary,
              ),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$completed/$total',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
