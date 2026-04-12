import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/domain/stroke_matching/dtw.dart';

void main() {
  group('DTW', () {
    test('two identical sequences have distance 0', () {
      final seq = List.generate(
          10, (i) => Point<double>(i.toDouble(), 0.0));
      expect(DTW.distance(seq, seq), closeTo(0.0, 0.001));
    });

    test('sequence vs itself shifted by 1 has small distance', () {
      final a = List.generate(
          10, (i) => Point<double>(i.toDouble(), 0.0));
      final b = List.generate(
          10, (i) => Point<double>(i + 1.0, 0.0));
      final dist = DTW.distance(a, b);
      expect(dist, greaterThan(0.0));
      expect(dist, lessThan(5.0));
    });

    test('completely different sequences have large distance', () {
      final a = List.generate(
          10, (i) => Point<double>(i.toDouble(), 0.0));
      final b = List.generate(
          10, (i) => Point<double>(0.0, i * 100.0));
      final dist = DTW.distance(a, b);
      expect(dist, greaterThan(50.0));
    });

    test('sequences of different lengths work', () {
      final a = List.generate(
          5, (i) => Point<double>(i.toDouble(), 0.0));
      final b = List.generate(
          10, (i) => Point<double>(i * 0.5, 0.0));
      final dist = DTW.distance(a, b);
      expect(dist, greaterThanOrEqualTo(0.0));
      expect(dist.isFinite, isTrue);
    });

    test('empty sequences return infinity', () {
      final seq = [const Point<double>(0.0, 0.0)];
      expect(DTW.distance([], seq), double.infinity);
      expect(DTW.distance(seq, []), double.infinity);
    });
  });
}
