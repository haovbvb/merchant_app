import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/cabin_fault.dart';
import 'package:merchant_app/data/models/cabinet_cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/layout_cabinet_info.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetOfflineState {
  final bool loading;
  final CabinetDetailBaseInfoBean? baseInfo;
  final String? secretKey;
  final bool layoutLoading;
  final LayoutCabinetInfo? layoutInfo;
  final bool operating;

  /// 蓝牙连接状态
  final bool bleConnected;

  /// 仓位列表 (蓝牙获取)
  final List<CabinetCabin> cabins;

  /// 换电阈值
  final int swapThreshold;

  /// 软件版本 (蓝牙获取)
  final String? softwareVersion;

  /// 备电状态 (蓝牙获取)
  final String? backupPowerStatus;

  /// 在仓电池数 (蓝牙获取)
  final int? batteryInSlot;

  /// 实时数据 (蓝牙获取)
  final String? gsmSignal;
  final String? chargerStatus;
  final String? ctrlSystemStatus;
  final String? omDoorStatus;
  final String? totalVoltage;
  final String? totalCurrent;
  final String? temperature;
  final String? electricityMeter;
  final String? smokeAlarmStatus;
  final String? waterAlarmStatus;
  final String? fanStatus;

  const CabinetOfflineState({
    this.loading = false,
    this.baseInfo,
    this.secretKey,
    this.layoutLoading = false,
    this.layoutInfo,
    this.operating = false,
    this.bleConnected = false,
    this.cabins = const [],
    this.swapThreshold = 100,
    this.softwareVersion,
    this.backupPowerStatus,
    this.batteryInSlot,
    this.gsmSignal,
    this.chargerStatus,
    this.ctrlSystemStatus,
    this.omDoorStatus,
    this.totalVoltage,
    this.totalCurrent,
    this.temperature,
    this.electricityMeter,
    this.smokeAlarmStatus,
    this.waterAlarmStatus,
    this.fanStatus,
  });

  CabinetOfflineState copyWith({
    bool? loading,
    CabinetDetailBaseInfoBean? baseInfo,
    String? secretKey,
    bool? layoutLoading,
    LayoutCabinetInfo? layoutInfo,
    bool? operating,
    bool? bleConnected,
    List<CabinetCabin>? cabins,
    int? swapThreshold,
    String? softwareVersion,
    String? backupPowerStatus,
    int? batteryInSlot,
    String? gsmSignal,
    String? chargerStatus,
    String? ctrlSystemStatus,
    String? omDoorStatus,
    String? totalVoltage,
    String? totalCurrent,
    String? temperature,
    String? electricityMeter,
    String? smokeAlarmStatus,
    String? waterAlarmStatus,
    String? fanStatus,
  }) {
    return CabinetOfflineState(
      loading: loading ?? this.loading,
      baseInfo: baseInfo ?? this.baseInfo,
      secretKey: secretKey ?? this.secretKey,
      layoutLoading: layoutLoading ?? this.layoutLoading,
      layoutInfo: layoutInfo ?? this.layoutInfo,
      operating: operating ?? this.operating,
      bleConnected: bleConnected ?? this.bleConnected,
      cabins: cabins ?? this.cabins,
      swapThreshold: swapThreshold ?? this.swapThreshold,
      softwareVersion: softwareVersion ?? this.softwareVersion,
      backupPowerStatus: backupPowerStatus ?? this.backupPowerStatus,
      batteryInSlot: batteryInSlot ?? this.batteryInSlot,
      gsmSignal: gsmSignal ?? this.gsmSignal,
      chargerStatus: chargerStatus ?? this.chargerStatus,
      ctrlSystemStatus: ctrlSystemStatus ?? this.ctrlSystemStatus,
      omDoorStatus: omDoorStatus ?? this.omDoorStatus,
      totalVoltage: totalVoltage ?? this.totalVoltage,
      totalCurrent: totalCurrent ?? this.totalCurrent,
      temperature: temperature ?? this.temperature,
      electricityMeter: electricityMeter ?? this.electricityMeter,
      smokeAlarmStatus: smokeAlarmStatus ?? this.smokeAlarmStatus,
      waterAlarmStatus: waterAlarmStatus ?? this.waterAlarmStatus,
      fanStatus: fanStatus ?? this.fanStatus,
    );
  }
}

final cabinetOfflineProvider =
    NotifierProvider<CabinetOfflineNotifier, CabinetOfflineState>(
      CabinetOfflineNotifier.new,
    );

class CabinetOfflineNotifier extends Notifier<CabinetOfflineState> {
  final ApiService _api = ApiService();

  @override
  CabinetOfflineState build() => const CabinetOfflineState();

