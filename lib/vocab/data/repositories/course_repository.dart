import 'package:write_it_lao/vocab/data/models/course_content.dart';
import 'package:write_it_lao/vocab/data/models/vocab_lesson.dart';
import 'package:write_it_lao/vocab/data/models/vocab_unit.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';

/// Read-only query API over loaded vocabulary content.
class CourseRepository {
  final CourseContent _content;
  final Map<String, VocabUnit> _unitsById;
  final Map<String, VocabLesson> _lessonsById;
  final Map<String, VocabWord> _wordsById;
  final Map<String, int> _lessonOrder;

  CourseRepository(this._content)
      : _unitsById = {for (final u in _content.units) u.unitId: u},
        _lessonsById = {for (final l in _content.lessons) l.lessonId: l},
        _wordsById = {for (final w in _content.words) w.wordId: w},
        _lessonOrder = {
          for (var i = 0; i < _content.lessons.length; i++)
            _content.lessons[i].lessonId: i,
        };

  CourseContent get content => _content;

  List<VocabUnit> getAllUnits() => List.unmodifiable(_content.units);

  VocabUnit? getUnit(String unitId) => _unitsById[unitId];

  VocabLesson? getLesson(String lessonId) => _lessonsById[lessonId];

  VocabWord? getWord(String wordId) => _wordsById[wordId];

  List<VocabLesson> getLessonsInUnit(String unitId) {
    final unit = _unitsById[unitId];
    if (unit == null) return const [];
    return unit.lessonIds
        .map((id) => _lessonsById[id])
        .whereType<VocabLesson>()
        .toList();
  }

  /// All words appearing in any lesson of the given unit (new + review),
  /// deduped, in lesson order.
  List<VocabWord> getWordsInUnit(String unitId) {
    final lessons = getLessonsInUnit(unitId);
    final seen = <String>{};
    final out = <VocabWord>[];
    for (final l in lessons) {
      for (final wid in [...l.newWordIds, ...l.reviewWordIds]) {
        if (seen.add(wid)) {
          final w = _wordsById[wid];
          if (w != null) out.add(w);
        }
      }
    }
    return out;
  }

  /// All words first introduced in a lesson preceding [lessonId] in canonical
  /// course order. Used by the SRS engine to scope review candidates.
  List<VocabWord> getWordsIntroducedBefore(String lessonId) {
    final idx = _lessonOrder[lessonId];
    if (idx == null) return const [];
    final out = <VocabWord>[];
    final seen = <String>{};
    for (var i = 0; i < idx; i++) {
      for (final wid in _content.lessons[i].newWordIds) {
        if (seen.add(wid)) {
          final w = _wordsById[wid];
          if (w != null) out.add(w);
        }
      }
    }
    return out;
  }
}
