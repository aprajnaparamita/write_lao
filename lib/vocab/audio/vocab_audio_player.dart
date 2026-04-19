import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// One-of state of a [VocabAudioPlayer].
enum VocabAudioState { idle, playing, error }

/// Abstraction over the underlying audio backend so widgets and lesson UI
/// can drive playback without binding to `audioplayers` directly. Tests
/// substitute a fake implementation that records calls and lets the test
/// drive completion synchronously.
abstract class VocabAudioPlayer {
  /// Latest playback state. Listenable via [stateStream].
  VocabAudioState get state;

  /// Path that's currently playing, or null if idle.
  String? get currentPath;

  /// Whether the device is muted (hardware switch on iOS, volume=0 on
  /// Android). When true, the UI should show a "muted" affordance and
  /// auto-play attempts still fire — they just won't be audible.
  bool get isMuted;

  Stream<VocabAudioState> get stateStream;

  /// Fires once per natural completion of a [play] call. Tests use this to
  /// synchronously chain "after this finishes, play the next one."
  Stream<String> get onComplete;

  /// Start playing [path] (an asset path under the app's vocab content
  /// directory). Stops any in-flight playback first.
  Future<void> play(String path);

  /// Stop any in-flight playback. Safe to call when idle.
  Future<void> stop();

  /// Release underlying platform resources.
  Future<void> dispose();
}

/// Production implementation backed by the `audioplayers` package.
class AudioPlayersVocabAudioPlayer implements VocabAudioPlayer {
  final AudioPlayer _player;
  final _stateController = StreamController<VocabAudioState>.broadcast();
  final _completeController = StreamController<String>.broadcast();
  StreamSubscription<void>? _completeSub;
  VocabAudioState _state = VocabAudioState.idle;
  String? _currentPath;

  AudioPlayersVocabAudioPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer() {
    _completeSub = _player.onPlayerComplete.listen((_) {
      final finished = _currentPath;
      _setState(VocabAudioState.idle);
      _currentPath = null;
      if (finished != null) _completeController.add(finished);
    });
  }

  void _setState(VocabAudioState s) {
    _state = s;
    _stateController.add(s);
  }

  @override
  VocabAudioState get state => _state;

  @override
  String? get currentPath => _currentPath;

  /// Hardware mute detection isn't in `audioplayers`. v1 returns false; a
  /// future plugin (or a settings toggle) can override this.
  @override
  bool get isMuted => false;

  @override
  Stream<VocabAudioState> get stateStream => _stateController.stream;

  @override
  Stream<String> get onComplete => _completeController.stream;

  @override
  Future<void> play(String path) async {
    await _player.stop();
    _currentPath = path;
    _setState(VocabAudioState.playing);
    try {
      // The content bundle stores paths like "audio/w_0001_word.wav" — the
      // production loader prefixes them with "vocab/" before handing them
      // to AssetSource (which expects paths under "assets/").
      await _player.play(AssetSource('vocab/$path'));
    } catch (_) {
      _setState(VocabAudioState.error);
      _currentPath = null;
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _currentPath = null;
    _setState(VocabAudioState.idle);
  }

  @override
  Future<void> dispose() async {
    await _completeSub?.cancel();
    await _stateController.close();
    await _completeController.close();
    await _player.dispose();
  }
}
