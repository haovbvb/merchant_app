import 'package:flutter/foundation.dart';
import 'package:foundation/foundation.dart';

import 'models/auth_result.dart';

class FeatureAuthGateway implements AuthGateway {
  FeatureAuthGateway._();

  static final FeatureAuthGateway instance = FeatureAuthGateway._();

  final ValueNotifier<AuthIdentitySnapshot> _state =
      ValueNotifier(const AuthIdentitySnapshot());

  Future<void> Function()? _logoutAction;

  @override
  ValueListenable<AuthIdentitySnapshot> get listenable => _state;

  @override
  AuthIdentitySnapshot get snapshot => _state.value;

  void bindLogoutAction(Future<void> Function() action) {
    _logoutAction = action;
  }

  void updateSession(AuthResult result) {
    _state.value = AuthIdentitySnapshot(
      token: result.token,
      name: result.name,
      avatar: result.avatar,
      emailCode: result.emailCode,
    );
  }

  void clearSession() {
    _state.value = const AuthIdentitySnapshot();
  }

  @override
  Future<void> logout() async {
    final action = _logoutAction;
    if (action != null) {
      await action();
      return;
    }
    clearSession();
  }
}
