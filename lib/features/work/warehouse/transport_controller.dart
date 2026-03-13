import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/city.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
import 'package:merchant_app/data/models/warehouse_info.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

const _pageSize = 20;

enum TransportMode { issue, receive }

class TransportListState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final int? status;
  final TransportMode mode;
  final String keyword;
  final List<DeviceTransport> items;
  final int total;

  const TransportListState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.status,
    this.mode = TransportMode.issue,
    this.keyword = '',
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  static const int _sentinel = -999;

  TransportListState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    int? status = _sentinel,
    TransportMode? mode,
    String? keyword,
    List<DeviceTransport>? items,
    int? total,
  }) {
    return TransportListState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      status: status == _sentinel ? this.status : status,
      mode: mode ?? this.mode,
      keyword: keyword ?? this.keyword,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final transportListProvider =
    NotifierProvider<TransportListNotifier, TransportListState>(
      TransportListNotifier.new,
    );

class TransportListNotifier extends Notifier<TransportListState> {
  final ApiService _api = ApiService();

  @override
  TransportListState build() => const TransportListState();

  Future<void> refresh({
    int? status,
    TransportMode? mode,
    String? keyword,
  }) async {
    final effectiveStatus = status;
    final effectiveMode = mode ?? state.mode;
    final effectiveKeyword = keyword ?? state.keyword;

    state = state.copyWith(
      loading: true,
      page: 1,
      status: effectiveStatus,
      mode: effectiveMode,
      keyword: effectiveKeyword,
    );

    final response = await _api.get<DeviceTransportResp>(
      _endpointForMode(effectiveMode),
      queryParameters: {
        'pageNum': 1,
        'pageSize': _pageSize,
        if (effectiveStatus != null) 'status': effectiveStatus,
        if (effectiveKeyword.trim().isNotEmpty) 'keyword': effectiveKeyword.trim(),
      },
      parser: (json) =>
          DeviceTransportResp.fromJson(Map<String, dynamic>.from(json as Map)),
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

    final response = await _api.get<DeviceTransportResp>(
      _endpointForMode(state.mode),
      queryParameters: {
        'pageNum': nextPage,
        'pageSize': _pageSize,
        if (state.status != null) 'status': state.status,
        if (state.keyword.trim().isNotEmpty) 'keyword': state.keyword.trim(),
      },
      parser: (json) =>
          DeviceTransportResp.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      items: [...state.items, ...?result?.list],
      total: result?.total ?? state.total,
    );
  }

  String _endpointForMode(TransportMode mode) {
    return mode == TransportMode.issue
        ? ApiPath.transportQueryDeviceIssuePage
        : ApiPath.transportQueryDeviceReceivePage;
  }
}

class TransportDetailState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final int total;
  final String transferNo;
  final DeviceTransportDetail? detail;
  final List<DeviceTransportDetailPageData> items;

  const TransportDetailState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.total = 0,
    this.transferNo = '',
    this.detail,
    this.items = const [],
  });

  bool get hasMore => items.length < total;

  TransportDetailState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    int? total,
    String? transferNo,
    DeviceTransportDetail? detail,
    List<DeviceTransportDetailPageData>? items,
  }) {
    return TransportDetailState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      total: total ?? this.total,
      transferNo: transferNo ?? this.transferNo,
      detail: detail ?? this.detail,
      items: items ?? this.items,
    );
  }
}

final transportDetailProvider =
    NotifierProvider<TransportDetailNotifier, TransportDetailState>(
      TransportDetailNotifier.new,
    );

class TransportDetailNotifier extends Notifier<TransportDetailState> {
  final ApiService _api = ApiService();

  @override
  TransportDetailState build() => const TransportDetailState();

