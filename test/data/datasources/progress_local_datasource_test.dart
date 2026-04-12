import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/datasources/progress_local_datasource.dart';
import 'package:write_it_lao/data/models/user_progress.dart';

void main() {
  group('ProgressLocalDataSource', () {
    late Box<CharacterProgress> characterBox;
    late Box<LessonProgress> lessonBox;
    late ProgressLocalDataSource dataSource;
    late Directory tempDir;

    setUpAll(() {
      tempDir = Directory.systemTemp.createTempSync('hive_test_datasource_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CharacterProgressAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(LessonProgressAdapter());
      }
    });

    tearDownAll(() {
      tempDir.deleteSync(recursive: true);
    });

    setUp(() async {
      characterBox = await Hive.openBox<CharacterProgress>('test_character_progress_${DateTime.now().microsecondsSinceEpoch}');
      lessonBox = await Hive.openBox<LessonProgress>('test_lesson_progress_${DateTime.now().microsecondsSinceEpoch}');
      dataSource = ProgressLocalDataSource(
        characterBox: characterBox,
        lessonBox: lessonBox,
      );
    });

    tearDown(() async {
      await characterBox.deleteFromDisk();
      await lessonBox.deleteFromDisk();
    });

    group('character progress', () {
      test('getCharacterProgress returns default for new codepoint', () {
        final progress = dataSource.getCharacterProgress('U+0E81');
        expect(progress.codepoint, 'U+0E81');
        expect(progress.practiceCount, 0);
        expect(progress.testAttemptCount, 0);
        expect(progress.testCorrectCount, 0);
      });

      test('saveCharacterProgress persists data', () {
        final progress = CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 5,
          lastPracticed: DateTime.now(),
        );

        dataSource.saveCharacterProgress(progress);
        final retrieved = dataSource.getCharacterProgress('U+0E81');

        expect(retrieved.practiceCount, 5);
      });

      test('saveCharacterProgress overwrites existing data', () {
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 5,
        ));

        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 10,
        ));

        final retrieved = dataSource.getCharacterProgress('U+0E81');
        expect(retrieved.practiceCount, 10);
      });

      test('getAllCharacterProgress returns all saved progress', () {
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 5,
        ));
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E82',
          practiceCount: 3,
        ));

        final allProgress = dataSource.getAllCharacterProgress();
        expect(allProgress.length, 2);
      });

      test('deleteCharacterProgress removes entry', () {
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 5,
        ));

        dataSource.deleteCharacterProgress('U+0E81');
        final retrieved = dataSource.getCharacterProgress('U+0E81');

        expect(retrieved.practiceCount, 0);
      });
    });

    group('lesson progress', () {
      test('getLessonProgress returns default for new lesson', () {
        final progress = dataSource.getLessonProgress('consonants_1');
        expect(progress.lessonId, 'consonants_1');
        expect(progress.stars, 0);
        expect(progress.isCompleted, isFalse);
      });

      test('saveLessonProgress persists data', () {
        final progress = LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
          isCompleted: true,
          bestTimeMs: 15000,
        );

        dataSource.saveLessonProgress(progress);
        final retrieved = dataSource.getLessonProgress('consonants_1');

        expect(retrieved.stars, 3);
        expect(retrieved.isCompleted, isTrue);
        expect(retrieved.bestTimeMs, 15000);
      });

      test('saveLessonProgress overwrites existing data', () {
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 1,
        ));

        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));

        final retrieved = dataSource.getLessonProgress('consonants_1');
        expect(retrieved.stars, 3);
      });

      test('getAllLessonProgress returns all saved progress', () {
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_2',
          stars: 2,
        ));

        final allProgress = dataSource.getAllLessonProgress();
        expect(allProgress.length, 2);
      });

      test('deleteLessonProgress removes entry', () {
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));

        dataSource.deleteLessonProgress('consonants_1');
        final retrieved = dataSource.getLessonProgress('consonants_1');

        expect(retrieved.stars, 0);
      });
    });

    group('stats', () {
      test('totalLessonsCompleted counts lessons with 1+ star', () {
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_2',
          stars: 1,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_3',
          stars: 0,
        ));

        expect(dataSource.totalLessonsCompleted, 2);
      });

      test('totalStarsEarned sums all stars', () {
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_2',
          stars: 2,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_3',
          stars: 1,
        ));

        expect(dataSource.totalStarsEarned, 6);
      });
    });

    group('clearAllProgress', () {
      test('clears all character and lesson progress', () async {
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 5,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));

        await dataSource.clearAllProgress();

        final charProgress = dataSource.getAllCharacterProgress();
        final lessonProgress = dataSource.getAllLessonProgress();
        expect(charProgress, isEmpty);
        expect(lessonProgress, isEmpty);
      });
    });
  });
}
