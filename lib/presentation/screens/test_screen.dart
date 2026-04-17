import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/controllers/test_controller.dart';
import 'package:write_it_lao/presentation/widgets/writing_canvas.dart';
import 'package:write_it_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';

class TestScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final VoidCallback? onComplete;

  const TestScreen({
    super.key,
    required this.lessonId,
    this.onComplete,
  });

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  Timer? _timer;
  bool _showHint = false;
  int _hintAttempts = 0;
  CharacterStrokeData? _currentStrokeData;
  final GlobalKey<WritingCanvasState> _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTest();
    });
  }

  void _startTest() {
    // Clear canvas to remove any leftover strokes from previous screens
    ref.read(canvasControllerProvider.notifier).clearAll();

    final charRepo = ref.read(characterRepositoryProvider);
    final lesson = charRepo.getLesson(widget.lessonId);
    if (lesson != null) {
      ref.read(testControllerProvider.notifier).startTest(lesson);
      _loadStrokeDataForCurrentCharacter();
    }
    _startTimer();
  }

  Future<void> _loadStrokeDataForCurrentCharacter() async {
    final state = ref.read(testControllerProvider);
    final character = state.currentCharacter;
    if (character != null) {
      final strokeDataSource = ref.read(characterStrokeDataSourceProvider);
      final strokeData = await strokeDataSource.loadStrokeData(character.codepoint);
      if (mounted) {
        setState(() => _currentStrokeData = strokeData);
        // Reset canvas for new character
        ref.read(canvasControllerProvider.notifier).clearAll();
        if (strokeData != null) {
          ref.read(canvasControllerProvider.notifier).setCharacter(strokeData);
        }
        _playPronunciation(character.codepoint);
      }
    }
  }

  void _playPronunciation(String codepoint) {
    ref.read(audioPlayerServiceProvider).playPronunciation(codepoint);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(testControllerProvider);
      if (!state.isComplete) {
        ref.read(testControllerProvider.notifier).updateTime(state.elapsedMs + 1000);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onStrokeEvaluated(StrokeEvaluation result) {
    final state = ref.read(testControllerProvider);

    if (result.result == StrokeMatchResult.correct) {
      ref.read(testControllerProvider.notifier).onCharacterCorrect(state.elapsedMs);

      // Check if test is complete
      if (state.currentIndex + 1 >= state.totalCharacters) {
        _timer?.cancel();
        final quizResult = ref.read(testControllerProvider.notifier).finishTest();
        
        // Save the result to progress repository
        if (quizResult != null) {
          ref.read(progressRepositoryProvider).recordTestResult(quizResult);
        }
        
        widget.onComplete?.call();
      } else {
        // Load next character's stroke data
        _hintAttempts = 0;
        _showHint = false;
        _loadStrokeDataForCurrentCharacter();
      }
    } else {
      _hintAttempts++;
      ref.read(testControllerProvider.notifier).onCharacterFailed();

      if (_hintAttempts >= 3) {
        setState(() => _showHint = true);
        ref.read(testControllerProvider.notifier).requestHint();
      }
    }
  }

  void _clearCanvas() {
    ref.read(canvasControllerProvider.notifier).clearAll();
    if (_currentStrokeData != null) {
      ref.read(canvasControllerProvider.notifier).setCharacter(_currentStrokeData!);
    }
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.leaveTestTitle),
          content: Text(l10n.leaveTestMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.continueButton),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.goBackButton),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).testTitle),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              }
            },
          ),
          actions: [
            // Timer display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  state.formattedTime,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Character info + acrophonical image
              if (state.currentCharacter != null && _hasAcrophonicalImage(state.currentCharacter!.codepoint))
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left half: character details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                state.currentCharacter!.displayChar,
                                style: const TextStyle(
                                  fontFamily: 'Noto Lao',
                                  fontSize: 48,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.currentCharacter!.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '/${state.currentCharacter!.romanization}/',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              if (state.currentCharacter!.acrophonicalMeaning != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '(${state.currentCharacter!.acrophonicalMeaning})',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Right half: acrophonical image
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/acrophonical/${state.currentCharacter!.codepoint}.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Fallback for characters without an acrophonical image
              if (state.currentCharacter != null && !_hasAcrophonicalImage(state.currentCharacter!.codepoint))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Text(
                        state.currentCharacter!.displayChar,
                        style: const TextStyle(
                          fontFamily: 'Noto Lao',
                          fontSize: 48,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        state.currentCharacter!.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '/${state.currentCharacter!.romanization}/',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (state.currentCharacter!.letterName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          state.currentCharacter!.letterName!,
                          style: const TextStyle(
                            fontFamily: 'Noto Lao',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: state.totalCharacters > 0
                      ? (state.currentIndex + 1) / state.totalCharacters
                      : 0,
                  backgroundColor: Colors.grey[200],
                ),
              ),

              const SizedBox(height: 8),
              Text(
                '${state.currentIndex + 1}/${state.totalCharacters}',
                style: Theme.of(context).textTheme.bodySmall,
              ),

              const SizedBox(height: 16),

              // Writing canvas
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: WritingCanvas(
                        key: _canvasKey,
                        strokeData: _currentStrokeData,
                        mode: _showHint ? CanvasMode.practice : CanvasMode.test,
                        onStrokeEvaluated: _onStrokeEvaluated,
                        onCharacterComplete: () {
                          // Handled in _onStrokeEvaluated
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Instruction
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  AppLocalizations.of(context).writeFromMemory,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Clear button
                    IconButton(
                      onPressed: _clearCanvas,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: AppLocalizations.of(context).clearTooltip,
                    ),

                    // Play pronunciation
                    IconButton(
                      onPressed: state.currentCharacter != null
                          ? () => _playPronunciation(state.currentCharacter!.codepoint)
                          : null,
                      icon: const Icon(Icons.volume_up),
                      tooltip: AppLocalizations.of(context).playPronunciation,
                    ),

                    if (_showHint) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() => _showHint = false);
                        },
                        icon: const Icon(Icons.visibility),
                        tooltip: AppLocalizations.of(context).hideHint,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  static const _acrophonicalCodepoints = {
    'U+0E81', 'U+0E82', 'U+0E84', 'U+0E87', 'U+0E88', 'U+0E8A',
    'U+0E8D', 'U+0E94', 'U+0E95', 'U+0E96', 'U+0E97', 'U+0E99',
    'U+0E9A', 'U+0E9B', 'U+0E9C', 'U+0E9D', 'U+0E9E', 'U+0E9F',
    'U+0EA1', 'U+0EA2', 'U+0EA3', 'U+0EA5', 'U+0EA7', 'U+0EAA',
    'U+0EAB', 'U+0EAD', 'U+0EAE',
  };

  bool _hasAcrophonicalImage(String codepoint) =>
      _acrophonicalCodepoints.contains(codepoint);
}
