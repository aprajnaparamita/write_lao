/// In-memory test fixtures for vocab course bundles.
///
/// Bundles are kept as JSON strings rather than files so tests can inject
/// them through the data source's [AssetStringLoader] without touching disk.
library;

/// 2 units, 3 lessons, 10 words. The canonical happy-path bundle.
final String validBundleJson = '''
{
  "version": "1.0.0-fixture",
  "language": "lao",
  "target_audience": "write_lao_500",
  "units": [
    {
      "unit_id": "u_01",
      "unit_number": 1,
      "title": "Greetings",
      "description": "Common Lao greetings",
      "lesson_ids": ["l_01_01", "l_01_02"]
    },
    {
      "unit_id": "u_02",
      "unit_number": 2,
      "title": "Family",
      "description": "Family vocabulary",
      "lesson_ids": ["l_02_01"]
    }
  ],
  "lessons": [
    {
      "lesson_id": "l_01_01",
      "unit_id": "u_01",
      "lesson_number": 1,
      "new_word_ids": ["w_0001", "w_0002", "w_0003"],
      "review_word_ids": []
    },
    {
      "lesson_id": "l_01_02",
      "unit_id": "u_01",
      "lesson_number": 2,
      "new_word_ids": ["w_0004", "w_0005", "w_0006"],
      "review_word_ids": ["w_0001", "w_0002"]
    },
    {
      "lesson_id": "l_02_01",
      "unit_id": "u_02",
      "lesson_number": 1,
      "new_word_ids": ["w_0007", "w_0008", "w_0009", "w_0010"],
      "review_word_ids": []
    }
  ],
  "words": [
    $_word1,
    $_word2,
    $_word3,
    $_word4,
    $_word5,
    $_word6,
    $_word7,
    $_word8,
    $_word9,
    $_word10
  ]
}
''';

/// Same as [validBundleJson] but l_01_02 references a non-existent word.
final String bundleWithDanglingWordJson = '''
{
  "version": "1.0.0-fixture",
  "language": "lao",
  "target_audience": "write_lao_500",
  "units": [
    {
      "unit_id": "u_01",
      "unit_number": 1,
      "title": "Greetings",
      "description": "x",
      "lesson_ids": ["l_01_01"]
    }
  ],
  "lessons": [
    {
      "lesson_id": "l_01_01",
      "unit_id": "u_01",
      "lesson_number": 1,
      "new_word_ids": ["w_0001", "w_does_not_exist"],
      "review_word_ids": []
    }
  ],
  "words": [
    $_word1
  ]
}
''';

/// Structurally valid but image_path points at a file not in the asset set.
final String bundleWithMissingImageJson = '''
{
  "version": "1.0.0-fixture",
  "language": "lao",
  "target_audience": "write_lao_500",
  "units": [
    {
      "unit_id": "u_01",
      "unit_number": 1,
      "title": "Greetings",
      "description": "x",
      "lesson_ids": ["l_01_01"]
    }
  ],
  "lessons": [
    {
      "lesson_id": "l_01_01",
      "unit_id": "u_01",
      "lesson_number": 1,
      "new_word_ids": ["w_missing_img"],
      "review_word_ids": []
    }
  ],
  "words": [
    {
      "word_id": "w_missing_img",
      "lao_word": "ສະບາຍດີ",
      "romanization": "saʔ baːj diː",
      "definitions": {"en": "hello"},
      "part_of_speech": "interjection",
      "characters": [
        {"position": 0, "character": "ສ", "type": "consonant"}
      ],
      "image_path": "images/does_not_exist.webp",
      "audio_path": "audio/w_missing_img_word.m4a",
      "examples": [
        {
          "example_id": "w_missing_img_ex1",
          "lao_script": "ສະບາຍດີ",
          "romanization": "saʔ baːj diː",
          "translations": {"en": "hello"},
          "audio_path": "audio/w_missing_img_example1.m4a"
        }
      ]
    }
  ]
}
''';

