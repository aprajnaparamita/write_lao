import 'package:flutter/material.dart';
import 'package:write_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Shown after completing the last lesson of a unit.
///
/// Brief celebration screen with "Unit X complete" and a Continue button
/// that returns to the unit list.
class UnitCompleteScreen extends StatelessWidget {
  final int unitNumber;
  final String unitTitle;
  final VoidCallback onContinue;

  const UnitCompleteScreen({
    super.key,
    required this.unitNumber,
    required this.unitTitle,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Complete'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 80,
                ),
                const SizedBox(height: 24),
                Text(
                  'Unit $unitNumber complete!',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  unitTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Great work! Ready for the next unit?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                FilledButton(
                  key: WordCardKeys.unitCompleteContinue,
                  onPressed: onContinue,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
