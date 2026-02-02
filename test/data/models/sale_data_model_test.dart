import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/sale_data.dart';

void main() {
  group('SaleData Model', () {
    test('fromJson should parse complete JSON correctly', () {
      final json = {
        'orderIncome': 12345.67,
        'orderNum': 100,
        'today': '2026-02-02',
      };

      final saleData = SaleData.fromJson(json);

      expect(saleData.orderIncome, 12345.67);
      expect(saleData.orderNum, 100);
      expect(saleData.today, '2026-02-02');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final saleData = SaleData.fromJson(json);

      expect(saleData.orderIncome, isNull);
      expect(saleData.orderNum, isNull);
      expect(saleData.today, isNull);
    });

    test('fromJson should handle integer orderIncome as double', () {
      final json = {
        'orderIncome': 1000, // int instead of double
        'orderNum': 50,
        'today': '2026-01-15',
      };

      final saleData = SaleData.fromJson(json);

      expect(saleData.orderIncome, 1000.0);
      expect(saleData.orderNum, 50);
    });

    test('fromJson should handle string today', () {
      final json = {
        'orderIncome': 999.99,
        'orderNum': 25,
        'today': 20260202, // numeric date
      };

      final saleData = SaleData.fromJson(json);

      expect(saleData.today, '20260202');
    });

    test('toJson should serialize all fields correctly', () {
      const saleData = SaleData(
        orderIncome: 5000.50,
        orderNum: 200,
        today: '2026-02-01',
      );

      final json = saleData.toJson();

      expect(json['orderIncome'], 5000.50);
      expect(json['orderNum'], 200);
      expect(json['today'], '2026-02-01');
    });

    test('toJson should handle null values', () {
      const saleData = SaleData(
        orderIncome: null,
        orderNum: null,
        today: null,
      );

      final json = saleData.toJson();

      expect(json['orderIncome'], isNull);
      expect(json['orderNum'], isNull);
      expect(json['today'], isNull);
    });

    test('toJson/fromJson should be reversible', () {
      const original = SaleData(
        orderIncome: 9999.99,
        orderNum: 500,
        today: '2026-12-31',
      );

      final json = original.toJson();
      final restored = SaleData.fromJson(json);

      expect(restored.orderIncome, original.orderIncome);
      expect(restored.orderNum, original.orderNum);
      expect(restored.today, original.today);
    });

    test('fromJson should handle zero values', () {
      final json = {
        'orderIncome': 0.0,
        'orderNum': 0,
        'today': '',
      };

      final saleData = SaleData.fromJson(json);

      expect(saleData.orderIncome, 0.0);
      expect(saleData.orderNum, 0);
      expect(saleData.today, '');
    });

    test('fromJson should handle large numbers', () {
      final json = {
        'orderIncome': 99999999.99,
        'orderNum': 1000000,
        'today': '2026-02-02',
      };

      final saleData = SaleData.fromJson(json);

      expect(saleData.orderIncome, 99999999.99);
      expect(saleData.orderNum, 1000000);
    });
  });
}
