/// IAP product ID for the 500-word vocabulary feature.
const String kVocabProductId = 'write_lao_vocabulary_500';

/// Result of an IAP operation.
sealed class IapResult {
  const IapResult();
}

/// Purchase completed successfully.
class IapSuccess extends IapResult {
  const IapSuccess();
}

/// Purchase was cancelled by the user.
class IapCancelled extends IapResult {
  const IapCancelled();
}

/// Purchase failed with an error.
class IapError extends IapResult {
  final String message;
  const IapError(this.message);
}

/// Restoring purchases found a valid entitlement.
class IapRestored extends IapResult {
  const IapRestored();
}

/// Restoring purchases found no entitlement.
class IapNotRestored extends IapResult {
  const IapNotRestored();
}

/// Platform-agnostic interface for in-app purchases.
///
/// Implementations wrap platform-specific code (Apple IAP, Google Play Billing).
/// Tests use a [MockIapService] that simulates responses.
abstract class IapService {
  /// Initiate a purchase flow for [kVocabProductId].
  /// Returns the result asynchronously.
  Future<IapResult> purchase();

  /// Query the platform for existing entitlements.
  /// Returns [IapRestored] if found, [IapNotRestored] if not.
  Future<IapResult> restorePurchases();

  /// Check if a purchase is currently available (e.g., network connectivity).
  /// If false, show a different error message.
  Future<bool> isAvailable();
}

/// In-memory mock for testing. Does not hit any platform APIs.
class MockIapService implements IapService {
  final bool simulateSuccess;
  final bool simulateRestored;

  const MockIapService({
    this.simulateSuccess = false,
    this.simulateRestored = false,
  });

  @override
  Future<IapResult> purchase() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (simulateSuccess) return const IapSuccess();
    return const IapCancelled();
  }

  @override
  Future<IapResult> restorePurchases() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (simulateRestored) return const IapRestored();
    return const IapNotRestored();
  }

  @override
  Future<bool> isAvailable() async => true;
}
