import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/charge_history.dart';
import 'package:merchant_app/data/models/charge_history_response.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class DeviceDetailState {
  final bool loading;
  final bool historyLoading;
  final bool toggling;
  final String sn;
  final BatteryDetail? detail;
  final List<ChargeHistory> histories;
  final int total;

  const DeviceDetailState({
    this.loading = false,
    this.historyLoading = false,
    this.toggling = false,
    this.sn = '',
    this.detail,
    this.histories = const [],
    this.total = 0,
  });

  DeviceDetailState copyWith({
    bool? loading,
    bool? historyLoading,
    bool? toggling,
    String? sn,
    BatteryDetail? detail,
    List<ChargeHistory>? histories,
    int? total,
  }) {
    return DeviceDetailState(
      loading: loading ?? this.loading,
      historyLoading: historyLoading ?? this.historyLoading,
      toggling: toggling ?? this.toggling,
      sn: sn ?? this.sn,
      detail: detail ?? this.detail,
      histories: histories ?? this.histories,
      total: total ?? this.total,
    );
  }
}

final deviceDetailProvider =
    NotifierProvider<DeviceDetailNotifier, DeviceDetailState>(
  DeviceDetailNotifier.new,
);

class DeviceDetailNotifier extends Notifier<DeviceDetailState> {
  final ApiService _api = ApiService();

  @override
  DeviceDetailState build() => const DeviceDetailState();

  Future<void> searchBattery(String sn) async {
    if (sn.trim().isEmpty) return;
    state = state.copyWith(loading: true, sn: sn.trim());
    final response = await _api.get<BatteryDetail?>(
      ApiPath.batterySearchBySn,
      queryParameters: {'sn': sn.trim()},
      parser: (json) => json == null
          ? null
          : BatteryDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, detail: response.result);
    await loadChargeHistory(sn: sn.trim());
  }

  Future<void> loadChargeHistory({String? sn}) async {
    final value = (sn ?? state.sn).trim();
    if (value.isEmpty) return;
    state = state.copyWith(historyLoading: true, sn: value);
    final response = await _api.get<ChargeHistoryResponse>(
      ApiPath.batteryQueryDeviceChargeRecord,
      queryParameters: {
        'sn': value,
        'pageNum': 1,
        'pageSize': 20,
      },
      parser: (json) => ChargeHistoryResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
      showHud: false,
    );
    final result = response.result;
    state = state.copyWith(
      historyLoading: false,
      histories: result?.list ?? const [],
      total: result?.total ?? 0,
    );
  }

  Future<bool> toggleDischargeStatus() async {
    final detail = state.detail;
    if (detail == null || state.sn.trim().isEmpty) return false;
    final current = detail.status ?? 0;
    final nextStatus = current == 1 ? 0 : 1;
    state = state.copyWith(toggling: true);
    final response = await _api.post<Object>(
      ApiPath.batteryTurnDischargeStatus,
      data: {
        'sn': state.sn.trim(),
        'status': nextStatus,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(toggling: false);
    if (response.isSuccess) {
      state = state.copyWith(
        detail: BatteryDetail(
          avgSpeed: detail.avgSpeed,
          color: detail.color,
          cycle: detail.cycle,
          deviceSn: detail.deviceSn,
          img: detail.img,
          latitude: detail.latitude,
          longitude: detail.longitude,
          mile: detail.mile,
          online: detail.online,
          operationDate: detail.operationDate,
          signalTime: detail.signalTime,
          soc: detail.soc,
          status: nextStatus,
          todayMile: detail.todayMile,
        ),
      );
    }
    return response.isSuccess;
  }
}
