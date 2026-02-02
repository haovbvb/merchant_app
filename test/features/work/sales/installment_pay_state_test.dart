import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/sales/installment_pay_controller.dart';

void main() {
  group('InstallmentPayState', () {
    test('copyWith should update loadingUser', () {
      const state = InstallmentPayState();
      final updated = state.copyWith(loadingUser: true);
      expect(updated.loadingUser, true);
      expect(updated.uploading, false);
      expect(updated.submitting, false);
    });

    test('copyWith should update uploading', () {
      const state = InstallmentPayState();
      final updated = state.copyWith(uploading: true);
      expect(updated.uploading, true);
    });

    test('copyWith should update submitting', () {
      const state = InstallmentPayState();
      final updated = state.copyWith(submitting: true);
      expect(updated.submitting, true);
    });

    test('copyWith should update attachments', () {
      const state = InstallmentPayState();
      final updated = state.copyWith(attachments: ['url1', 'url2']);
      expect(updated.attachments, ['url1', 'url2']);
    });

    test('copyWith should update submitSuccess and documentNo', () {
      const state = InstallmentPayState();
      final updated = state.copyWith(submitSuccess: true, documentNo: 'DOC789');
      expect(updated.submitSuccess, true);
      expect(updated.documentNo, 'DOC789');
    });

    test('default values should be correct', () {
      const state = InstallmentPayState();
      expect(state.loadingUser, false);
      expect(state.uploading, false);
      expect(state.submitting, false);
      expect(state.info, null);
      expect(state.orders, isEmpty);
      expect(state.selectedOrder, null);
      expect(state.attachments, isEmpty);
      expect(state.submitSuccess, false);
      expect(state.documentNo, null);
    });

    test('copyWith should preserve unchanged values', () {
      const state = InstallmentPayState(
        loadingUser: true,
        uploading: true,
        submitting: true,
        attachments: ['img1.jpg'],
        submitSuccess: true,
        documentNo: 'DOC001',
      );
      final updated = state.copyWith(loadingUser: false);
      expect(updated.loadingUser, false);
      expect(updated.uploading, true);
      expect(updated.submitting, true);
      expect(updated.attachments, ['img1.jpg']);
      expect(updated.submitSuccess, true);
      expect(updated.documentNo, 'DOC001');
    });

    test('copyWith should update orders list', () {
      const state = InstallmentPayState();
      final updated = state.copyWith(orders: []);
      expect(updated.orders, isEmpty);
    });

    test('copyWith with no arguments should return equivalent state', () {
      const state = InstallmentPayState(
        loadingUser: true,
        attachments: ['attachment.pdf'],
      );
      final updated = state.copyWith();
      expect(updated.loadingUser, true);
      expect(updated.attachments, ['attachment.pdf']);
    });
  });
}
