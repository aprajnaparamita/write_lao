import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';

/// Open-source builds ship the full vocabulary unlocked. The repository
/// forces `iapUnlocked = true` on every read/write when
/// `unlockByDefault` is set, so the flag can never be re-locked locally.
void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('hive_unlock_test_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String uniqueSuffix() => DateTime.now().microsecondsSinceEpoch.toString();

  UserVocabProgress lockedRecord() => UserVocabProgress(
    id: 'p_locked',
    createdAt: DateTime.utc(2026, 4, 19),
    updatedAt: DateTime.utc(2026, 4, 19),
  );

  group('unlockByDefault: true (open-source build)', () {
    late Box<UserVocabProgress> box;
    late UserVocabProgressRepository repo;

    setUp(() async {
      box = await Hive.openBox<UserVocabProgress>('up_open_${uniqueSuffix()}');
      repo = UserVocabProgressRepository(box, unlockByDefault: true);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('getOrCreate creates the singleton with iapUnlocked = true', () {
      final progress = repo.getOrCreate();
      expect(progress.iapUnlocked, isTrue);
      expect(box.get('singleton')?.iapUnlocked, isTrue);
    });

    test('existing locked record is upgraded to unlocked and persisted', () {
      box.put('singleton', lockedRecord());
      final progress = repo.getOrCreate();
      expect(progress.iapUnlocked, isTrue);
      expect(box.get('singleton')?.iapUnlocked, isTrue);
    });

    test('save() cannot re-lock content', () {
      repo.getOrCreate();
      final saved = repo.save(lockedRecord());
      expect(saved.iapUnlocked, isTrue);
      expect(box.get('singleton')?.iapUnlocked, isTrue);
    });

    test('markIapUnlocked stays a no-op-safe fast path', () {
      final marked = repo.markIapUnlocked();
      expect(marked.iapUnlocked, isTrue);
    });
  });

  group('unlockByDefault: false (store build)', () {
    late Box<UserVocabProgress> box;
    late UserVocabProgressRepository repo;

    setUp(() async {
      box = await Hive.openBox<UserVocabProgress>('up_store_${uniqueSuffix()}');
      repo = UserVocabProgressRepository(box, unlockByDefault: false);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('getOrCreate keeps iapUnlocked = false until purchased', () {
      expect(repo.getOrCreate().iapUnlocked, isFalse);
    });

    test('save persists the unlocked flag as-is', () {
      final saved = repo.save(lockedRecord().copyWith(iapUnlocked: true));
      expect(saved.iapUnlocked, isTrue);
      expect(box.get('singleton')?.iapUnlocked, isTrue);
    });
  });
}
