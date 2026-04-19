import 'dart:async';

import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';

/// Round play/stop button bound to a single audio path.
///
/// - Tapping while idle starts playback.
/// - Tapping while *this path* is playing stops it.
/// - Visual: turns the theme's primary color and grows ~10% while playing.
class WordAudioButton extends StatefulWidget {
  final String audioPath;
  final VocabAudioPlayer audio;
  final double iconSize;

  const WordAudioButton({
    super.key,
    required this.audioPath,
    required this.audio,
    this.iconSize = 28,
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
    final color = _isPlayingThis
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final scale = _isPlayingThis ? 1.1 : 1.0;
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      child: IconButton(
        iconSize: widget.iconSize,
        color: color,
        icon: Icon(_isPlayingThis ? Icons.stop_circle : Icons.play_circle),
        onPressed: _onTap,
      ),
    );
  }
}