/// Word w_0001 has a character with type "punctuation" — not allowed.
final String bundleWithInvalidCharTypeJson = '''
{
  "version": "1.0.0-fixture",
  "language": "lao",
  "target_audience": "write_lao_500",
  "units": [
    {
      "unit_id": "u_01",
      "unit_number": 1,
      "title": "Greetings",
      "description": "x",
      "lesson_ids": ["l_01_01"]
    }
  ],
  "lessons": [
    {
      "lesson_id": "l_01_01",
      "unit_id": "u_01",
      "lesson_number": 1,
      "new_word_ids": ["w_bad"],
      "review_word_ids": []
    }
  ],
  "words": [
    {
      "word_id": "w_bad",
      "lao_word": "ສະ",
      "romanization": "sa",
      "definitions": {"en": "x"},
      "part_of_speech": "noun",
      "characters": [
        {"position": 0, "character": "ສ", "type": "punctuation"}
      ],
      "image_path": "images/w_bad.webp",
      "audio_path": "audio/w_bad_word.m4a",
      "examples": [
        {
          "example_id": "w_bad_ex1",
          "lao_script": "ສະ",
          "romanization": "sa",
          "translations": {"en": "x"},
          "audio_path": "audio/w_bad_example1.m4a"
        }
      ]
    }
  ]
}
''';

/// All asset paths referenced by [validBundleJson] (already prefixed with
/// 'assets/vocab/'). Tests use this to seed the fake [AssetExistsCheck].
final Set<String> validBundleAssetPaths = {
  for (var i = 1; i <= 10; i++) ...[
    'assets/vocab/images/w_${i.toString().padLeft(4, '0')}.webp',
    'assets/vocab/audio/w_${i.toString().padLeft(4, '0')}_word.m4a',
    'assets/vocab/audio/w_${i.toString().padLeft(4, '0')}_example1.m4a',
    'assets/vocab/audio/w_${i.toString().padLeft(4, '0')}_example2.m4a',
  ],
  // The dangling-word fixture only references w_0001's assets.
  // The missing-image fixture is intentionally missing
  //   'assets/vocab/images/does_not_exist.webp'
  // but we still need its audio paths to exist so the test fails on the
  // image specifically and not on its audio.
  'assets/vocab/audio/w_missing_img_word.m4a',
  'assets/vocab/audio/w_missing_img_example1.m4a',
};

String _wordTemplate(int n, {String? lao}) {
  final id = 'w_${n.toString().padLeft(4, '0')}';
  final laoWord = lao ?? 'ສະ';
  return '''
{
  "word_id": "$id",
  "lao_word": "$laoWord",
  "romanization": "saʔ",
  "definitions": {"en": "fixture word $n", "fr": "mot de test $n"},
  "part_of_speech": "noun",
  "characters": [
    {"position": 0, "character": "ສ", "type": "consonant"},
    {"position": 1, "character": "ະ", "type": "vowel"}
  ],
  "image_path": "images/$id.webp",
  "audio_path": "audio/${id}_word.m4a",
  "examples": [
    {
      "example_id": "${id}_ex1",
      "lao_script": "$laoWord",
      "romanization": "saʔ",
      "translations": {"en": "test sentence $n", "fr": "phrase de test $n"},
      "audio_path": "audio/${id}_example1.m4a"
    },
    {
      "example_id": "${id}_ex2",
      "lao_script": "$laoWord",
      "romanization": "saʔ",
      "translations": {"en": "second sentence $n"},
      "audio_path": "audio/${id}_example2.m4a"
    }
  ]
}
''';
}

final String _word1 = _wordTemplate(1);
final String _word2 = _wordTemplate(2);
final String _word3 = _wordTemplate(3);
final String _word4 = _wordTemplate(4);
final String _word5 = _wordTemplate(5);
final String _word6 = _wordTemplate(6);
final String _word7 = _wordTemplate(7);
final String _word8 = _wordTemplate(8);
final String _word9 = _wordTemplate(9);
final String _word10 = _wordTemplate(10);
