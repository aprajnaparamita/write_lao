import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      ],
    );
  }
}
