import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class UnbindDeviceState {
  final bool loading;
  final bool submitting;
  final String cardNum;
  final String deviceSn;
  final String checkRemark;
  final String remark;
  final bool hasUnfinishedOrder;
  final String appointmentNo;
  final String? errorMessage;

  const UnbindDeviceState({
    this.loading = false,
    this.submitting = false,
    this.cardNum = '',
    this.deviceSn = '',
    this.checkRemark = '',
    this.remark = '',
    this.hasUnfinishedOrder = false,
    this.appointmentNo = '',
    this.errorMessage,
  });

  UnbindDeviceState copyWith({
    bool? loading,
    bool? submitting,
    String? cardNum,
    String? deviceSn,
    String? checkRemark,
    String? remark,
    bool? hasUnfinishedOrder,
    String? appointmentNo,
    String? errorMessage,
  }) {
    return UnbindDeviceState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      cardNum: cardNum ?? this.cardNum,
      deviceSn: deviceSn ?? this.deviceSn,
      checkRemark: checkRemark ?? this.checkRemark,
      remark: remark ?? this.remark,
      hasUnfinishedOrder: hasUnfinishedOrder ?? this.hasUnfinishedOrder,
      appointmentNo: appointmentNo ?? this.appointmentNo,
      errorMessage: errorMessage,
    );
  }
}

final unbindDeviceProvider =
    NotifierProvider<UnbindDeviceNotifier, UnbindDeviceState>(
  UnbindDeviceNotifier.new,
);

class UnbindDeviceNotifier extends Notifier<UnbindDeviceState> {
  final ApiService _api = ApiService();

  @override
  UnbindDeviceState build() => const UnbindDeviceState();

  void updateCardNum(String value) {
    if (value == state.cardNum) return;
    state = state.copyWith(
      cardNum: value,
      hasUnfinishedOrder: false,
      appointmentNo: '',
    );
  }

  void updateDeviceSn(String value) {
    if (value == state.deviceSn) return;
    state = state.copyWith(
      deviceSn: value,
      hasUnfinishedOrder: false,
      appointmentNo: '',
    );
  }

  void updateCheckRemark(String value) {
    state = state.copyWith(checkRemark: value);
  }

  void updateRemark(String value) {
    state = state.copyWith(remark: value);
  }

  Future<void> checkUnfinishedOrder() async {
    if (state.cardNum.trim().isEmpty || state.deviceSn.trim().isEmpty) {
      state = state.copyWith(
        hasUnfinishedOrder: false,
        appointmentNo: '',
        errorMessage: null,
      );
      return;
    }
    state = state.copyWith(loading: true, errorMessage: null);
    final response = await _api.get<Object>(
      ApiPath.unbindCheckMaintainRecord,
      queryParameters: {
        'cardNum': state.cardNum.trim(),
        'vehicleSn': state.deviceSn.trim(),
      },
      parser: (json) => json ?? Object(),
      showHud: false,
    );

    if (!response.isSuccess) {
      state = state.copyWith(
        loading: false,
        hasUnfinishedOrder: false,
        appointmentNo: '',
        errorMessage: response.message,
      );
      return;
    }

    final value = response.result?.toString() ?? '';
    final hasUnfinished = value.isNotEmpty && value != '{}' && value != 'null';
    state = state.copyWith(
      loading: false,
      hasUnfinishedOrder: hasUnfinished,
      appointmentNo: hasUnfinished ? value : '',
      errorMessage: null,
    );
  }

  Future<bool> unbindDevice() async {
    if (state.submitting) return false;
    state = state.copyWith(submitting: true, errorMessage: null);
    final response = await _api.post<Object>(
      ApiPath.unbindDevice,
      data: {
        'sn': state.deviceSn.trim(),
        'cardNum': state.cardNum.trim(),
        'checkRemark': state.checkRemark.trim(),
        'remark': state.remark.trim(),
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(
      submitting: false,
      errorMessage: response.isSuccess ? null : response.message,
    );
    return response.isSuccess;
  }

  void clearForm() {
    state = const UnbindDeviceState();
  }
}
