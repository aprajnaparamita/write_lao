import 'package:flutter/material.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/data/models/lao_character.dart';
import 'package:write_it_lao/presentation/widgets/star_rating.dart';

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
  final String subtitle;
  final String characterPreview;
  final int stars;
  final int totalLessons;
  final bool isAvailable;
  final bool isCurrent;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.characterPreview,
    this.stars = 0,
    this.totalLessons = 0,
    this.isAvailable = true,
    this.isCurrent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Character preview
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isAvailable
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : Colors.grey[200],
              border: Border.all(
                color: isAvailable
                    ? AppTheme.primary.withValues(alpha: 0.3)
                    : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: Text(
                isAvailable ? characterPreview : '🔒',
                style: const TextStyle(
                  fontFamily: 'Noto Lao',
                  fontSize: 28,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Stars
          if (isAvailable)
            StarRating(stars: stars, size: 18),

          if (isAvailable)
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
        ],
      ),
    );

    return Card(
      clipBehavior: isCurrent ? Clip.antiAlias : Clip.none,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: isCurrent ? null : BorderRadius.circular(12),
        child: isCurrent
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: AppTheme.primary),
                    Expanded(child: content),
                  ],
                ),
              )
            : content,
      ),
    );
  }
}
