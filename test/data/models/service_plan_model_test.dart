import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/service_plan.dart';

void main() {
  group('ServicePlanBean', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'infoName': 'Premium Plan',
        'packageAmount': 299.99,
        'batteryType': '60V',
        'carType': 'Electric Scooter',
        'infoCode': 'PLAN001',
        'deviceModel': 'Model X',
        'isSelected': true,
      };

      final plan = ServicePlanBean.fromJson(json);

      expect(plan.infoName, 'Premium Plan');
      expect(plan.packageAmount, 299.99);
      expect(plan.batteryType, '60V');
      expect(plan.carType, 'Electric Scooter');
      expect(plan.infoCode, 'PLAN001');
      expect(plan.deviceModel, 'Model X');
      expect(plan.isSelected, true);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final plan = ServicePlanBean.fromJson(json);

      expect(plan.infoName, isNull);
      expect(plan.packageAmount, isNull);
      expect(plan.batteryType, isNull);
      expect(plan.carType, isNull);
      expect(plan.infoCode, isNull);
      expect(plan.deviceModel, isNull);
      expect(plan.isSelected, false);
    });

    test('fromJson should parse packageAmount from int', () {
      final json = {'packageAmount': 100};
      final plan = ServicePlanBean.fromJson(json);
      expect(plan.packageAmount, 100.0);
    });

    test('fromJson should handle isSelected as false when not true', () {
      final json = {'isSelected': false};
      final plan = ServicePlanBean.fromJson(json);
      expect(plan.isSelected, false);
    });

    test('fromJson should handle isSelected when null', () {
      final json = {'isSelected': null};
      final plan = ServicePlanBean.fromJson(json);
      expect(plan.isSelected, false);
    });
  });

  group('ServicePlanInfo', () {
    test('fromJson should parse list and total', () {
      final json = {
        'list': [
          {'infoName': 'Plan 1', 'packageAmount': 100.0},
          {'infoName': 'Plan 2', 'packageAmount': 200.0},
        ],
        'total': 2,
      };

      final info = ServicePlanInfo.fromJson(json);

      expect(info.list.length, 2);
      expect(info.total, 2);
      expect(info.list[0].infoName, 'Plan 1');
      expect(info.list[1].infoName, 'Plan 2');
    });

    test('fromJson should handle empty list', () {
      final json = {
        'list': [],
        'total': 0,
      };

      final info = ServicePlanInfo.fromJson(json);

      expect(info.list, isEmpty);
      expect(info.total, 0);
    });

    test('fromJson should handle null list', () {
      final json = {
        'list': null,
        'total': 0,
      };

      final info = ServicePlanInfo.fromJson(json);

      expect(info.list, isEmpty);
      expect(info.total, 0);
    });

    test('fromJson should handle null total', () {
      final json = {
        'list': [],
        'total': null,
      };

      final info = ServicePlanInfo.fromJson(json);

      expect(info.total, 0);
    });
  });
}
