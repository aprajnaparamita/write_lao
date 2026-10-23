import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_lao/vocab/domain/deck_study_planner.dart';

UserWord _uw(
  String wordId, {
  WordStatus status = WordStatus.learning,
  DateTime? lastReviewedAt,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return UserWord(
    id: 'uuid-$wordId',
    wordId: wordId,
    status: status,
    lastReviewedAt: lastReviewedAt,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('planDeckStudy', () {
    test('orders by last_reviewed_at ASC, never-reviewed first', () {
      final words = {
        'a': _uw('a', lastReviewedAt: DateTime.utc(2026, 4, 10)),
        'b': _uw('b'), // never reviewed
        'c': _uw('c', lastReviewedAt: DateTime.utc(2026, 4, 1)),
        'd': _uw('d', lastReviewedAt: DateTime.utc(2026, 4, 18)),
      };
      final plan = planDeckStudy(
        wordIds: ['a', 'b', 'c', 'd'],
        userWordsByWordId: words,
      );
      expect(plan, equals(['b', 'c', 'a', 'd']));
    });

    test('caps at limit (default 10)', () {
      final ids = List<String>.generate(15, (i) => 'w$i');
      final words = {
        for (var i = 0; i < ids.length; i++)
          ids[i]: _uw(
            ids[i],
            lastReviewedAt: DateTime.utc(2026, 1, 1).add(Duration(days: i)),
          ),
      };
      final plan = planDeckStudy(wordIds: ids, userWordsByWordId: words);
      expect(plan, hasLength(10));
      // Earliest 10 by lastReviewedAt: w0..w9
      expect(plan, equals(List.generate(10, (i) => 'w$i')));
    });

    test('returns all when deck has fewer than limit words', () {
      final ids = ['a', 'b', 'c'];
      final words = {for (final id in ids) id: _uw(id)};
      final plan = planDeckStudy(
        wordIds: ids,
        userWordsByWordId: words,
        limit: 10,
      );
      expect(plan, hasLength(3));
    });

    test('skips retired words (v1 default)', () {
      final words = {
        'a': _uw('a', status: WordStatus.learning),
        'b': _uw('b', status: WordStatus.retired),
        'c': _uw('c', status: WordStatus.mature),
      };
      final plan = planDeckStudy(
        wordIds: ['a', 'b', 'c'],
        userWordsByWordId: words,
      );
      expect(plan, equals(['a', 'c']));
    });

    test('treats words with no UserWord row as never-reviewed', () {
      final words = {
        'a': _uw('a', lastReviewedAt: DateTime.utc(2026, 4, 10)),
      };
      final plan = planDeckStudy(
        wordIds: ['a', 'unseen'],
        userWordsByWordId: words,
      );
      // 'unseen' (no row) sorts BEFORE 'a' (reviewed Apr 10).
      expect(plan, equals(['unseen', 'a']));
    });

    test('limit=0 or empty deck returns empty', () {
      expect(
        planDeckStudy(wordIds: const [], userWordsByWordId: const {}),
        isEmpty,
      );
      expect(
        planDeckStudy(
          wordIds: const ['a'],
          userWordsByWordId: const {},
          limit: 0,
        ),
        isEmpty,
      );
    });
  });
}
