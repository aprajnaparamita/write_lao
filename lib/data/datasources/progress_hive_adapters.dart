import 'package:hive/hive.dart';
import 'package:write_lao/data/models/user_progress.dart';

/// Hive adapter for CharacterProgress
class CharacterProgressAdapter extends TypeAdapter<CharacterProgress> {
  @override
  final int typeId = 0;

  @override
  CharacterProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CharacterProgress(
      codepoint: fields[0] as String,
      practiceCount: fields[1] as int? ?? 0,
      testCorrectCount: fields[2] as int? ?? 0,
      testAttemptCount: fields[3] as int? ?? 0,
      stars: fields[4] as int? ?? 0,
      bestTimeMs: fields[5] as int?,
      lastPracticed: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CharacterProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.codepoint)
      ..writeByte(1)
      ..write(obj.practiceCount)
      ..writeByte(2)
      ..write(obj.testCorrectCount)
      ..writeByte(3)
      ..write(obj.testAttemptCount)
      ..writeByte(4)
      ..write(obj.stars)
      ..writeByte(5)
      ..write(obj.bestTimeMs)
      ..writeByte(6)
      ..write(obj.lastPracticed);
  }
}

/// Hive adapter for LessonProgress
class LessonProgressAdapter extends TypeAdapter<LessonProgress> {
  @override
  final int typeId = 1;

  @override
  LessonProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonProgress(
      lessonId: fields[0] as String,
      isUnlocked: fields[1] as bool? ?? false,
      isCompleted: fields[2] as bool? ?? false,
      stars: fields[3] as int? ?? 0,
      bestTimeMs: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LessonProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.isUnlocked)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.stars)
      ..writeByte(4)
      ..write(obj.bestTimeMs);
  }
}
