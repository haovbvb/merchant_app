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
  /// 蓝牙连接状态
  final bool bleConnected;
  /// 仓位列表 (蓝牙获取)
  final List<CabinetCabin> cabins;
  /// 换电阈值
  final int swapThreshold;

  const CabinetOfflineState({
    this.loading = false,
    this.baseInfo,
    this.secretKey,
    this.layoutLoading = false,
    this.layoutInfo,
    this.bleConnected = false,
    this.cabins = const [],
    this.swapThreshold = 100,
  });

  CabinetOfflineState copyWith({
    bool? loading,
    CabinetDetailBaseInfoBean? baseInfo,
    String? secretKey,
    bool? layoutLoading,
    LayoutCabinetInfo? layoutInfo,
    bool? bleConnected,
    List<CabinetCabin>? cabins,
    int? swapThreshold,
  }) {
    return CabinetOfflineState(
      loading: loading ?? this.loading,
      baseInfo: baseInfo ?? this.baseInfo,
      secretKey: secretKey ?? this.secretKey,
      layoutLoading: layoutLoading ?? this.layoutLoading,
      layoutInfo: layoutInfo ?? this.layoutInfo,
      bleConnected: bleConnected ?? this.bleConnected,
      cabins: cabins ?? this.cabins,
      swapThreshold: swapThreshold ?? this.swapThreshold,
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
    state = state.copyWith(
      loading: false,
      baseInfo: baseResponse.result,
      secretKey: secretResponse.result,
    );
  }

  Future<void> loadLayout(String sn) async {
    if (sn.isEmpty) return;
    state = state.copyWith(layoutLoading: true);
    final path = ApiPath.cabinetLayoutHistory.replaceAll('{sn}', sn);
    final response = await _api.get<LayoutCabinetInfo>(
      path,
      queryParameters: {'sn': sn},
      parser: (json) => LayoutCabinetInfo.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      layoutLoading: false,
      layoutInfo: response.result,
    );
  }

  /// 根据仓位数量初始化仓位列表
  void initCabins(int storeNum) {
    if (storeNum <= 0) return;
    final cabins = List.generate(
      storeNum,
      (i) => CabinetCabin(
        portNo: i + 1,
        slotName: '仓位 ${i + 1}',
      ),
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
        return c.copyWith(
          batterySoc: soc,
          swapFlag: soc >= threshold ? 1 : 0,
        );
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
      parser: (json) => CabinFaultBean.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    final result = response.result;
    state = state.copyWith(
      loading: false,
      items: page == 1 ? (result?.list ?? []) : [...state.items, ...?result?.list],
      total: result?.total ?? state.total,
    );
  }
}
