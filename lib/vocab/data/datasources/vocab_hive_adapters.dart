import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';

String _wordStatusToString(WordStatus s) {
  switch (s) {
    case WordStatus.newWord:
      return 'new';
    case WordStatus.learning:
      return 'learning';
    case WordStatus.reviewing:
      return 'reviewing';
    case WordStatus.mature:
      return 'mature';
    case WordStatus.retired:
      return 'retired';
  }
}

WordStatus _wordStatusFromString(String? s) {
  switch (s) {
    case 'new':
      return WordStatus.newWord;
    case 'learning':
      return WordStatus.learning;
    case 'reviewing':
      return WordStatus.reviewing;
    case 'mature':
      return WordStatus.mature;
    case 'retired':
      return WordStatus.retired;
    default:
      return WordStatus.newWord;
  }
}

String _syncStateToString(SyncState s) {
  switch (s) {
    case SyncState.local:
      return 'local';
    case SyncState.synced:
      return 'synced';
    case SyncState.pending:
      return 'pending';
    case SyncState.conflict:
      return 'conflict';
  }
}

SyncState _syncStateFromString(String? s) {
  switch (s) {
    case 'local':
      return SyncState.local;
    case 'synced':
      return SyncState.synced;
    case 'pending':
      return SyncState.pending;
    case 'conflict':
      return SyncState.conflict;
    default:
      return SyncState.local;
  }
}

class UserWordAdapter extends TypeAdapter<UserWord> {
  @override
  final int typeId = 12;

  @override
  UserWord read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return UserWord(
      id: fields[0] as String,
      wordId: fields[1] as String,
      easeFactor: fields[2] as double? ?? 2.5,
      intervalDays: fields[3] as int? ?? 0,
      nextReviewAt: fields[4] as DateTime?,
      lastReviewedAt: fields[5] as DateTime?,
      consecutiveCorrect: fields[6] as int? ?? 0,
      timesSeen: fields[7] as int? ?? 0,
      timesCorrect: fields[8] as int? ?? 0,
      firstSeenAt: fields[9] as DateTime?,
      status: _wordStatusFromString(fields[10] as String?),
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
      syncState: _syncStateFromString(fields[13] as String?),
    );
  }

  @override
  void write(BinaryWriter writer, UserWord obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.wordId)
      ..writeByte(2)
      ..write(obj.easeFactor)
      ..writeByte(3)
      ..write(obj.intervalDays)
      ..writeByte(4)
      ..write(obj.nextReviewAt)
      ..writeByte(5)
      ..write(obj.lastReviewedAt)
      ..writeByte(6)
      ..write(obj.consecutiveCorrect)
      ..writeByte(7)
      ..write(obj.timesSeen)
      ..writeByte(8)
      ..write(obj.timesCorrect)
      ..writeByte(9)
      ..write(obj.firstSeenAt)
      ..writeByte(10)
      ..write(_wordStatusToString(obj.status))
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(_syncStateToString(obj.syncState));
  }
}

class UserVocabProgressAdapter extends TypeAdapter<UserVocabProgress> {
  @override
  final int typeId = 13;

  @override
  UserVocabProgress read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return UserVocabProgress(
      id: fields[0] as String,
      currentUnitId: fields[1] as String?,
      currentLessonId: fields[2] as String?,
      unitsCompleted: fields[3] as int? ?? 0,
      lessonsCompleted: fields[4] as int? ?? 0,
      iapUnlocked: fields[5] as bool? ?? false,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      syncState: _syncStateFromString(fields[8] as String?),
    );
  }

  @override
  void write(BinaryWriter writer, UserVocabProgress obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentUnitId)
      ..writeByte(2)
      ..write(obj.currentLessonId)
      ..writeByte(3)
      ..write(obj.unitsCompleted)
      ..writeByte(4)
      ..write(obj.lessonsCompleted)
      ..writeByte(5)
      ..write(obj.iapUnlocked)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(_syncStateToString(obj.syncState));
  }
}

class UserSessionAdapter extends TypeAdapter<UserSession> {
  @override
  final int typeId = 14;

  @override
  UserSession read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return UserSession(
      id: fields[0] as String,
      lessonId: fields[1] as String,
      startedAt: fields[2] as DateTime,
      completedAt: fields[3] as DateTime?,
      errorsCount: fields[4] as int? ?? 0,
      durationSeconds: fields[5] as int?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      syncState: _syncStateFromString(fields[8] as String?),
    );
  }

  @override
  void write(BinaryWriter writer, UserSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lessonId)
      ..writeByte(2)
      ..write(obj.startedAt)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.errorsCount)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(_syncStateToString(obj.syncState));
  }
}

class FlagDeckAdapter extends TypeAdapter<FlagDeck> {
  @override
  final int typeId = 15;

  @override
  FlagDeck read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return FlagDeck(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      syncState: _syncStateFromString(fields[4] as String?),
    );
  }

  @override
  void write(BinaryWriter writer, FlagDeck obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(_syncStateToString(obj.syncState));
  }
}

class FlagDeckWordAdapter extends TypeAdapter<FlagDeckWord> {
  @override
  final int typeId = 16;

  @override
  FlagDeckWord read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return FlagDeckWord(
      id: fields[0] as String,
      deckId: fields[1] as String,
      wordId: fields[2] as String,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      syncState: _syncStateFromString(fields[5] as String?),
    );
  }

  @override
  void write(BinaryWriter writer, FlagDeckWord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.wordId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(_syncStateToString(obj.syncState));
  }
}

/// Box names for vocab feature.
class VocabBoxes {
  static const userWord = 'vocab_user_word';
  static const userProgress = 'vocab_user_progress';
  static const userSession = 'vocab_user_session';
  static const flagDeck = 'vocab_flag_deck';
  static const flagDeckWord = 'vocab_flag_deck_word';
}

/// Register all vocab Hive adapters. Idempotent — safe to call repeatedly.
void registerVocabHiveAdapters() {
  if (!Hive.isAdapterRegistered(12)) Hive.registerAdapter(UserWordAdapter());
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(UserVocabProgressAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(UserSessionAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) Hive.registerAdapter(FlagDeckAdapter());
  if (!Hive.isAdapterRegistered(16)) {
    Hive.registerAdapter(FlagDeckWordAdapter());
  }
}

/// Open all vocab Hive boxes. Idempotent — Hive caches open boxes.
Future<void> openVocabBoxes() async {
  await Future.wait([
    Hive.openBox<UserWord>(VocabBoxes.userWord),
    Hive.openBox<UserVocabProgress>(VocabBoxes.userProgress),
    Hive.openBox<UserSession>(VocabBoxes.userSession),
    Hive.openBox<FlagDeck>(VocabBoxes.flagDeck),
    Hive.openBox<FlagDeckWord>(VocabBoxes.flagDeckWord),
  ]);
}
