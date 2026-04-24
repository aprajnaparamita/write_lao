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
    setState(() {
      _totalErrors += outcome.errorCount;
      _wordPhase = _WordPhase.outro;
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
    final course = ref.read(courseRepositoryProvider).valueOrNull;
    final lesson = course?.getLesson(widget.lessonId);
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

  void _showFlagSheet(String wordId) {
    final flagRepo = ref.read(flagDeckRepositoryProvider);
    final decks = flagRepo.getAllDecks();
    final selected =
        flagRepo.getDecksContaining(wordId).map((d) => d.id).toSet();

    showModalBottomSheet<void>(
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
        },
      ),
    );
  }

  Future<void> _confirmAbort(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
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
      Navigator.of(this.context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      final course = ref.watch(courseRepositoryProvider).valueOrNull;
      final lesson = course?.getLesson(widget.lessonId);
      return LessonCompleteScreen(
        lessonNumber: lesson?.lessonNumber ?? 1,
        totalWords: _plan?.cards.length ?? 0,
        errors: _totalErrors,
        onContinue: () => context.go('/vocab/unit/${widget.unitId}'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('${_cardIndex + 1} / ${plan.cards.length}'),
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
          onFlag: () => _showFlagSheet(word.wordId),
        );
    }
  }
}
