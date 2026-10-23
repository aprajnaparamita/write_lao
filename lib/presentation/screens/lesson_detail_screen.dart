import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_lao/config/theme.dart';
import 'package:write_lao/l10n/app_localizations.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/presentation/widgets/star_rating.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  Map<String, int> _strokeCounts = {};
  bool _loadingStrokes = true;

  @override
  void initState() {
    super.initState();
    _loadStrokeCounts();
  }

  Future<void> _loadStrokeCounts() async {
    final charRepo = ref.read(characterRepositoryProvider);
    final characters = charRepo.getCharactersForLesson(widget.lessonId);
    final strokeDataSource = ref.read(characterStrokeDataSourceProvider);
    
    final counts = <String, int>{};
    for (final char in characters) {
      final strokeData = await strokeDataSource.loadStrokeData(char.codepoint);
      counts[char.codepoint] = strokeData?.strokes.length ?? 0;
    }
    
    if (mounted) {
      setState(() {
        _strokeCounts = counts;
        _loadingStrokes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final charRepo = ref.watch(characterRepositoryProvider);
    final progressRepo = ref.watch(progressRepositoryProvider);

    final lesson = charRepo.getLesson(widget.lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.lessonLabel)),
        body: Center(child: Text(l10n.lessonNotFound)),
      );
    }

    final progress = progressRepo.getLessonProgress(widget.lessonId);
    final characters = charRepo.getCharactersForLesson(widget.lessonId);
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
        child: Column(
          children: [
            // Scrollable content — expands to fill space above the sticky buttons.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  children: [
                    AnimatedStarRating(
                      stars: progress.stars,
                      size: 48,
                    ),

                    const SizedBox(height: 24),

                    if (bestTimeMs != null) ...[
                      Text(
                        l10n.bestTime,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(bestTimeMs),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ] else ...[
                      Text(
                        l10n.bestTime,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.bestTimeEmpty,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: Colors.grey[400],
                                ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    Text(
                      l10n.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (_loadingStrokes)
                      const CircularProgressIndicator()
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: characters.map((char) {
                          final strokeCount =
                              _strokeCounts[char.codepoint] ?? 0;
                          final charProgress = progressRepo
                              .getCharacterProgress(char.codepoint);
                          final isPracticed = charProgress.practiceCount > 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _CharacterBadgeWithInfo(
                              char: char.displayChar,
                              strokeCount: strokeCount,
                              isPracticed: isPracticed,
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Sticky action buttons — always visible at the bottom.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/practice/${widget.lessonId}'),
                      icon: const Icon(Icons.edit),
                      label: Text(l10n.practice),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/test/${widget.lessonId}'),
                      icon: const Icon(Icons.timer),
                      label: Text(l10n.test),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

class _CharacterBadgeWithInfo extends StatelessWidget {
  final String char;
  final int strokeCount;
  final bool isPracticed;

  const _CharacterBadgeWithInfo({
    required this.char,
    required this.strokeCount,
    required this.isPracticed,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isPracticed ? Colors.green.shade100 : Colors.grey.shade200;
    final borderColor = isPracticed ? Colors.green.shade400 : Colors.grey.shade400;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
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
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isPracticed ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$strokeCount stroke${strokeCount == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 10,
              color: isPracticed ? Colors.green.shade700 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
