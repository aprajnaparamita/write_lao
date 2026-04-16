import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/presentation/controllers/test_controller.dart';

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
  late AnimationController _contentController;
  late Animation<double> _starAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _starAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _starController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    // Start animations
    _starController.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _formatTime(int? ms) {
    if (ms == null) return '--:--';
    final seconds = (ms / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testControllerProvider);
    final stars = testState.earnedStars ?? 0;
    final characterList = testState.characters.map((c) => c.displayChar).toList();
    final bestTimeMs = testState.result?.totalTimeMs;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stars
              AnimatedBuilder(
                animation: _starAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isEarned = index < stars;
                      final animValue = isEarned 
                          ? _starAnimation.value 
                          : 1.0;
                      
                      return Transform.scale(
                        scale: isEarned ? animValue : 1.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(
                            isEarned ? Icons.star : Icons.star_border,
                            size: 64,
                            color: isEarned
                                ? AppTheme.starGold
                                : Colors.grey[300],
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Content with slide animation
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Title
                      Text(
                        stars == 3
                            ? 'Perfect!'
                            : stars == 2
                                ? 'Great Job!'
                                : 'Good Try!',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // Time taken
                      if (bestTimeMs != null) ...[
                        Text(
                          'Time',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(bestTimeMs),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Character list
                      Text(
                        'Characters',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: characterList.map((char) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                char,
                                style: const TextStyle(
                                  fontFamily: 'Noto Lao',
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 48),

                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/practice/${widget.lessonId}'),
                          child: const Text('Practice'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go('/test/${widget.lessonId}'),
                          child: const Text('Test Again'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Main Menu'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
