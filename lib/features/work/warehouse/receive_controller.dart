import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

const _pageSize = 20;

// ==================== 接收列表状态 ====================
class ReceiveListState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final int? status;
  final String keyword;
  final List<DeviceTransport> items;
  final int total;

  const ReceiveListState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.status,
    this.keyword = '',
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  ReceiveListState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    int? status,
    String? keyword,
    List<DeviceTransport>? items,
    int? total,
  }) {
    return ReceiveListState(
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

final receiveListProvider =
    NotifierProvider<ReceiveListNotifier, ReceiveListState>(
  ReceiveListNotifier.new,
);

class ReceiveListNotifier extends Notifier<ReceiveListState> {
  final ApiService _api = ApiService();

  @override
  ReceiveListState build() => const ReceiveListState();

  Future<void> refresh({int? status, String? keyword}) async {
    state = state.copyWith(
      loading: true,
      page: 1,
      status: status ?? state.status,
      keyword: keyword ?? state.keyword,
    );

    final response = await _api.get<DeviceTransportResp>(
      ApiPath.transportQueryDeviceReceivePage,
      queryParameters: {
        'pageNum': 1,
        'pageSize': _pageSize,
        if ((status ?? state.status) != null) 'status': status ?? state.status,
        if ((keyword ?? state.keyword).trim().isNotEmpty)
          'keyword': (keyword ?? state.keyword).trim(),
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
      ApiPath.transportQueryDeviceReceivePage,
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
}

// ==================== 接收详情状态 ====================
class ReceiveDetailState {
  final bool loading;
  final String transferNo;
  final DeviceTransportDetail? detail;
  final List<DeviceTransportDetailPageData> items;

  const ReceiveDetailState({
    this.loading = false,
    this.transferNo = '',
    this.detail,
    this.items = const [],
  });

  ReceiveDetailState copyWith({
    bool? loading,
    String? transferNo,
    DeviceTransportDetail? detail,
    List<DeviceTransportDetailPageData>? items,
  }) {
    return ReceiveDetailState(
      loading: loading ?? this.loading,
      transferNo: transferNo ?? this.transferNo,
      detail: detail ?? this.detail,
      items: items ?? this.items,
    );
  }
}

final receiveDetailProvider =
    NotifierProvider<ReceiveDetailNotifier, ReceiveDetailState>(
  ReceiveDetailNotifier.new,
);

class ReceiveDetailNotifier extends Notifier<ReceiveDetailState> {
  final ApiService _api = ApiService();

  @override
  ReceiveDetailState build() => const ReceiveDetailState();

  Future<void> loadDetail(String transferNo) async {
    state = state.copyWith(loading: true, transferNo: transferNo);

    final response = await _api.get<DeviceTransportDetail>(
      ApiPath.transportQueryReceiveDetail,
      queryParameters: {'transferNo': transferNo},
      parser: (json) =>
          DeviceTransportDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final detail = response.result;
    state = state.copyWith(
      loading: false,
      detail: detail,
      items: detail?.detailPage?.list ?? const [],
    );
  }

  Future<ReceiveResult> receiveDevice(String deviceSn) async {
    if (state.transferNo.isEmpty) {
      return ReceiveResult(success: false, message: 'Transfer number is empty');
    }
    try {
      await _api.post<Object>(
        ApiPath.transportReceive,
        data: {
          'deviceSn': deviceSn,
          'transferNo': state.transferNo,
        },
        parser: (json) => json ?? Object(),
      );
      await loadDetail(state.transferNo);
      return ReceiveResult(success: true, message: 'Received successfully');
    } catch (e) {
      return ReceiveResult(
        success: false,
        message: 'The device does not belong to this document',
      );
    }
  }

  Future<bool> withdrawDevice(String deviceSn) async {
    if (state.transferNo.isEmpty) return false;
    try {
      await _api.post<Object>(
        ApiPath.transportWithdraw,
        data: {
          'deviceSn': deviceSn,
          'transferNo': state.transferNo,
        },
        parser: (json) => json ?? Object(),
      );
      await loadDetail(state.transferNo);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class ReceiveResult {
  final bool success;
  final String message;

  ReceiveResult({required this.success, required this.message});
}
