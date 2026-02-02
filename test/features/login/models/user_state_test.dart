import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/login/models/auth_result.dart';
import 'package:merchant_app/features/login/models/user_state.dart';

AuthResult _createAuthResult({String token = 'test', String name = 'Test'}) {
  return AuthResult.fromJson({
    'token': token,
    'name': name,
  });
}

void main() {
  group('UserState', () {
    test('should have correct default values', () {
      const state = UserState();
      expect(state.token, isNull);
      expect(state.user, isNull);
      expect(state.isAuthenticated, false);
    });

    test('should create with provided values', () {
      final authResult = _createAuthResult(token: 'test-token');
      final state = UserState(token: 'test-token', user: authResult);
      expect(state.token, 'test-token');
      expect(state.user?.name, 'Test');
    });

    test('isAuthenticated should return true when token is non-empty', () {
      const state = UserState(token: 'valid-token');
      expect(state.isAuthenticated, true);
    });

    test('isAuthenticated should return false when token is null', () {
      const state = UserState(token: null);
      expect(state.isAuthenticated, false);
    });

    test('isAuthenticated should return false when token is empty', () {
      const state = UserState(token: '');
      expect(state.isAuthenticated, false);
    });

    test('copyWith should update token', () {
      const original = UserState(token: 'old-token');
      final updated = original.copyWith(token: 'new-token');
      expect(updated.token, 'new-token');
    });

    test('copyWith should update user', () {
      const original = UserState();
      final authResult = _createAuthResult(name: 'NewUser');
      final updated = original.copyWith(user: authResult);
      expect(updated.user?.name, 'NewUser');
    });

    test('copyWith should preserve values when not provided', () {
      final authResult = _createAuthResult(token: 'test');
      final original = UserState(token: 'token', user: authResult);
      final copy = original.copyWith();
      expect(copy.token, 'token');
      expect(copy.user?.name, 'Test');
    });
  });
}
