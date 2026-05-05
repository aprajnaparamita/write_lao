import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Shown after completing a vocab lesson.
///
/// Displays "Lesson X complete" with an encouraging message, a Continue
/// button that returns to the lesson list, and an optional preview of
/// the next lesson.
class LessonCompleteScreen extends StatelessWidget {
  final int lessonNumber;
  final int totalWords;
  final int errors;
  final VoidCallback onContinue;

  /// Label shown below the Continue button, e.g. "Lesson 3 — ສະ ບາຍ ດີ".
  /// If null, no next-lesson preview is shown.
  final String? nextLessonLabel;

  const LessonCompleteScreen({
    super.key,
    required this.lessonNumber,
    required this.totalWords,
    required this.errors,
    required this.onContinue,
    this.nextLessonLabel,
  });

  String get _encouragement {
    if (errors == 0) return 'Perfect score! 🎉';
    if (errors <= 1) return 'Great job!';
    if (errors <= totalWords ~/ 3) return 'Well done!';
    return 'Keep practicing!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Complete'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Lesson $lessonNumber complete',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You practiced $totalWords words'
                '${errors > 0 ? ' · $errors error${errors == 1 ? '' : 's'}' : ''}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                _encouragement,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                key: WordCardKeys.lessonCompleteContinue,
                onPressed: onContinue,
                child: const Text('Continue'),
              ),
              if (nextLessonLabel != null) ...[
                const SizedBox(height: 12),
                Text(
                  key: WordCardKeys.lessonCompleteNextLabel,
                  'Next: $nextLessonLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
