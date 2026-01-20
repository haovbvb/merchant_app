import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/sn_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class BluetoothAuthState {
  final bool loadingLock;
  final bool loadingUid;
  final bool submitting;
  final SNBean? lockInfo;
  final String? uid;

  const BluetoothAuthState({
    this.loadingLock = false,
    this.loadingUid = false,
    this.submitting = false,
    this.lockInfo,
    this.uid,
  });

  BluetoothAuthState copyWith({
    bool? loadingLock,
    bool? loadingUid,
    bool? submitting,
    SNBean? lockInfo,
    String? uid,
  }) {
    return BluetoothAuthState(
      loadingLock: loadingLock ?? this.loadingLock,
      loadingUid: loadingUid ?? this.loadingUid,
      submitting: submitting ?? this.submitting,
      lockInfo: lockInfo ?? this.lockInfo,
      uid: uid ?? this.uid,
    );
  }
}

final bluetoothAuthProvider =
    NotifierProvider<BluetoothAuthNotifier, BluetoothAuthState>(
  BluetoothAuthNotifier.new,
);

class BluetoothAuthNotifier extends Notifier<BluetoothAuthState> {
  final ApiService _api = ApiService();

  @override
  BluetoothAuthState build() => const BluetoothAuthState();

  Future<void> queryLockId(String sn) async {
    if (sn.isEmpty) return;
    state = state.copyWith(loadingLock: true);
    final response = await _api.get<SNBean>(
      ApiPath.bluetoothGetLockIdBySn,
      queryParameters: {'sn': sn},
      parser: (json) => SNBean.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loadingLock: false, lockInfo: response.result);
  }

  Future<void> queryUid(String phone) async {
    if (phone.isEmpty) return;
    state = state.copyWith(loadingUid: true);
    final response = await _api.get<String>(
      ApiPath.bluetoothGetUidByPhone,
      queryParameters: {'phone': phone},
      parser: (json) => json?.toString() ?? '',
    );
    state = state.copyWith(loadingUid: false, uid: response.result);
  }

  Future<bool> authorize({
    required String sn,
    required String phone,
    required String keyId,
    required int days,
  }) async {
    final lockInfo = state.lockInfo;
    if (sn.isEmpty || phone.isEmpty || keyId.isEmpty || lockInfo == null) {
      return false;
    }
    final safeDays = days <= 0 ? 1 : days;
    final now = DateTime.now();
    final begin = now.subtract(const Duration(hours: 1));
    final end = now.add(Duration(days: safeDays));

    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.bluetoothAuthAdd,
      data: {
        'phone': phone,
        'lockIcId': lockInfo.lockIcId,
        'lockDevId': lockInfo.lockDevId,
        'keyId': keyId,
        'authBegTime': begin.millisecondsSinceEpoch,
        'authEndTime': end.millisecondsSinceEpoch,
        'sn': sn,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }
}
