import 'package:flutter/material.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/data/models/lao_character.dart';

/// White card displaying a Lao character with a green check badge.
class CharacterResultCard extends StatelessWidget {
  final LaoCharacter character;

  const CharacterResultCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  character.displayChar,
                  style: const TextStyle(
                    fontFamily: 'Noto Lao',
                    fontSize: 48,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  character.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Positioned(
            top: 10,
            right: 10,
            child: _GreenCheckBadge(),
          ),
        ],
      ),
    );
  }
}

/// Full-width outlined button with white border for use on primary-colored backgrounds.
class ResultOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ResultOutlinedButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

/// Full-width white-filled button for use on primary-colored backgrounds.
class ResultFilledButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ResultFilledButton(
      {super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class _GreenCheckBadge extends StatelessWidget {
  const _GreenCheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppTheme.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 16),
    );
  }
}
