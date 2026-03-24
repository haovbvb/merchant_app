import 'auth_result.dart';

class UserState {
  const UserState({this.token, this.user});

  final String? token;
  final AuthResult? user;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  UserState copyWith({String? token, AuthResult? user}) =>
      UserState(token: token ?? this.token, user: user ?? this.user);
}
