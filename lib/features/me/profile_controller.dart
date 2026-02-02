import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/personal_info.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class ProfileState {
  final bool loading;
  final bool updating;
  final PersonalInfo? info;
  final int unreadMessageCount;

  const ProfileState({
    this.loading = false,
    this.updating = false,
    this.info,
    this.unreadMessageCount = 0,
  });

  ProfileState copyWith({
    bool? loading,
    bool? updating,
    PersonalInfo? info,
    int? unreadMessageCount,
  }) {
    return ProfileState(
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      info: info ?? this.info,
      unreadMessageCount: unreadMessageCount ?? this.unreadMessageCount,
    );
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

class ProfileNotifier extends Notifier<ProfileState> {
  final ApiService _api = ApiService();

  @override
  ProfileState build() => const ProfileState();

  /// 获取个人信息
  Future<void> loadProfile() async {
    state = state.copyWith(loading: true);
    final response = await _api.get<PersonalInfo?>(
      ApiPath.accountDetail,
      parser: (json) => json == null
          ? null
          : PersonalInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, info: response.result);
  }

  /// 获取未读消息数量
  Future<void> loadUnreadMessageCount() async {
    final response = await _api.get<int>(
      ApiPath.messageGetUnReadCount,
      parser: (json) => json is num ? json.toInt() : 0,
      showHud: false,
    );
    state = state.copyWith(unreadMessageCount: response.result ?? 0);
  }

  /// 修改昵称
  Future<bool> changeNickName(String nickName) async {
    if (nickName.trim().isEmpty) return false;
    state = state.copyWith(updating: true);
    final response = await _api.post<Object>(
      ApiPath.accountChangeNickName,
      data: {'nickName': nickName.trim()},
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);
    if (response.isSuccess && state.info != null) {
      // 更新本地状态
      state = state.copyWith(
        info: PersonalInfo(
          accountNo: state.info!.accountNo,
          workNo: state.info!.workNo,
          username: state.info!.username,
          phone: state.info!.phone,
          status: state.info!.status,
          showStatus: state.info!.showStatus,
          avatarUrl: state.info!.avatarUrl,
          nickName: nickName.trim(),
          userId: state.info!.userId,
        ),
      );
    }
    return response.isSuccess;
  }

  /// 修改头像
  Future<bool> changeAvatar(String filePath) async {
    if (filePath.isEmpty) return false;
    state = state.copyWith(updating: true);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _api.postForm<Object>(
      ApiPath.accountChangeAvatar,
      data: formData,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);
    if (response.isSuccess) {
      // 重新加载个人信息以获取新头像URL
      await loadProfile();
    }
    return response.isSuccess;
  }

  /// 刷新全部
  Future<void> refresh() async {
    await Future.wait([loadProfile(), loadUnreadMessageCount()]);
  }
}
