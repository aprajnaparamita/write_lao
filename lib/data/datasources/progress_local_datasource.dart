import 'package:hive/hive.dart';
import 'package:write_it_lao/data/models/user_progress.dart';

/// Local data source for progress data using Hive.
class ProgressLocalDataSource {
  static const String characterBoxName = 'character_progress';
  static const String lessonBoxName = 'lesson_progress';
  
  final Box<CharacterProgress> _characterBox;
  final Box<LessonProgress> _lessonBox;

  ProgressLocalDataSource({
    required Box<CharacterProgress> characterBox,
    required Box<LessonProgress> lessonBox,
  })  : _characterBox = characterBox,
        _lessonBox = lessonBox;

  // Character Progress Methods

  /// Get progress for a specific character.
  CharacterProgress getCharacterProgress(String codepoint) {
    return _characterBox.get(codepoint) ?? CharacterProgress(
      codepoint: codepoint,
    );
  }

  /// Save progress for a character.
  void saveCharacterProgress(CharacterProgress progress) {
    _characterBox.put(progress.codepoint, progress);
  }

  /// Get all character progress data.
  List<CharacterProgress> getAllCharacterProgress() {
    return _characterBox.values.toList();
  }

  /// Delete character progress.
  void deleteCharacterProgress(String codepoint) {
    _characterBox.delete(codepoint);
  }

  // Lesson Progress Methods

  /// Get progress for a specific lesson.
  LessonProgress getLessonProgress(String lessonId) {
    return _lessonBox.get(lessonId) ?? LessonProgress(
      lessonId: lessonId,
    );
  }

  /// Save progress for a lesson.
  void saveLessonProgress(LessonProgress progress) {
    _lessonBox.put(progress.lessonId, progress);
  }

  /// Get all lesson progress data.
  List<LessonProgress> getAllLessonProgress() {
    return _lessonBox.values.toList();
  }

  /// Delete lesson progress.
  void deleteLessonProgress(String lessonId) {
    _lessonBox.delete(lessonId);
  }

  // Reset Methods

  /// Clear all progress data.
  Future<void> clearAllProgress() async {
    await _characterBox.clear();
    await _lessonBox.clear();
  }

  /// Get total lessons completed (with at least 1 star).
  int get totalLessonsCompleted {
    return _lessonBox.values.where((p) => p.stars >= 1).length;
  }

  /// Get total stars earned.
  int get totalStarsEarned {
    return _lessonBox.values.fold(0, (sum, p) => sum + p.stars);
  }

  /// Get maximum possible stars (based on lessons with data).
  int get maxPossibleStars {
    // This would ideally be based on lessons that have stroke data
    return _lessonBox.values.length * 3;
  }
}
