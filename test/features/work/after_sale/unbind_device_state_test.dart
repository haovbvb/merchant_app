import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/after_sale/unbind_device_controller.dart';

void main() {
  group('UnbindDeviceState', () {
    test('should have correct default values', () {
      const state = UnbindDeviceState();
      expect(state.loading, false);
      expect(state.submitting, false);
      expect(state.cardNum, '');
      expect(state.deviceSn, '');
      expect(state.checkRemark, '');
      expect(state.remark, '');
      expect(state.hasUnfinishedOrder, false);
      expect(state.appointmentNo, '');
    });

    test('should create with provided values', () {
      const state = UnbindDeviceState(
        loading: true,
        submitting: true,
        cardNum: 'CARD001',
        deviceSn: 'DEV001',
        checkRemark: 'Check remark',
        remark: 'Remark',
        hasUnfinishedOrder: true,
        appointmentNo: 'APT001',
      );
      expect(state.loading, true);
      expect(state.submitting, true);
      expect(state.cardNum, 'CARD001');
      expect(state.deviceSn, 'DEV001');
      expect(state.checkRemark, 'Check remark');
      expect(state.remark, 'Remark');
      expect(state.hasUnfinishedOrder, true);
      expect(state.appointmentNo, 'APT001');
    });

    test('copyWith should update loading', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
    });

    test('copyWith should update submitting', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(submitting: true);
      expect(updated.submitting, true);
    });

    test('copyWith should update cardNum', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(cardNum: 'CARD123');
      expect(updated.cardNum, 'CARD123');
    });

    test('copyWith should update deviceSn', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(deviceSn: 'SN123');
      expect(updated.deviceSn, 'SN123');
    });

    test('copyWith should update checkRemark', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(checkRemark: 'New check remark');
      expect(updated.checkRemark, 'New check remark');
    });

    test('copyWith should update remark', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(remark: 'New remark');
      expect(updated.remark, 'New remark');
    });

    test('copyWith should update hasUnfinishedOrder', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(hasUnfinishedOrder: true);
      expect(updated.hasUnfinishedOrder, true);
    });

    test('copyWith should update appointmentNo', () {
      const original = UnbindDeviceState();
      final updated = original.copyWith(appointmentNo: 'APT123');
      expect(updated.appointmentNo, 'APT123');
    });

    test('copyWith should preserve values when not provided', () {
      const original = UnbindDeviceState(
        loading: true,
        submitting: true,
        cardNum: 'CARD001',
        deviceSn: 'DEV001',
        hasUnfinishedOrder: true,
      );
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.submitting, original.submitting);
      expect(copy.cardNum, original.cardNum);
      expect(copy.deviceSn, original.deviceSn);
      expect(copy.hasUnfinishedOrder, original.hasUnfinishedOrder);
    });
  });
}
