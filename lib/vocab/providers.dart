import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/course_content.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_it_lao/vocab/domain/lesson_engine.dart';

/// Loads the course bundle from app assets.
final courseContentDataSourceProvider = Provider<CourseContentDataSource>(
  (ref) => CourseContentDataSource.production(),
);

final courseContentProvider = FutureProvider<CourseContent>((ref) async {
  final ds = ref.watch(courseContentDataSourceProvider);
  return ds.load();
});

final courseRepositoryProvider = FutureProvider<CourseRepository>((ref) async {
  final content = await ref.watch(courseContentProvider.future);
  return CourseRepository(content);
});

final userWordRepositoryProvider = Provider<UserWordRepository>((ref) {
  return UserWordRepository(Hive.box<UserWord>(VocabBoxes.userWord));
});

final userVocabProgressRepositoryProvider =
    Provider<UserVocabProgressRepository>((ref) {
  return UserVocabProgressRepository(
    Hive.box<UserVocabProgress>(VocabBoxes.userProgress),
  );
});

final userSessionRepositoryProvider = Provider<UserSessionRepository>((ref) {
  return UserSessionRepository(
    Hive.box<UserSession>(VocabBoxes.userSession),
  );
});

final flagDeckRepositoryProvider = Provider<FlagDeckRepository>((ref) {
  return FlagDeckRepository(
    Hive.box<FlagDeck>(VocabBoxes.flagDeck),
    Hive.box<FlagDeckWord>(VocabBoxes.flagDeckWord),
  );
});

/// The lesson engine sits on top of every other vocab provider — it depends
/// on the loaded course bundle, so it's a `FutureProvider`.
final lessonEngineProvider = FutureProvider<LessonEngine>((ref) async {
  final course = await ref.watch(courseRepositoryProvider.future);
  return LessonEngine(
    course: course,
    userWords: ref.watch(userWordRepositoryProvider),
    userProgress: ref.watch(userVocabProgressRepositoryProvider),
    userSessions: ref.watch(userSessionRepositoryProvider),
    flagDecks: ref.watch(flagDeckRepositoryProvider),
  );
});
