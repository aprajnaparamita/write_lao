import 'package:flutter/material.dart';
import 'package:write_it_lao/config/theme.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < stars;
        return Icon(
          isFilled ? Icons.star : Icons.star_border,
          color: isFilled ? AppTheme.starGold : AppTheme.textSecondary,
          size: size,
        );
      }),
    );
  }
}

class AnimatedStarRating extends StatefulWidget {
  final int stars;
  final int maxStars;
  final double size;
  final Duration delay;

  const AnimatedStarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 40,
    this.delay = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _starAnimations = List.generate(widget.maxStars, (index) {
      final start = (index * widget.delay.inMilliseconds) / 600;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

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
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxStars, (index) {
            final isFilled = index < widget.stars;
            final animValue = _starAnimations[index].value;

            return Transform.scale(
              scale: isFilled ? animValue : 1.0,
              child: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled
                    ? AppTheme.starGold.withValues(alpha: animValue)
                    : AppTheme.textSecondary,
                size: widget.size,
              ),
            );
          }),
        );
      },
    );
  }
}
