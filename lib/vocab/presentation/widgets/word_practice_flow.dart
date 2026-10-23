import 'package:flutter/material.dart';
import 'package:write_lao/vocab/data/models/vocab_word.dart';
import 'package:write_lao/vocab/domain/card_mode.dart';
import 'package:write_lao/vocab/presentation/widgets/character_practice_card.dart';
import 'package:write_lao/vocab/presentation/widgets/character_test_card.dart';
import 'package:write_lao/vocab/presentation/widgets/stroke_canvas_host.dart';
import 'package:write_lao/vocab/presentation/widgets/word_outcome.dart';

/// Walks the user through every character of [word] one card at a time.
/// Owns the per-word error accumulator and timing; emits a [WordOutcome] on
/// the final character's completion. Aborting (via [onAbort]) emits nothing.
class WordPracticeFlow extends StatefulWidget {
  final VocabWord word;
  final CardMode mode;
  final ValueChanged<WordOutcome> onWordCompleted;
  final VoidCallback? onAbort;
  final StrokeCanvasHostBuilder canvasBuilder;
  final DateTime Function() now;

  WordPracticeFlow({
    super.key,
    required this.word,
    required this.mode,
    required this.onWordCompleted,
    required this.canvasBuilder,
    this.onAbort,
    DateTime Function()? now,
  }) : now = now ?? (() => DateTime.now().toUtc());

  @override
  State<WordPracticeFlow> createState() => _WordPracticeFlowState();
}

class _WordPracticeFlowState extends State<WordPracticeFlow> {
  int _currentIndex = 0;
  int _errorCount = 0;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = widget.now();
  }

  void _addErrors(int n) => setState(() => _errorCount += n);

  void _onCharacterComplete() {
    if (_currentIndex < widget.word.characters.length - 1) {
      setState(() => _currentIndex += 1);
      return;
    }
    final duration = widget.now().difference(_startedAt);
    widget.onWordCompleted(WordOutcome(
      wordId: widget.word.wordId,
      errorCount: _errorCount,
      durationMs: duration.inMilliseconds,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.word.characters[_currentIndex];
    if (widget.mode == CardMode.practice) {
      return CharacterPracticeCard(
        key: ValueKey('practice-$_currentIndex'),
        character: char,
        allCharacters: widget.word.characters,
        positionIndex: _currentIndex,
        onErrorAdded: _addErrors,
        onCharacterComplete: _onCharacterComplete,
        onAbort: widget.onAbort,
        canvasBuilder: widget.canvasBuilder,
        imagePath: widget.word.imagePath,
      );
    }
    return CharacterTestCard(
      key: ValueKey('test-$_currentIndex'),
      character: char,
      allCharacters: widget.word.characters,
      positionIndex: _currentIndex,
      onErrorAdded: _addErrors,
      onCharacterComplete: _onCharacterComplete,
      onAbort: widget.onAbort,
      canvasBuilder: widget.canvasBuilder,
      imagePath: widget.word.imagePath,
    );
  }
}
