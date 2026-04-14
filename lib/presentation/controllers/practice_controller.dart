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

  const PracticeState({
    this.currentLesson,
    this.currentCharacterIndex = 0,
    this.currentCharacter,
    this.currentStrokeData,
    this.isCharacterComplete = false,
    this.practicedCharacters = const {},
  });

  PracticeState copyWith({
    Lesson? currentLesson,
    int? currentCharacterIndex,
    LaoCharacter? currentCharacter,
    CharacterStrokeData? currentStrokeData,
    bool? isCharacterComplete,
    Set<String>? practicedCharacters,
  }) {
    return PracticeState(
      currentLesson: currentLesson ?? this.currentLesson,
      currentCharacterIndex: currentCharacterIndex ?? this.currentCharacterIndex,
      currentCharacter: currentCharacter ?? this.currentCharacter,
      currentStrokeData: currentStrokeData ?? this.currentStrokeData,
      isCharacterComplete: isCharacterComplete ?? this.isCharacterComplete,
      practicedCharacters: practicedCharacters ?? this.practicedCharacters,
    );
  }

  bool get isLastCharacter {
    if (currentLesson == null) return true;
    return currentCharacterIndex >= currentLesson!.characterCodepoints.length - 1;
  }

  int get totalCharacters {
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

    state = PracticeState(
      currentLesson: lesson,
      currentCharacterIndex: 0,
      currentCharacter: characters.first,
      practicedCharacters: const {},
    );
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
    if (state.currentLesson == null) return;

    final characters = _characterRepo.getCharactersForLesson(state.currentLesson!.id);
    final nextIndex = state.currentCharacterIndex + 1;

    if (nextIndex >= characters.length) {
      // At the end, stay on last character
      return;
    }

    state = state.copyWith(
      currentCharacterIndex: nextIndex,
      currentCharacter: characters[nextIndex],
      isCharacterComplete: false,
    );
  }

  void previousCharacter() {
    if (state.currentLesson == null) return;

    final characters = _characterRepo.getCharactersForLesson(state.currentLesson!.id);
    final prevIndex = state.currentCharacterIndex - 1;

    if (prevIndex < 0) {
      // At the beginning, stay on first character
      return;
    }

    state = state.copyWith(
      currentCharacterIndex: prevIndex,
      currentCharacter: characters[prevIndex],
      isCharacterComplete: state.practicedCharacters.contains(characters[prevIndex].codepoint),
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
