import 'package:flutter/material.dart';
import 'package:write_lao/config/theme.dart';
import 'package:write_lao/data/models/lao_character.dart';
import 'package:write_lao/presentation/widgets/star_rating.dart';

class CharacterCard extends StatelessWidget {
  final LaoCharacter character;
  final int stars;
  final bool isAvailable;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const CharacterCard({
    super.key,
    required this.character,
    this.stars = 0,
    this.isAvailable = true,
    this.isUnlocked = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isAvailable && isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: isAvailable && isUnlocked
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Character
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isAvailable && isUnlocked
                      ? AppTheme.primary.withValues(alpha: 0.1)
                      : Colors.grey[200],
                  border: Border.all(
                    color: isAvailable && isUnlocked
                        ? AppTheme.primary.withValues(alpha: 0.3)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    isAvailable ? character.displayChar : '🔒',
                    style: TextStyle(
                      fontFamily: 'Noto Lao',
                      fontSize: 32,
                      color: isAvailable && isUnlocked
                          ? AppTheme.textPrimary
                          : Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Name (use letterNameRomanized if available)
              Text(
                character.letterNameRomanized ?? character.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isAvailable && isUnlocked
                          ? AppTheme.textPrimary
                          : Colors.grey,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (character.acrophonicalMeaning != null) ...[
                const SizedBox(height: 2),
                Text(
                  character.acrophonicalMeaning!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],

              if (isAvailable && isUnlocked && stars > 0) ...[
                const SizedBox(height: 8),
                StarRating(stars: stars, size: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final String title;
  final List<String> characterPreviews;
  final int stars;
  final bool isCurrent;
  final VoidCallback? onTap;
  final VoidCallback? onReview;

  const LessonCard({
    super.key,
    required this.title,
    required this.characterPreviews,
    this.stars = 0,
    this.isCurrent = false,
    this.onTap,
    this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: isCurrent ? Clip.antiAlias : Clip.none,
      child: InkWell(
        onTap: onTap,
        borderRadius: isCurrent ? null : BorderRadius.circular(12),
        child: isCurrent
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: AppTheme.primary),
                    Expanded(child: _content(context)),
                  ],
                ),
              )
            : _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final charPreview = characterPreviews.take(8).join('  ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              StarRating(stars: stars, size: 16),
            ],
          ),
          if (charPreview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    charPreview,
                    style: const TextStyle(
                      fontFamily: 'Noto Lao',
                      fontSize: 20,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                if (onReview != null) ...[
                  const SizedBox(width: 8),
                  _ReviewPill(onPressed: onReview!),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewPill extends StatelessWidget {
  final VoidCallback onPressed;
  const _ReviewPill({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'COMPLETED',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
