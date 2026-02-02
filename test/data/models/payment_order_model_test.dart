import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/payment_order.dart';

void main() {
  group('PaymentOrder', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'amount': 1500.50,
        'cardNum': 'CARD001',
        'firstName': 'John',
        'lastName': 'Doe',
        'orderDate': 1704067200000,
        'orderNo': 'ORD001',
        'payType': 1,
        'period': 12,
        'status': 0,
        'type': 1,
        'username': 'johndoe',
      };

      final order = PaymentOrder.fromJson(json);

      expect(order.amount, 1500.50);
      expect(order.cardNum, 'CARD001');
      expect(order.firstName, 'John');
      expect(order.lastName, 'Doe');
      expect(order.orderDate, 1704067200000);
      expect(order.orderNo, 'ORD001');
      expect(order.payType, 1);
      expect(order.period, 12);
      expect(order.status, 0);
      expect(order.type, 1);
      expect(order.username, 'johndoe');
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final order = PaymentOrder.fromJson(json);

      expect(order.amount, 0.0);
      expect(order.cardNum, '');
      expect(order.firstName, '');
      expect(order.lastName, '');
      expect(order.orderDate, 0);
      expect(order.orderNo, '');
      expect(order.payType, 0);
      expect(order.period, 0);
      expect(order.status, 0);
      expect(order.type, 0);
      expect(order.username, '');
    });

    test('fromJson should parse amount from int', () {
      final json = {'amount': 1000};

      final order = PaymentOrder.fromJson(json);

      expect(order.amount, 1000.0);
    });

    test('fullName should return combined firstName and lastName', () {
      const order = PaymentOrder(firstName: 'John', lastName: 'Doe');

      expect(order.fullName, 'John Doe');
    });

    test('fullName should return username when names are empty', () {
      const order = PaymentOrder(username: 'johndoe');

      expect(order.fullName, 'johndoe');
    });

    test('fullName should trim whitespace', () {
      const order = PaymentOrder(firstName: 'John', lastName: '');

      expect(order.fullName, 'John');
    });

    test('isPending should return true for status 0', () {
      const order = PaymentOrder(status: 0);

      expect(order.isPending, true);
      expect(order.isConfirmed, false);
      expect(order.isRejected, false);
    });

    test('isConfirmed should return true for status 1', () {
      const order = PaymentOrder(status: 1);

      expect(order.isPending, false);
      expect(order.isConfirmed, true);
      expect(order.isRejected, false);
    });

    test('isRejected should return true for status 2', () {
      const order = PaymentOrder(status: 2);

      expect(order.isPending, false);
      expect(order.isConfirmed, false);
      expect(order.isRejected, true);
    });

    test('statusName should return correct status name', () {
      expect(const PaymentOrder(status: 0).statusName, '待审核');
      expect(const PaymentOrder(status: 1).statusName, '已确认');
      expect(const PaymentOrder(status: 2).statusName, '已拒绝');
      expect(const PaymentOrder(status: 3).statusName, '');
    });

    test('orderDateTime should return DateTime from timestamp', () {
      const order = PaymentOrder(orderDate: 1704067200000);

      expect(order.orderDateTime, isNotNull);
      expect(order.orderDateTime!.year, 2024);
    });

    test('orderDateTime should return null for zero timestamp', () {
      const order = PaymentOrder(orderDate: 0);

      expect(order.orderDateTime, isNull);
    });
  });

  group('PaymentOrderListResponse', () {
    test('fromJson should parse list and total correctly', () {
      final json = {
        'list': [
          {'orderNo': 'ORD001', 'amount': 100.0},
          {'orderNo': 'ORD002', 'amount': 200.0},
        ],
        'total': 2,
      };

      final response = PaymentOrderListResponse.fromJson(json);

      expect(response.list.length, 2);
      expect(response.total, 2);
      expect(response.list[0].orderNo, 'ORD001');
      expect(response.list[1].orderNo, 'ORD002');
    });

    test('fromJson should handle empty list', () {
      final json = {'list': [], 'total': 0};

      final response = PaymentOrderListResponse.fromJson(json);

      expect(response.list, isEmpty);
      expect(response.total, 0);
    });

    test('fromJson should handle null list', () {
      final json = {'list': null, 'total': 0};

      final response = PaymentOrderListResponse.fromJson(json);

      expect(response.list, isEmpty);
    });
  });
}
