import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class BluetoothOperateState {
  final bool processing;

  const BluetoothOperateState({this.processing = false});

  BluetoothOperateState copyWith({bool? processing}) {
    return BluetoothOperateState(processing: processing ?? this.processing);
  }
}

final bluetoothOperateProvider =
    NotifierProvider<BluetoothOperateNotifier, BluetoothOperateState>(
  BluetoothOperateNotifier.new,
);

class BluetoothOperateNotifier extends Notifier<BluetoothOperateState> {
  final ApiService _api = ApiService();

  @override
  BluetoothOperateState build() => const BluetoothOperateState();

  Future<String?> enOrDecrypt({
    required String payload,
    required bool isEncrypt,
  }) async {
    state = state.copyWith(processing: true);
    final response = await _api.postForm<String>(
      ApiPath.bluetoothEnOrDecrypt,
      data: FormData.fromMap({
        'str': payload,
        'isEncrypt': isEncrypt,
      }),
      parser: (json) => json?.toString() ?? '',
      showHud: false,
      notifyOnError: true,
    );
    state = state.copyWith(processing: false);
    return response.isSuccess ? response.result : null;
  }

  Future<bool> authAdd({
    required String phone,
    required String keyId,
    required String lockIcId,
    required String lockDevId,
    required String sn,
    required int authBegTime,
    required int authEndTime,
  }) async {
    state = state.copyWith(processing: true);
    final response = await _api.post<Object>(
      ApiPath.bluetoothAuthAdd,
      data: {
        'phone': phone,
        'lockIcId': lockIcId.isEmpty ? 0 : lockIcId,
        'keyId': keyId,
        'authBegTime': authBegTime,
        'authEndTime': authEndTime,
        'lockDevId': lockDevId.isEmpty ? 0 : lockDevId,
        'sn': sn,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(processing: false);
    return response.isSuccess;
  }
}
