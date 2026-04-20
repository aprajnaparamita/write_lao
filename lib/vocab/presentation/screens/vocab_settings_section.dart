import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:write_it_lao/vocab/domain/iap_service.dart';
import 'package:write_it_lao/vocab/presentation/screens/restore_purchases_screen.dart';
import 'package:write_it_lao/vocab/providers.dart';

/// Section to add to the Write Lao settings screen for vocabulary-related options.
class VocabSettingsSection extends ConsumerWidget {
  /// Called when the user wants to open the restore purchases screen.
  final VoidCallback? onRestorePurchases;

  const VocabSettingsSection({
    super.key,
    this.onRestorePurchases,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iapService = ref.watch(iapServiceProvider);

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
        Card(
          child: ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Purchases'),
            subtitle: const Text('Unlock vocabulary on a new device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onRestorePurchases ?? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RestorePurchasesScreen(
                    iapService: iapService,
                    onRestoreSuccess: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vocabulary unlocked!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onDismiss: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
