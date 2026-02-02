import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/qrcode/qr_code_list_controller.dart';

void main() {
  group('QrCodeListState', () {
    test('should have correct default values', () {
      const state = QrCodeListState();
      expect(state.loading, false);
      expect(state.deviceType, isNull);
      expect(state.items, isEmpty);
    });

    test('should create with provided values', () {
      const state = QrCodeListState(
        loading: true,
        deviceType: 1,
        items: ['SN001', 'SN002'],
      );
      expect(state.loading, true);
      expect(state.deviceType, 1);
      expect(state.items, ['SN001', 'SN002']);
    });

    test('copyWith should return new instance with updated values', () {
      const original = QrCodeListState(
        loading: false,
        deviceType: 1,
        items: ['SN001'],
      );
      
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
      expect(updated.deviceType, 1);
      expect(updated.items, ['SN001']);
    });

    test('copyWith should preserve values when not provided', () {
      const original = QrCodeListState(
        loading: true,
        deviceType: 2,
        items: ['A', 'B'],
      );
      
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.deviceType, original.deviceType);
      expect(copy.items, original.items);
    });

    test('copyWith should update items list', () {
      const original = QrCodeListState(items: ['A']);
      final updated = original.copyWith(items: ['A', 'B', 'C']);
      expect(updated.items, ['A', 'B', 'C']);
    });
  });
}
