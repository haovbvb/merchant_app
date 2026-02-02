import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/sales/swap_bind_controller.dart';

void main() {
  group('SwapBindState', () {
    test('copyWith should update loadingUser', () {
      const state = SwapBindState();
      final updated = state.copyWith(loadingUser: true);
      expect(updated.loadingUser, true);
      expect(updated.loadingPack, false);
      expect(updated.submitting, false);
    });

    test('copyWith should update loadingPack', () {
      const state = SwapBindState();
      final updated = state.copyWith(loadingPack: true);
      expect(updated.loadingPack, true);
    });

    test('copyWith should update submitting', () {
      const state = SwapBindState();
      final updated = state.copyWith(submitting: true);
      expect(updated.submitting, true);
    });

    test('copyWith should update paySource', () {
      const state = SwapBindState();
      expect(state.paySource, 2);
      final updated = state.copyWith(paySource: 1);
      expect(updated.paySource, 1);
    });

    test('copyWith should update submitSuccess and documentNo', () {
      const state = SwapBindState();
      final updated = state.copyWith(submitSuccess: true, documentNo: 'DOC123');
      expect(updated.submitSuccess, true);
      expect(updated.documentNo, 'DOC123');
    });

    test('default values should be correct', () {
      const state = SwapBindState();
      expect(state.loadingUser, false);
      expect(state.loadingPack, false);
      expect(state.submitting, false);
      expect(state.info, null);
      expect(state.selectedCar, null);
      expect(state.selectedBattery, null);
      expect(state.selectedBatteries, isEmpty);
      expect(state.packs, isEmpty);
      expect(state.selectedPack, null);
      expect(state.paySource, 2);
      expect(state.submitSuccess, false);
      expect(state.documentNo, null);
    });

    test('copyWith should preserve unchanged values', () {
      const state = SwapBindState(
        loadingUser: true,
        loadingPack: true,
        submitting: true,
        paySource: 3,
        submitSuccess: true,
        documentNo: 'DOC456',
      );
      final updated = state.copyWith(loadingUser: false);
      expect(updated.loadingUser, false);
      expect(updated.loadingPack, true);
      expect(updated.submitting, true);
      expect(updated.paySource, 3);
      expect(updated.submitSuccess, true);
      expect(updated.documentNo, 'DOC456');
    });

    test('copyWith should update selectedBatteries list', () {
      const state = SwapBindState();
      final updated = state.copyWith(selectedBatteries: []);
      expect(updated.selectedBatteries, isEmpty);
    });

    test('copyWith should update packs list', () {
      const state = SwapBindState();
      final updated = state.copyWith(packs: []);
      expect(updated.packs, isEmpty);
    });
  });
}
