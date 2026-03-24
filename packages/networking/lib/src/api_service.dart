import 'package:dio/dio.dart';

import 'models/base_response.dart';
import 'network_client.dart';
import 'network_exceptions.dart';
import 'request_executor.dart';

class ApiService {
  ApiService({NetworkClient? client}) : _client = client ?? NetworkClient();

  final NetworkClient _client;

  Future<BaseResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
    bool showHud = true,
    bool notifyOnError = true,
  }) async {
    try {
      final response = await RequestExecutor.get(
        _client.raw,
        path,
        queryParameters: queryParameters,
        extra: {
          'showHud': showHud,
          'notifyOnError': notifyOnError,
        },
      );
      return parseResponse(response, parser);
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  Future<BaseResponse<T>> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
    bool showHud = true,
    bool notifyOnError = true,
  }) async {
    try {
      final response = await RequestExecutor.post(
        _client.raw,
        path,
        data: data,
        extra: {
          'showHud': showHud,
          'notifyOnError': notifyOnError,
        },
      );
      return parseResponse(response, parser);
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  Future<BaseResponse<T>> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
    bool showHud = true,
    bool notifyOnError = true,
  }) async {
    try {
      final response = await RequestExecutor.put(
        _client.raw,
        path,
        data: data,
        extra: {
          'showHud': showHud,
          'notifyOnError': notifyOnError,
        },
      );
      return parseResponse(response, parser);
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  Future<BaseResponse<T>> postForm<T>(
    String path, {
    required FormData data,
    required T Function(dynamic json) parser,
    ProgressCallback? onSendProgress,
    bool showHud = true,
    bool notifyOnError = true,
  }) async {
    try {
      final response = await RequestExecutor.postForm(
        _client.raw,
        path,
        data: data,
        onSendProgress: onSendProgress,
        extra: {
          'showHud': showHud,
          'notifyOnError': notifyOnError,
        },
      );
      return parseResponse(response, parser);
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  static BaseResponse<T> parseResponse<T>(
    Response<dynamic> response,
    T Function(dynamic json) parser,
  ) {
    final payload = response.data;

    if (payload is Map<String, dynamic> && payload.containsKey('code')) {
      return BaseResponse.fromJson(payload, parser);
    }

    return BaseResponse.fromJson(
      {
        'code': response.statusCode ?? 0,
        'msg': response.statusMessage ?? '',
        'result': payload,
      },
      parser,
    );
  }
}
