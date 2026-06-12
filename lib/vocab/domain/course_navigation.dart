import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';

/// Pure-function gating and progress helpers used by the unit-list and
/// lesson-list screens. Everything here is read-only and idempotent.
///
/// The engine owns *advancing* progress (via `completeLesson`); this
/// module only interprets the snapshot the engine has already produced:
/// `currentUnitId` / `currentLessonId` point to the NEXT work the user
/// should do, so any lesson whose canonical order is strictly before
/// the current lesson is considered complete.
class CourseNavigation {
  final CourseRepository course;
  final UserVocabProgress progress;

  CourseNavigation({required this.course, required this.progress});

  /// True if the course has been fully walked — i.e. every lesson has been
  /// completed and there is no next lesson to do.
  ///
  /// A fresh user who hasn't started yet also has a null [currentLessonId],
  /// so we additionally require [lessonsCompleted] > 0 to distinguish
  /// "never started" from "finished everything".
  bool get isCourseComplete =>
      progress.currentLessonId == null && progress.lessonsCompleted > 0;

  int? _canonicalLessonIndex(String? lessonId) {
    if (lessonId == null) return null;
    final lessons = course.content.lessons;
    final i = lessons.indexWhere((l) => l.lessonId == lessonId);
    return i < 0 ? null : i;
  }

  /// A lesson is complete iff its canonical index precedes the user's
  /// current lesson (or the course is finished).
  bool isLessonComplete(String lessonId) {
    if (isCourseComplete) return true;
    final currentIdx = _canonicalLessonIndex(progress.currentLessonId);
    final thisIdx = _canonicalLessonIndex(lessonId);
    if (currentIdx == null || thisIdx == null) return false;
    return thisIdx < currentIdx;
  }

  /// True if every lesson in [unitId] is complete.
  bool isUnitComplete(String unitId) {
    final lessons = course.getLessonsInUnit(unitId);
    if (lessons.isEmpty) return false;
    return lessons.every((l) => isLessonComplete(l.lessonId));
  }

  /// Unit 1 is always unlocked (free). Unit N (N>1) requires IAP and the
  /// previous unit to be complete.
  bool isUnitUnlocked(String unitId) {
    final unit = course.getUnit(unitId);
    if (unit == null) return false;
    if (unit.unitNumber <= 1) return true;
    if (!progress.iapUnlocked) return false;
    String? prevUnitId;
    for (final u in course.getAllUnits()) {
      if (u.unitNumber == unit.unitNumber - 1) {
        prevUnitId = u.unitId;
        break;
      }
    }
    if (prevUnitId == null) return false;
    return isUnitComplete(prevUnitId);
  }

  /// Lesson 1 of an unlocked unit is unlocked; lesson N (N>1) unlocks
  /// when lesson N-1 is complete.
  bool isLessonUnlocked(String lessonId) {
    final lesson = course.getLesson(lessonId);
    if (lesson == null) return false;
    if (!isUnitUnlocked(lesson.unitId)) return false;
    final inUnit = course.getLessonsInUnit(lesson.unitId);
    final idx = inUnit.indexWhere((l) => l.lessonId == lessonId);
    if (idx <= 0) return true; // first lesson in unit (or unknown -> treat as 0)
    return isLessonComplete(inUnit[idx - 1].lessonId);
  }

  /// Count of completed lessons in [unitId].
  int completedLessonCount(String unitId) {
    final lessons = course.getLessonsInUnit(unitId);
    return lessons.where((l) => isLessonComplete(l.lessonId)).length;
  }

  /// Total lessons in [unitId].
  int totalLessonCount(String unitId) =>
      course.getLessonsInUnit(unitId).length;

  /// True if the given lesson is the one the user should do next.
  bool isCurrentLesson(String lessonId) =>
      !isCourseComplete && progress.currentLessonId == lessonId;
}

/// Count of words the user has "mastered." Per Phase 07 spec, mastered
/// means status is `mature` or `retired`.
int masteredWordCount(Iterable<UserWord> words) {
  var n = 0;
  for (final w in words) {
    if (w.status == WordStatus.mature || w.status == WordStatus.retired) n++;
  }
  return n;
}
