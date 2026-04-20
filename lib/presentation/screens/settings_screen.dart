import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/vocab/domain/vocab_config.dart';
import 'package:write_it_lao/vocab/presentation/screens/vocab_settings_section.dart';

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
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.strokeTolerance,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          l10n.toleranceForgiving,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Expanded(
                          child: Slider(
                            value: settings.strokeTolerance,
                            min: 0.55,
                            max: 0.85,
                            divisions: 6,
                            label: _getToleranceLabel(l10n, settings.strokeTolerance),
                            onChanged: (value) {
                              controller.setStrokeTolerance(value);
                            },
                          ),
                        ),
                        Text(
                          l10n.toleranceStrict,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Text(
                      _getToleranceDescription(l10n, settings.strokeTolerance),
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: SwitchListTile(
                title: Text(l10n.soundEffects),
                subtitle: Text(l10n.soundEffectsSubtitle),
                value: settings.soundEnabled,
                onChanged: (value) {
                  controller.setSoundEnabled(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: SwitchListTile(
                title: Text(l10n.hapticFeedback),
                subtitle: Text(l10n.hapticFeedbackSubtitle),
                value: settings.hapticEnabled,
                onChanged: (value) {
                  controller.setHapticEnabled(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.error),
                title: Text(
                  l10n.resetAllProgress,
                  style: const TextStyle(color: AppTheme.error),
                ),
                subtitle: Text(l10n.resetAllProgressSubtitle),
                onTap: () => _showResetConfirmation(context, ref),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutWriteLao),
                subtitle: Text(l10n.aboutVersionAuthor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
            ),
          ),

          if (VocabConfig.featureEnabled) const VocabSettingsSection(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getToleranceLabel(AppLocalizations l10n, double value) {
    if (value <= 0.60) return l10n.toleranceVeryEasy;
    if (value <= 0.65) return l10n.toleranceEasy;
    if (value <= 0.70) return l10n.toleranceMedium;
    if (value <= 0.75) return l10n.toleranceHard;
    if (value <= 0.80) return l10n.toleranceVeryHard;
    return l10n.toleranceExtreme;
  }

  String _getToleranceDescription(AppLocalizations l10n, double value) {
    if (value <= 0.60) return l10n.toleranceDescVeryEasy;
    if (value <= 0.65) return l10n.toleranceDescEasy;
    if (value <= 0.70) return l10n.toleranceDescMedium;
    if (value <= 0.75) return l10n.toleranceDescHard;
    if (value <= 0.80) return l10n.toleranceDescVeryHard;
    return l10n.toleranceDescExtreme;
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetProgressTitle),
        content: Text(l10n.resetProgressMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              ref.read(settingsControllerProvider.notifier).resetToDefaults();
              await ref.read(progressRepositoryProvider).resetAllProgress();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.progressResetSuccess),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}