  Future<void> loadDetail(String transferNo) async {
    state = state.copyWith(
      loading: true,
      loadingMore: false,
      page: 1,
      total: 0,
      transferNo: transferNo,
    );

    final response = await _api.get<DeviceTransportDetail>(
      ApiPath.transportQueryIssueDetail,
      queryParameters: {
        'transferNo': transferNo,
        'pageNum': 1,
        'pageSize': _pageSize,
      },
      parser: (json) => DeviceTransportDetail.fromJson(
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

  Future<void> loadMoreDetail() async {
    if (state.loading || state.loadingMore || !state.hasMore) {
      return;
    }
    final transferNo = state.transferNo;
    if (transferNo.isEmpty) {
      return;
    }

    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);

    final response = await _api.get<DeviceTransportDetail>(
      ApiPath.transportQueryIssueDetail,
      queryParameters: {
        'transferNo': transferNo,
        'pageNum': nextPage,
        'pageSize': _pageSize,
      },
      parser: (json) => DeviceTransportDetail.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final detail = response.result;
    final pageList = detail?.detailPage?.list ?? const <DeviceTransportDetailPageData>[];

    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      detail: detail ?? state.detail,
      items: [...state.items, ...pageList],
      total: detail?.detailPage?.total ?? state.total,
    );
  }

  Future<void> receiveDevice(String deviceSn) async {
    if (state.transferNo.isEmpty) return;
    await _api.post<Object>(
      ApiPath.transportReceive,
      data: {'deviceSn': deviceSn, 'transferNo': state.transferNo},
      parser: (json) => json ?? Object(),
    );
    await loadDetail(state.transferNo);
  }

  Future<void> withdrawDevice(String deviceSn) async {
    if (state.transferNo.isEmpty) return;
    await _api.post<Object>(
      ApiPath.transportWithdraw,
      data: {'deviceSn': deviceSn, 'transferNo': state.transferNo},
      parser: (json) => json ?? Object(),
    );
    await loadDetail(state.transferNo);
  }

  Future<void> editTrackingNumber(String trackingNumber) async {
    if (state.transferNo.isEmpty) return;
    await _api.post<Object>(
      ApiPath.transportEditTrackingNumber,
      data: {'transferNo': state.transferNo, 'trackingNumber': trackingNumber},
      parser: (json) => json ?? Object(),
    );
    await loadDetail(state.transferNo);
  }
}

class TransportCreateState {
  final bool loading;
  final bool submitting;
  final int deviceType;
  final WarehouseInfo? myWarehouse;
  final List<WarehouseInfo> inWarehouses;
  final WarehouseInfo? selectedInWarehouse;
  final List<City> cities;
  final List<String> sns;
  final String trackingNumber;
  final String warehouseKeyword;
  final String warehouseCityCode;
  final String warehouseCityName;

  const TransportCreateState({
    this.loading = false,
    this.submitting = false,
    this.deviceType = 0,
    this.myWarehouse,
    this.inWarehouses = const [],
    this.selectedInWarehouse,
    this.cities = const [],
    this.sns = const [],
    this.trackingNumber = '',
    this.warehouseKeyword = '',
    this.warehouseCityCode = '',
    this.warehouseCityName = '',
  });

  static const Object _unset = Object();

  TransportCreateState copyWith({
    bool? loading,
    bool? submitting,
    int? deviceType,
    Object? myWarehouse = _unset,
    List<WarehouseInfo>? inWarehouses,
    Object? selectedInWarehouse = _unset,
    List<City>? cities,
    List<String>? sns,
    String? trackingNumber,
    String? warehouseKeyword,
    String? warehouseCityCode,
    String? warehouseCityName,
  }) {
    return TransportCreateState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      deviceType: deviceType ?? this.deviceType,
      myWarehouse: myWarehouse == _unset
          ? this.myWarehouse
          : myWarehouse as WarehouseInfo?,
      inWarehouses: inWarehouses ?? this.inWarehouses,
      selectedInWarehouse: selectedInWarehouse == _unset
          ? this.selectedInWarehouse
          : selectedInWarehouse as WarehouseInfo?,
      cities: cities ?? this.cities,
      sns: sns ?? this.sns,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      warehouseKeyword: warehouseKeyword ?? this.warehouseKeyword,
      warehouseCityCode: warehouseCityCode ?? this.warehouseCityCode,
      warehouseCityName: warehouseCityName ?? this.warehouseCityName,
    );
  }
}

final transportCreateProvider =
    NotifierProvider<TransportCreateNotifier, TransportCreateState>(
      TransportCreateNotifier.new,
    );

class TransportCreateNotifier extends Notifier<TransportCreateState> {
  final ApiService _api = ApiService();
  int _warehouseListRequestId = 0;

