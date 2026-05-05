import 'package:flutter/material.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Shown after completing a vocab lesson.
class LessonCompleteScreen extends StatelessWidget {
  final int lessonNumber;
  final int totalWords;
  final int errors;
  final VoidCallback onContinue;
  final String? nextLessonLabel;

  /// Lao word strings to display in the card grid. When null no grid is shown.
  final List<String>? practicedWords;

  const LessonCompleteScreen({
    super.key,
    required this.lessonNumber,
    required this.totalWords,
    required this.errors,
    required this.onContinue,
    this.nextLessonLabel,
    this.practicedWords,
  });

  int get _stars {
    if (errors == 0) return 3;
    if (errors <= 1) return 2;
    if (totalWords > 0 && errors <= totalWords ~/ 3) return 2;
    return 1;
  }

  String get _encouragement {
    if (errors == 0) return 'Perfect score! 🎉';
    if (errors <= 1) return 'Great job!';
    if (totalWords > 0 && errors <= totalWords ~/ 3) return 'Well done!';
    return 'Keep practicing!';
  }

  @override
  Widget build(BuildContext context) {
    final words = practicedWords;
    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lesson Complete',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                children: [
                  _buildStars(context),
                  const SizedBox(height: 20),
                  Text(
                    'Lesson $lessonNumber complete',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You practiced $totalWords words'
                    '${errors > 0 ? ' · $errors error${errors == 1 ? '' : 's'}' : ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _encouragement,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (words != null && words.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: words.length,
                      itemBuilder: (context, index) =>
                          _WordCard(laoWord: words[index]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildStars(BuildContext context) {
    final earned = _stars;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isEarned = index < earned;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            isEarned ? Icons.star_rounded : Icons.star_border_rounded,
            size: 64,
            color: isEarned ? AppTheme.starGold : Colors.white24,
          ),
        );
      }),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              key: WordCardKeys.lessonCompleteContinue,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onContinue,
              child: const Text(
                'CONTINUE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
          if (nextLessonLabel != null) ...[
            const SizedBox(height: 10),
            Text(
              key: WordCardKeys.lessonCompleteNextLabel,
              'Next: $nextLessonLabel',
              style: const TextStyle(color: Colors.white60, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _WordCard extends StatelessWidget {
  final String laoWord;

  const _WordCard({required this.laoWord});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              laoWord,
              style: const TextStyle(
                fontFamily: 'Noto Lao',
                fontSize: 32,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
