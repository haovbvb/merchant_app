import 'package:flutter/foundation.dart';

@immutable
class AuthIdentitySnapshot {
  const AuthIdentitySnapshot({
    this.token,
    this.name,
    this.avatar,
    this.emailCode,
  });

  final String? token;
  final String? name;
  final String? avatar;
  final String? emailCode;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthIdentitySnapshot copyWith({
    String? token,
    String? name,
    String? avatar,
    String? emailCode,
  }) {
    return AuthIdentitySnapshot(
      token: token ?? this.token,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      emailCode: emailCode ?? this.emailCode,
    );
  }
}

abstract interface class AuthGateway {
  ValueListenable<AuthIdentitySnapshot> get listenable;

  AuthIdentitySnapshot get snapshot;

  Future<void> logout();
}

class NoopAuthGateway implements AuthGateway {
  final ValueNotifier<AuthIdentitySnapshot> _state =
      ValueNotifier(const AuthIdentitySnapshot());

  @override
  ValueListenable<AuthIdentitySnapshot> get listenable => _state;

  @override
  AuthIdentitySnapshot get snapshot => _state.value;

  @override
  Future<void> logout() async {}
}

class AuthGatewayRegistry {
  AuthGatewayRegistry._();

  static final AuthGatewayRegistry instance = AuthGatewayRegistry._();

  AuthGateway _current = NoopAuthGateway();

  AuthGateway get current => _current;

  void register(AuthGateway gateway) {
    _current = gateway;
  }
}
