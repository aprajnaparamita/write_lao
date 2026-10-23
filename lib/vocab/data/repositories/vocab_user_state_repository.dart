import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:write_it_lao/config/app_variant.dart';
import 'package:write_it_lao/vocab/data/models/vocab_user_state.dart';

/// Wall clock indirection so tests can freeze time.
typedef Clock = DateTime Function();
DateTime _systemNow() => DateTime.now().toUtc();

const _uuid = Uuid();

/// CRUD for user-word SRS records. UUIDs are auto-generated; `updated_at`
/// is bumped on every write so v2 sync can rely on it.
class UserWordRepository {
  final Box<UserWord> _box;
  final Clock _now;

  UserWordRepository(this._box, {Clock now = _systemNow}) : _now = now;

  /// Create a new UserWord for [wordId]. Returns the persisted record.
  UserWord create(String wordId) {
    final now = _now();
    final word = UserWord(
      id: _uuid.v4(),
      wordId: wordId,
      createdAt: now,
      updatedAt: now,
      firstSeenAt: now,
    );
    _box.put(word.id, word);
    return word;
  }

  /// Persist [word] and bump its `updated_at`. Returns the touched record.
  UserWord save(UserWord word) {
    final touched = word.copyWith(updatedAt: _now());
    _box.put(touched.id, touched);
    return touched;
  }

  UserWord? getById(String id) => _box.get(id);

  UserWord? getByWordId(String wordId) {
    for (final w in _box.values) {
      if (w.wordId == wordId) return w;
    }
    return null;
  }

  List<UserWord> getAll() => _box.values.toList();

  void delete(String id) => _box.delete(id);

  Future<void> clear() => _box.clear();
}

/// Singleton user progress record. In v1 the box always contains 0 or 1 row.
class UserVocabProgressRepository {
  final Box<UserVocabProgress> _box;
  final Clock _now;

  /// When true, `iapUnlocked` is forced to true on every read and write.
  /// Open-source builds ([kVocabUnlockedByDefault]) ship the full
  /// vocabulary unlocked; store builds keep it behind the IAP.
  /// Injectable so tests can exercise both behaviors.
  final bool unlockByDefault;

  static const String _singletonKey = 'singleton';

  UserVocabProgressRepository(
    this._box, {
    Clock now = _systemNow,
    bool? unlockByDefault,
  }) : _now = now,
       unlockByDefault = unlockByDefault ?? kVocabUnlockedByDefault;

  /// Forces `iapUnlocked = true` when [unlockByDefault] is set.
  UserVocabProgress _normalize(UserVocabProgress progress) {
    if (!unlockByDefault || progress.iapUnlocked) return progress;
    return progress.copyWith(iapUnlocked: true);
  }

  /// Returns the existing singleton, or creates one with defaults.
  UserVocabProgress getOrCreate() {
    final existing = _box.get(_singletonKey);
    if (existing != null) {
      final normalized = _normalize(existing);
      if (!identical(normalized, existing)) {
        _box.put(_singletonKey, normalized);
      }
      return normalized;
    }
    final now = _now();
    final created = UserVocabProgress(
      id: _uuid.v4(),
      createdAt: now,
      updatedAt: now,
      iapUnlocked: unlockByDefault,
    );
    _box.put(_singletonKey, created);
    return created;
  }

  UserVocabProgress save(UserVocabProgress progress) {
    final touched = _normalize(progress.copyWith(updatedAt: _now()));
    _box.put(_singletonKey, touched);
    return touched;
  }

  /// Sets `iapUnlocked = true` on the singleton, creating it if missing.
  /// Returns the persisted record.
  UserVocabProgress markIapUnlocked() {
    final current = getOrCreate();
    if (current.iapUnlocked) return current;
    return save(current.copyWith(iapUnlocked: true));
  }
}

class UserSessionRepository {
  final Box<UserSession> _box;
  final Clock _now;

  UserSessionRepository(this._box, {Clock now = _systemNow}) : _now = now;

  UserSession start(String lessonId) {
    final now = _now();
    final session = UserSession(
      id: _uuid.v4(),
      lessonId: lessonId,
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );
    _box.put(session.id, session);
    return session;
  }

  UserSession save(UserSession session) {
    final touched = session.copyWith(updatedAt: _now());
    _box.put(touched.id, touched);
    return touched;
  }

  UserSession? getById(String id) => _box.get(id);

  List<UserSession> findByLessonId(String lessonId) {
    return _box.values.where((s) => s.lessonId == lessonId).toList();
  }
}

class FlagDeckRepository {
  final Box<FlagDeck> _decks;
  final Box<FlagDeckWord> _deckWords;
  final Clock _now;

  FlagDeckRepository(this._decks, this._deckWords, {Clock now = _systemNow})
    : _now = now;

  FlagDeck createDeck(String name) {
    final now = _now();
    final deck = FlagDeck(
      id: _uuid.v4(),
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    _decks.put(deck.id, deck);
    return deck;
  }

  FlagDeck saveDeck(FlagDeck deck) {
    final touched = deck.copyWith(updatedAt: _now());
    _decks.put(touched.id, touched);
    return touched;
  }

  /// Returns the renamed deck, or null if [deckId] doesn't exist.
  FlagDeck? renameDeck(String deckId, String newName) {
    final existing = _decks.get(deckId);
    if (existing == null) return null;
    return saveDeck(existing.copyWith(name: newName));
  }

  /// Returns counts keyed by deckId for one round-trip from the join box.
  Map<String, int> getDeckWordCounts() {
    final counts = <String, int>{};
    for (final dw in _deckWords.values) {
      counts.update(dw.deckId, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  /// Cascade-deletes the deck and all its FlagDeckWord rows.
  void deleteDeck(String deckId) {
    _decks.delete(deckId);
    final orphans = _deckWords.values
        .where((dw) => dw.deckId == deckId)
        .map((dw) => dw.id)
        .toList();
    for (final id in orphans) {
      _deckWords.delete(id);
    }
  }

  List<FlagDeck> getAllDecks() => _decks.values.toList();

  FlagDeck? getDeck(String id) => _decks.get(id);

  /// Idempotent: re-flagging an already-flagged word is a no-op.
  /// Returns the existing or newly-created join row.
  FlagDeckWord flagWord({required String deckId, required String wordId}) {
    for (final dw in _deckWords.values) {
      if (dw.deckId == deckId && dw.wordId == wordId) return dw;
    }
    final now = _now();
    final dw = FlagDeckWord(
      id: _uuid.v4(),
      deckId: deckId,
      wordId: wordId,
      createdAt: now,
      updatedAt: now,
    );
    _deckWords.put(dw.id, dw);
    return dw;
  }

  void unflagWord({required String deckId, required String wordId}) {
    final matches = _deckWords.values
        .where((dw) => dw.deckId == deckId && dw.wordId == wordId)
        .map((dw) => dw.id)
        .toList();
    for (final id in matches) {
      _deckWords.delete(id);
    }
  }

  List<FlagDeckWord> getWordsInDeck(String deckId) {
    return _deckWords.values.where((dw) => dw.deckId == deckId).toList();
  }

  List<FlagDeck> getDecksContaining(String wordId) {
    final deckIds = _deckWords.values
        .where((dw) => dw.wordId == wordId)
        .map((dw) => dw.deckId)
        .toSet();
    return _decks.values.where((d) => deckIds.contains(d.id)).toList();
  }
}
