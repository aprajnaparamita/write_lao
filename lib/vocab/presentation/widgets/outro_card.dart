import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_base.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Confirmation card shown after the practice sequence. Auto-plays only the
/// headword; example play buttons are on-demand. Hosts the flag-to-deck
/// affordance (real picker lands in Phase 06) and the Next button.
class OutroCard extends StatefulWidget {
  final VocabWord word;
  final VocabAudioPlayer audio;
  final VoidCallback onNext;
  final VoidCallback onFlag;

  const OutroCard({
    super.key,
    required this.word,
    required this.audio,
    required this.onNext,
    required this.onFlag,
  });

  @override
  State<OutroCard> createState() => _OutroCardState();
}

class _OutroCardState extends State<OutroCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.audio.play(widget.word.audioPath);
    });
  }

  @override
  void dispose() {
    widget.audio.stop();
    super.dispose();
  }

  Future<void> _onNext() async {
    await widget.audio.stop();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      child: WordCardBase(
        word: widget.word,
        audio: widget.audio,
        actionRow: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              key: WordCardKeys.flagButton,
              iconSize: 28,
              tooltip: 'Flag to deck',
              icon: const Icon(Icons.bookmark_add_outlined),
              onPressed: widget.onFlag,
            ),
            FilledButton(
              key: WordCardKeys.nextButton,
              onPressed: _onNext,
              child: const Text('Got it \u2192'),
            ),
          ],
        ),
      ),
    );
  }
}
