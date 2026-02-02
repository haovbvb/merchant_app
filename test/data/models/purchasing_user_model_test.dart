import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';

void main() {
  group('PurchasingUser', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'address': '123 Main St',
        'avatar': 'https://example.com/avatar.png',
        'birthday': '1990-01-15',
        'cardImg': 'https://example.com/card.png',
        'cardNum': 'CARD12345',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'idNumber': 'ID123456789',
        'phone': '13800138000',
        'username': 'johndoe',
        'personImg': 'https://example.com/person.png',
      };

      final user = PurchasingUser.fromJson(json);

      expect(user.address, '123 Main St');
      expect(user.avatar, 'https://example.com/avatar.png');
      expect(user.birthday, '1990-01-15');
      expect(user.cardImg, 'https://example.com/card.png');
      expect(user.cardNum, 'CARD12345');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.idNumber, 'ID123456789');
      expect(user.phone, '13800138000');
      expect(user.username, 'johndoe');
      expect(user.personImg, 'https://example.com/person.png');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final user = PurchasingUser.fromJson(json);

      expect(user.address, isNull);
      expect(user.avatar, isNull);
      expect(user.birthday, isNull);
      expect(user.cardImg, isNull);
      expect(user.cardNum, isNull);
      expect(user.email, isNull);
      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.idNumber, isNull);
      expect(user.phone, isNull);
      expect(user.username, isNull);
      expect(user.personImg, isNull);
    });

    test('toJson should serialize all fields', () {
      const user = PurchasingUser(
        address: '123 Main St',
        avatar: 'https://example.com/avatar.png',
        birthday: '1990-01-15',
        cardImg: 'https://example.com/card.png',
        cardNum: 'CARD12345',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        idNumber: 'ID123456789',
        phone: '13800138000',
        username: 'johndoe',
        personImg: 'https://example.com/person.png',
      );

      final json = user.toJson();

      expect(json['address'], '123 Main St');
      expect(json['avatar'], 'https://example.com/avatar.png');
      expect(json['birthday'], '1990-01-15');
      expect(json['cardImg'], 'https://example.com/card.png');
      expect(json['cardNum'], 'CARD12345');
      expect(json['email'], 'test@example.com');
      expect(json['firstName'], 'John');
      expect(json['lastName'], 'Doe');
      expect(json['idNumber'], 'ID123456789');
      expect(json['phone'], '13800138000');
      expect(json['username'], 'johndoe');
      expect(json['personImg'], 'https://example.com/person.png');
    });

    test('toJson should serialize null values', () {
      const user = PurchasingUser();
      final json = user.toJson();
      
      expect(json['address'], isNull);
      expect(json['phone'], isNull);
    });

    test('fromJson/toJson round trip', () {
      final originalJson = {
        'address': 'Test Address',
        'firstName': 'Alice',
        'lastName': 'Smith',
        'phone': '13900139000',
      };

      final user = PurchasingUser.fromJson(originalJson);
      final resultJson = user.toJson();

      expect(resultJson['address'], originalJson['address']);
      expect(resultJson['firstName'], originalJson['firstName']);
      expect(resultJson['lastName'], originalJson['lastName']);
      expect(resultJson['phone'], originalJson['phone']);
    });
  });
}
