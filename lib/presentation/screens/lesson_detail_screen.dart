import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/star_rating.dart';

class LessonDetailScreen extends ConsumerWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);
    
    final lesson = charRepo.getLesson(lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson')),
        body: const Center(child: Text('Lesson not found')),
      );
    }
    
    final progress = progressRepo.getLessonProgress(lessonId);
    final characters = charRepo.getCharactersForLesson(lessonId);
    final bestTimeMs = progress.bestTimeMs;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Stars
              AnimatedStarRating(
                stars: progress.stars,
                size: 48,
              ),

              const SizedBox(height: 24),

              // Best time
              if (bestTimeMs != null) ...[
                Text(
                  'Best Time',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(bestTimeMs),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ] else ...[
                Text(
                  'Best Time',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '--:--',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Colors.grey[400],
                      ),
                ),
              ],

              const SizedBox(height: 32),

              // Character list
              Text(
                'Content',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: characters.map((char) {
                  return _CharacterBadge(char: char.displayChar);
                }).toList(),
              ),

              const Spacer(),

              // Practice button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/practice/$lessonId'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Practice'),
                ),
              ),
              const SizedBox(height: 12),

              // Test button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/test/$lessonId'),
                  icon: const Icon(Icons.timer),
                  label: const Text('Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(int ms) {
    final seconds = (ms / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _CharacterBadge extends StatelessWidget {
  final String char;

  const _CharacterBadge({required this.char});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          char,
          style: const TextStyle(
            fontFamily: 'Noto Lao',
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
