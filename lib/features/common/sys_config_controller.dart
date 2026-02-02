import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/city.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 城市列表 Provider
final cityListProvider = FutureProvider<List<City>>((ref) async {
  final api = ApiService();
  final response = await api.get<List<dynamic>>(
    ApiPath.cityList,
    parser: (json) => (json as List<dynamic>?) ?? [],
    showHud: false,
  );
  return response.result
          ?.map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];
});

/// 城市编码列表 Provider
final cityCodesProvider = FutureProvider<List<City>>((ref) async {
  final api = ApiService();
  final response = await api.get<List<dynamic>>(
    ApiPath.cityCodes,
    parser: (json) => (json as List<dynamic>?) ?? [],
    showHud: false,
  );
  return response.result
          ?.map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];
});

/// 运维人员列表 Provider
final opsAccountListProvider = FutureProvider<List<OpsAccount>>((ref) async {
  final api = ApiService();
  final response = await api.get<List<dynamic>>(
    ApiPath.opsAccountList,
    parser: (json) => (json as List<dynamic>?) ?? [],
    showHud: false,
  );
  return response.result
          ?.map((e) => OpsAccount.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];
});

/// 系统配置控制器
class SysConfigState {
  final bool uploading;
  final String? uploadedUrl;

  const SysConfigState({this.uploading = false, this.uploadedUrl});

  SysConfigState copyWith({bool? uploading, String? uploadedUrl}) {
    return SysConfigState(
      uploading: uploading ?? this.uploading,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
    );
  }
}

final sysConfigProvider = NotifierProvider<SysConfigNotifier, SysConfigState>(
  SysConfigNotifier.new,
);

class SysConfigNotifier extends Notifier<SysConfigState> {
  final ApiService _api = ApiService();

  @override
  SysConfigState build() => const SysConfigState();

  /// 上传文件
  Future<String?> upload(String filePath) async {
    if (filePath.isEmpty) return null;
    state = state.copyWith(uploading: true);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _api.postForm<String>(
      ApiPath.sysUpload,
      data: formData,
      parser: (json) => json?.toString() ?? '',
    );

    state = state.copyWith(uploading: false);
    if (response.isSuccess) {
      final url = response.result;
      state = state.copyWith(uploadedUrl: url);
      return url;
    }
    return null;
  }

  /// 获取位置配置
  Future<Map<String, dynamic>?> getLocationConfig() async {
    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.sysConfigLocation,
      parser: (json) => Map<String, dynamic>.from(json as Map),
      showHud: false,
    );
    return response.result;
  }

  void clear() {
    state = const SysConfigState();
  }
}
