import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:write_it_lao/vocab/data/models/course_content.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';

const String kVocabAssetRoot = 'assets/vocab/';
const String kCourseJsonPath = 'assets/vocab/course.json';

/// Thrown when the course bundle fails validation. Bundle errors indicate
/// build-time bugs and should be fixed at the source — do not attempt
/// recovery at runtime.
class CourseValidationException implements Exception {
  final List<String> errors;
  CourseValidationException(this.errors);

  @override
  String toString() =>
      'CourseValidationException:\n  - ${errors.join('\n  - ')}';
}

typedef AssetStringLoader = Future<String> Function(String path);
typedef AssetExistsCheck = Future<bool> Function(String path);

/// Loads and validates the vocabulary course bundle.
///
/// Production usage wires [loadString] to [rootBundle.loadString] and
/// [assetExists] to a [rootBundle.load]-based existence check. Tests inject
/// in-memory fakes so they can run without a Flutter binding.
class CourseContentDataSource {
  final AssetStringLoader loadString;
  final AssetExistsCheck assetExists;
  final String coursePath;
  final int? expectedWordCount;

  CourseContentDataSource({
    required this.loadString,
    required this.assetExists,
    this.coursePath = kCourseJsonPath,
    this.expectedWordCount,
  });

  factory CourseContentDataSource.production() {
    return CourseContentDataSource(
      loadString: rootBundle.loadString,
      assetExists: _rootBundleAssetExists,
      expectedWordCount: 500,
    );
  }

  Future<CourseContent> load() async {
    final sw = Stopwatch()..start();
    // ignore: avoid_print
    print('[CourseContentDataSource.load] Starting load of $coursePath');
    final raw = await loadString(coursePath);
    // ignore: avoid_print
    print('[CourseContentDataSource.load] JSON loaded, size=${raw.length} chars, elapsed=${sw.elapsedMilliseconds}ms');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final content = CourseContent.fromJson(json);
    // ignore: avoid_print
    print('[CourseContentDataSource.load] Parsed ${content.words.length} words, starting validation, elapsed=${sw.elapsedMilliseconds}ms');
    await CourseContentValidator.validate(
      content,
      assetExists: assetExists,
      assetRoot: kVocabAssetRoot,
      expectedWordCount: expectedWordCount,
    );
    // ignore: avoid_print
    print('[CourseContentDataSource.load] Done, total elapsed=${sw.elapsedMilliseconds}ms');
    sw.stop();
    return content;
  }
}

Future<bool> _rootBundleAssetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (_) {
    return false;
  }
}

/// Pure validation over an already-parsed [CourseContent]. Failing loud per
/// spec — collects every error and throws [CourseValidationException] if any.
class CourseContentValidator {
  static Future<void> validate(
    CourseContent content, {
    required AssetExistsCheck assetExists,
    String assetRoot = kVocabAssetRoot,
    int? expectedWordCount,
  }) async {
    final sw = Stopwatch()..start();
    // ignore: avoid_print
    print('[CourseContentValidator.validate] Starting validation');

    final errors = <String>[];

    // Build lookup maps and check for duplicate IDs.
    final unitsById = <String, dynamic>{};
    for (final u in content.units) {
      if (unitsById.containsKey(u.unitId)) {
        errors.add('Duplicate unit_id: ${u.unitId}');
      }
      unitsById[u.unitId] = u;
    }
    final lessonsById = <String, dynamic>{};
    for (final l in content.lessons) {
      if (lessonsById.containsKey(l.lessonId)) {
        errors.add('Duplicate lesson_id: ${l.lessonId}');
      }
      lessonsById[l.lessonId] = l;
    }
    final wordsById = <String, VocabWord>{};
    for (final w in content.words) {
      if (wordsById.containsKey(w.wordId)) {
        errors.add('Duplicate word_id: ${w.wordId}');
      }
      wordsById[w.wordId] = w;
    }

    // Every lesson_id in unit.lesson_ids exists in lessons.
    for (final u in content.units) {
      for (final lid in u.lessonIds) {
        if (!lessonsById.containsKey(lid)) {
          errors.add(
            'Unit ${u.unitId} references unknown lesson_id: $lid',
          );
        }
      }
    }

    // Every unit_id on a lesson exists in units. Word references resolve.
    for (final l in content.lessons) {
      if (!unitsById.containsKey(l.unitId)) {
        errors.add(
          'Lesson ${l.lessonId} references unknown unit_id: ${l.unitId}',
        );
      }
      for (final wid in l.newWordIds) {
        if (!wordsById.containsKey(wid)) {
          errors.add(
            'Lesson ${l.lessonId} new_word_ids references unknown word_id: '
            '$wid',
          );
        }
      }
      for (final wid in l.reviewWordIds) {
        if (!wordsById.containsKey(wid)) {
          errors.add(
            'Lesson ${l.lessonId} review_word_ids references unknown '
            'word_id: $wid',
          );
        }
      }
    }

    // Every word has at least one example. Character positions are dense.
    // Asset paths are checked async in a second pass.
    for (final w in content.words) {
      if (w.examples.isEmpty) {
        errors.add('Word ${w.wordId} has no examples');
      }
      if (w.characters.isEmpty) {
        errors.add('Word ${w.wordId} has no characters');
      }
    }

    // ignore: avoid_print
    print('[CourseContentValidator.validate] Logical validation done, found ${errors.length} errors, elapsed=${sw.elapsedMilliseconds}ms');

    // Asset existence (image + word audio + per-example audio).
    final referenced = <String>{};
    for (final w in content.words) {
      referenced.add('$assetRoot${w.imagePath}');
      referenced.add('$assetRoot${w.audioPath}');
      for (final ex in w.examples) {
        referenced.add('$assetRoot${ex.audioPath}');
      }
    }
    // ignore: avoid_print
    print('[CourseContentValidator.validate] Checking ${referenced.length} asset references...');
    final assetCheckSw = Stopwatch()..start();
    final missing = <String>[];
    await Future.wait(referenced.map((p) async {
      if (!await assetExists(p)) missing.add(p);
    }));
    // ignore: avoid_print
    print('[CourseContentValidator.validate] Asset check done, ${missing.length} missing, elapsed=${assetCheckSw.elapsedMilliseconds}ms');
    assetCheckSw.stop();

    for (final p in missing) {
      errors.add('Referenced asset not found in bundle: $p');
    }

    if (errors.isNotEmpty) {
      throw CourseValidationException(errors);
    }

    // Soft check (warning only, not a hard failure).
    if (expectedWordCount != null &&
        content.words.length != expectedWordCount) {
      // ignore: avoid_print
      print(
        '[CourseContentValidator] WARNING: expected $expectedWordCount '
        'words, got ${content.words.length}',
      );
    }

    // ignore: avoid_print
    print('[CourseContentValidator.validate] Validation complete, total elapsed=${sw.elapsedMilliseconds}ms');
    sw.stop();
  }
}
