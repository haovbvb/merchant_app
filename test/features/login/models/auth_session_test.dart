import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/login/models/auth_result.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';

AuthResult _createAuthResult({
  String token = 'test-token',
  String name = 'TestUser',
}) {
  return AuthResult.fromJson({
    'token': token,
    'name': name,
  });
}

void main() {
  group('AuthSession', () {
    setUp(() {
      // Clear the singleton state before each test
      AuthSession.instance.clear();
    });

    test('should be a singleton', () {
      final instance1 = AuthSession.instance;
      final instance2 = AuthSession.instance;
      expect(identical(instance1, instance2), true);
    });

    test('should have null current by default', () {
      expect(AuthSession.instance.current, isNull);
    });

    test('update should set current AuthResult', () {
      final authResult = _createAuthResult(
        token: 'test-token',
        name: 'TestUser',
      );
      
      AuthSession.instance.update(authResult);
      
      expect(AuthSession.instance.current, isNotNull);
      expect(AuthSession.instance.current?.token, 'test-token');
      expect(AuthSession.instance.current?.name, 'TestUser');
    });

    test('clear should set current to null', () {
      final authResult = _createAuthResult(token: 'token');
      AuthSession.instance.update(authResult);
      expect(AuthSession.instance.current, isNotNull);
      
      AuthSession.instance.clear();
      
      expect(AuthSession.instance.current, isNull);
    });

    test('update should replace existing AuthResult', () {
      final authResult1 = _createAuthResult(token: 'token1', name: 'User1');
      final authResult2 = _createAuthResult(token: 'token2', name: 'User2');
      
      AuthSession.instance.update(authResult1);
      expect(AuthSession.instance.current?.name, 'User1');
      
      AuthSession.instance.update(authResult2);
      expect(AuthSession.instance.current?.name, 'User2');
      expect(AuthSession.instance.current?.token, 'token2');
    });
  });
}
