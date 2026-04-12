import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/writing_canvas.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const PracticeScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  CharacterStrokeData? _currentStrokeData;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLesson();
    });
  }

  void _loadLesson() {
    final charRepo = ref.read(characterRepositoryProvider);
    final lesson = charRepo.getLesson(widget.lessonId);
    if (lesson != null) {
      ref.read(practiceControllerProvider.notifier).setLesson(lesson);
      _loadStrokeDataForCurrentCharacter();
    }
  }

  Future<void> _loadStrokeDataForCurrentCharacter() async {
    final state = ref.read(practiceControllerProvider);
    final character = state.currentCharacter;
    if (character != null) {
      final strokeDataSource = ref.read(characterStrokeDataSourceProvider);
      final strokeData = await strokeDataSource.loadStrokeData(character.codepoint);
      if (mounted) {
        setState(() => _currentStrokeData = strokeData);
        ref.read(practiceControllerProvider.notifier).setCharacter(character, strokeData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceControllerProvider);
    final character = state.currentCharacter;

    return Scaffold(
      appBar: AppBar(
        title: Text(character?.name ?? 'Practice'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Character info
            if (character != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      character.char,
                      style: const TextStyle(
                        fontFamily: 'Noto Lao',
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '/${character.romanization}/',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${state.currentCharacterIndex + 1}/${state.totalCharacters}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Writing canvas
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    child: _buildCanvas(state),
                  ),
                ),
              ),
            ),

            // Instruction text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                state.isCharacterComplete
                    ? 'Great job! Move to next character'
                    : 'Trace the character',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Clear button
                  IconButton(
                    onPressed: () {
                      // Clear canvas - handled by WritingCanvas internally
                    },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear',
                  ),

                  // Show/hide hint button
                  IconButton(
                    onPressed: () {
                      setState(() => _showHint = !_showHint);
                    },
                    icon: Icon(_showHint ? Icons.visibility : Icons.visibility_off),
                    tooltip: _showHint ? 'Hide hint' : 'Show hint',
                  ),
                ],
              ),
            ),

            // Navigation
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: state.currentCharacterIndex > 0
                        ? () {
                            ref.read(practiceControllerProvider.notifier).previousCharacter();
                            _loadStrokeDataForCurrentCharacter();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    onPressed: !state.isLastCharacter
                        ? () {
                            ref.read(practiceControllerProvider.notifier).nextCharacter();
                            _loadStrokeDataForCurrentCharacter();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas(PracticeState state) {
    final character = state.currentCharacter;
    if (character == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return WritingCanvas(
      strokeData: _currentStrokeData,
      mode: _showHint ? CanvasMode.practice : CanvasMode.test,
      onCharacterComplete: () {
        ref.read(practiceControllerProvider.notifier).onCharacterComplete();
      },
      onStrokeEvaluated: (result) {
        // Handle evaluation feedback
      },
    );
  }
}
