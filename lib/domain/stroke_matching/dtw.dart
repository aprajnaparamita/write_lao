import 'dart:math';
import 'path_utils.dart';

class DTW {
  /// Compute DTW distance between two point sequences.
  /// Returns the normalized DTW distance (total cost / alignment length).
  static double distance(List<Point<double>> a, List<Point<double>> b) {
    if (a.isEmpty || b.isEmpty) return double.infinity;

    final n = a.length;
    final m = b.length;

    // Create cost matrix
    final d = List.generate(
      n + 1,
      (_) => List.filled(m + 1, double.infinity),
    );
    d[0][0] = 0.0;

    for (var i = 1; i <= n; i++) {
      for (var j = 1; j <= m; j++) {
        final cost = PathUtils.distance(a[i - 1], b[j - 1]);
        d[i][j] = cost +
            [d[i - 1][j], d[i][j - 1], d[i - 1][j - 1]]
                .reduce(min);
      }
    }

    // Normalize by alignment length
    return d[n][m] / max(n, m);
  }
}
