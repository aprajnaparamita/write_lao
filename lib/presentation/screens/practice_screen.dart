import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/canvas_controller.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/widgets/writing_canvas.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final List<String>? characterCodepoints;

  const PracticeScreen({
    super.key,
    required this.lessonId,
    this.characterCodepoints,
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
    // Always clear canvas when entering practice to remove leftover strokes
    ref.read(canvasControllerProvider.notifier).clearAll();

    final charRepo = ref.read(characterRepositoryProvider);

    // Review mode: use passed character codepoints
    if (widget.characterCodepoints != null && widget.characterCodepoints!.isNotEmpty) {
      final characters = widget.characterCodepoints!
          .map((cp) => charRepo.getCharacter(cp))
          .whereType<LaoCharacter>()
          .toList();
      if (characters.isNotEmpty) {
        ref.read(practiceControllerProvider.notifier).setCharacters(
          characters,
          title: AppLocalizations.of(context).reviewTitle,
        );
        _loadStrokeDataForCurrentCharacter();
      }
      return;
    }

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
        // Clear and reset canvas (important when same character repeats in sequence)
        ref.read(canvasControllerProvider.notifier).clearAll();
        if (strokeData != null) {
          ref.read(canvasControllerProvider.notifier).setCharacter(strokeData);
        }
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
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leavePracticeTitle),
        content: Text(l10n.leavePracticeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.continueButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.goBackButton),
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
          title: Text(character?.letterNameRomanized ?? character?.name ?? AppLocalizations.of(context).practiceTitle),
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
              // Character info + acrophonical image split container
              if (character != null && _hasAcrophonicalImage(character.codepoint))
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left half: character details, right-aligned
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                character.displayChar,
                                style: const TextStyle(
                                  fontFamily: 'Noto Lao',
                                  fontSize: 48,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                character.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '/${character.romanization}/',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              if (character.letterName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  character.letterName!,
                                  style: const TextStyle(
                                    fontFamily: 'Noto Lao',
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                              if (character.acrophonicalMeaning != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '(${character.acrophonicalMeaning})',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                '${state.currentCharacterIndex + 1}/${state.totalCharacters}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right half: acrophonical image, left-aligned, fills height
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                'assets/images/acrophonical/${character.codepoint}.png',
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
              if (character != null && !_hasAcrophonicalImage(character.codepoint))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        character.displayChar,
                        style: const TextStyle(
                          fontFamily: 'Noto Lao',
                          fontSize: 48,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        character.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '/${character.romanization}/',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (character.letterName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          character.letterName!,
                          style: const TextStyle(
                            fontFamily: 'Noto Lao',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '${state.currentCharacterIndex + 1}/${state.totalCharacters}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

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
                          ? AppLocalizations.of(context).allDone
                          : AppLocalizations.of(context).moveToNext)
                      : AppLocalizations.of(context).traceCharacter,
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
                      tooltip: AppLocalizations.of(context).clearTooltip,
                    ),

                    // Play pronunciation
                    IconButton(
                      onPressed: character != null
                          ? () => _playPronunciation(character.codepoint)
                          : null,
                      icon: const Icon(Icons.volume_up),
                      tooltip: AppLocalizations.of(context).playPronunciation,
                    ),

                    // Show/hide hint button
                    IconButton(
                      onPressed: () {
                        setState(() => _showHint = !_showHint);
                      },
                      icon: Icon(_showHint ? Icons.visibility : Icons.visibility_off),
                      tooltip: _showHint ? AppLocalizations.of(context).hideHint : AppLocalizations.of(context).showHint,
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

  static const _acrophonicalCodepoints = {
    'U+0E81', 'U+0E82', 'U+0E84', 'U+0E87', 'U+0E88', 'U+0E8A',
    'U+0E8D', 'U+0E94', 'U+0E95', 'U+0E96', 'U+0E97', 'U+0E99',
    'U+0E9A', 'U+0E9B', 'U+0E9C', 'U+0E9D', 'U+0E9E', 'U+0E9F',
    'U+0EA1', 'U+0EA2', 'U+0EA3', 'U+0EA5', 'U+0EA7', 'U+0EAA',
    'U+0EAB', 'U+0EAD', 'U+0EAE',
  };

  bool _hasAcrophonicalImage(String codepoint) =>
      _acrophonicalCodepoints.contains(codepoint);

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
