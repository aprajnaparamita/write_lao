import 'dart:async';

import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';

/// Test fake for [VocabAudioPlayer]. Records every `play` and `stop` call;
/// tests trigger natural completion via [completeCurrent] so chained
/// auto-play sequences fire deterministically.
class FakeVocabAudioPlayer implements VocabAudioPlayer {
  final List<String> playedPaths = [];
  int stopCallCount = 0;
  bool _muted;
  String? _currentPath;
  VocabAudioState _state = VocabAudioState.idle;
  final _stateController = StreamController<VocabAudioState>.broadcast();
  final _completeController = StreamController<String>.broadcast();

  FakeVocabAudioPlayer({bool muted = false}) : _muted = muted;

  /// Toggle mute state mid-test (e.g., to verify the icon updates).
  set muted(bool v) => _muted = v;

  @override
  bool get isMuted => _muted;

  @override
  VocabAudioState get state => _state;

  @override
  String? get currentPath => _currentPath;

  @override
  Stream<VocabAudioState> get stateStream => _stateController.stream;

  @override
  Stream<String> get onComplete => _completeController.stream;

  @override
  Future<void> play(String path) async {
    playedPaths.add(path);
    _currentPath = path;
    _state = VocabAudioState.playing;
    _stateController.add(_state);
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    _currentPath = null;
    _state = VocabAudioState.idle;
    _stateController.add(_state);
  }

  /// Complete the in-flight playback as if the audio file ended naturally.
  /// Triggers the [onComplete] stream so listeners can chain.
  void completeCurrent() {
    final finished = _currentPath;
    _currentPath = null;
    _state = VocabAudioState.idle;
    _stateController.add(_state);
    if (finished != null) _completeController.add(finished);
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
    await _completeController.close();
  }
}
