import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/data/models/lesson.dart';
import 'package:write_it_lao/data/models/quiz_result.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';

class QuizService {
  /// Start a new quiz for a lesson. Returns the sequence of characters.
  List<LaoCharacter> startQuiz(Lesson lesson, CharacterRepository charRepo) {
    return charRepo.getCharactersForLesson(lesson.id);
  }

  /// Calculate stars based on quiz performance.
  /// 
  /// Star thresholds:
  /// - 3 stars: 0 hints used AND time <= (characterCount × 10 seconds)
  /// - 2 stars: 0 hints used AND time > (characterCount × 10 seconds)
  /// - 1 star: 1+ hints used
  int calculateStars({
    required int totalCharacters,
    required int hintsUsed,
    required int totalTimeMs,
  }) {
    if (hintsUsed > 0) {
      return 1;
    }

    final maxTimeMs = totalCharacters * 10 * 1000; // 10 seconds per character

    if (totalTimeMs <= maxTimeMs) {
      return 3;
    } else {
      return 2;
    }
  }

  /// Create a QuizResult from the completed quiz data.
  QuizResult createResult({
    required String lessonId,
    required List<CharacterAttempt> attempts,
    required int totalTimeMs,
    int hintsUsed = 0,
  }) {
    final totalCharacters = attempts.length;
    final correctCharacters = attempts.where((a) => a.correct).length;

    final stars = calculateStars(
      totalCharacters: totalCharacters,
      hintsUsed: hintsUsed,
      totalTimeMs: totalTimeMs,
    );

    return QuizResult(
      lessonId: lessonId,
      totalCharacters: totalCharacters,
      correctCharacters: correctCharacters,
      totalTimeMs: totalTimeMs,
      stars: stars,
      completedAt: DateTime.now(),
      attempts: attempts,
    );
  }
}
