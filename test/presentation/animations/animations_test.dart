import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:write_lao/config/theme.dart';

void main() {
  group('Star Animation Tests', () {
    testWidgets('Stars animate based on earned count', (tester) async {
      int starsEarned = 2;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _StarDisplayTestWidget(stars: starsEarned),
          ),
        ),
      );

      // Initially, stars should show in their initial state
      final icons = find.byType(Icon);
      expect(icons, findsNWidgets(3));

      // Pump through animation
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      // After animation completes, verify the number of filled stars
      final starIcons = tester.widgetList<Icon>(icons);
      int filledStars = 0;
      for (final icon in starIcons) {
        if (icon.icon == Icons.star) {
          filledStars++;
        }
      }
      expect(filledStars, starsEarned);
    });

    testWidgets('Perfect score shows all three stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _StarDisplayTestWidget(stars: 3),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final icons = tester.widgetList<Icon>(find.byType(Icon));
      int filledStars = 0;
      for (final icon in icons) {
        if (icon.icon == Icons.star) {
          filledStars++;
        }
      }
      expect(filledStars, 3);
    });

    testWidgets('Zero stars shows all empty stars', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _StarDisplayTestWidget(stars: 0),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final icons = tester.widgetList<Icon>(find.byType(Icon));
      int emptyStars = 0;
      for (final icon in icons) {
        if (icon.icon == Icons.star_border) {
          emptyStars++;
        }
      }
      expect(emptyStars, 3);
    });
  });

  group('Shake Animation Tests', () {
    testWidgets('Shake animation plays on trigger', (tester) async {
      bool shakeTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _ShakeAnimationTestWidget(
              onShakeComplete: () => shakeTriggered = true,
            ),
          ),
        ),
      );

      // Find and tap the trigger button
      await tester.tap(find.byKey(const Key('trigger_shake')));
      await tester.pump();

      // Animation should be running
      await tester.pump(const Duration(milliseconds: 100));

      // Complete the animation
      await tester.pump(const Duration(milliseconds: 400));

      expect(shakeTriggered, true);
    });
  });

  group('Screen Transition Tests', () {
    testWidgets('Custom transitions build without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FadeTransition(
                  opacity: const AlwaysStoppedAnimation(1.0),
                  child: const Text('Test'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}

/// Test widget for star display
class _StarDisplayTestWidget extends StatefulWidget {
  final int stars;

  const _StarDisplayTestWidget({required this.stars});

  @override
  State<_StarDisplayTestWidget> createState() => _StarDisplayTestWidgetState();
}

class _StarDisplayTestWidgetState extends State<_StarDisplayTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < widget.stars;
            final animValue = isEarned ? _animation.value : 1.0;

            return Transform.scale(
              scale: isEarned ? animValue : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  isEarned ? Icons.star : Icons.star_border,
                  size: 64,
                  color: isEarned ? AppTheme.starGold : Colors.grey[300],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Test widget for shake animation
class _ShakeAnimationTestWidget extends StatefulWidget {
  final VoidCallback? onShakeComplete;

  const _ShakeAnimationTestWidget({this.onShakeComplete});

  @override
  State<_ShakeAnimationTestWidget> createState() => _ShakeAnimationTestWidgetState();
}

class _ShakeAnimationTestWidgetState extends State<_ShakeAnimationTestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(_shakeController);
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onShakeComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    _shakeController.forward(from: 0);
  }

  double _calculateShakeOffset(double animationValue) {
    // 3 oscillations, 10px amplitude
    const oscillations = 3;
    const amplitude = 10.0;
    return amplitude *
        (1 - animationValue) *
        math.sin(animationValue * oscillations * 2 * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_calculateShakeOffset(_shakeAnimation.value), 0),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          key: const Key('trigger_shake'),
          onPressed: _triggerShake,
          child: const Text('Shake'),
        ),
      ],
    );
  }
}

