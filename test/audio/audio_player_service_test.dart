import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/audio/audio_player_service.dart';

void _mockAudioplayersChannels() {
  // audioplayers uses platform channels that don't exist in the test VM.
  // Return null (success) for every method call on both channels.
  const globalChannel = MethodChannel('xyz.luan/audioplayers.global');
  const playerChannel = MethodChannel('xyz.luan/audioplayers');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(globalChannel, (_) async => null);
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(playerChannel, (_) async => null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerService', () {
    late AudioPlayerService service;

    setUp(() {
      _mockAudioplayersChannels();
      service = AudioPlayerService();
    });

    tearDown(() {
      service.dispose();
    });

    test('isEnabled returns true by default', () {
      expect(service.isEnabled, true);
    });

    test('setEnabled changes isEnabled', () {
      service.setEnabled(false);
      expect(service.isEnabled, false);

      service.setEnabled(true);
      expect(service.isEnabled, true);
    });

    test('playCorrectSound completes when enabled', () async {
      await expectLater(service.playCorrectSound(), completes);
    });

    test('playIncorrectSound completes when enabled', () async {
      await expectLater(service.playIncorrectSound(), completes);
    });

    test('playCompleteSound completes when enabled', () async {
      await expectLater(service.playCompleteSound(), completes);
    });

    test('playStarSound completes when enabled', () async {
      await expectLater(service.playStarSound(), completes);
    });

    test('playPronunciation completes for unknown codepoint', () async {
      await expectLater(service.playPronunciation('U+9999'), completes);
    });

    test('sound methods are no-ops when disabled', () async {
      service.setEnabled(false);
      // None of these should throw
      await service.playCorrectSound();
      await service.playIncorrectSound();
      await service.playCompleteSound();
      await service.playStarSound();
      await service.playPronunciation('U+0E81');
    });

    test('stopAll completes without throwing', () async {
      await expectLater(service.stopAll(), completes);
    });
  });
}
