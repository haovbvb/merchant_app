import 'package:merchant_app/network/api_service.dart';
import 'package:merchant_app/network/base_response.dart';
import 'package:mocktail/mocktail.dart';

/// Mock ApiService for testing
class MockApiService extends Mock implements ApiService {}

/// Helper to create success response
BaseResponse<T> successResponse<T>(T data) {
  return BaseResponse<T>(
    code: 200,
    message: 'success',
    result: data,
  );
}

/// Helper to create error response
BaseResponse<T> errorResponse<T>({
  int code = 500,
  String message = 'error',
}) {
  return BaseResponse<T>(
    code: code,
    message: message,
    result: null,
  );
}
