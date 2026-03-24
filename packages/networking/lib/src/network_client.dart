import 'package:dio/dio.dart';
import 'package:foundation/foundation.dart';

class NetworkClient {
  NetworkClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.interceptors.add(_NetworkDebugInterceptor());
  }

  final Dio _dio;

  Dio get raw => _dio;
}

class _NetworkDebugInterceptor extends Interceptor {
  static const String _requestIdKey = '_debugRequestId';
  static const String _startMsKey = '_debugStartMs';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final now = DateTime.now();
    final id = _buildRequestId(now, options);
    options.extra[_requestIdKey] = id;
    options.extra[_startMsKey] = now.millisecondsSinceEpoch;

    NetworkDebugStore.instance.onRequest(
      id: id,
      method: options.method,
      url: options.uri.toString(),
      path: options.path,
      startedAt: now,
      query: _toStringDynamicMap(options.queryParameters),
      requestBody: options.data,
      requestHeaders: _toStringDynamicMap(options.headers),
    );

    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final id = options.extra[_requestIdKey]?.toString();
    if (id != null && id.isNotEmpty) {
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

      NetworkDebugStore.instance.onResponse(
        id: id,
        statusCode: response.statusCode,
        businessCode: businessCode,
        message: message,
        durationMs: _durationFromOptions(options),
        responseBody: payload,
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final id = options.extra[_requestIdKey]?.toString();
    if (id != null && id.isNotEmpty) {
      NetworkDebugStore.instance.onError(
        id: id,
        statusCode: err.response?.statusCode,
        responseBody: err.response?.data,
        error: err.message,
        durationMs: _durationFromOptions(options),
      );
    }

    handler.next(err);
  }

  String _buildRequestId(DateTime now, RequestOptions options) {
    final micros = now.microsecondsSinceEpoch;
    final pathHash = options.path.hashCode.abs();
    return '$micros-$pathHash';
  }

  int? _durationFromOptions(RequestOptions options) {
    final startMs = options.extra[_startMsKey];
    if (startMs is int) {
      return DateTime.now().millisecondsSinceEpoch - startMs;
    }
    return null;
  }

  Map<String, dynamic>? _toStringDynamicMap(Map<dynamic, dynamic>? input) {
    if (input == null || input.isEmpty) return null;
    return input.map((key, value) => MapEntry(key.toString(), value));
  }
}
