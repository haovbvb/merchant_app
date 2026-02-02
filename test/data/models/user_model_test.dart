import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/user.dart';

void main() {
  group('User Model', () {
    test('fromJson should parse complete JSON correctly', () {
      final json = {
        'token': 'test_token_123',
        'name': 'John Doe',
        'phone': '1234567890',
        'avatar': 'https://example.com/avatar.jpg',
        'role': 1,
        'agentNo': 'AGENT001',
        'shopNo': 'SHOP001',
        'managerFlag': true,
        'tenantName': 'Test Tenant',
        'emailCode': 'test@example.com',
        'currencyUnit': 'USD',
        'areaCode': '+1',
        'appRole': 'admin',
        'serviceType': 'premium',
      };

      final user = User.fromJson(json);

      expect(user.token, 'test_token_123');
      expect(user.name, 'John Doe');
      expect(user.phone, '1234567890');
      expect(user.avatar, 'https://example.com/avatar.jpg');
      expect(user.role, 1);
      expect(user.agentNo, 'AGENT001');
      expect(user.shopNo, 'SHOP001');
      expect(user.managerFlag, true);
      expect(user.tenantName, 'Test Tenant');
      expect(user.emailCode, 'test@example.com');
      expect(user.currencyUnit, 'USD');
      expect(user.areaCode, '+1');
      expect(user.appRole, 'admin');
      expect(user.serviceType, 'premium');
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final user = User.fromJson(json);

      expect(user.token, '');
      expect(user.name, '');
      expect(user.phone, '');
      expect(user.avatar, '');
      expect(user.role, 0);
      expect(user.agentNo, '');
      expect(user.shopNo, isNull);
      expect(user.managerFlag, false);
      expect(user.tenantName, '');
      expect(user.emailCode, '');
      expect(user.currencyUnit, '');
      expect(user.areaCode, '');
      expect(user.appRole, '');
      expect(user.serviceType, '');
    });

    test('fromJson should handle numeric role as num', () {
      final json = {
        'token': 'token',
        'name': 'name',
        'phone': 'phone',
        'avatar': 'avatar',
        'role': 2.0, // double instead of int
        'agentNo': 'agent',
        'managerFlag': false,
        'tenantName': 'tenant',
        'emailCode': 'email',
        'currencyUnit': 'USD',
        'areaCode': '+1',
        'appRole': 'user',
        'serviceType': 'basic',
      };

      final user = User.fromJson(json);

      expect(user.role, 2);
    });

    test('toJson should serialize all fields correctly', () {
      const user = User(
        token: 'test_token',
        name: 'Test User',
        phone: '9876543210',
        avatar: 'https://example.com/test.jpg',
        role: 3,
        agentNo: 'AGENT002',
        shopNo: 'SHOP002',
        managerFlag: true,
        tenantName: 'Test Tenant 2',
        emailCode: 'test2@example.com',
        currencyUnit: 'EUR',
        areaCode: '+44',
        appRole: 'manager',
        serviceType: 'enterprise',
      );

      final json = user.toJson();

      expect(json['token'], 'test_token');
      expect(json['name'], 'Test User');
      expect(json['phone'], '9876543210');
      expect(json['avatar'], 'https://example.com/test.jpg');
      expect(json['role'], 3);
      expect(json['agentNo'], 'AGENT002');
      expect(json['shopNo'], 'SHOP002');
      expect(json['managerFlag'], true);
      expect(json['tenantName'], 'Test Tenant 2');
      expect(json['emailCode'], 'test2@example.com');
      expect(json['currencyUnit'], 'EUR');
      expect(json['areaCode'], '+44');
      expect(json['appRole'], 'manager');
      expect(json['serviceType'], 'enterprise');
    });

    test('toJson/fromJson should be reversible', () {
      const original = User(
        token: 'reversible_token',
        name: 'Reversible User',
        phone: '1112223333',
        avatar: 'https://example.com/reversible.jpg',
        role: 5,
        agentNo: 'AGENT_REV',
        shopNo: 'SHOP_REV',
        managerFlag: false,
        tenantName: 'Reversible Tenant',
        emailCode: 'reversible@example.com',
        currencyUnit: 'GBP',
        areaCode: '+86',
        appRole: 'operator',
        serviceType: 'standard',
      );

      final json = original.toJson();
      final restored = User.fromJson(json);

      expect(restored.token, original.token);
      expect(restored.name, original.name);
      expect(restored.phone, original.phone);
      expect(restored.avatar, original.avatar);
      expect(restored.role, original.role);
      expect(restored.agentNo, original.agentNo);
      expect(restored.shopNo, original.shopNo);
      expect(restored.managerFlag, original.managerFlag);
      expect(restored.tenantName, original.tenantName);
      expect(restored.emailCode, original.emailCode);
      expect(restored.currencyUnit, original.currencyUnit);
      expect(restored.areaCode, original.areaCode);
      expect(restored.appRole, original.appRole);
      expect(restored.serviceType, original.serviceType);
    });
  });
}
