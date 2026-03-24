import 'package:networking/networking.dart';

class AuthApiPath {
  const AuthApiPath._();

  static const String login = '/admin/sys/user/login';
  static const String logout = '/admin/sys/user/logout';

  static String urlOf(String path) => NetworkEnvironmentConfig.urlOf(path);
}
