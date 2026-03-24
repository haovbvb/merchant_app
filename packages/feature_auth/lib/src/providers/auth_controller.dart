import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:networking/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_api_path.dart';
import '../constants/storage_keys.dart';
import '../models/auth_result.dart';
import '../models/auth_session.dart';
import '../models/user_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, UserState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<UserState> {
  final ApiService _apiService = ApiService();

  @override
  UserState build() {
    return const UserState();
  }

  Future<bool> login({required String name, required String password}) async {
    try {
      final hashedPassword = HashUtils.md5Lower32(password);
      final response = await _apiService.post<AuthResult>(
        AuthApiPath.urlOf(AuthApiPath.login),
        data: {'name': name, 'password': hashedPassword},
        parser: _parseAuthResult,
      );

      if (!response.isSuccess) {
        final msg = response.message.isEmpty ? '登录失败' : response.message;
        Toast.show(msg);
        return false;
      }

      final authResult = response.result;
      if (authResult == null || authResult.token.isEmpty) {
        Toast.show('缺少 token');
        return false;
      }

      await updateSession(authResult);
      return true;
    } catch (_) {
      Toast.show('登录失败，请稍后重试');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post<AuthResult>(
        AuthApiPath.urlOf(AuthApiPath.logout),
        parser: _parseAuthResult,
      );
    } catch (_) {
      // Ignore logout request failure and still clear local session.
    }

    await clearSession();
  }

  Future<void> updateSession(AuthResult result) async {
    await _persistToken(result.token);
    AuthSession.instance.update(result);
    state = UserState(token: result.token, user: result);
  }

  Future<void> clearSession() async {
    await _clearToken();
    AuthSession.instance.clear();
    state = const UserState();
  }

  Future<String?> loadTokenFromStorage() async {
    return _readToken();
  }

  AuthResult _parseAuthResult(dynamic data) {
    if (data is Map<String, dynamic>) {
      return AuthResult.fromJson(data);
    }
    if (data is Map) {
      return AuthResult.fromJson(Map<String, dynamic>.from(data));
    }
    throw Exception('响应格式错误');
  }

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AuthStorageKeys.authToken, token);
  }

  Future<String?> _readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AuthStorageKeys.authToken);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AuthStorageKeys.authToken);
  }
}
