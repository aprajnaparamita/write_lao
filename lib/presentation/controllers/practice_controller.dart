import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:write_it_lao/audio/audio_player_service.dart';
import 'package:write_it_lao/data/datasources/character_stroke_datasource.dart';
import 'package:write_it_lao/data/datasources/progress_local_datasource.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/data/models/lesson.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';
import 'package:write_it_lao/data/repositories/progress_repository.dart';

class PracticeState {
  final Lesson? currentLesson;
  final int currentCharacterIndex;
  final LaoCharacter? currentCharacter;
  final CharacterStrokeData? currentStrokeData;
  final bool isCharacterComplete;
  final Set<String> practicedCharacters;
  final List<LaoCharacter> practiceSequence;

  const PracticeState({
    this.currentLesson,
    this.currentCharacterIndex = 0,
    this.currentCharacter,
    this.currentStrokeData,
    this.isCharacterComplete = false,
    this.practicedCharacters = const {},
    this.practiceSequence = const [],
  });

  PracticeState copyWith({
    Lesson? currentLesson,
    int? currentCharacterIndex,
    LaoCharacter? currentCharacter,
    CharacterStrokeData? currentStrokeData,
    bool? isCharacterComplete,
    Set<String>? practicedCharacters,
    List<LaoCharacter>? practiceSequence,
  }) {
    return PracticeState(
      currentLesson: currentLesson ?? this.currentLesson,
      currentCharacterIndex: currentCharacterIndex ?? this.currentCharacterIndex,
      currentCharacter: currentCharacter ?? this.currentCharacter,
      currentStrokeData: currentStrokeData ?? this.currentStrokeData,
      isCharacterComplete: isCharacterComplete ?? this.isCharacterComplete,
      practicedCharacters: practicedCharacters ?? this.practicedCharacters,
      practiceSequence: practiceSequence ?? this.practiceSequence,
    );
  }

  bool get isLastCharacter {
    if (practiceSequence.isNotEmpty) {
      return currentCharacterIndex >= practiceSequence.length - 1;
    }
    if (currentLesson == null) return true;
    return currentCharacterIndex >= currentLesson!.characterCodepoints.length - 1;
  }

  int get totalCharacters {
    if (practiceSequence.isNotEmpty) return practiceSequence.length;
    return currentLesson?.characterCodepoints.length ?? 0;
  }

  bool get canProceedToTest {
    if (currentLesson == null) return false;
    return practicedCharacters.length >= currentLesson!.characterCodepoints.length;
  }
}

class PracticeController extends StateNotifier<PracticeState> {
  final CharacterRepository _characterRepo;

  PracticeController(this._characterRepo) : super(const PracticeState());

  void setLesson(Lesson lesson) {
    final characters = _characterRepo.getCharactersForLesson(lesson.id);
    if (characters.isEmpty) {
      state = PracticeState(currentLesson: lesson);
      return;
    }

    final sequence = _generateGraduatedSequence(characters);

    state = PracticeState(
      currentLesson: lesson,
      currentCharacterIndex: 0,
      currentCharacter: sequence.first,
      practiceSequence: sequence,
      practicedCharacters: const {},
    );
  }

  /// Generates a graduated practice sequence.
  /// Pattern: introduce each character, then interleave review of all known
  /// characters. E.g. for chars A,B,C:
  ///   A,A, B,A,B,A,B,B, C,A,B,C,A,B,C,C, ...
  /// Padded with full cycles to reach [totalSteps].
  static List<LaoCharacter> _generateGraduatedSequence(
    List<LaoCharacter> characters, {
    int totalSteps = 20,
  }) {
    final numChars = characters.length;
    final indices = <int>[];

    for (int n = 0; n < numChars && indices.length < totalSteps; n++) {
      if (n == 0) {
        // Introduce first character: show twice
        indices.add(0);
        if (indices.length < totalSteps) indices.add(0);
      } else {
        // Introduce new character
        indices.add(n);
        // Cycle through all known characters (0..n) twice
        for (int cycle = 0; cycle < 2 && indices.length < totalSteps; cycle++) {
          for (int i = 0; i <= n && indices.length < totalSteps; i++) {
            indices.add(i);
          }
        }
        // Reinforce new character
        if (indices.length < totalSteps) indices.add(n);
      }
    }

    // Fill remaining slots with full cycles
    int cycleIndex = 0;
    while (indices.length < totalSteps) {
      indices.add(cycleIndex % numChars);
      cycleIndex++;
    }

    return indices.map((i) => characters[i]).toList();
  }

  void setCharacter(LaoCharacter character, CharacterStrokeData? strokeData) {
    state = state.copyWith(
      currentCharacter: character,
      currentStrokeData: strokeData,
      isCharacterComplete: false,
    );
  }

  void onCharacterComplete() {
    if (state.currentCharacter == null) return;

    final newPracticed = {...state.practicedCharacters, state.currentCharacter!.codepoint};
    state = state.copyWith(
      isCharacterComplete: true,
      practicedCharacters: newPracticed,
    );
  }

  void nextCharacter() {
    if (state.practiceSequence.isEmpty) return;

    final nextIndex = state.currentCharacterIndex + 1;
    if (nextIndex >= state.practiceSequence.length) return;

    state = state.copyWith(
      currentCharacterIndex: nextIndex,
      currentCharacter: state.practiceSequence[nextIndex],
      isCharacterComplete: false,
    );
  }

  void previousCharacter() {
    if (state.practiceSequence.isEmpty) return;

    final prevIndex = state.currentCharacterIndex - 1;
    if (prevIndex < 0) return;

    state = state.copyWith(
      currentCharacterIndex: prevIndex,
      currentCharacter: state.practiceSequence[prevIndex],
      isCharacterComplete: state.practicedCharacters.contains(
        state.practiceSequence[prevIndex].codepoint,
      ),
    );
  }

  void reset() {
    if (state.currentLesson == null) return;
    setLesson(state.currentLesson!);
  }
}

final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepository();
});

final progressLocalDataSourceProvider = Provider<ProgressLocalDataSource>((ref) {
  final characterBox = Hive.box<CharacterProgress>('character_progress');
  final lessonBox = Hive.box<LessonProgress>('lesson_progress');
  return ProgressLocalDataSource(characterBox: characterBox, lessonBox: lessonBox);
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final dataSource = ref.watch(progressLocalDataSourceProvider);
  final characterRepo = ref.watch(characterRepositoryProvider);
  return ProgressRepository(dataSource: dataSource, characterRepo: characterRepo);
});

final characterStrokeDataSourceProvider = Provider<CharacterStrokeDataSource>((ref) {
  return CharacterStrokeDataSource();
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final practiceControllerProvider = StateNotifierProvider<PracticeController, PracticeState>((ref) {
  final characterRepo = ref.watch(characterRepositoryProvider);
  return PracticeController(characterRepo);
});
