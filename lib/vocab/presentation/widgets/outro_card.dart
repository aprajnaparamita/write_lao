import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_base.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Confirmation card shown after the practice sequence. Auto-plays only the
/// headword; example play buttons are on-demand. Hosts the save-to-category
/// affordance and the Next button.
///
/// [isFlagged] controls the bookmark icon state:
///   - false → amber outline bookmark ("Save")
///   - true  → filled amber bookmark ("Saved")
class OutroCard extends StatefulWidget {
  final VocabWord word;
  final VocabAudioPlayer audio;
  final VoidCallback onNext;
  final VoidCallback onFlag;
  final bool isFlagged;

  const OutroCard({
    super.key,
    required this.word,
    required this.audio,
    required this.onNext,
    required this.onFlag,
    this.isFlagged = false,
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
    final theme = Theme.of(context);
    final flagColor =
        widget.isFlagged ? Colors.amber.shade700 : theme.colorScheme.primary;
    final flagBg = widget.isFlagged
        ? Colors.amber.shade100
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.4);

    return WordCardBase(
      word: widget.word,
      audio: widget.audio,
      actionRow: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // ── Bookmark button — large, colored, state-aware ─────────────
          Material(
            key: WordCardKeys.flagButton,
            color: flagBg,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onFlag,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isFlagged
                          ? Icons.bookmark
                          : Icons.bookmark_add_outlined,
                      size: 28,
                      color: flagColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isFlagged ? 'Saved' : 'Save',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: flagColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          FilledButton(
            key: WordCardKeys.nextButton,
            onPressed: _onNext,
            child: const Text('Got it →'),
          ),
        ],
      ),
    );
  }
}
