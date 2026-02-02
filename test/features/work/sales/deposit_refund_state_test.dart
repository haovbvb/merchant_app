import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/sales/deposit_refund_controller.dart';

void main() {
  group('DepositRefundState', () {
    test('copyWith should update loading', () {
      const state = DepositRefundState();
      final updated = state.copyWith(loading: true);
      expect(updated.loading, true);
      expect(updated.submitting, false);
    });

    test('copyWith should update submitting', () {
      const state = DepositRefundState();
      final updated = state.copyWith(submitting: true);
      expect(updated.submitting, true);
      expect(updated.loading, false);
    });

    test('copyWith should update submitSuccess', () {
      const state = DepositRefundState();
      final updated = state.copyWith(submitSuccess: true);
      expect(updated.submitSuccess, true);
    });

    test('copyWith should update voucherConfirmed', () {
      const state = DepositRefundState();
      expect(state.voucherConfirmed, true);
      final updated = state.copyWith(voucherConfirmed: false);
      expect(updated.voucherConfirmed, false);
    });

    test('default values should be correct', () {
      const state = DepositRefundState();
      expect(state.loading, false);
      expect(state.submitting, false);
      expect(state.submitSuccess, false);
      expect(state.info, null);
      expect(state.selectedDeposit, null);
      expect(state.voucherConfirmed, true);
    });

    test('copyWith should preserve unchanged values', () {
      const state = DepositRefundState(
        loading: true,
        submitting: true,
        submitSuccess: true,
        voucherConfirmed: false,
      );
      final updated = state.copyWith(loading: false);
      expect(updated.loading, false);
      expect(updated.submitting, true);
      expect(updated.submitSuccess, true);
      expect(updated.voucherConfirmed, false);
    });

    test('copyWith with no arguments should return equivalent state', () {
      const state = DepositRefundState(
        loading: true,
        voucherConfirmed: false,
      );
      final updated = state.copyWith();
      expect(updated.loading, true);
      expect(updated.voucherConfirmed, false);
    });
  });
}
