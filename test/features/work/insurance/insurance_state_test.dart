import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/insurance/insurance_controller.dart';

void main() {
  group('InsuranceApplyState', () {
    test('should have correct default values', () {
      const state = InsuranceApplyState();

      expect(state.loading, false);
      expect(state.submitting, false);
      expect(state.user, isNull);
      expect(state.device, isNull);
      expect(state.plan, isNull);
    });

    test('copyWith should update loading', () {
      const state = InsuranceApplyState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.submitting, false);
    });

    test('copyWith should update submitting', () {
      const state = InsuranceApplyState();
      final updated = state.copyWith(submitting: true);

      expect(updated.submitting, true);
      expect(updated.loading, false);
    });

    test('copyWith should update device', () {
      const state = InsuranceApplyState();
      final device = {'sn': 'SN001', 'model': 'Model A'};
      final updated = state.copyWith(device: device);

      expect(updated.device, device);
    });

    test('copyWith should preserve existing values when not provided', () {
      final device = {'sn': 'SN001'};
      final state = InsuranceApplyState(
        loading: true,
        submitting: true,
        device: device,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.submitting, true);
      expect(updated.device, device);
    });

    test('copyWith should return new instance with same values when called without arguments', () {
      final device = {'key': 'value'};
      final state = InsuranceApplyState(
        loading: true,
        device: device,
      );
      final updated = state.copyWith();

      expect(updated.loading, true);
      expect(updated.device, device);
    });
  });
}
