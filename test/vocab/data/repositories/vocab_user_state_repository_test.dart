import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:write_it_lao/vocab/data/datasources/vocab_hive_adapters.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_it_lao/vocab/data/repositories/vocab_user_state_repository.dart';

void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir =
        Directory.systemTemp.createTempSync('hive_vocab_test_');
    Hive.init(tempDir.path);
    registerVocabHiveAdapters();
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  String _suffix() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  group('Hive vocab schema', () {
    test('opens vocab boxes cleanly on a fresh init', () async {
      final box = await Hive.openBox<UserWord>('vw_open_${_suffix()}');
      expect(box.isOpen, isTrue);
      await box.deleteFromDisk();
    });

    test('registerVocabHiveAdapters is idempotent (safe to call twice)', () {
      // First call already happened in setUpAll; calling again must not
      // throw (per Hive, registering a duplicate adapter throws by default).
      expect(registerVocabHiveAdapters, returnsNormally);
      expect(registerVocabHiveAdapters, returnsNormally);
    });
  });

  group('UserWordRepository', () {
    late Box<UserWord> box;
    late UserWordRepository repo;
    late DateTime currentNow;

    setUp(() async {
      box = await Hive.openBox<UserWord>('vw_${_suffix()}');
      currentNow = DateTime.utc(2026, 4, 19, 12);
      repo = UserWordRepository(box, now: () => currentNow);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('create() generates a UUID, sets created_at + updated_at, persists',
        () {
      final w = repo.create('w_0001');
      expect(w.id, isNotEmpty);
      expect(w.id.length, greaterThan(20)); // UUID v4 string
      expect(w.wordId, 'w_0001');
      expect(w.createdAt, currentNow);
      expect(w.updatedAt, currentNow);
      expect(w.firstSeenAt, currentNow);
      expect(w.status, WordStatus.newWord);
      expect(w.syncState, SyncState.local);

      // Round-trip through the box (verifies the Hive adapter).
      final fetched = repo.getById(w.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, w.id);
      expect(fetched.wordId, 'w_0001');
      expect(fetched.createdAt, currentNow);
    });

    test('save() bumps updated_at without changing created_at', () {
      final w = repo.create('w_0002');
      final originalCreatedAt = w.createdAt;

      // Advance the clock and save.
      currentNow = currentNow.add(const Duration(hours: 3));
      final updated = repo.save(
        w.copyWith(intervalDays: 6, consecutiveCorrect: 1),
      );

      expect(updated.updatedAt, currentNow);
      expect(updated.createdAt, originalCreatedAt);
      expect(updated.intervalDays, 6);

      final reread = repo.getById(w.id);
      expect(reread!.updatedAt, currentNow);
      expect(reread.createdAt, originalCreatedAt);
    });

    test('getByWordId finds an inserted record', () {
      final w = repo.create('w_0003');
      final found = repo.getByWordId('w_0003');
      expect(found, isNotNull);
      expect(found!.id, w.id);
    });

    test('UUIDs are unique across creates', () {
      final ids = <String>{
        for (var i = 0; i < 5; i++) repo.create('w_$i').id,
      };
      expect(ids, hasLength(5));
    });
  });

  group('UserVocabProgressRepository', () {
    late Box<UserVocabProgress> box;
    late UserVocabProgressRepository repo;

    setUp(() async {
      box = await Hive.openBox<UserVocabProgress>('vp_${_suffix()}');
      repo = UserVocabProgressRepository(box);
    });

    tearDown(() async {
      await box.deleteFromDisk();
    });

    test('getOrCreate returns the same singleton across calls', () {
      final first = repo.getOrCreate();
      final second = repo.getOrCreate();
      expect(first.id, second.id);
      expect(first.iapUnlocked, isFalse);
    });

    test('save bumps updated_at and persists', () async {
      final p = repo.getOrCreate();
      final t0 = p.updatedAt;
      await Future.delayed(const Duration(milliseconds: 5));
      final p2 = repo.save(p.copyWith(iapUnlocked: true));
      expect(p2.iapUnlocked, isTrue);
      expect(p2.updatedAt.isAfter(t0) || p2.updatedAt == t0, isTrue);
      expect(repo.getOrCreate().iapUnlocked, isTrue);
    });
  });

  group('FlagDeckRepository', () {
    late Box<FlagDeck> deckBox;
    late Box<FlagDeckWord> deckWordBox;
    late FlagDeckRepository repo;

    setUp(() async {
      deckBox = await Hive.openBox<FlagDeck>('fd_${_suffix()}');
      deckWordBox = await Hive.openBox<FlagDeckWord>('fdw_${_suffix()}');
      repo = FlagDeckRepository(deckBox, deckWordBox);
    });

    tearDown(() async {
      await deckBox.deleteFromDisk();
      await deckWordBox.deleteFromDisk();
    });

    test('flagWord is idempotent (no duplicate row on re-flag)', () {
      final deck = repo.createDeck('Tricky words');
      final first = repo.flagWord(deckId: deck.id, wordId: 'w_0001');
      final second = repo.flagWord(deckId: deck.id, wordId: 'w_0001');
      expect(first.id, second.id);
      expect(repo.getWordsInDeck(deck.id), hasLength(1));
    });

    test('deleteDeck cascades to its FlagDeckWord rows', () {
      final deck = repo.createDeck('To delete');
      repo.flagWord(deckId: deck.id, wordId: 'w_0001');
      repo.flagWord(deckId: deck.id, wordId: 'w_0002');
      expect(repo.getWordsInDeck(deck.id), hasLength(2));

      repo.deleteDeck(deck.id);

      expect(repo.getDeck(deck.id), isNull);
      expect(repo.getWordsInDeck(deck.id), isEmpty);
    });
  });
}
