import '../models/lao_character.dart';
import '../models/lesson.dart';
import '../lao_characters.dart';
import '../lesson_definitions.dart';

class CharacterRepository {
  late final List<LaoCharacter> _characters;
  late final Map<String, LaoCharacter> _characterMap;
  late final List<Lesson> _lessons;
  late final Map<String, Lesson> _lessonMap;

  CharacterRepository() {
    _characters = kLaoCharacters
        .map((json) => LaoCharacter.fromJson(json))
        .toList();
    _characterMap = {for (final c in _characters) c.codepoint: c};

    _lessons = kLessonDefinitions
        .map((json) => Lesson.fromJson(json))
        .toList();
    _lessonMap = {for (final l in _lessons) l.id: l};
  }

  List<LaoCharacter> getAllCharacters() => List.unmodifiable(_characters);

  LaoCharacter? getCharacter(String codepoint) => _characterMap[codepoint];

  List<LaoCharacter> getCharactersByPhase(int phase) =>
      _characters.where((c) => c.phase == phase).toList();

  List<Lesson> getAllLessons() => List.unmodifiable(_lessons);

  Lesson? getLesson(String lessonId) => _lessonMap[lessonId];

  List<LaoCharacter> getCharactersForLesson(String lessonId) {
    final lesson = _lessonMap[lessonId];
    if (lesson == null) return [];
    return lesson.characterCodepoints
        .map((cp) => _characterMap[cp])
        .whereType<LaoCharacter>()
        .toList();
  }
}
