import 'package:freezed_annotation/freezed_annotation.dart';

part 'vocab_user_state.freezed.dart';
part 'vocab_user_state.g.dart';

enum WordStatus {
  @JsonValue('new')
  newWord,
  @JsonValue('learning')
  learning,
  @JsonValue('reviewing')
  reviewing,
  @JsonValue('mature')
  mature,
  @JsonValue('retired')
  retired,
}

enum SyncState {
  @JsonValue('local')
  local,
  @JsonValue('synced')
  synced,
  @JsonValue('pending')
  pending,
  @JsonValue('conflict')
  conflict,
}

@freezed
class UserWord with _$UserWord {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserWord({
    required String id,
    required String wordId,
    @Default(2.5) double easeFactor,
    @Default(0) int intervalDays,
    DateTime? nextReviewAt,
    DateTime? lastReviewedAt,
    @Default(0) int consecutiveCorrect,
    @Default(0) int timesSeen,
    @Default(0) int timesCorrect,
    DateTime? firstSeenAt,
    @Default(WordStatus.newWord) WordStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(SyncState.local) SyncState syncState,
  }) = _UserWord;

  factory UserWord.fromJson(Map<String, dynamic> json) =>
      _$UserWordFromJson(json);
}

@freezed
class UserVocabProgress with _$UserVocabProgress {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserVocabProgress({
    required String id,
    String? currentUnitId,
    String? currentLessonId,
    @Default(0) int unitsCompleted,
    @Default(0) int lessonsCompleted,
    @Default(false) bool iapUnlocked,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(SyncState.local) SyncState syncState,
  }) = _UserVocabProgress;

  factory UserVocabProgress.fromJson(Map<String, dynamic> json) =>
      _$UserVocabProgressFromJson(json);
}

@freezed
class UserSession with _$UserSession {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserSession({
    required String id,
    required String lessonId,
    required DateTime startedAt,
    DateTime? completedAt,
    @Default(0) int errorsCount,
    int? durationSeconds,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(SyncState.local) SyncState syncState,
  }) = _UserSession;

  factory UserSession.fromJson(Map<String, dynamic> json) =>
      _$UserSessionFromJson(json);
}

@freezed
class FlagDeck with _$FlagDeck {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory FlagDeck({
    required String id,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(SyncState.local) SyncState syncState,
  }) = _FlagDeck;

  factory FlagDeck.fromJson(Map<String, dynamic> json) =>
      _$FlagDeckFromJson(json);
}

@freezed
class FlagDeckWord with _$FlagDeckWord {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory FlagDeckWord({
    required String id,
    required String deckId,
    required String wordId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(SyncState.local) SyncState syncState,
  }) = _FlagDeckWord;

  factory FlagDeckWord.fromJson(Map<String, dynamic> json) =>
      _$FlagDeckWordFromJson(json);
}
