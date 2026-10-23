import 'dart:async';

import 'package:flutter/material.dart';
import 'package:write_lao/vocab/audio/vocab_audio_player.dart';

/// Round play/stop button bound to a single audio path.
///
/// - Tapping while idle starts playback.
/// - Tapping while *this path* is playing stops it.
/// - Visual: uses [activeColor], pops 25 % larger with an easeOutBack bounce
///   the moment this track starts playing, and shrinks back smoothly on stop.
class WordAudioButton extends StatefulWidget {
  final String audioPath;
  final VocabAudioPlayer audio;

  /// Base icon size. The button grows to ~1.25× this while playing.
  final double iconSize;

  /// Colour used while this path is actively playing. Falls back to the
  /// theme's primary colour when omitted.
  final Color? activeColor;

  const WordAudioButton({
    super.key,
    required this.audioPath,
    required this.audio,
    this.iconSize = 52,
    this.activeColor,
  });

  @override
  State<WordAudioButton> createState() => _WordAudioButtonState();
}

class _WordAudioButtonState extends State<WordAudioButton> {
  StreamSubscription<VocabAudioState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _stateSub = widget.audio.stateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    super.dispose();
  }

  bool get _isPlayingThis =>
      widget.audio.state == VocabAudioState.playing &&
      widget.audio.currentPath == widget.audioPath;

  Future<void> _onTap() async {
    if (_isPlayingThis) {
      await widget.audio.stop();
    } else {
      await widget.audio.play(widget.audioPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor =
        widget.activeColor ?? Theme.of(context).colorScheme.primary;
    final color = _isPlayingThis
        ? activeColor
        : Theme.of(context).colorScheme.onSurfaceVariant;

    // easeOutBack overshoots briefly → natural "pop" feel on play start.
    // easeOut gives a smooth, quick collapse on stop.
    return AnimatedScale(
      scale: _isPlayingThis ? 1.25 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: _isPlayingThis ? Curves.easeOutBack : Curves.easeOut,
      child: IconButton(
        iconSize: widget.iconSize,
        color: color,
        icon: Icon(_isPlayingThis ? Icons.stop_circle : Icons.play_circle),
        onPressed: _onTap,
      ),
    );
  }
}