  Future<void> load(String sn) async {
    if (sn.isEmpty) return;
    state = state.copyWith(loading: true);
    try {
      final baseResponse = await _api.get<CabinetDetailBaseInfoBean>(
        ApiPath.cabinetBaseInfo,
        queryParameters: {'sn': sn},
        parser: (json) => CabinetDetailBaseInfoBean.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      );
      final secretResponse = await _api.get<String>(
        ApiPath.cabinetSecretKey,
        queryParameters: {'sn': sn},
        parser: (json) => json?.toString() ?? '',
      );
      final baseInfo = baseResponse.result;
      final storeNum = baseInfo?.storeNum ?? 0;
      final cabins = storeNum > 0
          ? List.generate(
              storeNum,
              (i) => CabinetCabin(
                portNo: i + 1,
                slotName: '仓位 ${i + 1}',
                status: 1,
              ),
            )
          : const <CabinetCabin>[];
      state = state.copyWith(
        loading: false,
        baseInfo: baseInfo,
        secretKey: secretResponse.result,
        swapThreshold: baseInfo?.swapThreshold ?? 100,
        cabins: cabins,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        baseInfo: null,
        secretKey: null,
        cabins: const [],
      );
    }
  }

  Future<void> loadLayout(String sn) async {
    if (sn.isEmpty) return;
    state = state.copyWith(layoutLoading: true);
    try {
      final path = ApiPath.cabinetLayoutHistory.replaceAll('{sn}', sn);
      final response = await _api.get<LayoutCabinetInfo>(
        path,
        queryParameters: {'sn': sn},
        parser: (json) =>
            LayoutCabinetInfo.fromJson(Map<String, dynamic>.from(json as Map)),
      );
      state = state.copyWith(layoutLoading: false, layoutInfo: response.result);
    } catch (_) {
      state = state.copyWith(layoutLoading: false, layoutInfo: null);
    }
  }

  /// 根据仓位数量初始化仓位列表
  void initCabins(int storeNum) {
    if (storeNum <= 0) return;
    final cabins = List.generate(
      storeNum,
      (i) => CabinetCabin(portNo: i + 1, slotName: '仓位 ${i + 1}'),
    );
    state = state.copyWith(cabins: cabins);
  }

  /// 更新蓝牙连接状态
  void setBleConnected(bool connected) {
    state = state.copyWith(bleConnected: connected);
  }

  /// 更新仓位电池状态
  void updateCabinBatteryStatus(int portNo, int batteryStatus) {
    final cabins = state.cabins.map((c) {
      if (c.portNo == portNo) {
        return c.copyWith(batteryStatus: batteryStatus == 0 ? 0 : 1);
      }
      return c;
    }).toList();
    state = state.copyWith(cabins: cabins);
  }

  /// 更新仓位电池SN
  void updateCabinBatterySn(int portNo, String batterySn) {
    final cabins = state.cabins.map((c) {
      if (c.portNo == portNo) {
        return c.copyWith(batterySn: batterySn);
      }
      return c;
    }).toList();
    state = state.copyWith(cabins: cabins);
  }

  /// 更新仓位电池电量
  void updateCabinBatterySoc(int portNo, int soc) {
    final threshold = state.swapThreshold;
    final cabins = state.cabins.map((c) {
      if (c.portNo == portNo) {
        return c.copyWith(batterySoc: soc, swapFlag: soc >= threshold ? 1 : 0);
      }
      return c;
    }).toList();
    state = state.copyWith(cabins: cabins);
  }

  /// 更新仓门状态
  void updateCabinDoorStatus(int portNo, int status) {
    final cabins = state.cabins.map((c) {
      if (c.portNo == portNo) {
        return c.copyWith(status: status);
      }
      return c;
    }).toList();
    state = state.copyWith(cabins: cabins);
  }

  /// 更新换电阈值
  void updateSwapThreshold(int threshold) {
    final cabins = state.cabins.map((c) {
      return c.copyWith(swapFlag: c.batterySoc >= threshold ? 1 : 0);
    }).toList();
    state = state.copyWith(swapThreshold: threshold, cabins: cabins);
  }

  void updateCabinSwapFlag(int portNo, int swapFlag) {
    final cabins = state.cabins.map((c) {
      if (c.portNo == portNo) {
        return c.copyWith(swapFlag: swapFlag == 1 ? 1 : 0);
      }
      return c;
    }).toList();
    state = state.copyWith(cabins: cabins);
  }

  void updateSoftwareVersion(String? value) {
    state = state.copyWith(softwareVersion: value);
  }

  void updateBackupPowerStatus(String? value) {
    state = state.copyWith(backupPowerStatus: value);
  }

  void updateBatteryInSlot(int value) {
    state = state.copyWith(batteryInSlot: value);
  }

