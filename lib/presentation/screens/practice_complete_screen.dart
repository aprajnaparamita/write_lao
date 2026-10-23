import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:write_lao/config/theme.dart';
import 'package:write_lao/l10n/app_localizations.dart';
import 'package:write_lao/presentation/controllers/practice_controller.dart';
import 'package:write_lao/presentation/widgets/result_screen_widgets.dart';
import 'package:write_lao/vocab/data/repositories/vocab_preferences_repository.dart';
import 'package:write_lao/vocab/providers.dart';

class PracticeCompleteScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final List<String> characterList;

  const PracticeCompleteScreen({
    super.key,
    required this.lessonId,
    required this.characterList,
  });

  @override
  ConsumerState<PracticeCompleteScreen> createState() =>
      _PracticeCompleteScreenState();
}

class _PracticeCompleteScreenState extends ConsumerState<PracticeCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();

    // Increment the character-session counter and check if any prompt
    // (vocab upsell or rating) should be shown.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(vocabPreferencesRepositoryRawProvider);
      prefs.incrementCharSessions();
      _checkPrompts(prefs);
    });
  }

  void _checkPrompts(VocabPreferencesRepository prefs) {
    if (!mounted) return;
    final progress =
        ref.read(userVocabProgressRepositoryProvider).getOrCreate();
    final count = prefs.charSessionCount;

    // ── Step 1: Vocab upsell (threshold 3, only if not purchased) ─────
    if (!progress.iapUnlocked &&
        !prefs.vocabUpsellDismissed &&
        count >= charSessionUpsellThreshold) {
      prefs.dismissVocabUpsell();
      _showVocabUpsell();
      return;
    }

    // ── Step 2: Rating prompt (threshold 5) ────────────────────────────
    if (!prefs.ratingPromptDismissed && count >= ratingPromptThreshold) {
      prefs.dismissRatingPrompt();
      _showRatingPrompt();
    }
  }

  void _showVocabUpsell() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, color: AppTheme.primary),
            SizedBox(width: 10),
            Expanded(child: Text('500 Lao Words')),
          ],
        ),
        content: const Text(
          'Ready to go further? Unlock 500 vocabulary words with '
          'stroke-by-stroke writing practice, spaced repetition, and '
          'a one‑time purchase.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/vocab/upsell');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('See Details'),
          ),
        ],
      ),
    );
  }

  void _showRatingPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enjoying Write Lao?'),
        content: const Text(
          'If you\'re enjoying the app, would you like to leave a review? '
          'It helps others discover Write Lao.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showFeedbackPrompt();
            },
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              InAppReview.instance.requestReview();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.feedback_outlined, color: AppTheme.primary),
            SizedBox(width: 10),
            Expanded(child: Text('We value your opinion')),
          ],
        ),
        content: const Text(
          'Tell us how we can improve. We read every message.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse('https://writelao.xyz/support'));
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: const Text('Contact Us'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(characterRepositoryProvider);
    final isReview = widget.lessonId == 'review';

    final characters = isReview
        ? () {
            final all = repo.getAllCharacters();
            final charSet = widget.characterList.toSet();
            return all.where((c) => charSet.contains(c.char)).toList();
          }()
        : repo.getCharactersForLesson(widget.lessonId);

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isReview ? l10n.reviewTitle : l10n.practiceComplete,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          l10n.practiceComplete,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.practiceCompleteMessage(characters.length),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (characters.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: characters.length,
                            itemBuilder: (context, i) =>
                                CharacterResultCard(character: characters[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButtons(context, l10n, isReview),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(
      BuildContext context, AppLocalizations l10n, bool isReview) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isReview) ...[
            ResultFilledButton(
              label: l10n.takeTest.toUpperCase(),
              onPressed: () => context.go('/test/${widget.lessonId}'),
            ),
            const SizedBox(height: 10),
            ResultOutlinedButton(
              label: l10n.practiceAgain.toUpperCase(),
              onPressed: () => context.go('/practice/${widget.lessonId}'),
            ),
          ] else ...[
            ResultFilledButton(
              label: l10n.backToReview.toUpperCase(),
              onPressed: () {
                context.pop();
                context.pop();
              },
            ),
          ],
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
