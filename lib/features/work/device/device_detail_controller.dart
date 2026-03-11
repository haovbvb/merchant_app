import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/logger.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/charge_history.dart';
import 'package:merchant_app/data/models/charge_history_response.dart';
import 'package:merchant_app/data/models/device_fix_record_response.dart';
import 'package:merchant_app/data/models/device_search_result.dart';
import 'package:merchant_app/data/models/maintenance.dart';
import 'package:merchant_app/data/models/static_battery_mile.dart';
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
  final DeviceSearchResult? searchResult;
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
    this.searchResult,
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
    DeviceSearchResult? searchResult,
    bool clearSearchResult = false,
    BatteryDetail? batteryDetail,
    bool clearBatteryDetail = false,
    VehicleDetail? vehicleDetail,
    bool clearVehicleDetail = false,
    CabinetDetailBaseInfoBean? cabinetDetail,
    bool clearCabinetDetail = false,
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
        searchResult: clearSearchResult
          ? null
          : (searchResult ?? this.searchResult),
        batteryDetail: clearBatteryDetail
          ? null
          : (batteryDetail ?? this.batteryDetail),
        vehicleDetail: clearVehicleDetail
          ? null
          : (vehicleDetail ?? this.vehicleDetail),
        cabinetDetail: clearCabinetDetail
          ? null
          : (cabinetDetail ?? this.cabinetDetail),
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

  /// 通用设备搜索 - 对应 Android 的 commonSearch
  /// 先通过 SN 查询设备类型，再调用对应的详情接口
  Future<DeviceSearchResult?> commonSearch(String sn) async {
    final value = sn.trim();
    if (value.isEmpty) return null;

    state = state.copyWith(
      loading: true,
      sn: value,
      clearSearchResult: true,
      clearBatteryDetail: true,
      clearVehicleDetail: true,
      clearCabinetDetail: true,
      histories: const [],
      fixRecords: const [],
      maintenanceRecords: const [],
      cabinPorts: const [],
      total: 0,
    );

    final response = await _api.get<DeviceSearchResult?>(
      ApiPath.deviceCommonSearch,
      queryParameters: {'deviceSn': value},
      parser: (json) => json == null
          ? null
          : DeviceSearchResult.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    if (result == null) {
      state = state.copyWith(loading: false);
      logI('[DeviceDetail] commonSearch: 未找到设备 $value');
      return null;
    }

    logI('[DeviceDetail] commonSearch: 设备类型=${result.type}, sn=$value');
    state = state.copyWith(searchResult: result, deviceType: result.type ?? 1);

    // 根据设备类型加载详情
    final deviceType = result.type ?? 1;
    if (deviceType == 1) {
      // 电池
      await _loadBatteryDetail(value);
    } else if (deviceType == 2) {
      // 车辆
      await _loadVehicleDetailFromSearch(value, result.deviceInfo);
    } else if (deviceType == 3) {
      // 电柜
      await _loadCabinetDetail(value);
    }

    state = state.copyWith(loading: false);
    return result;
  }

  Future<void> _loadBatteryDetail(String sn) async {
    final response = await _api.get<BatteryDetail?>(
      ApiPath.batterySearchBySn,
      queryParameters: {'sn': sn},
      parser: (json) => json == null
          ? null
          : BatteryDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(batteryDetail: response.result);
    await loadChargeHistory(sn: sn);
    await loadFixRecords(sn: sn, deviceType: 1);
  }

  Future<void> _loadVehicleDetailFromSearch(
    String sn,
    DeviceInfo? info,
  ) async {
    if (info != null) {
      state = state.copyWith(vehicleDetail: _vehicleFromSearch(info));
    }

    await loadFixRecords(sn: sn, deviceType: 2);
    await loadMaintenanceRecords(sn: sn);
  }

  VehicleDetail _vehicleFromSearch(DeviceInfo info) {
    return VehicleDetail(
      sn: info.sn,
      vin: info.vin,
      carNumber: info.carNumber,
      img: info.img,
      latitude: info.latitude,
      longitude: info.longitude,
      createTime: info.createTime,
      ownerName: info.bindUserName,
      phone: info.bindUserPhone,
    );
  }

  Future<void> _loadCabinetDetail(String sn) async {
    final response = await _api.get<CabinetDetailBaseInfoBean?>(
      ApiPath.cabinetBaseInfo,
      queryParameters: {'sn': sn},
      parser: (json) => json == null
          ? null
          : CabinetDetailBaseInfoBean.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
    );
    state = state.copyWith(cabinetDetail: response.result);
    await loadCabinPorts(sn: sn);
    await loadFixRecords(sn: sn, deviceType: 3);
  }

  Future<bool> searchBattery(String sn) async {
    return searchDevice(sn: sn, deviceType: 1);
  }

  Future<bool> searchDevice({
    required String sn,
    required int deviceType,
  }) async {
    final value = sn.trim();
    if (value.isEmpty) return false;
    state = state.copyWith(
      loading: true,
      sn: value,
      deviceType: deviceType,
      clearSearchResult: true,
      clearBatteryDetail: true,
      clearVehicleDetail: true,
      clearCabinetDetail: true,
      histories: const [],
      fixRecords: const [],
      maintenanceRecords: const [],
      cabinPorts: const [],
      total: 0,
    );

    if (deviceType == 2) {
      await _loadVehicleDetailFromSearch(value, state.searchResult?.deviceInfo);
      state = state.copyWith(loading: false);
      return state.vehicleDetail != null;
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
      return response.result != null;
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
    return response.result != null;
  }

  Future<void> loadChargeHistory({String? sn}) async {
    final value = (sn ?? state.sn).trim();
    if (value.isEmpty) return;
    state = state.copyWith(historyLoading: true, sn: value);
    final response = await _api.get<ChargeHistoryResponse>(
      ApiPath.batteryQueryDeviceChargeRecord,
      queryParameters: {'sn': value, 'pageNum': 1, 'pageSize': 20},
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
      queryParameters: {'sn': value, 'pageNum': 1, 'pageSize': 20},
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
      queryParameters: {'sn': value, 'pageNum': 1, 'pageSize': 20},
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
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) =>
                    Cabin.fromJson(Map<String, dynamic>.from(item as Map)),
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
      data: {'sn': state.sn.trim(), 'status': nextStatus},
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

  /// 端口控制 - 对应 Android 的 openCabinDoor
  /// [type]: 1=开仓门, 2=禁用端口, 3=启用端口
  Future<bool> controlCabinPort({required int port, required int type}) async {
    final value = state.sn.trim();
    if (value.isEmpty) return false;
    final response = await _api.post<Object>(
      ApiPath.cabinetCtrlPort,
      data: {'sn': value, 'port': port, 'type': type},
      parser: (json) => json ?? Object(),
    );
    if (response.isSuccess) {
      // 刷新端口列表
      await loadCabinPorts(sn: value);
    }
    return response.isSuccess;
  }

  Future<bool> openCabinDoor({required int port}) async {
    return controlCabinPort(port: port, type: 1);
  }

  Future<bool> disableCabinPort({required int port}) async {
    return controlCabinPort(port: port, type: 2);
  }

  Future<bool> enableCabinPort({required int port}) async {
    return controlCabinPort(port: port, type: 3);
  }

  Future<bool> openCabinBackDoor() async {
    final value =
        (state.searchResult?.deviceInfo?.sn ??
                state.cabinetDetail?.stationSn ??
                state.sn)
            .trim();
    if (value.isEmpty) return false;
    final response = await _api.postForm<Object>(
      ApiPath.cabinetOpenBackDoor,
      data: FormData.fromMap({'devId': value}),
      parser: (json) => json ?? Object(),
    );
    return response.isSuccess;
  }

  /// 电池里程统计 - 对应 Android 的 staticBatteryMile
  Future<StaticBatteryMile?> getBatteryMileStats(String sn) async {
    final value = sn.trim();
    if (value.isEmpty) return null;
    final response = await _api.get<StaticBatteryMile>(
      ApiPath.batteryStaticMile,
      queryParameters: {'sn': value},
      parser: (json) =>
          StaticBatteryMile.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return response.result;
  }
}
