import 'package:write_it_lao/data/datasources/progress_local_datasource.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/data/models/quiz_result.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';

class ProgressRepository {
  final ProgressLocalDataSource _dataSource;
  final CharacterRepository _characterRepo;

  ProgressRepository({
    required ProgressLocalDataSource dataSource,
    required CharacterRepository characterRepo,
  })  : _dataSource = dataSource,
        _characterRepo = characterRepo;

  // Character Progress

  /// Record a practice session for a character.
  void recordPractice(String codepoint) {
    final current = _dataSource.getCharacterProgress(codepoint);
    final updated = current.copyWith(
      practiceCount: current.practiceCount + 1,
      lastPracticed: DateTime.now(),
    );
    _dataSource.saveCharacterProgress(updated);
  }

  /// Get progress for a character.
  CharacterProgress getCharacterProgress(String codepoint) {
    return _dataSource.getCharacterProgress(codepoint);
  }

  /// Get progress for all characters.
  List<CharacterProgress> getAllCharacterProgress() {
    return _dataSource.getAllCharacterProgress();
  }

  // Lesson Progress

  /// Record a test result.
  void recordTestResult(QuizResult result) {
    final current = _dataSource.getLessonProgress(result.lessonId);
    final updated = current.copyWith(
      isCompleted: true,
      stars: result.stars > current.stars ? result.stars : current.stars,
      bestTimeMs: current.bestTimeMs == null || result.totalTimeMs < current.bestTimeMs!
          ? result.totalTimeMs
          : current.bestTimeMs,
    );
    _dataSource.saveLessonProgress(updated);
  }

  /// Get progress for a lesson.
  LessonProgress getLessonProgress(String lessonId) {
    return _dataSource.getLessonProgress(lessonId);
  }

  /// Get progress for all lessons.
  List<LessonProgress> getAllLessonProgress() {
    return _dataSource.getAllLessonProgress();
  }

  // Stats

  /// Get total lessons completed (with at least 1 star).
  int totalLessonsCompleted() {
    return _dataSource.totalLessonsCompleted;
  }

  /// Get total stars earned.
  int totalStarsEarned() {
    return _dataSource.totalStarsEarned;
  }

  /// Get max possible stars.
  int maxPossibleStars() {
    return _characterRepo.getAllLessons().length * 3;
  }

  /// Get weak characters (lowest accuracy) for review.
  List<LaoCharacter> getWeakCharacters({int limit = 10}) {
    final allCharacters = _characterRepo.getAllCharacters();
    final progressList = _dataSource.getAllCharacterProgress();
    
    // Create a map for quick lookup
    final progressMap = {for (var p in progressList) p.codepoint: p};
    
    // Calculate accuracy and sort
    final charactersWithAccuracy = allCharacters.map((char) {
      final progress = progressMap[char.codepoint];
      final accuracy = progress != null && progress.testAttemptCount > 0
          ? progress.testCorrectCount / progress.testAttemptCount
          : 0.0;
      return (character: char, accuracy: accuracy, practiceCount: progress?.practiceCount ?? 0);
    }).toList();
    
    // Filter to only characters with some practice
    final practiced = charactersWithAccuracy
        .where((c) => c.practiceCount > 0)
        .toList();
    
    // Sort by accuracy (ascending), then by practice count (ascending)
    practiced.sort((a, b) {
      final accuracyCompare = a.accuracy.compareTo(b.accuracy);
      if (accuracyCompare != 0) return accuracyCompare;
      return a.practiceCount.compareTo(b.practiceCount);
    });
    
    return practiced.take(limit).map((c) => c.character).toList();
  }

  /// Check if a lesson is unlocked.
  bool isLessonUnlocked(String lessonId, CharacterRepository charRepo) {
    // First lesson is always unlocked
    final lessonIndex = charRepo.getAllLessons().indexWhere((l) => l.id == lessonId);
    if (lessonIndex <= 0) return true;
    
    // Check if previous lesson has at least 1 star
    final previousLesson = charRepo.getAllLessons()[lessonIndex - 1];
    final previousProgress = _dataSource.getLessonProgress(previousLesson.id);
    return previousProgress.stars >= 1;
  }

  /// Reset all progress.
  Future<void> resetAllProgress() async {
    await _dataSource.clearAllProgress();
  }

  // Phase progress

  /// Get progress for a specific phase.
  Map<String, int> getPhaseProgress(int phase) {
    final lessons = _characterRepo.getLessonsByPhase(phase);
    if (lessons.isEmpty) return {'completed': 0, 'total': 0};
    
    var completed = 0;
    for (final lesson in lessons) {
      final progress = _dataSource.getLessonProgress(lesson.id);
      if (progress.stars >= 1) completed++;
    }
    
    return {'completed': completed, 'total': lessons.length};
  }
}
