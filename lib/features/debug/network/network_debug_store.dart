import 'dart:collection';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkLogEntry {
  const NetworkLogEntry({
    required this.id,
    required this.method,
    required this.url,
    required this.path,
    required this.startedAt,
    this.query,
    this.requestBody,
    this.requestHeaders,
    this.responseBody,
    this.statusCode,
    this.businessCode,
    this.message,
    this.durationMs,
    this.error,
    this.isError = false,
    this.completed = false,
  });

  final String id;
  final String method;
  final String url;
  final String path;
  final DateTime startedAt;
  final Map<String, dynamic>? query;
  final dynamic requestBody;
  final Map<String, dynamic>? requestHeaders;
  final dynamic responseBody;
  final int? statusCode;
  final int? businessCode;
  final String? message;
  final int? durationMs;
  final String? error;
  final bool isError;
  final bool completed;

  NetworkLogEntry copyWith({
    dynamic responseBody = _unset,
    int? statusCode,
    int? businessCode,
    String? message,
    int? durationMs,
    String? error,
    bool? isError,
    bool? completed,
  }) {
    return NetworkLogEntry(
      id: id,
      method: method,
      url: url,
      path: path,
      startedAt: startedAt,
      query: query,
      requestBody: requestBody,
      requestHeaders: requestHeaders,
      responseBody: responseBody == _unset ? this.responseBody : responseBody,
      statusCode: statusCode ?? this.statusCode,
      businessCode: businessCode ?? this.businessCode,
      message: message ?? this.message,
      durationMs: durationMs ?? this.durationMs,
      error: error ?? this.error,
      isError: isError ?? this.isError,
      completed: completed ?? this.completed,
    );
  }
}

const _unset = Object();

class NetworkDebugStore extends ChangeNotifier {
  NetworkDebugStore._();

  static final NetworkDebugStore instance = NetworkDebugStore._();

  static const int _maxEntries = 200;
  static const bool _envEnabled = bool.fromEnvironment(
    'NETWORK_DEBUG_LOG',
    defaultValue: true,
  );

  bool get enabled => _envEnabled;
  bool _floatingEntryVisible = false;

  bool get floatingEntryVisible => enabled && _floatingEntryVisible;

  final List<NetworkLogEntry> _entries = <NetworkLogEntry>[];

  UnmodifiableListView<NetworkLogEntry> get entries =>
      UnmodifiableListView(_entries);

  void clear() {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
  }

  void showFloatingEntry() {
    if (!enabled || _floatingEntryVisible) return;
    _floatingEntryVisible = true;
    notifyListeners();
  }

  void hideFloatingEntry() {
    if (!_floatingEntryVisible) return;
    _floatingEntryVisible = false;
    notifyListeners();
  }

  void onRequest(RequestOptions options) {
    if (!enabled) return;
    final id = options.extra['_debugRequestId']?.toString();
    if (id == null || id.isEmpty) return;

    final entry = NetworkLogEntry(
      id: id,
      method: options.method.toUpperCase(),
      url: options.uri.toString(),
      path: options.path,
      startedAt: DateTime.now(),
      query: _sanitizeMap(options.queryParameters),
      requestBody: _sanitizeAny(options.data),
      requestHeaders: _sanitizeHeaders(options.headers),
    );

    _entries.insert(0, entry);
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    notifyListeners();
  }

  void onResponse(Response<dynamic> response) {
    if (!enabled) return;
    final options = response.requestOptions;
    final id = options.extra['_debugRequestId']?.toString();
    if (id == null || id.isEmpty) return;

    final durationMs = _durationFromOptions(options);
    final payload = response.data;
    int? businessCode;
    String? message;
    if (payload is Map<String, dynamic>) {
      final code = payload['code'];
      if (code is int) {
        businessCode = code;
      } else if (code is String) {
        businessCode = int.tryParse(code);
      }
      final msg = payload['msg'];
      if (msg != null) {
        message = msg.toString();
      }
    }

    _updateEntry(
      id,
      (old) => old.copyWith(
        responseBody: _sanitizeAny(payload),
        statusCode: response.statusCode,
        businessCode: businessCode,
        message: message,
        durationMs: durationMs,
        isError: false,
        completed: true,
      ),
    );
  }

  void onError(DioException error) {
    if (!enabled) return;
    final options = error.requestOptions;
    final id = options.extra['_debugRequestId']?.toString();
    if (id == null || id.isEmpty) return;

    final durationMs = _durationFromOptions(options);
    _updateEntry(
      id,
      (old) => old.copyWith(
        statusCode: error.response?.statusCode,
        responseBody: _sanitizeAny(error.response?.data),
        error: error.message,
        durationMs: durationMs,
        isError: true,
        completed: true,
      ),
    );
  }

  void _updateEntry(String id, NetworkLogEntry Function(NetworkLogEntry old) f) {
    final index = _entries.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _entries[index] = f(_entries[index]);
    notifyListeners();
  }

  int? _durationFromOptions(RequestOptions options) {
    final startMs = options.extra['_debugStartMs'];
    if (startMs is int) {
      return DateTime.now().millisecondsSinceEpoch - startMs;
    }
    return null;
  }

  Map<String, dynamic>? _sanitizeMap(Map<String, dynamic>? input) {
    if (input == null || input.isEmpty) return null;
    final result = <String, dynamic>{};
    input.forEach((key, value) {
      result[key] = _sanitizeByKey(key, value);
    });
    return result;
  }

  Map<String, dynamic>? _sanitizeHeaders(Map<String, dynamic> input) {
    if (input.isEmpty) return null;
    final result = <String, dynamic>{};
    input.forEach((key, value) {
      result[key] = _sanitizeByKey(key, value);
    });
    return result;
  }

  dynamic _sanitizeAny(dynamic value) {
    if (value is Map) {
      final mapped = <String, dynamic>{};
      value.forEach((k, v) {
        final key = k.toString();
        mapped[key] = _sanitizeByKey(key, v);
      });
      return mapped;
    }
    if (value is List) {
      return value.map(_sanitizeAny).toList();
    }
    return value;
  }

  dynamic _sanitizeByKey(String key, dynamic value) {
    final lowered = key.toLowerCase();
    if (lowered.contains('token') ||
        lowered.contains('password') ||
        lowered.contains('phone')) {
      return '***';
    }
    return _sanitizeAny(value);
  }
}

String prettyJson(dynamic value) {
  if (value == null) return '';
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return value;
    }
  }
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}