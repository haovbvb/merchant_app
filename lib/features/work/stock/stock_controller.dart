import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/stock.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 库存列表状态
class StockListState {
  final bool loading;
  final StockNum? num;
  final int page;
  final List<Stock> items;
  final int total;
  final int type; // 0=全部 1=调入 2=调出

  const StockListState({
    this.loading = false,
    this.num,
    this.page = 1,
    this.items = const [],
    this.total = 0,
    this.type = 0,
  });

  bool get hasMore => items.length < total;

  StockListState copyWith({
    bool? loading,
    StockNum? num,
    int? page,
    List<Stock>? items,
    int? total,
    int? type,
  }) {
    return StockListState(
      loading: loading ?? this.loading,
      num: num ?? this.num,
      page: page ?? this.page,
      items: items ?? this.items,
      total: total ?? this.total,
      type: type ?? this.type,
    );
  }
}

final stockListProvider = NotifierProvider<StockListNotifier, StockListState>(
  StockListNotifier.new,
);

class StockListNotifier extends Notifier<StockListState> {
  final ApiService _api = ApiService();

  @override
  StockListState build() => const StockListState();

  /// 加载库存数量统计
  Future<void> loadNum() async {
    final response = await _api.get<StockNum>(
      ApiPath.stockIndex,
      parser: (json) =>
          StockNum.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    state = state.copyWith(num: response.result);
  }

  /// 加载库存列表
  Future<void> loadList({int page = 1, int? type}) async {
    final queryType = type ?? state.type;
    state = state.copyWith(loading: true, page: page, type: queryType);

    final params = <String, dynamic>{'pageNum': page, 'pageSize': 20};
    if (queryType > 0) {
      params['transferType'] = queryType;
    }

    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.stockQueryList,
      queryParameters: params,
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );

    final result = response.result;
    final list =
        (result?['list'] as List<dynamic>?)
            ?.map((e) => Stock.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final total = (result?['total'] as num?)?.toInt() ?? 0;

    state = state.copyWith(
      loading: false,
      items: page == 1 ? list : [...state.items, ...list],
      total: total,
    );
  }

  /// 刷新
  Future<void> refresh({int? type}) async {
    await Future.wait([loadNum(), loadList(page: 1, type: type)]);
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    await loadList(page: state.page + 1);
  }

  /// 切换类型
  void setType(int type) {
    if (type == state.type) return;
    loadList(page: 1, type: type);
  }
}

/// 库存详情状态
class StockDetailState {
  final bool loading;
  final StockDetail? detail;

  const StockDetailState({this.loading = false, this.detail});

  StockDetailState copyWith({bool? loading, StockDetail? detail}) {
    return StockDetailState(
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
    );
  }
}

final stockDetailProvider =
    NotifierProvider<StockDetailNotifier, StockDetailState>(
      StockDetailNotifier.new,
    );

class StockDetailNotifier extends Notifier<StockDetailState> {
  final ApiService _api = ApiService();

  @override
  StockDetailState build() => const StockDetailState();

  /// 加载调拨详情
  Future<void> load(String transferNo) async {
    if (transferNo.isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _api.get<StockDetail>(
      ApiPath.stockQueryDetail,
      queryParameters: {'transferNo': transferNo},
      parser: (json) =>
          StockDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, detail: response.result);
  }
}

/// 库存调拨状态
class StockTransferState {
  final bool loading;
  final bool submitting;
  final BatteryTransfer? battery;

  const StockTransferState({
    this.loading = false,
    this.submitting = false,
    this.battery,
  });

  StockTransferState copyWith({
    bool? loading,
    bool? submitting,
    BatteryTransfer? battery,
  }) {
    return StockTransferState(
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      battery: battery ?? this.battery,
    );
  }
}

final stockTransferProvider =
    NotifierProvider<StockTransferNotifier, StockTransferState>(
      StockTransferNotifier.new,
    );

class StockTransferNotifier extends Notifier<StockTransferState> {
  final ApiService _api = ApiService();

  @override
  StockTransferState build() => const StockTransferState();

  /// 查询电池调拨信息
  Future<bool> queryBattery(String batterySn) async {
    if (batterySn.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.get<BatteryTransfer>(
      ApiPath.stockQueryTransferBatteryBySn,
      queryParameters: {'batterySn': batterySn},
      parser: (json) =>
          BatteryTransfer.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, battery: response.result);
    return response.isSuccess;
  }

  /// 提交调拨
  Future<bool> transfer({
    required String shopNo,
    required List<String> batterySnList,
    String? remark,
  }) async {
    if (shopNo.isEmpty || batterySnList.isEmpty) return false;
    state = state.copyWith(submitting: true);
    final data = <String, dynamic>{
      'shopNo': shopNo,
      'batterySnList': batterySnList,
    };
    if (remark != null && remark.isNotEmpty) {
      data['remark'] = remark;
    }
    final response = await _api.post<Object>(
      ApiPath.stockTransfer,
      data: data,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(submitting: false);
    return response.isSuccess;
  }

  /// 清除
  void clear() {
    state = const StockTransferState();
  }
}
