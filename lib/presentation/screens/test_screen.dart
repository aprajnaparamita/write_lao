import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final GlobalKey<WritingCanvasState> _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTest();
    });
  }

  void _startTest() {
    final charRepo = ref.read(characterRepositoryProvider);
    final lesson = charRepo.getLesson(widget.lessonId);
    if (lesson != null) {
      ref.read(testControllerProvider.notifier).startTest(lesson);
    }
    _startTimer();
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
        ref.read(testControllerProvider.notifier).finishTest();
        widget.onComplete?.call();
      }
    } else {
      _hintAttempts++;
      ref.read(testControllerProvider.notifier).onCharacterFailed();

      if (_hintAttempts >= 3) {
        // Show hint
        setState(() => _showHint = true);
        ref.read(testControllerProvider.notifier).requestHint();
      }
    }
  }

  void _clearCanvas() {
    _canvasKey.currentState?.clearCanvas();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test'),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
            // Character to write
            if (state.currentCharacter != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(
                      state.currentCharacter!.char,
                      style: const TextStyle(
                        fontFamily: 'Noto Lao',
                        fontSize: 64,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '/${state.currentCharacter!.romanization}/',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
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
                'Write this character from memory',
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
                  TextButton.icon(
                    onPressed: _clearCanvas,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear'),
                  ),

                  if (_showHint) ...[
                    const SizedBox(width: 24),
                    // Hint button
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _showHint = false);
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('Hint'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
