import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/static_sale_shop.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 门店销售统计列表状态
class ShopStaticListState {
  final bool loading;
  final StaticSaleNum? num;
  final int page;
  final List<StaticSaleShop> items;
  final int total;

  const ShopStaticListState({
    this.loading = false,
    this.num,
    this.page = 1,
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  ShopStaticListState copyWith({
    bool? loading,
    StaticSaleNum? num,
    int? page,
    List<StaticSaleShop>? items,
    int? total,
  }) {
    return ShopStaticListState(
      loading: loading ?? this.loading,
      num: num ?? this.num,
      page: page ?? this.page,
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final shopStaticListProvider =
    NotifierProvider<ShopStaticListNotifier, ShopStaticListState>(
      ShopStaticListNotifier.new,
    );

class ShopStaticListNotifier extends Notifier<ShopStaticListState> {
  final ApiService _api = ApiService();

  @override
  ShopStaticListState build() => const ShopStaticListState();

  /// 加载统计数量
  Future<void> loadNum() async {
    final response = await _api.get<StaticSaleNum>(
      ApiPath.shopStaticIndex,
      parser: (json) =>
          StaticSaleNum.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    state = state.copyWith(num: response.result);
  }

  /// 加载门店统计列表
  Future<void> loadList({int page = 1}) async {
    state = state.copyWith(loading: true, page: page);

    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.shopStaticQueryList,
      queryParameters: {'pageNum': page, 'pageSize': 20},
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );

    final result = response.result;
    final list =
        (result?['list'] as List<dynamic>?)
            ?.map((e) => StaticSaleShop.fromJson(e as Map<String, dynamic>))
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
  Future<void> refresh() async {
    await Future.wait([loadNum(), loadList(page: 1)]);
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    await loadList(page: state.page + 1);
  }
}

/// 门店销售统计详情状态
class ShopStaticDetailState {
  final bool loading;
  final StaticSaleShopDetail? detail;
  final StaticSaleShopDate? dateData;

  const ShopStaticDetailState({
    this.loading = false,
    this.detail,
    this.dateData,
  });

  ShopStaticDetailState copyWith({
    bool? loading,
    StaticSaleShopDetail? detail,
    StaticSaleShopDate? dateData,
  }) {
    return ShopStaticDetailState(
      loading: loading ?? this.loading,
      detail: detail ?? this.detail,
      dateData: dateData ?? this.dateData,
    );
  }
}

final shopStaticDetailProvider =
    NotifierProvider<ShopStaticDetailNotifier, ShopStaticDetailState>(
      ShopStaticDetailNotifier.new,
    );

class ShopStaticDetailNotifier extends Notifier<ShopStaticDetailState> {
  final ApiService _api = ApiService();

  @override
  ShopStaticDetailState build() => const ShopStaticDetailState();

  /// 加载门店统计详情
  Future<void> load(String shopNo) async {
    if (shopNo.isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _api.get<StaticSaleShopDetail>(
      ApiPath.shopStaticQueryDetail,
      queryParameters: {'shopNo': shopNo},
      parser: (json) =>
          StaticSaleShopDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, detail: response.result);
  }

  /// 加载日期数据 (可选：用于图表)
  Future<void> loadDateData(
    String shopNo, {
    String? startDate,
    String? endDate,
  }) async {
    if (shopNo.isEmpty) return;
    final params = <String, dynamic>{'shopNo': shopNo};
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;

    final response = await _api.get<StaticSaleShopDate>(
      ApiPath.shopStaticQueryDetail,
      queryParameters: params,
      parser: (json) =>
          StaticSaleShopDate.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    state = state.copyWith(dateData: response.result);
  }
}
