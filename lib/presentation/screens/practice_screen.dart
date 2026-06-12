import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/data/models/stroke_data.dart';
import 'package:write_it_lao/domain/stroke_matching/matching_result.dart';
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
    // Portrait lock is handled globally for phones at app startup (main.dart).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLesson();
    });
  }

  void _loadLesson() {
    ref.read(canvasControllerProvider.notifier).clearAll();
    final charRepo = ref.read(characterRepositoryProvider);

    if (widget.characterCodepoints != null &&
        widget.characterCodepoints!.isNotEmpty) {
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
      final strokeData =
          await strokeDataSource.loadStrokeData(character.codepoint);
      if (mounted) {
        ref.read(canvasControllerProvider.notifier).clearAll();
        if (strokeData != null) {
          ref.read(canvasControllerProvider.notifier).setCharacter(strokeData);
        }
        setState(() => _currentStrokeData = strokeData);
        ref
            .read(practiceControllerProvider.notifier)
            .setCharacter(character, strokeData);
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
      barrierDismissible: false,
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

    // Record practice so Weak Characters and progress tracking work.
    if (state.currentCharacter != null) {
      ref
          .read(progressRepositoryProvider)
          .recordPractice(state.currentCharacter!.codepoint);
    }

    if (state.isLastCharacter) {
      final characters = state.currentLesson != null
          ? ref
              .read(characterRepositoryProvider)
              .getCharactersForLesson(state.currentLesson!.id)
          : [];
      final charList = characters.map((c) => c.char).toList();
      context.push(
        '/practice/${widget.lessonId}/complete',
        extra: {'characterList': charList},
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practiceControllerProvider);
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
          title: Text(
            character?.letterNameRomanized ??
                character?.name ??
                l10n.practiceTitle,
          ),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Compact info header ────────────────────────────────
                  _buildHeader(context, character, constraints.maxHeight),
                  // ── Drawing canvas — Expanded so it takes all free space ─
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: _buildCanvas(state),
                        ),
                      ),
                    ),
                  ),
                  // ── Compact bottom controls ────────────────────────────
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
  //
  // Fixed height so it never competes with the canvas for vertical space.
  // Height is proportional to available height, clamped to avoid becoming
  // too large on tablets or too small on compact phones.

  Widget _buildHeader(
      BuildContext context, LaoCharacter? character, double availH) {
    if (character == null) return const SizedBox(height: 8);

    // 20 % of available height, clamped: 100–140 px.
    // Slightly taller than before to accommodate the larger glyph.
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
            // Large Lao character glyph — prominent, no label needed since
            // the AppBar title already shows the romanized name.
            Text(
              character.displayChar,
              style: TextStyle(
                fontFamily: 'Noto Lao',
                // 80 % of interior height, clamped 72–104 sp.
                fontSize: ((headerH - 12) * 0.80).clamp(72.0, 104.0),
                height: 1.0,
              ),
            ),
            const SizedBox(width: 12),
            // Romanization / letter-name / mnemonic — character name removed
            // (already shown in AppBar title, no need to repeat it).
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
            // Acrophonical mnemonic image (square, same height as header)
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

  // ── Canvas ─────────────────────────────────────────────────────────────────

  void _onStrokeEvaluated(StrokeEvaluation result) {
    final audio = ref.read(audioPlayerServiceProvider);
    final haptic = ref.read(hapticServiceProvider);
    if (result.result == StrokeMatchResult.correct) {
      audio.playCorrectSound();
      haptic.onStrokeCorrect();
    } else {
      audio.playIncorrectSound();
      haptic.onStrokeIncorrect();
    }
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
      onStrokeEvaluated: _onStrokeEvaluated,
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  //
  // Compact by design:
  //  • Progress bar + count on one line
  //  • Instruction text (single line)
  //  • Icon-only action row (labels removed to save ~24 px)
  //  • Full-width Next button

  Widget _buildBottomBar(
    BuildContext context,
    PracticeState state,
    LaoCharacter? character,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar + "X / Y" count
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: state.totalCharacters > 0
                        ? (state.currentCharacterIndex + 1) /
                            state.totalCharacters
                        : 0,
                    minHeight: 5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      state.isCharacterComplete ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.currentCharacterIndex + 1} / ${state.totalCharacters}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Instruction
          Text(
            state.isCharacterComplete ? l10n.moveToNext : l10n.traceCharacter,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: state.isCharacterComplete
                      ? Colors.green.shade700
                      : Colors.grey[600],
                ),
          ),
          // Action icons (no text labels — saves 24 px; icons are self-evident)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  ref.read(canvasControllerProvider.notifier).clearAll();
                  if (_currentStrokeData != null) {
                    ref
                        .read(canvasControllerProvider.notifier)
                        .setCharacter(_currentStrokeData!);
                  }
                },
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
              IconButton(
                onPressed: () => setState(() => _showHint = !_showHint),
                icon: Icon(
                    _showHint ? Icons.visibility : Icons.visibility_off),
                tooltip: _showHint ? l10n.hideHint : l10n.showHint,
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Next / All done button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: state.isCharacterComplete && !state.isLastCharacter
                  ? () {
                      ref
                          .read(practiceControllerProvider.notifier)
                          .nextCharacter();
                      _loadStrokeDataForCurrentCharacter();
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: state.isCharacterComplete
                    ? Colors.green
                    : Colors.grey.shade300,
                foregroundColor: state.isCharacterComplete
                    ? Colors.white
                    : Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isLastCharacter ? Icons.check : Icons.arrow_forward,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.isLastCharacter ? l10n.allDone : 'Next',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
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
