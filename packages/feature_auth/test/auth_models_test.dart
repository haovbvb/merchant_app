import 'package:feature_auth/feature_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthResult', () {
    test('parses json with mixed types and ops list', () {
      final result = AuthResult.fromJson({
        'token': 't-1',
        'name': 'merchant',
        'phone': '123456',
        'avatar': 'https://x/avatar.png',
        'role': '2',
        'agentNo': 'A01',
        'agentName': 'Agent',
        'shopNo': 'S01',
        'shopName': 'Shop',
        'appRole': 'owner',
        'managerFlag': 'true',
        'ops': [
          {
            'code': 'scan',
            'dictionaryCode': 'd.scan',
            'id': 1,
            'isOwn': '1',
            'name': 'Scan',
            'platform': '2',
          },
        ],
        'tenantName': 'Tenant',
        'emailCode': 'E100',
        'tenantId': 'TID',
        'currencyUnit': 'USD',
        'platform': '3',
        'areaCode': '+1',
        'cityCode': '001',
        'cardNum': 'C-1',
        'serviceType': 'normal',
        'apiKey': 'k-1',
      });

      expect(result.token, 't-1');
      expect(result.role, 2);
      expect(result.managerFlag, isTrue);
      expect(result.platform, 3);
      expect(result.ops, hasLength(1));
      expect(result.ops.first.code, 'scan');
      expect(result.ops.first.isOwn, 1);
      expect(result.ops.first.platform, 2);
    });

    test('defaults when fields are missing', () {
      final result = AuthResult.fromJson({});

      expect(result.token, isEmpty);
      expect(result.role, 0);
      expect(result.managerFlag, isFalse);
      expect(result.ops, isEmpty);
      expect(result.platform, 0);
      expect(result.raw, isA<Map<String, dynamic>>());
    });
  });

  group('AuthSession and UserState', () {
    test('AuthSession update and clear works', () {
      final session = AuthSession.instance;
      session.clear();

      final result = AuthResult.fromJson({'token': 'session-token'});
      session.update(result);
      expect(session.current?.token, 'session-token');

      session.clear();
      expect(session.current, isNull);
    });

    test('UserState auth and copyWith', () {
      const state = UserState(token: 'abc');
      expect(state.isAuthenticated, isTrue);

      final copied = state.copyWith(token: 'next');
      expect(copied.token, 'next');
      expect(copied.isAuthenticated, isTrue);

      const emptyState = UserState(token: '');
      expect(emptyState.isAuthenticated, isFalse);
    });
  });
}
