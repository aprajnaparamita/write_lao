import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/vocab/audio/vocab_audio_player.dart';
import 'package:write_it_lao/vocab/data/models/vocab_word.dart';
import 'package:write_it_lao/vocab/data/repositories/course_repository.dart';
import 'package:write_it_lao/vocab/domain/card_mode.dart';
import 'package:write_it_lao/vocab/domain/lesson_engine.dart';
import 'package:write_it_lao/vocab/domain/srs.dart';
import 'package:write_it_lao/vocab/presentation/screens/lesson_complete_screen.dart';
import 'package:write_it_lao/vocab/presentation/widgets/deck_picker_sheet.dart';
import 'package:write_it_lao/vocab/presentation/widgets/hear_identify_card.dart';
import 'package:write_it_lao/vocab/presentation/widgets/intro_card.dart';
import 'package:write_it_lao/vocab/presentation/widgets/outro_card.dart';
import 'package:write_it_lao/vocab/presentation/widgets/stroke_canvas_host.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_outcome.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_practice_flow.dart';
import 'package:write_it_lao/vocab/providers.dart';

enum _WordPhase { intro, practice, outro }

class VocabLessonPracticeScreen extends ConsumerStatefulWidget {
  final String unitId;
  final String lessonId;

  const VocabLessonPracticeScreen({
    super.key,
    required this.unitId,
    required this.lessonId,
  });

  @override
  ConsumerState<VocabLessonPracticeScreen> createState() =>
      _VocabLessonPracticeScreenState();
}