  @override
  TransportCreateState build() => const TransportCreateState();

  void resetCreateState() {
    state = const TransportCreateState();
  }

  void setDeviceType(int deviceType) {
    state = state.copyWith(deviceType: deviceType);
  }

  void setInitialSns(List<String> sns) {
    final unique = <String>{...sns.where((sn) => sn.trim().isNotEmpty)};
    state = state.copyWith(sns: unique.toList());
  }

  Future<void> loadMyWarehouse() async {
    state = state.copyWith(loading: true);
    final response = await _api.get<WarehouseInfo>(
      ApiPath.transportQueryMyWarehouseInfo,
      parser: (json) =>
          WarehouseInfo.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, myWarehouse: response.result);
  }

  Future<void> loadInWarehouseList({
    String? keyword,
    String? cityCode,
  }) async {
    final nextKeyword = (keyword ?? state.warehouseKeyword).trim();
    final nextCityCode = (cityCode ?? state.warehouseCityCode).trim();
    final requestId = ++_warehouseListRequestId;

    // Clear stale list immediately so UI shows loading state on city switch.
    state = state.copyWith(
      loading: true,
      inWarehouses: const <WarehouseInfo>[],
      selectedInWarehouse: null,
      warehouseKeyword: nextKeyword,
      warehouseCityCode: nextCityCode,
    );
    final response = await _api.get<List<WarehouseInfo>>(
      ApiPath.transportQueryInWarehouseList,
      queryParameters: {'cityCode': nextCityCode, 'name': nextKeyword},
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) => WarehouseInfo.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList() ??
          const <WarehouseInfo>[],
    );

    // Ignore outdated response when newer filter request has been sent.
    if (requestId != _warehouseListRequestId) {
      return;
    }

    state = state.copyWith(
      loading: false,
      inWarehouses: response.result ?? const <WarehouseInfo>[],
      warehouseKeyword: nextKeyword,
      warehouseCityCode: nextCityCode,
    );
  }

  Future<void> loadCities() async {
    final response = await _api.get<List<City>>(
      ApiPath.cityList,
      parser: (json) =>
          (json as List<dynamic>?)
              ?.map(
                (item) => City.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList() ??
          const <City>[],
      showHud: false,
      notifyOnError: false,
    );
    state = state.copyWith(cities: response.result ?? const []);
  }

  void selectInWarehouse(WarehouseInfo warehouse) {
    state = state.copyWith(selectedInWarehouse: warehouse);
  }

  Future<void> addSn(String deviceSn) async {
    if (deviceSn.isEmpty || state.sns.contains(deviceSn)) return;
    final warehouseNo = state.myWarehouse?.warehouseNo ?? '';
    if (warehouseNo.isNotEmpty && state.deviceType != 0) {
      final response = await _api.get<Object>(
        ApiPath.transportCheckDeviceSn,
        queryParameters: {
          'deviceType': state.deviceType,
          'deviceSn': deviceSn,
          'warehouseNo': warehouseNo,
        },
        parser: (json) => json ?? Object(),
      );
      if (!response.isSuccess) {
        return;
      }
    }
    state = state.copyWith(sns: [...state.sns, deviceSn]);
  }

  void removeSn(String deviceSn) {
    state = state.copyWith(
      sns: state.sns.where((sn) => sn != deviceSn).toList(),
    );
  }

  void setTrackingNumber(String trackingNumber) {
    state = state.copyWith(trackingNumber: trackingNumber);
  }

  Future<bool> createIssue() async {
    final inWarehouseNo = state.selectedInWarehouse?.inWarehouseNo ?? '';
    final outWarehouseNo = state.myWarehouse?.warehouseNo ?? '';
    if (inWarehouseNo.isEmpty || state.deviceType == 0 || state.sns.isEmpty) {
      return false;
    }
    state = state.copyWith(submitting: true);
    final response = await _api.post<Object>(
      ApiPath.transportCreateIssue,
      data: {
        'inWarehouseNo': inWarehouseNo,
        'outWarehouseNo': outWarehouseNo,
        'deviceType': state.deviceType,
        'sns': state.sns,
        'trackingNumber': state.trackingNumber,
      },
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }
}