  void updateRealtimeData({
    String? gsmSignal,
    String? chargerStatus,
    String? ctrlSystemStatus,
    String? omDoorStatus,
    String? totalVoltage,
    String? totalCurrent,
    String? temperature,
    String? electricityMeter,
    String? smokeAlarmStatus,
    String? waterAlarmStatus,
    String? fanStatus,
  }) {
    state = state.copyWith(
      gsmSignal: gsmSignal,
      chargerStatus: chargerStatus,
      ctrlSystemStatus: ctrlSystemStatus,
      omDoorStatus: omDoorStatus,
      totalVoltage: totalVoltage,
      totalCurrent: totalCurrent,
      temperature: temperature,
      electricityMeter: electricityMeter,
      smokeAlarmStatus: smokeAlarmStatus,
      waterAlarmStatus: waterAlarmStatus,
      fanStatus: fanStatus,
    );
  }

  void patchBaseInfo({
    int? swapThreshold,
    String? apn,
    int? volume,
    String? platformUrl,
  }) {
    final current = state.baseInfo;
    if (current == null) return;
    final map = current.toJson();
    if (swapThreshold != null) {
      map['swapThreshold'] = swapThreshold;
      updateSwapThreshold(swapThreshold);
    }
    if (apn != null) {
      map['apn'] = apn;
    }
    if (volume != null) {
      map['volume'] = volume;
    }
    if (platformUrl != null) {
      map['platformUrl'] = platformUrl;
    }
    state = state.copyWith(baseInfo: CabinetDetailBaseInfoBean.fromJson(map));
  }

  Future<bool> restartCabinet({required String pId}) async {
    if (pId.isEmpty) return false;
    state = state.copyWith(operating: true);
    try {
      final response = await _api.post<Object>(
        ApiPath.cabinetRestart,
        data: {'pID': pId, 'shutDown': 0, 'type': 3},
        parser: (json) => json ?? Object(),
      );
      return response.isSuccess;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(operating: false);
    }
  }

  Future<bool> openBackDoor({required String sn}) async {
    if (sn.isEmpty) return false;
    state = state.copyWith(operating: true);
    try {
      final response = await _api.post<Object>(
        ApiPath.cabinetOpenBackDoor,
        data: {'sn': sn},
        parser: (json) => json ?? Object(),
      );
      return response.isSuccess;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(operating: false);
    }
  }

  Future<bool> controlCabinPort({
    required String sn,
    required int port,
    required int type,
  }) async {
    if (sn.isEmpty || port <= 0) return false;
    state = state.copyWith(operating: true);
    try {
      final response = await _api.post<Object>(
        ApiPath.cabinetCtrlPort,
        data: {'sn': sn, 'port': port, 'type': type},
        parser: (json) => json ?? Object(),
      );
      if (response.isSuccess) {
        if (type == 2 || type == 3) {
          final nextStatus = type == 3 ? 1 : 0;
          final cabins = state.cabins.map((cabin) {
            if (cabin.portNo == port) {
              return cabin.copyWith(status: nextStatus);
            }
            return cabin;
          }).toList();
          state = state.copyWith(cabins: cabins);
        }
      }
      return response.isSuccess;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(operating: false);
    }
  }
}

class CabinetFaultState {
  final bool loading;
  final int page;
  final List<CabinFaultItem> items;
  final int total;

  const CabinetFaultState({
    this.loading = false,
    this.page = 1,
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  CabinetFaultState copyWith({
    bool? loading,
    int? page,
    List<CabinFaultItem>? items,
    int? total,
  }) {
    return CabinetFaultState(
      loading: loading ?? this.loading,
      page: page ?? this.page,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final cabinetFaultProvider =
    NotifierProvider<CabinetFaultNotifier, CabinetFaultState>(
      CabinetFaultNotifier.new,
    );

class CabinetFaultNotifier extends Notifier<CabinetFaultState> {
  final ApiService _api = ApiService();

  @override
  CabinetFaultState build() => const CabinetFaultState();

  Future<void> query(String sn, int port, {int page = 1}) async {
    if (sn.isEmpty || port <= 0) return;
    state = state.copyWith(loading: true, page: page);
    final response = await _api.get<CabinFaultBean>(
      ApiPath.cabinetFaultList,
      queryParameters: {
        'pageNum': page,
        'pageSize': 20,
        'sn': sn,
        'port': port,
      },
      parser: (json) =>
          CabinFaultBean.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    final result = response.result;
    state = state.copyWith(
      loading: false,
      items: page == 1
          ? (result?.list ?? [])
          : [...state.items, ...?result?.list],
      total: result?.total ?? state.total,
    );
  }
}
