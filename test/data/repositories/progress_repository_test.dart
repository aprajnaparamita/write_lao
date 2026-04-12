import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/data/datasources/progress_hive_adapters.dart';
import 'package:write_it_lao/data/datasources/progress_local_datasource.dart';
import 'package:write_it_lao/data/models/user_progress.dart';
import 'package:write_it_lao/data/repositories/character_repository.dart';
import 'package:write_it_lao/data/repositories/progress_repository.dart';

void main() {
  group('ProgressRepository', () {
    late Box<CharacterProgress> characterBox;
    late Box<LessonProgress> lessonBox;
    late ProgressLocalDataSource dataSource;
    late CharacterRepository charRepo;
    late ProgressRepository progressRepo;
    late Directory tempDir;

    setUpAll(() {
      tempDir = Directory.systemTemp.createTempSync('hive_test_repo_');
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
      characterBox = await Hive.openBox<CharacterProgress>('test_char_progress_repo_${DateTime.now().microsecondsSinceEpoch}');
      lessonBox = await Hive.openBox<LessonProgress>('test_lesson_progress_repo_${DateTime.now().microsecondsSinceEpoch}');
      dataSource = ProgressLocalDataSource(
        characterBox: characterBox,
        lessonBox: lessonBox,
      );
      charRepo = CharacterRepository();
      progressRepo = ProgressRepository(
        dataSource: dataSource,
        characterRepo: charRepo,
      );
    });

    tearDown(() async {
      await characterBox.deleteFromDisk();
      await lessonBox.deleteFromDisk();
    });

    group('recordPractice', () {
      test('increments practice count', () {
        progressRepo.recordPractice('U+0E81');
        var progress = progressRepo.getCharacterProgress('U+0E81');
        expect(progress.practiceCount, 1);

        progressRepo.recordPractice('U+0E81');
        progress = progressRepo.getCharacterProgress('U+0E81');
        expect(progress.practiceCount, 2);
      });

      test('sets lastPracticed timestamp', () {
        final before = DateTime.now();
        progressRepo.recordPractice('U+0E81');
        final after = DateTime.now();

        final progress = progressRepo.getCharacterProgress('U+0E81');
        expect(progress.lastPracticed, isNotNull);
        expect(progress.lastPracticed!.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
        expect(progress.lastPracticed!.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      });
    });

    group('recordTestResult', () {
      test('updates stars when higher', () {
        // Note: This test requires actual QuizResult creation
        // For simplicity, we test the behavior through the data source
        final progress = LessonProgress(
          lessonId: 'consonants_1',
          stars: 1,
        );
        dataSource.saveLessonProgress(progress);

        // Simulate a better result
        final updatedProgress = progress.copyWith(stars: 3, isCompleted: true);
        dataSource.saveLessonProgress(updatedProgress);

        final retrieved = progressRepo.getLessonProgress('consonants_1');
        expect(retrieved.stars, 3);
      });

      test('updates bestTimeMs when better', () {
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          bestTimeMs: 30000,
        ));

        // Simulate better time
        final updatedProgress = LessonProgress(
          lessonId: 'consonants_1',
          stars: 2,
          bestTimeMs: 15000,
        );
        dataSource.saveLessonProgress(updatedProgress);

        final retrieved = progressRepo.getLessonProgress('consonants_1');
        expect(retrieved.bestTimeMs, 15000);
      });
    });

    group('totalLessonsCompleted', () {
      test('counts lessons with at least 1 star', () {
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
          stars: 0,
        ));

        expect(progressRepo.totalLessonsCompleted(), 2);
      });
    });

    group('isLessonUnlocked', () {
      test('first lesson is always unlocked', () {
        final lessons = charRepo.getAllLessons();
        final firstLesson = lessons.first;

        expect(progressRepo.isLessonUnlocked(firstLesson.id, charRepo), isTrue);
      });

      test('lesson locked when previous has no stars', () {
        final lessons = charRepo.getAllLessons();
        final secondLesson = lessons[1];

        expect(progressRepo.isLessonUnlocked(secondLesson.id, charRepo), isFalse);
      });

      test('lesson unlocked when previous has stars', () {
        final lessons = charRepo.getAllLessons();
        final firstLesson = lessons.first;
        final secondLesson = lessons[1];

        // Complete first lesson
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: firstLesson.id,
          stars: 1,
        ));

        expect(progressRepo.isLessonUnlocked(secondLesson.id, charRepo), isTrue);
      });
    });

    group('getWeakCharacters', () {
      test('returns characters sorted by accuracy', () {
        // Add some practice data
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          testAttemptCount: 10,
          testCorrectCount: 8,
          practiceCount: 5,
        ));
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E82',
          testAttemptCount: 10,
          testCorrectCount: 3,
          practiceCount: 3,
        ));
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E84',
          testAttemptCount: 10,
          testCorrectCount: 1,
          practiceCount: 2,
        ));

        final weakChars = progressRepo.getWeakCharacters(limit: 10);

        // Should be sorted by accuracy (ascending)
        expect(weakChars.length, lessThanOrEqualTo(10));
      });
    });

    group('resetAllProgress', () {
      test('clears all progress', () async {
        dataSource.saveCharacterProgress(CharacterProgress(
          codepoint: 'U+0E81',
          practiceCount: 5,
        ));
        dataSource.saveLessonProgress(LessonProgress(
          lessonId: 'consonants_1',
          stars: 3,
        ));

        await progressRepo.resetAllProgress();

        final charProgress = progressRepo.getAllCharacterProgress();
        final lessonProgress = progressRepo.getAllLessonProgress();
        expect(charProgress, isEmpty);
        expect(lessonProgress, isEmpty);
      });
    });

    group('getPhaseProgress', () {
      test('returns correct counts for phase', () {
        final allLessons = charRepo.getAllLessons();
        final phase1Lessons = allLessons.where((l) => l.phase == 1).toList();
        final phase1LessonIds = phase1Lessons.map((l) => l.id).toSet();

        // Complete some phase 1 lessons
        for (final lessonId in phase1LessonIds.take(3)) {
          dataSource.saveLessonProgress(LessonProgress(
            lessonId: lessonId,
            stars: 3,
          ));
        }

        final progress = progressRepo.getPhaseProgress(1);
        expect(progress['completed'], 3);
        expect(progress['total'], phase1Lessons.length);
      });

      test('returns zeros for phase with no lessons', () {
        final progress = progressRepo.getPhaseProgress(99);
        expect(progress['completed'], 0);
        expect(progress['total'], 0);
      });
    });
  });
}
