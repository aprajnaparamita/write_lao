import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:write_it_lao/config/app_info.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/l10n/app_localizations.dart';
import 'package:write_it_lao/presentation/controllers/practice_controller.dart';
import 'package:write_it_lao/vocab/domain/vocab_config.dart';
import 'package:write_it_lao/vocab/presentation/screens/vocab_settings_section.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Settings state provider
class SettingsState {
  final double strokeTolerance;
  final bool soundEnabled;
  final bool hapticEnabled;

  const SettingsState({
    this.strokeTolerance = 0.75,
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
                            min: 0.65,
                            max: 0.95,
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
                leading: const Icon(Icons.mail_outline),
                title: const Text('Contact Us'),
                subtitle: const Text('Support & feedback'),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () => launchUrl(Uri.parse('https://writelao.xyz/support')),
              ),
            ),
          ),

          const SizedBox(height: 8),

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
                subtitle: Text(l10n.aboutAuthor),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/about'),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Version (read directly from pubspec via package_info_plus) ───
          // Tapping copies the full "version (build)" string to the clipboard
          // so users/support can grab it without typing it out.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.tag),
                title: const Text('Version'),
                subtitle: Text(
                  formatAppVersion(ref.watch(appInfoProvider)),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                trailing: const Icon(Icons.copy_outlined, size: 18),
                onTap: () => _copyVersionToClipboard(context, ref),
              ),
            ),
          ),

          if (VocabConfig.featureEnabled) const VocabSettingsSection(),

          // ── Debug tools (only visible in debug builds) ───────────────
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Row(
                        children: [
                          Icon(Icons.bug_report,
                              size: 13, color: Colors.orange.shade800),
                          const SizedBox(width: 5),
                          Text(
                            'DEBUG ONLY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.send_outlined,
                          color: Colors.orange.shade700),
                      title: const Text('Send test error to Sentry'),
                      subtitle: const Text(
                          'Fires a real exception to verify the DSN is wired up.'),
                      onTap: () => _sendTestSentryError(context),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: Icon(Icons.menu_book_rounded,
                          color: Colors.orange.shade700),
                      title: const Text('Test: Vocab Upsell dialog'),
                      subtitle: const Text('Shows the 500-word upsell popup.'),
                      onTap: () =>
                          _showDebugVocabUpsell(context, ref),
                    ),
                    ListTile(
                      leading: Icon(Icons.star_border_rounded,
                          color: Colors.orange.shade700),
                      title: const Text('Test: Rating prompt'),
                      subtitle:
                          const Text('Shows the "Enjoying Write Lao?" flow.'),
                      onTap: () =>
                          _showDebugRatingPrompt(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getToleranceLabel(AppLocalizations l10n, double value) {
    if (value <= 0.70) return l10n.toleranceVeryEasy;
    if (value <= 0.75) return l10n.toleranceEasy;
    if (value <= 0.80) return l10n.toleranceMedium;
    if (value <= 0.85) return l10n.toleranceHard;
    if (value <= 0.90) return l10n.toleranceVeryHard;
    return l10n.toleranceExtreme;
  }

  String _getToleranceDescription(AppLocalizations l10n, double value) {
    if (value <= 0.70) return l10n.toleranceDescVeryEasy;
    if (value <= 0.75) return l10n.toleranceDescEasy;
    if (value <= 0.80) return l10n.toleranceDescMedium;
    if (value <= 0.85) return l10n.toleranceDescHard;
    if (value <= 0.90) return l10n.toleranceDescVeryHard;
    return l10n.toleranceDescExtreme;
  }

  /// Sends a real exception to Sentry, bypassing the debug-mode guard in
  /// [SentryHelper] so you can confirm the DSN and pipeline are working.
  /// Only reachable via the debug-only card in the UI.
  Future<void> _sendTestSentryError(BuildContext context) async {
    try {
      throw Exception(
          'Write Lao — manual Sentry test triggered from Settings screen.');
    } catch (e, stack) {
      await Sentry.captureException(
        e,
        stackTrace: stack,
        hint: Hint.withMap({
          'message': 'Debug test button — not a real crash',
        }),
        withScope: (scope) {
          scope.setTag('triggered_by', 'debug_settings_button');
          scope.setContexts('debug_info', {
            'source': 'SettingsScreen._sendTestSentryError',
            'build_mode': 'debug',
          });
        },
      );
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Test error sent to Sentry ✓'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade700,
        ),
      );
    }
  }

  // ── Debug prompt testers ──────────────────────────────────────────────────

  void _showDebugVocabUpsell(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
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
              if (ref.read(userVocabProgressRepositoryProvider)
                  .getOrCreate()
                  .iapUnlocked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('IAP already unlocked — no-op.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              context.push('/vocab/upsell');
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('See Details'),
          ),
        ],
      ),
    );
  }

  void _showDebugRatingPrompt(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
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
              _showDebugFeedbackPrompt(context);
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
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showDebugFeedbackPrompt(BuildContext context) {
    showDialog(
      context: context,
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
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
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

  /// Copies the live version + build number to the system clipboard and
  /// confirms with a snackbar. Used by the Version card in Settings.
  void _copyVersionToClipboard(BuildContext context, WidgetRef ref) {
    final appInfo = ref.read(appInfoProvider);
    final text = formatAppVersion(appInfo);
    // While PackageInfo is still loading, the helper returns "…", so don't
    // clobber the clipboard with a useless ellipsis.
    if (text == '…') return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $text'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
