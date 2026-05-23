import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:write_it_lao/config/theme.dart';
import 'package:write_it_lao/vocab/domain/iap_service.dart';
import 'package:write_it_lao/vocab/presentation/widgets/word_card_keys.dart';

class UpsellScreen extends StatefulWidget {
  final VoidCallback? onPurchaseComplete;
  final VoidCallback? onDismissed;

  /// Optional callback for the RESTORE button in the header.
  /// When null the button is hidden.
  final VoidCallback? onRestore;

  final IapService iapService;

  /// Platform-localized price string (e.g. "$4.99"). When null the button
  /// reads "BUY NOW" — the platform sheet always shows the real price.
  final String? priceLabel;

  const UpsellScreen({
    super.key,
    this.onPurchaseComplete,
    this.onDismissed,
    this.onRestore,
    required this.iapService,
    this.priceLabel,
  });

  @override
  State<UpsellScreen> createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  bool _isLoading = false;
  String? _error;

  static const _cardColor = Color(0xFF1A004A);

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
        break;
      case IapError(:final message):
        setState(() => _error = message);
      case IapRestored():
        widget.onPurchaseComplete?.call();
      case IapNotRestored():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildScrollableContent()),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: WordCardKeys.upsellMaybeLater,
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onDismissed,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Debug-only instant unlock ─────────────────────────────
              if (kDebugMode)
                TextButton(
                  key: const Key('debug.upsell.instantUnlock'),
                  onPressed: widget.onPurchaseComplete,
                  child: const Text(
                    '🔓 UNLOCK',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              if (widget.onRestore != null)
                TextButton(
                  onPressed: widget.onRestore,
                  child: const Text(
                    'RESTORE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Unlock 500 Words',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _FeatureCard(
            color: _cardColor,
            iconBgColor: AppTheme.primaryLight,
            icon: Icons.menu_book,
            title: '500 Vocabulary Words',
            description:
                'Practice writing every essential Lao word with stroke-by-stroke guidance.',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            color: _cardColor,
            iconBgColor: AppTheme.primaryLight,
            icon: Icons.repeat,
            title: 'Spaced Repetition',
            description:
                'Smart review keeps words fresh without overloading you.',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            color: _cardColor,
            iconBgColor: AppTheme.primaryLight,
            icon: Icons.favorite,
            title: 'One-time Purchase',
            description:
                'Pay once, no subscription. Includes all future content.',
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: AppTheme.primary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              key: WordCardKeys.upsellBuyNow,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _handlePurchase,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.priceLabel == null
                          ? 'BUY NOW'
                          : 'BUY NOW — ${widget.priceLabel}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '* One-time purchase — full access to all content and future updates',
            style: TextStyle(color: Colors.white60, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Color color;
  final Color iconBgColor;
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.color,
    required this.iconBgColor,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
