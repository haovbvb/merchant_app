import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/device_inventory_detail.dart';
import 'package:merchant_app/data/models/device_inventory_resp.dart';
import 'package:merchant_app/data/models/device_inventory_scan_result.dart';
import 'package:merchant_app/data/models/warehouse_info.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

const _pageSize = 20;

class InventoryListState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final int? status;
  final String keyword;
  final List<DeviceInventory> items;
  final int total;

  const InventoryListState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.status,
    this.keyword = '',
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  InventoryListState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    int? status,
    String? keyword,
    List<DeviceInventory>? items,
    int? total,
  }) {
    return InventoryListState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      status: status ?? this.status,
      keyword: keyword ?? this.keyword,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final inventoryListProvider =
    NotifierProvider<InventoryListNotifier, InventoryListState>(
      InventoryListNotifier.new,
    );

class InventoryListNotifier extends Notifier<InventoryListState> {
  final ApiService _api = ApiService();

  @override
  InventoryListState build() => const InventoryListState();

  Future<void> refresh({int? status, String? keyword}) async {
    state = state.copyWith(
      loading: true,
      page: 1,
      status: status ?? state.status,
      keyword: keyword ?? state.keyword,
    );

    final response = await _api.get<DeviceInventoryResp>(
      ApiPath.inventoryQueryDeviceInventoryPage,
      queryParameters: {
        'pageNum': 1,
        'pageSize': _pageSize,
        if ((keyword ?? state.keyword).trim().isNotEmpty)
          'keyword': (keyword ?? state.keyword).trim(),
        if ((status ?? state.status) != null) 'status': status ?? state.status,
      },
      parser: (json) =>
          DeviceInventoryResp.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loading: false,
      items: result?.list ?? const [],
      total: result?.total ?? 0,
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasMore) {
      return;
    }
    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);

    final response = await _api.get<DeviceInventoryResp>(
      ApiPath.inventoryQueryDeviceInventoryPage,
      queryParameters: {
        'pageNum': nextPage,
        'pageSize': _pageSize,
        if (state.keyword.trim().isNotEmpty) 'keyword': state.keyword.trim(),
        if (state.status != null) 'status': state.status,
      },
      parser: (json) =>
          DeviceInventoryResp.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      items: [...state.items, ...?result?.list],
      total: result?.total ?? state.total,
    );
  }
}

class InventoryDetailState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final String inventoryNo;
  final DeviceInventoryDetail? detail;
  final List<DeviceInventoryData> items;
  final int total;
  final WarehouseInfo? warehouse;
  final int? deviceType;

  const InventoryDetailState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.inventoryNo = '',
    this.detail,
    this.items = const [],
    this.total = 0,
    this.warehouse,
    this.deviceType,
  });

  bool get hasMore => items.length < total;

  InventoryDetailState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    String? inventoryNo,
    DeviceInventoryDetail? detail,
    List<DeviceInventoryData>? items,
    int? total,
    WarehouseInfo? warehouse,
    int? deviceType,
  }) {
    return InventoryDetailState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      inventoryNo: inventoryNo ?? this.inventoryNo,
      detail: detail ?? this.detail,
      items: items ?? this.items,
      total: total ?? this.total,
      warehouse: warehouse ?? this.warehouse,
      deviceType: deviceType ?? this.deviceType,
    );
  }
}

final inventoryDetailProvider =
    NotifierProvider<InventoryDetailNotifier, InventoryDetailState>(
      InventoryDetailNotifier.new,
    );

class InventoryDetailNotifier extends Notifier<InventoryDetailState> {
  final ApiService _api = ApiService();

  @override
  InventoryDetailState build() => const InventoryDetailState();

  Future<void> startInventory(int deviceType) async {
    state = state.copyWith(loading: true, deviceType: deviceType);

    final warehouse = state.warehouse ?? await _loadMyWarehouseInfo();
    final warehouseNo = warehouse?.warehouseNo ?? '';
    if (warehouseNo.isEmpty) {
      state = state.copyWith(loading: false);
      return;
    }

    final response = await _api.post<DeviceInventoryDetail>(
      ApiPath.inventoryStart,
      data: {'deviceType': deviceType, 'warehouseNo': warehouseNo},
      parser: (json) => DeviceInventoryDetail.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final detail = response.result;
    state = state.copyWith(
      loading: false,
      detail: detail,
      inventoryNo: detail?.inventoryNo ?? state.inventoryNo,
      items: detail?.detailPage?.list ?? const [],
      total: detail?.detailPage?.total ?? 0,
      warehouse: warehouse,
    );
  }

  Future<void> loadDetail(String inventoryNo) async {
    state = state.copyWith(loading: true, page: 1, inventoryNo: inventoryNo);

    final response = await _api.get<DeviceInventoryDetail>(
      ApiPath.inventoryQueryInventoryDetail,
      queryParameters: {
        'inventoryNo': inventoryNo,
        'pageNum': 1,
        'pageSize': _pageSize,
      },
      parser: (json) => DeviceInventoryDetail.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final detail = response.result;
    state = state.copyWith(
      loading: false,
      detail: detail,
      items: detail?.detailPage?.list ?? const [],
      total: detail?.detailPage?.total ?? 0,
    );
  }

  Future<int?> scanInventory(String deviceSn) async {
    if (state.inventoryNo.isEmpty) return null;
    final response = await _api.post<DeviceInventoryScanResult>(
      ApiPath.inventoryScan,
      data: {'deviceSn': deviceSn, 'inventoryNo': state.inventoryNo},
      parser: (json) => DeviceInventoryScanResult.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    await loadDetail(state.inventoryNo);
    return response.result?.result;
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasMore) {
      return;
    }
    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);

    final response = await _api.get<DeviceInventoryDetail>(
      ApiPath.inventoryQueryInventoryDetail,
      queryParameters: {
        'inventoryNo': state.inventoryNo,
        'pageNum': nextPage,
        'pageSize': _pageSize,
      },
      parser: (json) => DeviceInventoryDetail.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final detail = response.result;
    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      detail: detail ?? state.detail,
      items: [...state.items, ...?detail?.detailPage?.list],
      total: detail?.detailPage?.total ?? state.total,
    );
  }

  Future<void> completeInventory() async {
    if (state.inventoryNo.isEmpty) return;
    await _api.post<Object>(
      ApiPath.inventoryComplete,
      data: {'inventoryNo': state.inventoryNo},
      parser: (json) => json ?? Object(),
    );
    await loadDetail(state.inventoryNo);
  }

  Future<void> revokeInventory() async {
    if (state.inventoryNo.isEmpty) return;
    await _api.post<Object>(
      ApiPath.inventoryRevoke,
      data: {'inventoryNo': state.inventoryNo},
      parser: (json) => json ?? Object(),
    );
    await loadDetail(state.inventoryNo);
  }

  Future<WarehouseInfo?> _loadMyWarehouseInfo() async {
    final response = await _api.get<WarehouseInfo>(
      ApiPath.transportQueryMyWarehouseInfo,
      parser: (json) =>
          WarehouseInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    return response.result;
  }
}

/// 盘点仓库列表 Provider
final inventoryWarehouseListProvider = FutureProvider<List<WarehouseInfo>>((
  ref,
) async {
  final api = ApiService();
  final response = await api.get<List<WarehouseInfo>>(
    ApiPath.inventoryQueryInventoryHouseList,
    parser: (json) => (json as List<dynamic>? ?? [])
        .map((e) => WarehouseInfo.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList(),
    showHud: false,
  );
  return response.result ?? [];
});
