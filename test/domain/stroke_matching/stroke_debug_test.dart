import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/domain/stroke_matching/stroke_matcher.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
import 'package:write_it_lao/domain/stroke_matching/dtw.dart';
import 'package:write_it_lao/domain/stroke_matching/path_utils.dart';
import 'package:write_it_lao/domain/stroke_matching/point_resampler.dart';

void main() {
  test('debug stroke matching scores', () {
    final file = File('assets/stroke_data/0E81.json');
    final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final charData = CharacterStrokeData.fromJson(json);
    final ref = charData.strokes[0];
    final refPoints = ref.pointsAsPoints;

    print('=== Reference stroke ===');
    print('Points: ${refPoints.length}');
    print('Start: (${refPoints.first.x.toStringAsFixed(1)}, ${refPoints.first.y.toStringAsFixed(1)})');
    print('End: (${refPoints.last.x.toStringAsFixed(1)}, ${refPoints.last.y.toStringAsFixed(1)})');

    final matcher = StrokeMatcher(canvasSize: 512.0);
    final resampler = PointResampler();

    // Test 1: exact match
    var eval = matcher.evaluate(refPoints, ref);
    print('\n=== Exact match ===');
    print('Result: ${eval.result}, similarity: ${eval.similarity.toStringAsFixed(4)}, dtw: ${eval.distanceScore.toStringAsFixed(4)}');
    print('dirCorrect: ${eval.directionCorrect}, posCorrect: ${eval.positionCorrect}');

    // Test 2: slightly noisy version
    final rng = Random(42);
    final noisy = refPoints.map((p) => Point<double>(
      p.x + (rng.nextDouble() - 0.5) * 20,
      p.y + (rng.nextDouble() - 0.5) * 20,
    )).toList();
    eval = matcher.evaluate(noisy, ref);
    print('\n=== Noisy match (±10px) ===');
    print('Result: ${eval.result}, similarity: ${eval.similarity.toStringAsFixed(4)}, dtw: ${eval.distanceScore.toStringAsFixed(4)}');

    // Test 3: very noisy
    final veryNoisy = refPoints.map((p) => Point<double>(
      p.x + (rng.nextDouble() - 0.5) * 60,
      p.y + (rng.nextDouble() - 0.5) * 60,
    )).toList();
    eval = matcher.evaluate(veryNoisy, ref);
    print('\n=== Very noisy match (±30px) ===');
    print('Result: ${eval.result}, similarity: ${eval.similarity.toStringAsFixed(4)}, dtw: ${eval.distanceScore.toStringAsFixed(4)}');

    // Test 4: fewer points with noise (sparse user input)
    final sparse = <Point<double>>[];
    for (var i = 0; i < refPoints.length; i += 3) {
      sparse.add(Point<double>(
        refPoints[i].x + (rng.nextDouble() - 0.5) * 30,
        refPoints[i].y + (rng.nextDouble() - 0.5) * 30,
      ));
    }
    eval = matcher.evaluate(sparse, ref);
    print('\n=== Sparse + noisy (${sparse.length} pts, ±15px) ===');
    print('Result: ${eval.result}, similarity: ${eval.similarity.toStringAsFixed(4)}, dtw: ${eval.distanceScore.toStringAsFixed(4)}');

    // Test 5: rough hand-drawn loop shape
    final handDrawn = <Point<double>>[];
    for (var i = 0; i < 20; i++) {
      final t = i / 19.0;
      final angle = t * 2 * pi;
      handDrawn.add(Point<double>(
        200 + 40 * cos(angle),
        300 + 40 * sin(angle),
      ));
    }
    for (var i = 0; i < 10; i++) {
      handDrawn.add(Point<double>(
        220 + i * 15.0,
        320 + (rng.nextDouble() - 0.5) * 10,
      ));
    }
    eval = matcher.evaluate(handDrawn, ref);
    print('\n=== Hand-simulated rough shape ===');
    print('Result: ${eval.result}, similarity: ${eval.similarity.toStringAsFixed(4)}, dtw: ${eval.distanceScore.toStringAsFixed(4)}');
    print('dirCorrect: ${eval.directionCorrect}, posCorrect: ${eval.positionCorrect}');

    // Debug internals
    print('\n=== Debug normalization ===');
    final drawnResampled = resampler.resample(List.from(refPoints), 48);
    final refResampled = resampler.resample(List.from(refPoints), 48);
    final drawnNorm = PathUtils.scaleToFit(PathUtils.centerOnOrigin(drawnResampled), 1.0);
    final refNorm = PathUtils.scaleToFit(PathUtils.centerOnOrigin(refResampled), 1.0);

    print('Drawn resampled: ${drawnResampled.length} pts');
    print('Ref resampled: ${refResampled.length} pts');
    print('Drawn norm [0]: (${drawnNorm.first.x.toStringAsFixed(4)}, ${drawnNorm.first.y.toStringAsFixed(4)})');
    print('Ref norm [0]: (${refNorm.first.x.toStringAsFixed(4)}, ${refNorm.first.y.toStringAsFixed(4)})');

    final dtw = DTW.distance(drawnNorm, refNorm);
    print('DTW self-distance: ${dtw.toStringAsFixed(6)}');

    // noisy normalized
    final noisyResampled = resampler.resample(List.from(noisy), 48);
    final noisyNorm = PathUtils.scaleToFit(PathUtils.centerOnOrigin(noisyResampled), 1.0);
    final noisyDtw = DTW.distance(noisyNorm, refNorm);
    print('Noisy DTW: ${noisyDtw.toStringAsFixed(6)}');

    // Per-point distances
    var maxDist = 0.0;
    var totalDist = 0.0;
    for (var i = 0; i < noisyNorm.length; i++) {
      final d = PathUtils.distance(noisyNorm[i], refNorm[i]);
      totalDist += d;
      if (d > maxDist) maxDist = d;
    }
    print('Noisy avg point-wise dist: ${(totalDist / noisyNorm.length).toStringAsFixed(4)}');
    print('Noisy max point-wise dist: ${maxDist.toStringAsFixed(4)}');

    final refBB = PathUtils.boundingBox(refNorm);
    print('Ref norm bbox: w=${refBB.width.toStringAsFixed(4)}, h=${refBB.height.toStringAsFixed(4)}');

    // Test with a VERY different number of input points (like 5-10, simulating quick swipe)
    print('\n=== Quick swipe (5 points along rough path) ===');
    final quickSwipe = [
      Point<double>(176.0, 323.0),
      Point<double>(170.0, 290.0),
      Point<double>(210.0, 250.0),
      Point<double>(250.0, 300.0),
      Point<double>(330.0, 360.0),
    ];
    eval = matcher.evaluate(quickSwipe, ref);
    print('Result: ${eval.result}, similarity: ${eval.similarity.toStringAsFixed(4)}, dtw: ${eval.distanceScore.toStringAsFixed(4)}');
    print('dirCorrect: ${eval.directionCorrect}, posCorrect: ${eval.positionCorrect}');

    // Check path length to ensure it passes the minimum
    final swipeLen = resampler.pathLength(quickSwipe);
    print('Swipe path length: ${swipeLen.toStringAsFixed(1)}, min required: ${0.05 * 512}');
  });
}
