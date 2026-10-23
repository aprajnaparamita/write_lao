import 'dart:async';

import 'package:flutter/material.dart';
import 'package:write_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_base.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

/// First card the user sees for a word. Auto-plays headword → example1 → example2.
class IntroCard extends StatefulWidget {
  final VocabWord word;
  final VocabAudioPlayer audio;
  final VoidCallback onContinue;

  const IntroCard({
    super.key,
    required this.word,
    required this.audio,
    required this.onContinue,
  });

  @override
  State<IntroCard> createState() => _IntroCardState();
}

class _IntroCardState extends State<IntroCard> {
  /// Gap inserted before each auto-chained clip.
  ///
  /// Beyond giving a natural pause between the word and its examples, this is
  /// load-bearing: the next clip must NOT be started synchronously from inside
  /// the previous clip's completion callback. When a clip finishes, the
  /// audioplayers iOS backend emits `onComplete` and *then* asynchronously runs
  /// its teardown — a `seek(0)` plus (default release mode) a
  /// `replaceCurrentItem(nil)`. Calling `play()` immediately on that event races
  /// with the teardown, which clobbers the freshly-set source so the clip never
  /// produces sound — while our wrapper has already optimistically flipped the
  /// button to its "playing" state. The symptom is the first example showing a
  /// pressed/playing button with no audio. Deferring past the teardown fixes it.
  static const _chainGap = Duration(milliseconds: 350);

  StreamSubscription<String>? _completeSub;
  Timer? _chainTimer;
  bool _headwordFinished = false;
  bool _example1Finished = false;

  @override
  void initState() {
    super.initState();
    _completeSub = widget.audio.onComplete.listen(_onAudioComplete);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.audio.play(widget.word.audioPath);
    });
  }

  /// Plays [path] after [_chainGap], superseding any pending chained play.
  void _playAfterGap(String path) {
    _chainTimer?.cancel();
    _chainTimer = Timer(_chainGap, () {
      if (!mounted) return;
      widget.audio.play(path);
    });
  }

  void _onAudioComplete(String finishedPath) {
    if (!mounted) return;
    final examples = widget.word.examples;

    if (!_headwordFinished && finishedPath == widget.word.audioPath) {
      _headwordFinished = true;
      if (examples.isNotEmpty) {
        _playAfterGap(examples.first.audioPath);
      }
      return;
    }

    if (_headwordFinished && !_example1Finished &&
        examples.isNotEmpty && finishedPath == examples.first.audioPath) {
      _example1Finished = true;
      if (examples.length >= 2) {
        _playAfterGap(examples[1].audioPath);
      }
    }
  }

  @override
  void dispose() {
    _chainTimer?.cancel();
    _completeSub?.cancel();
    widget.audio.stop();
    super.dispose();
  }

  Future<void> _onContinue() async {
    _chainTimer?.cancel();
    await widget.audio.stop();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return WordCardBase(
      word: widget.word,
      audio: widget.audio,
      actionRow: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            key: WordCardKeys.continueButton,
            onPressed: _onContinue,
            child: const Text("I'm ready"),
          ),
        ],
      ),
    );
  }
}
