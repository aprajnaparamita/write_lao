import 'package:flutter/material.dart';
import 'package:write_it_lao/vocab/domain/iap_service.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

/// Full-screen upsell modal shown to free users after completing the preview
/// lesson or when they tap a locked unit.
class UpsellScreen extends StatefulWidget {
  /// Called when the user taps "Buy now" and the purchase succeeds.
  final VoidCallback? onPurchaseComplete;

  /// Called when the user taps "Maybe later" or backs out.
  final VoidCallback? onDismissed;

  /// The IAP service to use for purchasing.
  final IapService iapService;

  /// Platform-localized price string (e.g. "$0.99", "€0.89"). When null the
  /// button reads "Buy Now" — the platform's purchase sheet always shows the
  /// real price, so this is only a preview.
  final String? priceLabel;

  const UpsellScreen({
    super.key,
    this.onPurchaseComplete,
    this.onDismissed,
    required this.iapService,
    this.priceLabel,
  });

  @override
  State<UpsellScreen> createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  bool _isLoading = false;
  String? _error;

  Future<void> _handlePurchase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await widget.iapService.purchase();

    if (!mounted) return;

    setState(() => _isLoading = false);

    switch (result) {
      case IapSuccess():
        widget.onPurchaseComplete?.call();
      case IapCancelled():
        // User cancelled, stay on screen
        break;
      case IapError(:final message):
        setState(() => _error = message);
      case IapRestored():
        // Shouldn't happen from purchase(), but handle gracefully
        widget.onPurchaseComplete?.call();
      case IapNotRestored():
        // Shouldn't happen from purchase()
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onDismissed?.call();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                Text(
                  'Unlock 500 Words',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Learn Lao vocabulary with writing practice.\nMaster 500 essential words.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const _FeatureRow(icon: Icons.edit, text: 'Writing practice for every word'),
                const _FeatureRow(icon: Icons.repeat, text: 'Spaced repetition review'),
                const _FeatureRow(icon: Icons.volume_up, text: 'Audio pronunciation'),
                const _FeatureRow(icon: Icons.flag, text: 'Flag words for extra practice'),
                const SizedBox(height: 32),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                FilledButton(
                  key: WordCardKeys.upsellBuyNow,
                  onPressed: _isLoading ? null : _handlePurchase,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.priceLabel == null
                          ? 'Buy Now'
                          : 'Buy Now — ${widget.priceLabel}'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: WordCardKeys.upsellMaybeLater,
                  onPressed: () {
                    widget.onDismissed?.call();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Maybe later'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
