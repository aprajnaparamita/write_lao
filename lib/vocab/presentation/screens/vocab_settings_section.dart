import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Section to add to the Write Lao settings screen for vocabulary-related options.
class VocabSettingsSection extends ConsumerWidget {
  /// Called when the user wants to open the restore purchases screen.
  /// Defaults to `context.push('/vocab/restore')`.
  final VoidCallback? onRestorePurchases;

  const VocabSettingsSection({
    super.key,
    this.onRestorePurchases,
  });

  static const restoreTileKey = Key('vocab.settings.restoreTile');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            'Vocabulary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ListTile(
              key: restoreTileKey,
              leading: const Icon(Icons.restore),
              title: const Text('Restore Purchases'),
              subtitle: const Text('Unlock vocabulary on a new device'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onRestorePurchases ??
                  () => context.push('/vocab/restore'),
            ),
          ),
        ),

        // ── Debug-only tools ────────────────────────────────────────────
        if (kDebugMode) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Developer Tools',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.lock_open, color: Colors.orange),
                    title: const Text('Unlock All Content (debug)'),
                    subtitle: const Text(
                        'Skips IAP — simulates a successful purchase'),
                    onTap: () {
                      final repo =
                          ref.read(userVocabProgressRepositoryProvider);
                      repo.markIapUnlocked();
                      ref.read(vocabStateRevProvider.notifier).state++;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ IAP unlocked — all content accessible'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline,
                        color: Colors.deepOrange),
                    title: const Text('Reset IAP Lock (debug)'),
                    subtitle: const Text(
                        'Re-locks content to re-test the purchase flow'),
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset IAP lock?'),
                          content: const Text(
                              'This re-locks all paid content so you can '
                              'test the purchase flow again.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !context.mounted) return;
                      final repo =
                          ref.read(userVocabProgressRepositoryProvider);
                      final progress = repo.getOrCreate();
                      repo.save(progress.copyWith(iapUnlocked: false));
                      ref.read(vocabStateRevProvider.notifier).state++;
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔒 IAP reset — content locked again'),
                          backgroundColor: Colors.deepOrange,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
