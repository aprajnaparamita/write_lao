import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Shown after completing a lesson (but not the last lesson of a unit).
///
/// Displays "Lesson X complete" with an encouraging message and a Continue
/// button that returns to the lesson list.
class LessonCompleteScreen extends StatelessWidget {
  final int lessonNumber;
  final int totalWords;
  final int errors;
  final VoidCallback onContinue;

  const LessonCompleteScreen({
    super.key,
    required this.lessonNumber,
    required this.totalWords,
    required this.errors,
    required this.onContinue,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onContinue,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Lesson $lessonNumber complete',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _encouragement,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (errors > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$errors error${errors == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
                const SizedBox(height: 48),
                FilledButton(
                  key: WordCardKeys.lessonCompleteContinue,
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
