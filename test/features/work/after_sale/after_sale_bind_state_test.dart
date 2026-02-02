import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/after_sale_can_bind_order_bean.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/user_detail.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_controller.dart';

void main() {
  group('AfterSaleBindState', () {
    test('should have correct default values', () {
      const state = AfterSaleBindState();
      expect(state.loading, false);
      expect(state.binding, false);
      expect(state.cardNum, '');
      expect(state.deviceSn, '');
      expect(state.userDetail, isNull);
      expect(state.orders, isEmpty);
      expect(state.selectedOrder, isNull);
      expect(state.deviceInfo, isNull);
      expect(state.errorMessage, isNull);
    });

    test('should create with provided values', () {
      const state = AfterSaleBindState(
        loading: true,
        binding: true,
        cardNum: 'CARD001',
        deviceSn: 'DEV001',
        errorMessage: 'Error',
      );
      expect(state.loading, true);
      expect(state.binding, true);
      expect(state.cardNum, 'CARD001');
      expect(state.deviceSn, 'DEV001');
      expect(state.errorMessage, 'Error');
    });

    test('copyWith should update loading', () {
      const original = AfterSaleBindState();
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
    });

    test('copyWith should update binding', () {
      const original = AfterSaleBindState();
      final updated = original.copyWith(binding: true);
      expect(updated.binding, true);
    });

    test('copyWith should update cardNum', () {
      const original = AfterSaleBindState();
      final updated = original.copyWith(cardNum: 'CARD123');
      expect(updated.cardNum, 'CARD123');
    });

    test('copyWith should update deviceSn', () {
      const original = AfterSaleBindState();
      final updated = original.copyWith(deviceSn: 'SN123');
      expect(updated.deviceSn, 'SN123');
    });

    test('copyWith should update userDetail', () {
      const original = AfterSaleBindState();
      final user = UserDetail.fromJson({'cardNum': 'CARD001', 'phone': '13800138000'});
      final updated = original.copyWith(userDetail: user);
      expect(updated.userDetail?.cardNum, 'CARD001');
    });

    test('copyWith should update orders list', () {
      const original = AfterSaleBindState();
      final orders = [
        AfterSaleCanBindOrderBean.fromJson({'orderNo': 'ORD001'}),
        AfterSaleCanBindOrderBean.fromJson({'orderNo': 'ORD002'}),
      ];
      final updated = original.copyWith(orders: orders);
      expect(updated.orders.length, 2);
    });

    test('copyWith should update selectedOrder', () {
      const original = AfterSaleBindState();
      final order = AfterSaleCanBindOrderBean.fromJson({'orderNo': 'ORD001'});
      final updated = original.copyWith(selectedOrder: order);
      expect(updated.selectedOrder?.orderNo, 'ORD001');
    });

    test('copyWith should update deviceInfo', () {
      const original = AfterSaleBindState();
      final device = BatterOrVehicleInfo.fromJson({
        'batteryVo': {'sn': 'BAT001'},
        'deviceType': 1,
      });
      final updated = original.copyWith(deviceInfo: device);
      expect(updated.deviceInfo?.batteryVo?.sn, 'BAT001');
    });

    test('copyWith errorMessage can be set to null', () {
      const original = AfterSaleBindState(errorMessage: 'Old error');
      final updated = original.copyWith(errorMessage: null);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith errorMessage can be updated', () {
      const original = AfterSaleBindState();
      final updated = original.copyWith(errorMessage: 'New error');
      expect(updated.errorMessage, 'New error');
    });

    test('copyWith should preserve values when not provided', () {
      const original = AfterSaleBindState(
        loading: true,
        binding: true,
        cardNum: 'CARD001',
        deviceSn: 'DEV001',
      );
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.binding, original.binding);
      expect(copy.cardNum, original.cardNum);
      expect(copy.deviceSn, original.deviceSn);
    });
  });
}
