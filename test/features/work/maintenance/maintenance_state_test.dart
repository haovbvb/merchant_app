import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';

void main() {
  group('MaintenanceBookState', () {
    test('should have correct default values', () {
      const state = MaintenanceBookState();

      expect(state.loading, false);
      expect(state.submitting, false);
      expect(state.sn, '');
      expect(state.note, '');
      expect(state.appointment, isNull);
      expect(state.amount, '');
      expect(state.paySource, 2);
      expect(state.voucherImages, isEmpty);
    });

    test('copyWith should update loading', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.submitting, false);
    });

    test('copyWith should update submitting', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(submitting: true);

      expect(updated.submitting, true);
      expect(updated.loading, false);
    });

    test('copyWith should update sn', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(sn: 'SN001');

      expect(updated.sn, 'SN001');
    });

    test('copyWith should update note', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(note: 'Test note');

      expect(updated.note, 'Test note');
    });

    test('copyWith should update amount', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(amount: '100.00');

      expect(updated.amount, '100.00');
    });

    test('copyWith should update paySource', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(paySource: 1);

      expect(updated.paySource, 1);
    });

    test('copyWith should update voucherImages', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(voucherImages: ['img1.jpg', 'img2.jpg']);

      expect(updated.voucherImages.length, 2);
      expect(updated.voucherImages[0], 'img1.jpg');
    });

    test('copyWith should clear appointment when clearAppointment is true', () {
      const state = MaintenanceBookState();
      final updated = state.copyWith(clearAppointment: true);

      expect(updated.appointment, isNull);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = MaintenanceBookState(
        loading: true,
        submitting: true,
        sn: 'SN001',
        note: 'Note',
        amount: '50',
        paySource: 1,
        voucherImages: ['img.jpg'],
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.submitting, true);
      expect(updated.sn, 'SN001');
      expect(updated.note, 'Note');
      expect(updated.amount, '50');
      expect(updated.paySource, 1);
      expect(updated.voucherImages, ['img.jpg']);
    });

    test('canConfirmCost should return true when amount is not empty for online payment', () {
      const state = MaintenanceBookState(amount: '100', paySource: 2);

      expect(state.canConfirmCost, true);
    });

    test('canConfirmCost should return false when amount is empty', () {
      const state = MaintenanceBookState(amount: '', paySource: 2);

      expect(state.canConfirmCost, false);
    });

    test('canConfirmCost should return true when amount is provided for cash payment', () {
      const state = MaintenanceBookState(amount: '100', paySource: 1);

      expect(state.canConfirmCost, true);
    });

    test('canConfirmCost should return false when amount is whitespace only', () {
      const state = MaintenanceBookState(amount: '   ', paySource: 2);

      expect(state.canConfirmCost, false);
    });
  });
}
