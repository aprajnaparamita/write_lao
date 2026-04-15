import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
        _playPronunciation(character.codepoint);
      }
    }
  }

  void _playPronunciation(String codepoint) {
    ref.read(audioPlayerServiceProvider).playPronunciation(codepoint);
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Practice?'),
        content: const Text('Are you sure you want to leave practice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onCharacterComplete() {
    final state = ref.read(practiceControllerProvider);
    ref.read(practiceControllerProvider.notifier).onCharacterComplete();

    // If this was the last character, navigate to practice complete
    if (state.isLastCharacter) {
      final characters = state.currentLesson != null
          ? ref.read(characterRepositoryProvider)
              .getCharactersForLesson(state.currentLesson!.id)
          : [];
      final charList = characters.map((c) => c.char).toList();

      context.push(
        '/practice/${widget.lessonId}/complete',
        extra: {'characterList': charList},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceControllerProvider);
    final character = state.currentCharacter;

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
          title: Text(character?.letterNameRomanized ?? character?.name ?? 'Practice'),
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
                        character.displayChar,
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
                      if (character.acrophonicalMeaning != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${character.acrophonicalMeaning})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (character != null && character.letterName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    character.letterName!,
                    style: const TextStyle(
                      fontFamily: 'Noto Lao',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
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
                      ? (state.isLastCharacter
                          ? 'All done! Great job!'
                          : 'Great job! Move to next character')
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
                        ref.read(canvasControllerProvider.notifier).clearAll();
                        if (_currentStrokeData != null) {
                          ref.read(canvasControllerProvider.notifier).setCharacter(_currentStrokeData!);
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Clear',
                    ),

                    // Play pronunciation
                    IconButton(
                      onPressed: character != null
                          ? () => _playPronunciation(character.codepoint)
                          : null,
                      icon: const Icon(Icons.volume_up),
                      tooltip: 'Play pronunciation',
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
      onCharacterComplete: _onCharacterComplete,
      onStrokeEvaluated: (result) {
        // Handle evaluation feedback
      },
    );
  }
}
