import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/authorization_record_list.dart';
import 'package:merchant_app/data/models/cabinet_authorization_list.dart';
import 'package:merchant_app/data/models/user_authorization_list.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetAuthorizationState {
  final bool loadingCabinet;
  final bool loadingUsers;
  final bool loadingRecords;
  final bool submitting;
  final CabinetAuthorizationList? cabinetList;
  final UserAuthorizationList? userList;
  final AuthorizationRecordList? recordList;

  const CabinetAuthorizationState({
    this.loadingCabinet = false,
    this.loadingUsers = false,
    this.loadingRecords = false,
    this.submitting = false,
    this.cabinetList,
    this.userList,
    this.recordList,
  });

  CabinetAuthorizationState copyWith({
    bool? loadingCabinet,
    bool? loadingUsers,
    bool? loadingRecords,
    bool? submitting,
    CabinetAuthorizationList? cabinetList,
    UserAuthorizationList? userList,
    AuthorizationRecordList? recordList,
  }) {
    return CabinetAuthorizationState(
      loadingCabinet: loadingCabinet ?? this.loadingCabinet,
      loadingUsers: loadingUsers ?? this.loadingUsers,
      loadingRecords: loadingRecords ?? this.loadingRecords,
      submitting: submitting ?? this.submitting,
      cabinetList: cabinetList ?? this.cabinetList,
      userList: userList ?? this.userList,
      recordList: recordList ?? this.recordList,
    );
  }
}

final cabinetAuthorizationProvider =
    NotifierProvider<CabinetAuthorizationNotifier, CabinetAuthorizationState>(
  CabinetAuthorizationNotifier.new,
);

class CabinetAuthorizationNotifier extends Notifier<CabinetAuthorizationState> {
  final ApiService _api = ApiService();

  @override
  CabinetAuthorizationState build() => const CabinetAuthorizationState();

  Future<void> queryCabinets(String sn, {int page = 1, int size = 20}) async {
    if (sn.isEmpty) return;
    state = state.copyWith(loadingCabinet: true);
    final response = await _api.get<CabinetAuthorizationList>(
      ApiPath.stationQueryListBySn,
      queryParameters: {
        'sn': sn,
        'pageNum': page,
        'pageSize': size,
      },
      parser: (json) => CabinetAuthorizationList.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingCabinet: false,
      cabinetList: response.result,
    );
  }

  Future<void> queryUsers(
    String sn,
    String keyword, {
    int page = 1,
    int size = 20,
  }) async {
    if (sn.isEmpty) return;
    state = state.copyWith(loadingUsers: true);
    final response = await _api.get<UserAuthorizationList>(
      ApiPath.accountQueryBePermissionList,
      queryParameters: {
        'sn': sn,
        'keyword': keyword,
        'pageNum': page,
        'pageSize': size,
      },
      parser: (json) => UserAuthorizationList.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingUsers: false,
      userList: response.result,
    );
  }

  Future<void> queryRecords(
    String sn,
    String bePermission, {
    int page = 1,
    int size = 20,
  }) async {
    if (sn.isEmpty) return;
    state = state.copyWith(loadingRecords: true);
    final response = await _api.get<AuthorizationRecordList>(
      ApiPath.stationQueryPermission,
      queryParameters: {
        'sn': sn,
        'bePermission': bePermission,
        'pageNum': page,
        'pageSize': size,
      },
      parser: (json) => AuthorizationRecordList.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingRecords: false,
      recordList: response.result,
    );
  }

  Future<bool> authorize({
    required String sn,
    required String accountNo,
    required String beginTime,
    required String endTime,
  }) async {
    if (sn.isEmpty || accountNo.isEmpty) return false;
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.stationPermission,
      data: {
        'sn': sn,
        'accountNo': accountNo,
        'beginTime': beginTime,
        'endTime': endTime,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }

  Future<bool> cancelPermission({
    required String sn,
    required int permissionId,
  }) async {
    if (sn.isEmpty || permissionId <= 0) return false;
    final response = await _api.post<Object>(
      ApiPath.stationCancelPermission,
      data: {
        'sn': sn,
        'permissionId': permissionId,
      },
      parser: (json) => json ?? Object(),
    );
    return response.isSuccess;
  }
}
