import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';

/// Settings state provider
class SettingsState {
  final double strokeTolerance;
  final bool soundEnabled;
  final bool hapticEnabled;

  const SettingsState({
    this.strokeTolerance = 0.70,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  SettingsState copyWith({
    double? strokeTolerance,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return SettingsState(
      strokeTolerance: strokeTolerance ?? this.strokeTolerance,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController() : super(const SettingsState());

  void setStrokeTolerance(double value) {
    state = state.copyWith(strokeTolerance: value);
  }

  void setSoundEnabled(bool value) {
    state = state.copyWith(soundEnabled: value);
  }

  void setHapticEnabled(bool value) {
    state = state.copyWith(hapticEnabled: value);
  }

  void resetToDefaults() {
    state = const SettingsState();
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController();
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Stroke Tolerance
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stroke Tolerance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Forgiving',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Expanded(
                          child: Slider(
                            value: settings.strokeTolerance,
                            min: 0.55,
                            max: 0.85,
                            divisions: 6,
                            label: _getToleranceLabel(settings.strokeTolerance),
                            onChanged: (value) {
                              controller.setStrokeTolerance(value);
                            },
                          ),
                        ),
                        Text(
                          'Strict',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      _getToleranceDescription(settings.strokeTolerance),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Sound Effects
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Play sounds for correct/incorrect strokes'),
                value: settings.soundEnabled,
                onChanged: (value) {
                  controller.setSoundEnabled(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Haptic Feedback
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate on stroke events'),
                value: settings.hapticEnabled,
                onChanged: (value) {
                  controller.setHapticEnabled(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Reset Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.error),
                title: const Text(
                  'Reset All Progress',
                  style: TextStyle(color: AppTheme.error),
                ),
                subtitle: const Text('Clear all lesson progress and stars'),
                onTap: () => _showResetConfirmation(context, ref),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2026 Write Lao',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getToleranceLabel(double value) {
    if (value <= 0.60) return 'Very Easy';
    if (value <= 0.65) return 'Easy';
    if (value <= 0.70) return 'Medium';
    if (value <= 0.75) return 'Hard';
    if (value <= 0.80) return 'Very Hard';
    return 'Extreme';
  }

  String _getToleranceDescription(double value) {
    if (value <= 0.60) return 'Almost any drawing will be accepted';
    if (value <= 0.65) return 'Loose matching, good for beginners';
    if (value <= 0.70) return 'Balanced difficulty (recommended)';
    if (value <= 0.75) return 'Requires more precision';
    if (value <= 0.80) return 'Strict matching';
    return 'Very strict matching for experts';
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will permanently delete all your progress, including:\n\n'
          '• Lesson completion status\n'
          '• Stars earned\n'
          '• Best times\n'
          '• Practice history\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              ref.read(settingsControllerProvider.notifier).resetToDefaults();
              await ref.read(progressRepositoryProvider).resetAllProgress();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progress has been reset'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
