import 'package:dio/dio.dart';

class NetworkExceptions implements Exception {
  NetworkExceptions(this.message);

  final String message;

  static bool _containsAny(String value, List<String> needles) {
    for (final item in needles) {
      if (value.contains(item)) {
        return true;
      }
    }
    return false;
  }

  static NetworkExceptions fromDioException(dynamic error) {
    if (error is DioException) {
      final rawMessage = (error.message ?? '').toLowerCase();
      final rawError = (error.error?.toString() ?? '').toLowerCase();
      final merged = '$rawMessage $rawError';

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return NetworkExceptions('连接超时');
        case DioExceptionType.receiveTimeout:
          return NetworkExceptions('响应超时');
        case DioExceptionType.sendTimeout:
          return NetworkExceptions('请求超时');
        case DioExceptionType.badResponse:
          return NetworkExceptions('服务器返回错误: ${error.response?.statusCode}');
        case DioExceptionType.cancel:
          return NetworkExceptions('请求已取消');
        case DioExceptionType.unknown:
          if (_containsAny(merged, const ['handshakeexception', 'ssl', 'tls', 'certificate'])) {
            return NetworkExceptions('SSL/TLS 握手失败，请检查网络、系统时间或证书配置');
          }
          if (_containsAny(merged, const ['socketexception', 'failed host lookup'])) {
            return NetworkExceptions('网络连接失败，请检查网络后重试');
          }
          final detail = error.error?.toString() ?? error.message ?? 'unknown';
          return NetworkExceptions('未知错误: $detail');
        default:
          return NetworkExceptions('网络错误');
      }
    }
    return NetworkExceptions('未知错误: $error');
  }

  @override
  String toString() => message;
}
