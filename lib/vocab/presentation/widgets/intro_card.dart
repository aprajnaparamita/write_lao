import 'dart:async';

import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_base.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

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
  StreamSubscription<String>? _completeSub;
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

  void _onAudioComplete(String finishedPath) {
    if (!mounted) return;
    final examples = widget.word.examples;

    if (!_headwordFinished && finishedPath == widget.word.audioPath) {
      _headwordFinished = true;
      if (examples.isNotEmpty) {
        widget.audio.play(examples.first.audioPath);
      }
      return;
    }

    if (_headwordFinished && !_example1Finished &&
        examples.isNotEmpty && finishedPath == examples.first.audioPath) {
      _example1Finished = true;
      if (examples.length >= 2) {
        widget.audio.play(examples[1].audioPath);
      }
    }
  }

  @override
  void dispose() {
    _completeSub?.cancel();
    widget.audio.stop();
    super.dispose();
  }

  Future<void> _onContinue() async {
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
