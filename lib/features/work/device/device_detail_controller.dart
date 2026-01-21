import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/charge_history.dart';
import 'package:merchant_app/data/models/charge_history_response.dart';
import 'package:merchant_app/data/models/device_fix_record_response.dart';
import 'package:merchant_app/data/models/maintenance.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class DeviceDetailState {
  final bool loading;
  final bool historyLoading;
  final bool toggling;
  final bool fixLoading;
  final bool maintenanceLoading;
  final bool portsLoading;
  final String sn;
  final int deviceType;
  final BatteryDetail? batteryDetail;
  final VehicleDetail? vehicleDetail;
  final CabinetDetailBaseInfoBean? cabinetDetail;
  final List<ChargeHistory> histories;
  final List<DeviceFixRecord> fixRecords;
  final List<MaintenanceRecord> maintenanceRecords;
  final List<Cabin> cabinPorts;
  final int total;

  const DeviceDetailState({
    this.loading = false,
    this.historyLoading = false,
    this.toggling = false,
    this.fixLoading = false,
    this.maintenanceLoading = false,
    this.portsLoading = false,
    this.sn = '',
    this.deviceType = 1,
    this.batteryDetail,
    this.vehicleDetail,
    this.cabinetDetail,
    this.histories = const [],
    this.fixRecords = const [],
    this.maintenanceRecords = const [],
    this.cabinPorts = const [],
    this.total = 0,
  });

  DeviceDetailState copyWith({
    bool? loading,
    bool? historyLoading,
    bool? toggling,
    bool? fixLoading,
    bool? maintenanceLoading,
    bool? portsLoading,
    String? sn,
    int? deviceType,
    BatteryDetail? batteryDetail,
    VehicleDetail? vehicleDetail,
    CabinetDetailBaseInfoBean? cabinetDetail,
    List<ChargeHistory>? histories,
    List<DeviceFixRecord>? fixRecords,
    List<MaintenanceRecord>? maintenanceRecords,
    List<Cabin>? cabinPorts,
    int? total,
  }) {
    return DeviceDetailState(
      loading: loading ?? this.loading,
      historyLoading: historyLoading ?? this.historyLoading,
      toggling: toggling ?? this.toggling,
      fixLoading: fixLoading ?? this.fixLoading,
      maintenanceLoading: maintenanceLoading ?? this.maintenanceLoading,
      portsLoading: portsLoading ?? this.portsLoading,
      sn: sn ?? this.sn,
      deviceType: deviceType ?? this.deviceType,
      batteryDetail: batteryDetail ?? this.batteryDetail,
      vehicleDetail: vehicleDetail ?? this.vehicleDetail,
      cabinetDetail: cabinetDetail ?? this.cabinetDetail,
      histories: histories ?? this.histories,
      fixRecords: fixRecords ?? this.fixRecords,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
      cabinPorts: cabinPorts ?? this.cabinPorts,
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
    await searchDevice(sn: sn, deviceType: 1);
  }

  Future<void> searchDevice({required String sn, required int deviceType}) async {
    final value = sn.trim();
    if (value.isEmpty) return;
    state = state.copyWith(
      loading: true,
      sn: value,
      deviceType: deviceType,
      batteryDetail: null,
      vehicleDetail: null,
      cabinetDetail: null,
      histories: const [],
      fixRecords: const [],
      maintenanceRecords: const [],
      cabinPorts: const [],
      total: 0,
    );

    if (deviceType == 2) {
      final response = await _api.get<VehicleDetail?>(
        ApiPath.vehicleGetDetail,
        queryParameters: {'sn': value},
        parser: (json) => json == null
            ? null
            : VehicleDetail.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      state = state.copyWith(loading: false, vehicleDetail: response.result);
      await loadFixRecords(sn: value, deviceType: deviceType);
      await loadMaintenanceRecords(sn: value);
      return;
    }

    if (deviceType == 3) {
      final response = await _api.get<CabinetDetailBaseInfoBean?>(
        ApiPath.cabinetBaseInfo,
        queryParameters: {'sn': value},
        parser: (json) => json == null
            ? null
            : CabinetDetailBaseInfoBean.fromJson(
                Map<String, dynamic>.from(json as Map),
              ),
      );
      state = state.copyWith(loading: false, cabinetDetail: response.result);
      await loadCabinPorts(sn: value);
      await loadFixRecords(sn: value, deviceType: deviceType);
      return;
    }

    final response = await _api.get<BatteryDetail?>(
      ApiPath.batterySearchBySn,
      queryParameters: {'sn': value},
      parser: (json) => json == null
          ? null
          : BatteryDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, batteryDetail: response.result);
    await loadChargeHistory(sn: value);
    await loadFixRecords(sn: value, deviceType: deviceType);
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

  Future<void> loadFixRecords({String? sn, int? deviceType}) async {
    final value = (sn ?? state.sn).trim();
    if (value.isEmpty) return;
    final type = deviceType ?? state.deviceType;
    String path = ApiPath.batteryQueryFixList;
    if (type == 2) {
      path = ApiPath.carQueryFixList;
    } else if (type == 3) {
      path = ApiPath.cabinetQueryFixList;
    }
    state = state.copyWith(fixLoading: true);
    final response = await _api.get<DeviceFixRecordResponse>(
      path,
      queryParameters: {
        'sn': value,
        'pageNum': 1,
        'pageSize': 20,
      },
      parser: (json) => DeviceFixRecordResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
      showHud: false,
    );
    state = state.copyWith(
      fixLoading: false,
      fixRecords: response.result?.list ?? const [],
    );
  }

  Future<void> loadMaintenanceRecords({String? sn}) async {
    final value = (sn ?? state.sn).trim();
    if (value.isEmpty) return;
    state = state.copyWith(maintenanceLoading: true);
    final response = await _api.get<DeviceMaintenanceResponse>(
      ApiPath.carQueryMaintainList,
      queryParameters: {
        'sn': value,
        'pageNum': 1,
        'pageSize': 20,
      },
      parser: (json) => DeviceMaintenanceResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
      showHud: false,
    );
    state = state.copyWith(
      maintenanceLoading: false,
      maintenanceRecords: response.result?.list ?? const [],
    );
  }

  Future<void> loadCabinPorts({String? sn}) async {
    final value = (sn ?? state.sn).trim();
    if (value.isEmpty) return;
    state = state.copyWith(portsLoading: true);
    final response = await _api.get<List<Cabin>>(
      ApiPath.cabinetPortDetail,
      queryParameters: {'sn': value},
      parser: (json) => (json as List<dynamic>?)
              ?.map(
                (item) => Cabin.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <Cabin>[],
      showHud: false,
    );
    state = state.copyWith(
      portsLoading: false,
      cabinPorts: response.result ?? const [],
    );
  }

  Future<bool> toggleDischargeStatus() async {
    final detail = state.batteryDetail;
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
        batteryDetail: BatteryDetail(
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

  Future<bool> openCabinDoor({required int port}) async {
    final value = state.sn.trim();
    if (value.isEmpty) return false;
    final response = await _api.post<Object>(
      ApiPath.cabinetCtrlPort,
      data: {
        'sn': value,
        'port': port,
      },
      parser: (json) => json ?? Object(),
    );
    return response.isSuccess;
  }

  Future<bool> openCabinBackDoor() async {
    final value = state.sn.trim();
    if (value.isEmpty) return false;
    final response = await _api.post<Object>(
      ApiPath.cabinetOpenBackDoor,
      data: {'sn': value},
      parser: (json) => json ?? Object(),
    );
    return response.isSuccess;
  }
}
