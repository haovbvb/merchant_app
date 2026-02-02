import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/payment/payment_controller.dart';

void main() {
  group('PaymentListState', () {
    test('should have correct default values', () {
      const state = PaymentListState();

      expect(state.loading, false);
      expect(state.page, 1);
      expect(state.items, isEmpty);
      expect(state.total, 0);
      expect(state.status, -1);
    });

    test('hasMore should return true when items less than total', () {
      const state = PaymentListState(items: [], total: 10);

      expect(state.hasMore, true);
    });

    test('hasMore should return false when items equal to total', () {
      const state = PaymentListState(items: [], total: 0);

      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const state = PaymentListState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should update page', () {
      const state = PaymentListState();
      final updated = state.copyWith(page: 3);

      expect(updated.page, 3);
    });

    test('copyWith should update total', () {
      const state = PaymentListState();
      final updated = state.copyWith(total: 50);

      expect(updated.total, 50);
      expect(updated.hasMore, true);
    });

    test('copyWith should update status', () {
      const state = PaymentListState();
      final updated = state.copyWith(status: 0);

      expect(updated.status, 0);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = PaymentListState(
        loading: true,
        page: 2,
        total: 30,
        status: 1,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.page, 2);
      expect(updated.total, 30);
      expect(updated.status, 1);
    });
  });

  group('PaymentConfirmState', () {
    test('should have correct default values', () {
      const state = PaymentConfirmState();

      expect(state.loading, false);
      expect(state.confirming, false);
      expect(state.order, isNull);
    });

    test('copyWith should update loading', () {
      const state = PaymentConfirmState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should update confirming', () {
      const state = PaymentConfirmState();
      final updated = state.copyWith(confirming: true);

      expect(updated.confirming, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = PaymentConfirmState(loading: true, confirming: true);
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.confirming, true);
    });
  });
}
