import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_lao/vocab/domain/hear_identify_planner.dart';

UserWord _uw(String id, WordStatus status) => UserWord(
      id: 'uuid-$id',
      wordId: id,
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('filterLearned', () {
    test('keeps learning, reviewing, mature', () {
      final pool = [
        _uw('a', WordStatus.newWord),
        _uw('b', WordStatus.learning),
        _uw('c', WordStatus.reviewing),
        _uw('d', WordStatus.mature),
        _uw('e', WordStatus.retired),
      ];
      expect(
        filterLearned(pool).map((w) => w.wordId),
        equals(['b', 'c', 'd']),
      );
    });
  });

  group('pickDistractors', () {
    test('returns exactly count distinct IDs, never the correct one', () {
      final out = pickDistractors(
        correctWordId: 'a',
        learnedPool: ['a', 'b', 'c', 'd', 'e', 'f'],
        count: 3,
        random: math.Random(42),
      );
      expect(out, hasLength(3));
      expect(out, isNot(contains('a')));
      expect(out.toSet().length, 3); // distinct
    });

    test('returns all available if pool smaller than count', () {
      final out = pickDistractors(
        correctWordId: 'a',
        learnedPool: ['a', 'b'],
        count: 3,
        random: math.Random(42),
      );
      expect(out, equals(['b']));
    });

    test('deterministic with same seed', () {
      final pool = ['a', 'b', 'c', 'd', 'e', 'f', 'g'];
      final r1 = pickDistractors(
        correctWordId: 'a',
        learnedPool: pool,
        count: 3,
        random: math.Random(7),
      );
      final r2 = pickDistractors(
        correctWordId: 'a',
        learnedPool: pool,
        count: 3,
        random: math.Random(7),
      );
      expect(r1, equals(r2));
    });
  });

  group('shouldInsertHearIdentify', () {
    test('disabled config → never insert', () {
      expect(
        shouldInsertHearIdentify(
          config: HearIdentifyConfig.disabled,
          learnedPoolSize: 100,
          isFirstLessonOfUnit: false,
          random: math.Random(0),
        ),
        isFalse,
      );
    });

    test('first lesson of unit → never insert', () {
      expect(
        shouldInsertHearIdentify(
          config: const HearIdentifyConfig(probability: 1.0),
          learnedPoolSize: 100,
          isFirstLessonOfUnit: true,
          random: math.Random(0),
        ),
        isFalse,
      );
    });

    test('pool < min learned words → never insert', () {
      expect(
        shouldInsertHearIdentify(
          config: const HearIdentifyConfig(
            probability: 1.0,
            minLearnedWords: 5,
          ),
          learnedPoolSize: 4,
          isFirstLessonOfUnit: false,
          random: math.Random(0),
        ),
        isFalse,
      );
    });

    test('probability 1.0 + eligible → always insert', () {
      expect(
        shouldInsertHearIdentify(
          config: const HearIdentifyConfig(probability: 1.0),
          learnedPoolSize: 10,
          isFirstLessonOfUnit: false,
          random: math.Random(0),
        ),
        isTrue,
      );
    });

    test('probability 0.0 + eligible → never insert', () {
      expect(
        shouldInsertHearIdentify(
          config: const HearIdentifyConfig(probability: 0.0),
          learnedPoolSize: 10,
          isFirstLessonOfUnit: false,
          random: math.Random(0),
        ),
        isFalse,
      );
    });

    test('probability 0.25 → ~25% over a large sample', () {
      final config = const HearIdentifyConfig(probability: 0.25);
      final r = math.Random(123);
      var hits = 0;
      const n = 4000;
      for (var i = 0; i < n; i++) {
        if (shouldInsertHearIdentify(
          config: config,
          learnedPoolSize: 10,
          isFirstLessonOfUnit: false,
          random: r,
        )) {
          hits++;
        }
      }
      // Tolerate ±3 percentage points for n=4000.
      expect(hits / n, closeTo(0.25, 0.03));
    });
  });
}
