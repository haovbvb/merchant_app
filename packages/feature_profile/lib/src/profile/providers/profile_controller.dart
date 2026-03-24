import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:networking/networking.dart';

import '../models/personal_info.dart';
import '../profile_api_path.dart';

class ProfileState {
  const ProfileState({
    this.loading = false,
    this.updating = false,
    this.info,
    this.unreadMessageCount = 0,
  });

  final bool loading;
  final bool updating;
  final PersonalInfo? info;
  final int unreadMessageCount;

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
  static const int _nickNameMaxLength = 15;

  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(loading: true);
    final response = await _api.get<PersonalInfo?>(
      ProfileApiPath.urlOf(ProfileApiPath.accountDetail),
      parser: (json) => json == null
          ? null
          : PersonalInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, info: response.result);
  }

  Future<void> loadUnreadMessageCount() async {
    final response = await _api.get<int>(
      ProfileApiPath.urlOf(ProfileApiPath.messageGetUnReadCount),
      parser: (json) => json is num ? json.toInt() : 0,
      showHud: false,
    );
    state = state.copyWith(unreadMessageCount: response.result ?? 0);
  }

  Future<bool> changeNickName(String nickName) async {
    final normalized = nickName.trim();
    if (normalized.isEmpty) return false;
    final limited = normalized.length > _nickNameMaxLength
        ? normalized.substring(0, _nickNameMaxLength)
        : normalized;

    state = state.copyWith(updating: true);
    final response = await _api.post<Object>(
      ProfileApiPath.urlOf(ProfileApiPath.accountChangeNickName),
      data: {'newNickName': limited},
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);

    if (response.isSuccess && state.info != null) {
      final current = state.info!;
      state = state.copyWith(
        info: PersonalInfo(
          accountNo: current.accountNo,
          workNo: current.workNo,
          username: current.username,
          phone: current.phone,
          status: current.status,
          showStatus: current.showStatus,
          avatarUrl: current.avatarUrl,
          nickName: limited,
          userId: current.userId,
        ),
      );
    }
    return response.isSuccess;
  }

  Future<bool> changeAvatar(String filePath) async {
    if (filePath.isEmpty) return false;

    state = state.copyWith(updating: true);
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _api.postForm<Object>(
      ProfileApiPath.urlOf(ProfileApiPath.accountChangeAvatar),
      data: formData,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);

    if (response.isSuccess) {
      await loadProfile();
    }
    return response.isSuccess;
  }

  Future<void> refresh() async {
    await Future.wait([loadProfile(), loadUnreadMessageCount()]);
  }
}
