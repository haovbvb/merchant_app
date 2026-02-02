import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/login/models/auth_result.dart';

void main() {
  group('AuthResult', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'token': 'test-token',
        'name': 'Test User',
        'phone': '13800138000',
        'avatar': 'https://example.com/avatar.png',
        'role': 1,
        'agentNo': 'AGENT001',
        'agentName': 'Test Agent',
        'shopNo': 'SHOP001',
        'shopName': 'Test Shop',
        'appRole': 'admin',
        'managerFlag': true,
        'ops': [
          {
            'code': 'OP001',
            'dictionaryCode': 'DICT001',
            'id': '1',
            'isOwn': 1,
            'name': 'Operation 1',
            'platform': 1,
          },
        ],
        'tenantName': 'Test Tenant',
        'emailCode': 'EMAIL001',
        'tenantId': 'TENANT001',
        'currencyUnit': 'CNY',
        'platform': 2,
        'areaCode': 'AREA001',
        'cityCode': 'CITY001',
        'cardNum': 'CARD001',
        'serviceType': 'premium',
        'apiKey': 'API_KEY_123',
      };

      final result = AuthResult.fromJson(json);

      expect(result.token, 'test-token');
      expect(result.name, 'Test User');
      expect(result.phone, '13800138000');
      expect(result.avatar, 'https://example.com/avatar.png');
      expect(result.role, 1);
      expect(result.agentNo, 'AGENT001');
      expect(result.agentName, 'Test Agent');
      expect(result.shopNo, 'SHOP001');
      expect(result.shopName, 'Test Shop');
      expect(result.appRole, 'admin');
      expect(result.managerFlag, true);
      expect(result.ops.length, 1);
      expect(result.tenantName, 'Test Tenant');
      expect(result.emailCode, 'EMAIL001');
      expect(result.tenantId, 'TENANT001');
      expect(result.currencyUnit, 'CNY');
      expect(result.platform, 2);
      expect(result.areaCode, 'AREA001');
      expect(result.cityCode, 'CITY001');
      expect(result.cardNum, 'CARD001');
      expect(result.serviceType, 'premium');
      expect(result.apiKey, 'API_KEY_123');
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final result = AuthResult.fromJson(json);

      expect(result.token, '');
      expect(result.name, '');
      expect(result.phone, '');
      expect(result.avatar, '');
      expect(result.role, 0);
      expect(result.agentNo, '');
      expect(result.agentName, '');
      expect(result.shopNo, '');
      expect(result.shopName, '');
      expect(result.appRole, '');
      expect(result.managerFlag, false);
      expect(result.ops, isEmpty);
      expect(result.tenantName, '');
      expect(result.emailCode, '');
      expect(result.tenantId, '');
      expect(result.currencyUnit, '');
      expect(result.platform, 0);
      expect(result.areaCode, '');
      expect(result.cityCode, '');
      expect(result.cardNum, '');
      expect(result.serviceType, '');
      expect(result.apiKey, '');
    });

    test('fromJson should parse role from string', () {
      final json = {'role': '5'};
      final result = AuthResult.fromJson(json);
      expect(result.role, 5);
    });

    test('fromJson should parse platform from string', () {
      final json = {'platform': '3'};
      final result = AuthResult.fromJson(json);
      expect(result.platform, 3);
    });

    test('fromJson should parse managerFlag from string "true"', () {
      final json = {'managerFlag': 'true'};
      final result = AuthResult.fromJson(json);
      expect(result.managerFlag, true);
    });

    test('fromJson should parse managerFlag from string "false"', () {
      final json = {'managerFlag': 'false'};
      final result = AuthResult.fromJson(json);
      expect(result.managerFlag, false);
    });

    test('fromJson should handle multiple operations', () {
      final json = {
        'ops': [
          {'code': 'OP1', 'name': 'Op 1'},
          {'code': 'OP2', 'name': 'Op 2'},
          {'code': 'OP3', 'name': 'Op 3'},
        ],
      };

      final result = AuthResult.fromJson(json);

      expect(result.ops.length, 3);
      expect(result.ops[0].code, 'OP1');
      expect(result.ops[1].code, 'OP2');
      expect(result.ops[2].code, 'OP3');
    });

    test('fromJson should preserve raw json', () {
      final json = {'token': 'test', 'customField': 'customValue'};
      final result = AuthResult.fromJson(json);
      expect(result.raw, json);
      expect(result.raw['customField'], 'customValue');
    });
  });

  group('AuthOperation', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'code': 'OP001',
        'dictionaryCode': 'DICT001',
        'id': '123',
        'isOwn': 1,
        'name': 'Test Operation',
        'platform': 2,
      };

      final operation = AuthOperation.fromJson(json);

      expect(operation.code, 'OP001');
      expect(operation.dictionaryCode, 'DICT001');
      expect(operation.id, '123');
      expect(operation.isOwn, 1);
      expect(operation.name, 'Test Operation');
      expect(operation.platform, 2);
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final operation = AuthOperation.fromJson(json);

      expect(operation.code, '');
      expect(operation.dictionaryCode, '');
      expect(operation.id, '');
      expect(operation.isOwn, 0);
      expect(operation.name, '');
      expect(operation.platform, 0);
    });

    test('fromJson should parse isOwn from string', () {
      final json = {'isOwn': '1'};
      final operation = AuthOperation.fromJson(json);
      expect(operation.isOwn, 1);
    });

    test('fromJson should parse platform from string', () {
      final json = {'platform': '5'};
      final operation = AuthOperation.fromJson(json);
      expect(operation.platform, 5);
    });
  });
}
