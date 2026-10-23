import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/vocab/data/models/vocab_user_state.dart';
import 'package:write_lao/vocab/domain/card_mode.dart';

void main() {
  group('cardModeFor', () {
    test('new and learning → practice', () {
      expect(cardModeFor(WordStatus.newWord), CardMode.practice);
      expect(cardModeFor(WordStatus.learning), CardMode.practice);
    });

    test('reviewing, mature, retired → test', () {
      expect(cardModeFor(WordStatus.reviewing), CardMode.test);
      expect(cardModeFor(WordStatus.mature), CardMode.test);
      expect(cardModeFor(WordStatus.retired), CardMode.test);
    });
  });
}
