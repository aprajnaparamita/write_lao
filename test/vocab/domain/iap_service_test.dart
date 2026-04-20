import 'package:flutter_test/flutter_test.dart';
import 'package:write_it_lao/vocab/domain/iap_service.dart';

void main() {
  group('MockIapService', () {
    test('purchase returns cancelled by default', () async {
      const service = MockIapService();
      final result = await service.purchase();
      expect(result, isA<IapCancelled>());
    });

    test('purchase returns success when simulateSuccess is true', () async {
      const service = MockIapService(simulateSuccess: true);
      final result = await service.purchase();
      expect(result, isA<IapSuccess>());
    });

    test('restorePurchases returns notRestored by default', () async {
      const service = MockIapService();
      final result = await service.restorePurchases();
      expect(result, isA<IapNotRestored>());
    });

    test('restorePurchases returns restored when simulateRestored is true', () async {
      const service = MockIapService(simulateRestored: true);
      final result = await service.restorePurchases();
      expect(result, isA<IapRestored>());
    });

    test('isAvailable returns true', () async {
      const service = MockIapService();
      expect(await service.isAvailable(), isTrue);
    });
  });

  group('IapResult types', () {
    test('IapSuccess equality', () {
      const a = IapSuccess();
      const b = IapSuccess();
      expect(a, equals(b));
    });

    test('IapCancelled equality', () {
      const a = IapCancelled();
      const b = IapCancelled();
      expect(a, equals(b));
    });

    test('IapError contains message', () {
      const error = IapError('test error');
      expect(error.message, 'test error');
    });
  });
}
