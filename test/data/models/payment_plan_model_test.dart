import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/payment_plan.dart';

void main() {
  group('PaymentPlan', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'amount': 1000.00,
        'fee': 50.00,
        'perAmount': 100.00,
        'period': 12,
        'planName': '12期免息',
        'planNo': 'PLAN001',
        'rate': 0.05,
        'totalAmount': 1050.00,
        'selected': true,
      };

      final plan = PaymentPlan.fromJson(json);

      expect(plan.amount, 1000.00);
      expect(plan.fee, 50.00);
      expect(plan.perAmount, 100.00);
      expect(plan.period, 12);
      expect(plan.planName, '12期免息');
      expect(plan.planNo, 'PLAN001');
      expect(plan.rate, 0.05);
      expect(plan.totalAmount, 1050.00);
      expect(plan.selected, true);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final plan = PaymentPlan.fromJson(json);

      expect(plan.amount, isNull);
      expect(plan.fee, isNull);
      expect(plan.perAmount, isNull);
      expect(plan.period, isNull);
      expect(plan.planName, isNull);
      expect(plan.planNo, isNull);
      expect(plan.rate, isNull);
      expect(plan.totalAmount, isNull);
      expect(plan.selected, false);
    });

    test('fromJson should parse numeric values from int', () {
      final json = {
        'amount': 1000,
        'fee': 50,
        'perAmount': 100,
        'period': 6,
        'rate': 0,
        'totalAmount': 1050,
      };

      final plan = PaymentPlan.fromJson(json);

      expect(plan.amount, 1000.0);
      expect(plan.fee, 50.0);
      expect(plan.perAmount, 100.0);
      expect(plan.period, 6);
      expect(plan.rate, 0.0);
      expect(plan.totalAmount, 1050.0);
    });

    test('fromJson should handle selected as false when not true', () {
      final json = {'selected': false};
      final plan = PaymentPlan.fromJson(json);
      expect(plan.selected, false);
    });

    test('fromJson should handle selected when null', () {
      final json = {'selected': null};
      final plan = PaymentPlan.fromJson(json);
      expect(plan.selected, false);
    });

    test('fromJson should handle selected with non-boolean value', () {
      final json = {'selected': 1};
      final plan = PaymentPlan.fromJson(json);
      // 1 != true, so should be false
      expect(plan.selected, false);
    });
  });
}
