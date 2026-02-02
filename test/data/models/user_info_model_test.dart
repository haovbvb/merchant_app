import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/user_info.dart';

void main() {
  group('UserInfo', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'avatar': 'https://example.com/avatar.png',
        'cardNum': 'CARD001',
        'firstName': 'John',
        'lastName': 'Doe',
        'registerDate': '2024-01-01',
        'remainPay': 1500.50,
        'remainPeriod': 6,
        'totalPay': 3000.00,
        'type': 1,
        'username': 'johndoe',
        'idNumber': 'ID123456',
        'status': 1,
        'order': 5,
        'orderAmount': 500.00,
        'asset': 3,
      };

      final user = UserInfo.fromJson(json);

      expect(user.avatar, 'https://example.com/avatar.png');
      expect(user.cardNum, 'CARD001');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.registerDate, '2024-01-01');
      expect(user.remainPay, 1500.50);
      expect(user.remainPeriod, 6);
      expect(user.totalPay, 3000.00);
      expect(user.type, 1);
      expect(user.username, 'johndoe');
      expect(user.idNumber, 'ID123456');
      expect(user.status, 1);
      expect(user.order, 5);
      expect(user.orderAmount, 500.00);
      expect(user.asset, 3);
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final user = UserInfo.fromJson(json);

      expect(user.avatar, '');
      expect(user.cardNum, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.registerDate, '');
      expect(user.remainPay, 0.0);
      expect(user.remainPeriod, 0);
      expect(user.totalPay, 0.0);
      expect(user.type, 0);
      expect(user.username, '');
      expect(user.idNumber, '');
      expect(user.status, 0);
      expect(user.order, isNull);
      expect(user.orderAmount, isNull);
      expect(user.asset, isNull);
    });

    test('fromJson should parse numeric values from int', () {
      final json = {
        'remainPay': 1500,
        'remainPeriod': 6,
        'totalPay': 3000,
        'type': 1,
        'status': 1,
      };

      final user = UserInfo.fromJson(json);

      expect(user.remainPay, 1500.0);
      expect(user.remainPeriod, 6);
      expect(user.totalPay, 3000.0);
      expect(user.type, 1);
      expect(user.status, 1);
    });

    test('toJson should serialize all fields correctly', () {
      const user = UserInfo(
        avatar: 'https://example.com/avatar.png',
        cardNum: 'CARD001',
        firstName: 'John',
        lastName: 'Doe',
        registerDate: '2024-01-01',
        remainPay: 1500.50,
        remainPeriod: 6,
        totalPay: 3000.00,
        type: 1,
        username: 'johndoe',
        idNumber: 'ID123456',
        status: 1,
        order: 5,
        orderAmount: 500.00,
        asset: 3,
      );

      final json = user.toJson();

      expect(json['avatar'], 'https://example.com/avatar.png');
      expect(json['cardNum'], 'CARD001');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['registerDate'], '2024-01-01');
      expect(json['remainPay'], 1500.50);
      expect(json['remainPeriod'], 6);
      expect(json['totalPay'], 3000.00);
      expect(json['type'], 1);
      expect(json['username'], 'johndoe');
      expect(json['idNumber'], 'ID123456');
      expect(json['status'], 1);
      expect(json['order'], 5);
      expect(json['orderAmount'], 500.00);
      expect(json['asset'], 3);
    });

    test('fromJson/toJson round trip', () {
      final originalJson = {
        'avatar': 'avatar.png',
        'cardNum': 'CARD123',
        'firstName': 'Alice',
        'lastName': 'Smith',
        'registerDate': '2024-02-01',
        'remainPay': 2000.0,
        'remainPeriod': 12,
        'totalPay': 4000.0,
        'type': 2,
        'username': 'alice',
        'idNumber': 'ID789',
        'status': 0,
        'order': 10,
        'orderAmount': 1000.0,
        'asset': 5,
      };

      final user = UserInfo.fromJson(originalJson);
      final resultJson = user.toJson();

      expect(resultJson['cardNum'], originalJson['cardNum']);
      expect(resultJson['firstName'], originalJson['firstName']);
      expect(resultJson['remainPay'], originalJson['remainPay']);
      expect(resultJson['order'], originalJson['order']);
    });
  });
}
