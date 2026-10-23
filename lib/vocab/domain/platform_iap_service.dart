import 'dart:async';

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:write_lao/config/sentry.dart';
import 'package:write_lao/vocab/domain/iap_service.dart';

/// Extracts a short, user-friendly message from an IAP exception.
/// Full details are sent to Sentry separately — never shown to the user.
String _friendlyIapError(Object e) {
  if (e is PlatformException) {
    // StoreKit error codes we can give a helpful hint for.
    switch (e.code) {
      case 'storekit_duplicate_product_object':
        return 'A purchase is already in progress. Please wait a moment.';
      case 'storekit_payment_not_allowed':
        return 'Purchases are disabled on this device. Check your Screen Time or parental controls settings.';
      case 'storekit_payment_cancelled':
        return ''; // User cancelled — treat as IapCancelled, not an error.
    }
    // Use the short StoreKit message if available; otherwise a generic fallback.
    final msg = e.message;
    if (msg != null && msg.isNotEmpty && msg.length < 120) return msg;
  }
  return 'Something went wrong. Please try again.';
}

/// Real iOS / Android IAP implementation backed by StoreKit / Google Play.
///
/// Uses [InAppPurchase] from the `in_app_purchase` package.
/// Converts the stream-based purchase API into a clean `Future<IapResult>`
/// that the UI can await directly.
class PlatformIapService implements IapService {
  final InAppPurchase _iap = InAppPurchase.instance;

  // ── isAvailable ────────────────────────────────────────────────────────────

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  // ── purchase ───────────────────────────────────────────────────────────────

  @override
  Future<IapResult> purchase() async {
    // 1. Store reachable?
    if (!await _iap.isAvailable()) {
      await SentryHelper.captureMessage(
        'IAP: store not available (isAvailable returned false)',
        context: {'product_id': kVocabProductId},
      );
      return const IapError(
        'The App Store is not available. Please check your internet '
        'connection and try again.',
      );
    }

    // 2. Fetch product details from the store.
    final response =
        await _iap.queryProductDetails({kVocabProductId});

    if (response.productDetails.isEmpty) {
      await SentryHelper.captureMessage(
        'IAP: product not found in store',
        context: {
          'product_id': kVocabProductId,
          'not_found_ids': response.notFoundIDs.join(', '),
          'store_error': response.error?.message,
          'store_error_code': response.error?.code,
          'store_error_source': response.error?.source,
        },
      );
      return const IapError(
        'Unable to load purchase details from the App Store. '
        'Please try again later.',
      );
    }

    final product = response.productDetails.first;

    // 3. Set up a Completer that the stream listener will complete.
    final completer = Completer<IapResult>();
    StreamSubscription<List<PurchaseDetails>>? sub;

    sub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final p in purchases) {
          if (p.productID != kVocabProductId) continue;

          // Always acknowledge the purchase so Apple/Google doesn't refund.
          if (p.pendingCompletePurchase) {
            await _iap.completePurchase(p);
          }

          switch (p.status) {
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
              if (!completer.isCompleted) {
                completer.complete(const IapSuccess());
                await sub?.cancel();
              }
              return;

            case PurchaseStatus.canceled:
              if (!completer.isCompleted) {
                completer.complete(const IapCancelled());
                await sub?.cancel();
              }
              return;

            case PurchaseStatus.error:
              final msg = p.error?.message ?? 'The purchase failed.';
              await SentryHelper.captureMessage(
                'IAP: purchase returned error status',
                context: {
                  'product_id': kVocabProductId,
                  'error_code': p.error?.code,
                  'error_message': p.error?.message,
                  'error_source': p.error?.source,
                },
              );
              if (!completer.isCompleted) {
                completer.complete(IapError(msg));
                await sub?.cancel();
              }
              return;

            case PurchaseStatus.pending:
              // StoreKit is processing — keep the listener open.
              break;
          }
        }
      },
      onError: (Object error, StackTrace stack) async {
        await SentryHelper.captureException(
          error,
          stack,
          hint: 'IAP: purchaseStream emitted an error',
          context: {'product_id': kVocabProductId},
        );
        if (!completer.isCompleted) {
          completer.complete(IapError(_friendlyIapError(error)));
        }
        await sub?.cancel();
      },
    );

    // 4. Kick off the purchase flow.
    try {
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (e, stack) {
      await SentryHelper.captureException(
        e,
        stack,
        hint: 'IAP: buyNonConsumable threw synchronously',
        context: {'product_id': kVocabProductId},
      );
      await sub.cancel();
      final msg = _friendlyIapError(e);
      // Empty msg means user cancelled via the system sheet.
      return msg.isEmpty ? const IapCancelled() : IapError(msg);
    }

    // 5. Wait for the stream to complete the Completer.
    return completer.future;
  }

  // ── restorePurchases ───────────────────────────────────────────────────────

  @override
  Future<IapResult> restorePurchases() async {
    if (!await _iap.isAvailable()) {
      return const IapError(
        'The App Store is not available. Please check your internet '
        'connection and try again.',
      );
    }

    final completer = Completer<IapResult>();
    StreamSubscription<List<PurchaseDetails>>? sub;

    sub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final p in purchases) {
          if (p.productID != kVocabProductId) continue;
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);

          if (p.status == PurchaseStatus.restored ||
              p.status == PurchaseStatus.purchased) {
            if (!completer.isCompleted) {
              completer.complete(const IapRestored());
            }
            return;
          }

          if (p.status == PurchaseStatus.error && !completer.isCompleted) {
            final msg = p.error?.message ?? 'Restore failed.';
            await SentryHelper.captureMessage(
              'IAP: restore returned error status',
              context: {
                'product_id': kVocabProductId,
                'error_code': p.error?.code,
                'error_message': p.error?.message,
              },
            );
            completer.complete(IapError(msg));
            return;
          }
        }
      },
      onError: (Object error, StackTrace stack) async {
        await SentryHelper.captureException(
          error,
          stack,
          hint: 'IAP: purchaseStream emitted an error during restore',
        );
        if (!completer.isCompleted) {
          completer.complete(IapError(_friendlyIapError(error)));
        }
      },
    );

    try {
      await _iap.restorePurchases();
    } catch (e, stack) {
      await SentryHelper.captureException(
        e,
        stack,
        hint: 'IAP: restorePurchases threw synchronously',
      );
      await sub.cancel();
      return IapError(_friendlyIapError(e));
    }

    // iOS delivers restored purchases asynchronously and doesn't emit a
    // "done" signal on the purchase stream. Give it 10 s; if nothing
    // arrives the user has no prior purchase.
    await Future.delayed(const Duration(seconds: 10));
    await sub.cancel();

    if (!completer.isCompleted) {
      completer.complete(const IapNotRestored());
    }

    return completer.future;
  }

  // ── getPriceLabel ──────────────────────────────────────────────────────────

  @override
  Future<String?> getPriceLabel() async {
    try {
      if (!await _iap.isAvailable()) return null;
      final response = await _iap.queryProductDetails({kVocabProductId});
      if (response.productDetails.isEmpty) return null;
      // StoreKit returns the localized currency-formatted price (e.g.
      // "$4.99", "€4,99", "¥800"). Do NOT hand-format — let Apple localize.
      return response.productDetails.first.price;
    } catch (e, stack) {
      await SentryHelper.captureException(
        e,
        stack,
        hint: 'IAP: getPriceLabel failed',
      );
      return null;
    }
  }
}
