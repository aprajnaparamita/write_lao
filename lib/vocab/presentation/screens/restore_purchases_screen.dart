import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/domain/iap_service.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Settings screen for restoring purchases.
///
/// Shown when user taps "Restore Purchases" from settings.
class RestorePurchasesScreen extends StatefulWidget {
  final IapService iapService;
  final VoidCallback? onRestoreSuccess;
  final VoidCallback? onDismiss;

  const RestorePurchasesScreen({
    super.key,
    required this.iapService,
    this.onRestoreSuccess,
    this.onDismiss,
  });

  @override
  State<RestorePurchasesScreen> createState() => _RestorePurchasesScreenState();
}

class _RestorePurchasesScreenState extends State<RestorePurchasesScreen> {
  bool _isLoading = false;
  String? _message;
  bool? _success;

  Future<void> _handleRestore() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final result = await widget.iapService.restorePurchases();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      switch (result) {
        case IapRestored():
          _success = true;
          _message = 'Purchase restored successfully!';
          widget.onRestoreSuccess?.call();
        case IapNotRestored():
          _success = false;
          _message = 'No previous purchase found. Please purchase to unlock.';
        case IapError(:final message):
          _success = false;
          _message = 'Error: $message';
        case IapSuccess():
          _success = false;
          _message = 'Unexpected result. Please try again.';
        case IapCancelled():
          _success = false;
          _message = 'Restore cancelled. Please try again.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restore Purchases'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onDismiss,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.restore,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Restore Purchases',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'If you\'ve previously purchased the vocabulary feature on another device or reinstalled the app, '
                'tap Restore to unlock your purchase.\n\n'
                'Note: Your learning progress does not transfer between devices — only the purchase entitlement.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_message != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _success == true
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _success == true ? Icons.check_circle : Icons.error,
                        color: _success == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_message!)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              if (_success != true) ...[
                FilledButton(
                  onPressed: _isLoading ? null : _handleRestore,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Restore Purchases'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onDismiss,
                  child: const Text('Cancel'),
                ),
              ] else ...[
                FilledButton(
                  key: WordCardKeys.restoreContinue,
                  onPressed: widget.onDismiss,
                  child: const Text('Continue'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
