import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';

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

  group('AudioPlayersVocabAudioPlayer disposal safety', () {
    setUp(_mockAudioplayersChannels);

    test('stop() after dispose() does not throw', () async {
      final audio = AudioPlayersVocabAudioPlayer();
      await audio.dispose();
      // Regression: previously this hit the state stream after it was closed,
      // throwing "Cannot add new events after calling close".
      await expectLater(audio.stop(), completes);
    });

    test('play() after dispose() does not throw', () async {
      final audio = AudioPlayersVocabAudioPlayer();
      await audio.dispose();
      await expectLater(audio.play('audio/w_0001_word.m4a'), completes);
    });

    test('a stop() in flight when dispose() runs does not throw', () async {
      final audio = AudioPlayersVocabAudioPlayer();
      // Kick off a stop() and tear the player down before it resumes — the
      // exact teardown race seen in production (a card's dispose stops audio
      // while the screen disposes the player).
      final pending = audio.stop();
      await audio.dispose();
      await expectLater(pending, completes);
    });
  });
}
