import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:write_lao/vocab/data/datasources/course_content_datasource.dart';
import 'package:write_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_lao/vocab/data/models/course_content.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_lao/vocab/data/repositories/vocab_preferences_repository.dart';
import 'package:write_lao/vocab/data/repositories/vocab_user_state_repository.dart';
import 'package:write_lao/vocab/domain/iap_service.dart';
import 'package:write_lao/vocab/domain/platform_iap_service.dart';
import 'package:write_lao/vocab/domain/lesson_engine.dart';

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

/// Raw (non-reactive) preferences repository — the underlying storage.
final vocabPreferencesRepositoryRawProvider =
    Provider<VocabPreferencesRepository>((ref) {
  return VocabPreferencesRepository(
    Hive.box<dynamic>(VocabBoxes.preferences),
  );
});

/// Banner dismiss revision counter. Watching this provider triggers rebuilds
/// whenever the banner dismiss state changes (tracked via a counter).
/// The actual dismiss action is handled in `_FreeUnitBanner`.
final vocabBannerDismissRevProvider = StateProvider<int>((ref) => 0);

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

/// IAP service provider.
/// - Debug builds: [MockIapService] with instant-success so the full
///   purchase flow (spinner → unlock → pop) can be exercised without a
///   real App Store connection.
/// - Release / profile: [PlatformIapService] talks to StoreKit / Google Play.
final iapServiceProvider = Provider<IapService>((ref) {
  if (kDebugMode) return const MockIapService(simulateSuccess: true);
  return PlatformIapService();
});

/// Localized StoreKit price label for the vocab IAP (e.g. "$4.99").
/// Null while loading or if the store is unreachable; surfaces that watch
/// it should fall back to a generic "BUY NOW" until a value arrives.
final iapPriceLabelProvider = FutureProvider<String?>((ref) async {
  final iap = ref.watch(iapServiceProvider);
  return iap.getPriceLabel();
});

/// Change counter bumped whenever vocab user state is mutated through a
/// non-reactive path (e.g., an IAP unlock, a progress advance). Consumers
/// that display progress `watch` this provider to trigger a rebuild; the
/// underlying Hive box is re-read on every build, so reading the latest
/// value after a bump returns the updated state.
final vocabStateRevProvider = StateProvider<int>((ref) => 0);