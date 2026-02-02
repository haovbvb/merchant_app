import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/payment_plan.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';
import 'package:merchant_app/data/models/service_plan.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';

void main() {
  group('SellBindState', () {
    test('should have correct default values', () {
      const state = SellBindState();
      expect(state.loadingUser, false);
      expect(state.loadingDevice, false);
      expect(state.loadingPlans, false);
      expect(state.loadingPaymentPlans, false);
      expect(state.submitting, false);
      expect(state.submitSuccess, false);
      expect(state.documentNo, isNull);
      expect(state.user, isNull);
      expect(state.deviceInfo, isNull);
      expect(state.plans, isEmpty);
      expect(state.selectedPlan, isNull);
      expect(state.paymentPlans, isEmpty);
      expect(state.selectedPaymentPlan, isNull);
      expect(state.paySource, 2);
      expect(state.payType, 1);
      expect(state.cardImgUrl, isNull);
      expect(state.personImgUrl, isNull);
    });

    test('should create with provided values', () {
      const state = SellBindState(
        loadingUser: true,
        loadingDevice: true,
        paySource: 1,
        payType: 2,
        documentNo: 'DOC001',
      );
      expect(state.loadingUser, true);
      expect(state.loadingDevice, true);
      expect(state.paySource, 1);
      expect(state.payType, 2);
      expect(state.documentNo, 'DOC001');
    });

    test('copyWith should update loadingUser', () {
      const original = SellBindState();
      final updated = original.copyWith(loadingUser: true);
      expect(updated.loadingUser, true);
    });

    test('copyWith should update loadingDevice', () {
      const original = SellBindState();
      final updated = original.copyWith(loadingDevice: true);
      expect(updated.loadingDevice, true);
    });

    test('copyWith should update loadingPlans', () {
      const original = SellBindState();
      final updated = original.copyWith(loadingPlans: true);
      expect(updated.loadingPlans, true);
    });

    test('copyWith should update loadingPaymentPlans', () {
      const original = SellBindState();
      final updated = original.copyWith(loadingPaymentPlans: true);
      expect(updated.loadingPaymentPlans, true);
    });

    test('copyWith should update submitting', () {
      const original = SellBindState();
      final updated = original.copyWith(submitting: true);
      expect(updated.submitting, true);
    });

    test('copyWith should update submitSuccess', () {
      const original = SellBindState();
      final updated = original.copyWith(submitSuccess: true);
      expect(updated.submitSuccess, true);
    });

    test('copyWith should update documentNo', () {
      const original = SellBindState();
      final updated = original.copyWith(documentNo: 'DOC123');
      expect(updated.documentNo, 'DOC123');
    });

    test('copyWith should update user', () {
      const original = SellBindState();
      final user = PurchasingUser.fromJson({'username': 'testuser'});
      final updated = original.copyWith(user: user);
      expect(updated.user?.username, 'testuser');
    });

    test('copyWith should update deviceInfo', () {
      const original = SellBindState();
      final device = BatterOrVehicleInfo.fromJson({
        'batteryVo': {'sn': 'DEV001'},
        'deviceType': 1,
      });
      final updated = original.copyWith(deviceInfo: device);
      expect(updated.deviceInfo?.batteryVo?.sn, 'DEV001');
    });

    test('copyWith should update plans list', () {
      const original = SellBindState();
      final plans = [
        ServicePlanBean.fromJson({'infoCode': '1', 'infoName': 'Plan 1'}),
        ServicePlanBean.fromJson({'infoCode': '2', 'infoName': 'Plan 2'}),
      ];
      final updated = original.copyWith(plans: plans);
      expect(updated.plans.length, 2);
    });

    test('copyWith should update selectedPlan', () {
      const original = SellBindState();
      final plan = ServicePlanBean.fromJson({'infoCode': '1', 'infoName': 'Selected Plan'});
      final updated = original.copyWith(selectedPlan: plan);
      expect(updated.selectedPlan?.infoName, 'Selected Plan');
    });

    test('copyWith should update paymentPlans list', () {
      const original = SellBindState();
      final paymentPlans = [
        PaymentPlan.fromJson({'id': '1', 'name': 'Payment 1'}),
        PaymentPlan.fromJson({'id': '2', 'name': 'Payment 2'}),
      ];
      final updated = original.copyWith(paymentPlans: paymentPlans);
      expect(updated.paymentPlans.length, 2);
    });

    test('copyWith should update paySource and payType', () {
      const original = SellBindState();
      final updated = original.copyWith(paySource: 3, payType: 5);
      expect(updated.paySource, 3);
      expect(updated.payType, 5);
    });

    test('copyWith should update image URLs', () {
      const original = SellBindState();
      final updated = original.copyWith(
        cardImgUrl: 'https://example.com/card.jpg',
        personImgUrl: 'https://example.com/person.jpg',
      );
      expect(updated.cardImgUrl, 'https://example.com/card.jpg');
      expect(updated.personImgUrl, 'https://example.com/person.jpg');
    });

    test('copyWith should preserve values when not provided', () {
      const original = SellBindState(
        loadingUser: true,
        loadingDevice: true,
        submitting: true,
        paySource: 3,
        payType: 4,
        documentNo: 'DOC001',
      );
      final copy = original.copyWith();
      expect(copy.loadingUser, original.loadingUser);
      expect(copy.loadingDevice, original.loadingDevice);
      expect(copy.submitting, original.submitting);
      expect(copy.paySource, original.paySource);
      expect(copy.payType, original.payType);
      expect(copy.documentNo, original.documentNo);
    });
  });
}
