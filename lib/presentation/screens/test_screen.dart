import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_lao/data/models/lao_character.dart';
import 'package:write_lao/data/models/stroke_data.dart';
import 'package:write_lao/l10n/app_localizations.dart';
import 'package:write_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/presentation/controllers/test_controller.dart';
import 'package:write_lao/presentation/widgets/writing_canvas.dart';
import 'package:write_lao/domain/stroke_matching/matching_result.dart';

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
  bool _characterComplete = false;

  @override
  void initState() {
    super.initState();
    // Portrait lock is handled globally for phones at app startup (main.dart).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTest();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTest() {
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
      final strokeData =
          await strokeDataSource.loadStrokeData(character.codepoint);
      if (mounted) {
        setState(() {
          _currentStrokeData = strokeData;
          _characterComplete = false;
        });
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
        ref
            .read(testControllerProvider.notifier)
            .updateTime(state.elapsedMs + 1000);
      }
    });
  }

  void _onStrokeEvaluated(StrokeEvaluation result) {
    final audio = ref.read(audioPlayerServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    if (result.result == StrokeMatchResult.correct) {
      audio.playCorrectSound();
      haptic.onStrokeCorrect();
    } else {
      audio.playIncorrectSound();
      haptic.onStrokeIncorrect();
      _hintAttempts++;
      ref.read(testControllerProvider.notifier).onCharacterFailed();
      if (_hintAttempts >= 3) {
        setState(() => _showHint = true);
        ref.read(testControllerProvider.notifier).requestHint();
      }
    }
  }

  void _onNextPressed() {
    final state = ref.read(testControllerProvider);
    ref.read(testControllerProvider.notifier).onCharacterCorrect(state.elapsedMs);

    final newState = ref.read(testControllerProvider);
    if (newState.isComplete) {
      _timer?.cancel();
      final quizResult =
          ref.read(testControllerProvider.notifier).finishTest();
      if (quizResult != null) {
        ref.read(progressRepositoryProvider).recordTestResult(quizResult);
        // Notify star-displaying screens (home lesson list, progress) that
        // persisted progress changed so they refresh without a tab switch.
        ref.read(progressRevProvider.notifier).state++;
      }
      widget.onComplete?.call();
    } else {
      _hintAttempts = 0;
      setState(() {
        _showHint = false;
        _characterComplete = false;
      });
      _loadStrokeDataForCurrentCharacter();
    }
  }

  void _clearCanvas() {
    ref.read(canvasControllerProvider.notifier).clearAll();
    if (_currentStrokeData != null) {
      ref
          .read(canvasControllerProvider.notifier)
          .setCharacter(_currentStrokeData!);
    }
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testControllerProvider);
    final character = state.currentCharacter;
    final l10n = AppLocalizations.of(context);

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
          title: Text(l10n.testTitle),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Compact info header ──────────────────────────────
                  _buildHeader(context, character, constraints.maxHeight),
                  // ── Drawing canvas — Expanded ────────────────────────
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: WritingCanvas(
                            key: _canvasKey,
                            strokeData: _currentStrokeData,
                            mode:
                                _showHint ? CanvasMode.practice : CanvasMode.test,
                            onStrokeEvaluated: _onStrokeEvaluated,
                            onCharacterComplete: () =>
                                setState(() => _characterComplete = true),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // ── Compact bottom controls ──────────────────────────
                  _buildBottomBar(context, state, character, l10n),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Info header ────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, LaoCharacter? character, double availH) {
    if (character == null) return const SizedBox(height: 8);

    final headerH = (availH * 0.20).clamp(100.0, 140.0);
    final hasImg = _hasAcrophonicalImage(character.codepoint);
    final imgSize = headerH - 14;

    return SizedBox(
      height: headerH,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Large Lao character glyph
            Text(
              character.displayChar,
              style: TextStyle(
                fontFamily: 'Noto Lao',
                fontSize: ((headerH - 12) * 0.80).clamp(72.0, 104.0),
                height: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            // Romanization / letter-name / mnemonic (name removed — in AppBar)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '/${character.romanization}/',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (character.letterName != null)
                    Text(
                      character.letterName!,
                      style: const TextStyle(
                        fontFamily: 'Noto Lao',
                        fontSize: 17,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (character.acrophonicalMeaning != null)
                    Text(
                      '(${character.acrophonicalMeaning})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // Acrophonical image
            if (hasImg) ...[
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/acrophonical/${character.codepoint}.webp',
                  width: imgSize,
                  height: imgSize,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────

  Widget _buildBottomBar(
    BuildContext context,
    TestState state,
    LaoCharacter? character,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar + count
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: state.totalCharacters > 0
                        ? (state.currentIndex + 1) / state.totalCharacters
                        : 0,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _characterComplete ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.currentIndex + 1} / ${state.totalCharacters}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Instruction
          Text(
            _characterComplete
                ? 'Great! Keep going'
                : l10n.writeFromMemory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _characterComplete
                      ? Colors.green.shade700
                      : Colors.grey[600],
                ),
          ),
          // Action icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.clearTooltip,
              ),
              IconButton(
                onPressed: character != null
                    ? () => _playPronunciation(character.codepoint)
                    : null,
                icon: const Icon(Icons.volume_up),
                tooltip: l10n.playPronunciation,
              ),
              if (_showHint)
                IconButton(
                  onPressed: () => setState(() => _showHint = false),
                  icon: const Icon(Icons.visibility),
                  tooltip: l10n.hideHint,
                )
              else
                // Placeholder so the row width doesn't jump
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          // Next button — fades in when character is complete
          AnimatedOpacity(
            opacity: _characterComplete ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _characterComplete ? _onNextPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 3,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_forward, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Next',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Invisible spacer holds height when button is hidden
          AnimatedOpacity(
            opacity: _characterComplete ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: const SizedBox(height: 52),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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
