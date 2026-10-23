import 'package:write_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';

/// Checks whether a lesson is accessible to the user based on their
/// purchase state and the free preview configuration.
class ContentAccess {
  final CourseRepository course;
  final UserVocabProgress progress;

  const ContentAccess({required this.course, required this.progress});

  /// True if the user has purchased the vocabulary feature.
  bool get hasPurchased => progress.iapUnlocked;

  /// True if [lessonId] is in unit 1, which is always free.
  bool isInFreePreview(String lessonId) {
    if (hasPurchased) return false;
    final lesson = course.getLesson(lessonId);
    if (lesson == null) return false;
    return lesson.unitId == course.getAllUnits().first.unitId;
  }

  /// True if [lessonId] is accessible to the user.
  bool canAccessLesson(String lessonId) {
    if (hasPurchased) return true;
    return isInFreePreview(lessonId);
  }

  /// True if [unitId] has any accessible content for this user.
  bool hasAccessibleContent(String unitId) {
    if (hasPurchased) return true;
    // Only unit 1 is accessible without purchase.
    final unit = course.getUnit(unitId);
    if (unit == null) return false;
    return unit.unitNumber == 1;
  }
}
