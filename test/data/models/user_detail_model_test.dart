import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/user_detail.dart';

void main() {
  group('UserDetail', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'avatar': 'https://example.com/avatar.png',
        'cardNum': 'CARD001',
        'firstName': 'John',
        'lastName': 'Doe',
        'createTime': '2024-01-01 12:00:00',
        'birthday': '1990-01-15',
        'email': 'john@example.com',
        'highPrivacy': true,
        'idNumber': 'ID123456',
        'imgList': 'img1.jpg,img2.jpg',
        'phone': '13800138000',
        'remark': 'VIP user',
        'status': 1,
        'type': 2,
        'username': 'johndoe',
        'batteryList': [
          {'sn': 'BAT001', 'model': 'Model A'},
        ],
        'vehicleList': [
          {'sn': 'VEH001', 'model': 'Model B'},
        ],
      };

      final user = UserDetail.fromJson(json);

      expect(user.avatar, 'https://example.com/avatar.png');
      expect(user.cardNum, 'CARD001');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.createTime, '2024-01-01 12:00:00');
      expect(user.birthday, '1990-01-15');
      expect(user.email, 'john@example.com');
      expect(user.highPrivacy, true);
      expect(user.idNumber, 'ID123456');
      expect(user.imgList, 'img1.jpg,img2.jpg');
      expect(user.phone, '13800138000');
      expect(user.remark, 'VIP user');
      expect(user.status, 1);
      expect(user.type, 2);
      expect(user.username, 'johndoe');
      expect(user.batteryList?.length, 1);
      expect(user.vehicleList?.length, 1);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final user = UserDetail.fromJson(json);

      expect(user.avatar, isNull);
      expect(user.cardNum, isNull);
      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.createTime, isNull);
      expect(user.birthday, isNull);
      expect(user.email, isNull);
      expect(user.highPrivacy, isNull);
      expect(user.idNumber, isNull);
      expect(user.imgList, isNull);
      expect(user.phone, isNull);
      expect(user.remark, isNull);
      expect(user.status, isNull);
      expect(user.type, isNull);
      expect(user.username, isNull);
      expect(user.batteryList, isNull);
      expect(user.vehicleList, isNull);
    });

    test('fromJson should handle empty batteryList and vehicleList', () {
      final json = {
        'batteryList': [],
        'vehicleList': [],
      };

      final user = UserDetail.fromJson(json);

      expect(user.batteryList, isEmpty);
      expect(user.vehicleList, isEmpty);
    });

    test('fromJson should handle null batteryList and vehicleList', () {
      final json = {
        'batteryList': null,
        'vehicleList': null,
      };

      final user = UserDetail.fromJson(json);

      expect(user.batteryList, isNull);
      expect(user.vehicleList, isNull);
    });

    test('fromJson should parse highPrivacy correctly', () {
      final jsonTrue = {'highPrivacy': true};
      final jsonFalse = {'highPrivacy': false};

      final userTrue = UserDetail.fromJson(jsonTrue);
      final userFalse = UserDetail.fromJson(jsonFalse);

      expect(userTrue.highPrivacy, true);
      expect(userFalse.highPrivacy, false);
    });

    test('fromJson should parse status and type from various types', () {
      final jsonInt = {'status': 1, 'type': 2};
      final jsonDouble = {'status': 1.0, 'type': 2.0};

      final userInt = UserDetail.fromJson(jsonInt);
      final userDouble = UserDetail.fromJson(jsonDouble);

      expect(userInt.status, 1);
      expect(userInt.type, 2);
      expect(userDouble.status, 1);
      expect(userDouble.type, 2);
    });
  });
}