class _VocabLessonPracticeScreenState
    extends ConsumerState<VocabLessonPracticeScreen> {
  LessonPlan? _plan;
  int _cardIndex = 0;
  int _totalErrors = 0;
  DateTime? _startedAt;
  bool _loading = true;
  String? _error;
  bool _finished = false;
  _WordPhase _wordPhase = _WordPhase.intro;
  bool _wordIsFlagged = false;
  late final VocabAudioPlayer _audio;

  @override
  void initState() {
    super.initState();
    _audio = AudioPlayersVocabAudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLesson();
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _initLesson() async {
    try {
      final engine = await ref.read(lessonEngineProvider.future);
      final plan = engine.startLesson(widget.lessonId);
      _startedAt = DateTime.now();
      if (mounted) {
        setState(() {
          _plan = plan;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _onIntroContinue() {
    setState(() => _wordPhase = _WordPhase.practice);
  }

  void _onWordCompleted(WordOutcome outcome) {
    final engine = ref.read(lessonEngineProvider).valueOrNull;
    if (engine != null) {
      engine.recordCardOutcome(outcome.wordId, cardOutcomeForErrors(outcome.errorCount));
    }
    final flagged = ref
        .read(flagDeckRepositoryProvider)
        .getDecksContaining(outcome.wordId)
        .isNotEmpty;
    setState(() {
      _totalErrors += outcome.errorCount;
      _wordPhase = _WordPhase.outro;
      _wordIsFlagged = flagged;
    });
  }

  void _onOutroNext() {
    _audio.stop();
    _advanceCard();
  }

  void _onHearIdentifyAnswered(String wordId, bool correct) {
    final engine = ref.read(lessonEngineProvider).valueOrNull;
    if (engine != null) {
      engine.recordCardOutcome(wordId, correct ? CardOutcome.good : CardOutcome.again);
    }
    if (!correct) setState(() => _totalErrors++);
    _audio.stop();
    _advanceCard();
  }

  void _advanceCard() {
    if (_plan == null) return;
    if (_cardIndex < _plan!.cards.length - 1) {
      setState(() {
        _cardIndex++;
        _wordPhase = _WordPhase.intro;
      });
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() {
    final engine = ref.read(lessonEngineProvider).valueOrNull;
    final duration =
        _startedAt != null ? DateTime.now().difference(_startedAt!) : null;

    if (engine != null && _plan != null) {
      engine.completeLesson(
        _plan!.sessionId,
        duration: duration,
        totalErrors: _totalErrors,
      );
    }

    setState(() => _finished = true);
  }

  Future<void> _showFlagSheet(String wordId) async {
    final flagRepo = ref.read(flagDeckRepositoryProvider);
    final decks = flagRepo.getAllDecks();
    final selected =
        flagRepo.getDecksContaining(wordId).map((d) => d.id).toSet();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DeckPickerSheet(
        wordId: wordId,
        decks: decks,
        initiallySelectedDeckIds: selected,
        onFlag: (deckId) => flagRepo.flagWord(deckId: deckId, wordId: wordId),
        onUnflag: (deckId) =>
            flagRepo.unflagWord(deckId: deckId, wordId: wordId),
        onCreateAndFlag: (name) {
          final deck = flagRepo.createDeck(name);
          flagRepo.flagWord(deckId: deck.id, wordId: wordId);
          return deck; // returned so DeckPickerSheet can update its list
        },
      ),
    );

    // Refresh bookmark state after the sheet closes.
    if (!mounted) return;
    final flagged = flagRepo.getDecksContaining(wordId).isNotEmpty;
    setState(() => _wordIsFlagged = flagged);
  }

  Future<void> _confirmAbort(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      // Must be false: the finger-lift that ends the button press would
      // otherwise register as a barrier tap and instantly dismiss the dialog.
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave lesson?'),
        content: const Text('Your progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (result == true && mounted) {
      _audio.stop();
      // ignore: use_build_context_synchronously
      this.context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final course = ref.watch(courseRepositoryProvider).valueOrNull;
      final lesson = course?.getLesson(widget.lessonId);
      final progress =
          ref.watch(userVocabProgressRepositoryProvider).getOrCreate();
      final nextLesson = (course != null && progress.currentLessonId != null)
          ? course.getLesson(progress.currentLessonId!)
          : null;
      String? nextLessonLabel;
      if (nextLesson != null) {
        final firstWord = nextLesson.newWordIds.isNotEmpty
            ? course?.getWord(nextLesson.newWordIds.first)?.laoWord
            : null;
        nextLessonLabel = 'Lesson ${nextLesson.lessonNumber}'
            '${firstWord != null ? ' — $firstWord' : ''}';
      }
      final practicedWords = _plan?.cards
          .map((c) => course?.getWord(c.wordId)?.laoWord)
          .whereType<String>()
          .toList();
      return LessonCompleteScreen(
        lessonNumber: lesson?.lessonNumber ?? 1,
        totalWords: _plan?.cards.length ?? 0,
        errors: _totalErrors,
        nextLessonLabel: nextLessonLabel,
        practicedWords: practicedWords,
        onContinue: () => context.pop(),
      );
    }

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final plan = _plan!;
    final card = plan.cards[_cardIndex];
    final course = ref.watch(courseRepositoryProvider).valueOrNull!;
    final word = course.getWord(card.wordId);
    if (word == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Word not found: ${card.wordId}')),
      );
    }

    final lessonsInUnit = course.getLessonsInUnit(widget.unitId);
    final lessonIndex =
        lessonsInUnit.indexWhere((l) => l.lessonId == widget.lessonId);
    final lessonNumInUnit = lessonIndex >= 0 ? lessonIndex + 1 : null;
    final totalLessonsInUnit = lessonsInUnit.length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${_cardIndex + 1} / ${plan.cards.length}'),
            if (lessonNumInUnit != null)
              Text(
                'Lesson $lessonNumInUnit of $totalLessonsInUnit',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmAbort(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_cardIndex + 1) / plan.cards.length,
          ),
          // ── Mode banner ─────────────────────────────────────────────────
          // Full-width, flat tint — clearly a label, not a button.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey('phase-$_cardIndex-$_wordPhase'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7),
              color: _phaseColor(card).withValues(alpha: 0.10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _phaseIcon(card),
                    size: 15,
                    color: _phaseColor(card),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _phaseLabel(card).toUpperCase(),
                    style: TextStyle(
                      color: _phaseColor(card),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildCard(card, word, course),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(LessonCard card, VocabWord word, CourseRepository course) {
    if (card.kind == LessonCardKind.hearIdentify) {
      final distractors = card.distractorWordIds
          .map((id) => course.getWord(id))
          .whereType<VocabWord>()
          .toList();
      final options = <VocabWord>[word, ...distractors]..shuffle();
      return HearIdentifyCard(
        key: ValueKey('hearIdentify-$_cardIndex'),
        correctWord: word,
        options: options,
        audio: _audio,
        onAnswered: (correct) => _onHearIdentifyAnswered(word.wordId, correct),
      );
    }

    switch (_wordPhase) {
      case _WordPhase.intro:
        return IntroCard(
          key: ValueKey('intro-$_cardIndex'),
          word: word,
          audio: _audio,
          onContinue: _onIntroContinue,
        );

      case _WordPhase.practice:
        final wordStatus = ref
            .read(userWordRepositoryProvider)
            .getByWordId(word.wordId)
            ?.status;
        final mode =
            wordStatus != null ? cardModeFor(wordStatus) : CardMode.practice;
        return WordPracticeFlow(
          key: ValueKey('practice-$_cardIndex'),
          word: word,
          mode: mode,
          onWordCompleted: _onWordCompleted,
          onAbort: () => _confirmAbort(context),
          canvasBuilder: defaultStrokeCanvasHostBuilder,
        );

      case _WordPhase.outro:
        return OutroCard(
          key: ValueKey('outro-$_cardIndex'),
          word: word,
          audio: _audio,
          onNext: _onOutroNext,
          isFlagged: _wordIsFlagged,
          onFlag: () => _showFlagSheet(word.wordId),
        );
    }
  }

  /// Returns the display label for the current card phase.
  String _phaseLabel(LessonCard card) {
    if (card.kind == LessonCardKind.hearIdentify) return 'Listen';
    switch (_wordPhase) {
      case _WordPhase.intro:
        return 'Listen';
      case _WordPhase.practice:
        return 'Write';
      case _WordPhase.outro:
        return 'Review';
    }
  }

  /// Returns the icon for the current card phase.
  IconData _phaseIcon(LessonCard card) {
    if (card.kind == LessonCardKind.hearIdentify) return Icons.hearing;
    switch (_wordPhase) {
      case _WordPhase.intro:
        return Icons.hearing;
      case _WordPhase.practice:
        return Icons.draw_outlined;
      case _WordPhase.outro:
        return Icons.check_circle_outline;
    }
  }

  /// Returns the color for the current card phase label.
  Color _phaseColor(LessonCard card) {
    if (card.kind == LessonCardKind.hearIdentify) return Colors.blue;
    switch (_wordPhase) {
      case _WordPhase.intro:
        return Colors.blue;
      case _WordPhase.practice:
        return Colors.orange;
      case _WordPhase.outro:
        return Colors.green;
    }
  }
}
