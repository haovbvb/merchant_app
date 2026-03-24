import 'package:dio/dio.dart';

import 'network_exceptions.dart';

class RequestExecutor {
  const RequestExecutor._();

  static Future<Response<dynamic>> get(
    Dio dio,
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: _buildOptions(extra: extra),
      );
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  static Future<Response<dynamic>> post(
    Dio dio,
    String path, {
    dynamic data,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        options: _buildOptions(extra: extra),
      );
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  static Future<Response<dynamic>> put(
    Dio dio,
    String path, {
    dynamic data,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        options: _buildOptions(extra: extra),
      );
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  static Future<Response<dynamic>> postForm(
    Dio dio,
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
    Map<String, dynamic>? extra,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        onSendProgress: onSendProgress,
        options: _buildOptions(
          contentType: 'multipart/form-data',
          extra: extra,
        ),
      );
    } catch (error) {
      throw NetworkExceptions.fromDioException(error);
    }
  }

  static Options _buildOptions({
    String? contentType,
    Map<String, dynamic>? extra,
  }) {
    return Options(
      contentType: contentType,
      extra: extra,
    );
  }
}
