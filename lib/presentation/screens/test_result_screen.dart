import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/presentation/controllers/test_controller.dart';
import 'package:write_it_lao/presentation/widgets/result_screen_widgets.dart';

class TestResultScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final VoidCallback? onPracticePressed;
  final VoidCallback? onTestAgainPressed;

  const TestResultScreen({
    super.key,
    required this.lessonId,
    this.onPracticePressed,
    this.onTestAgainPressed,
  });

  @override
  ConsumerState<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends ConsumerState<TestResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _fadeController;
  late Animation<double> _starAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _starController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String? _nextLessonId() {
    final charRepo = ref.read(characterRepositoryProvider);
    final lessons = charRepo.getAllLessons();
    final idx = lessons.indexWhere((l) => l.id == widget.lessonId);
    if (idx < 0 || idx + 1 >= lessons.length) return null;
    return lessons[idx + 1].id;
  }

  String _formatTime(int? ms) {
    if (ms == null) return '--:--';
    final seconds = (ms / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final testState = ref.watch(testControllerProvider);
    final stars = testState.earnedStars ?? 0;
    final characters = testState.characters;
    final bestTimeMs = testState.result?.totalTimeMs;
    final lessonTitle = testState.lesson?.title ?? l10n.resultGoodTry;
    final nextId = _nextLessonId();
    final passed = stars >= 2;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(lessonTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                children: [
                  _buildStars(stars),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          stars == 3
                              ? l10n.resultPerfect
                              : stars == 2
                                  ? l10n.resultGreatJob
                                  : l10n.resultGoodTry,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (bestTimeMs != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            l10n.time,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(bestTimeMs),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        _buildCharacterGrid(characters),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, l10n, passed, nextId),
        ],
      ),
    );
  }

  Widget _buildStars(int stars) {
    return AnimatedBuilder(
      animation: _starAnimation,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final earned = index < stars;
            return Transform.scale(
              scale: earned ? _starAnimation.value.clamp(0.0, 1.2) : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  earned ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 72,
                  color: earned ? AppTheme.starGold : Colors.white24,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildCharacterGrid(List<LaoCharacter> characters) {
    if (characters.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: characters.length,
      itemBuilder: (context, i) =>
          CharacterResultCard(character: characters[i]),
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, AppLocalizations l10n, bool passed, String? nextId) {
    final primaryLabel =
        (passed && nextId != null) ? 'Next Lesson' : l10n.practiceAgain;
    final primaryRoute = (passed && nextId != null)
        ? '/lessons/$nextId'
        : '/practice/${widget.lessonId}';

    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ResultOutlinedButton(
            label: l10n.practiceAgain.toUpperCase(),
            onPressed: () => context.go('/practice/${widget.lessonId}'),
          ),
          const SizedBox(height: 10),
          ResultFilledButton(
            label: primaryLabel.toUpperCase(),
            onPressed: () => context.go(primaryRoute),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => context.go('/'),
            child: Text(
              l10n.mainMenu,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
