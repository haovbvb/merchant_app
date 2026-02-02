import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 摄像头操作状态
class CameraOperationState {
  final bool loading;
  final bool verified;
  final String? message;

  const CameraOperationState({
    this.loading = false,
    this.verified = false,
    this.message,
  });

  CameraOperationState copyWith({
    bool? loading,
    bool? verified,
    String? message,
  }) {
    return CameraOperationState(
      loading: loading ?? this.loading,
      verified: verified ?? this.verified,
      message: message ?? this.message,
    );
  }
}

final cameraOperationProvider =
    NotifierProvider<CameraOperationNotifier, CameraOperationState>(
      CameraOperationNotifier.new,
    );

class CameraOperationNotifier extends Notifier<CameraOperationState> {
  final ApiService _api = ApiService();

  @override
  CameraOperationState build() => const CameraOperationState();

  /// 验证电柜位置绑定
  Future<bool> verifyStationLocation({
    required String sn,
    required double latitude,
    required double longitude,
  }) async {
    if (sn.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.post<Object>(
      ApiPath.cameraVerifyBound,
      data: {'sn': sn, 'latitude': latitude, 'longitude': longitude},
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(
      loading: false,
      verified: response.isSuccess,
      message: response.message,
    );
    return response.isSuccess;
  }

  /// 解绑设备
  Future<bool> unbindDevice(String sn) async {
    if (sn.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.post<Object>(
      ApiPath.cameraUnbind,
      data: {'sn': sn},
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(loading: false, message: response.message);
    return response.isSuccess;
  }

  void clear() {
    state = const CameraOperationState();
  }
}
