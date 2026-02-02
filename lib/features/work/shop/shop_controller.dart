import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/shop.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 门店列表状态
class ShopListState {
  final bool loading;
  final ShopNum? num;
  final int page;
  final List<ShopItem> items;
  final int total;
  final int type; // 0=全部 1=直营 2=加盟

  const ShopListState({
    this.loading = false,
    this.num,
    this.page = 1,
    this.items = const [],
    this.total = 0,
    this.type = 0,
  });

  bool get hasMore => items.length < total;

  ShopListState copyWith({
    bool? loading,
    ShopNum? num,
    int? page,
    List<ShopItem>? items,
    int? total,
    int? type,
  }) {
    return ShopListState(
      loading: loading ?? this.loading,
      num: num ?? this.num,
      page: page ?? this.page,
      items: items ?? this.items,
      total: total ?? this.total,
      type: type ?? this.type,
    );
  }
}

final shopListProvider = NotifierProvider<ShopListNotifier, ShopListState>(
  ShopListNotifier.new,
);

class ShopListNotifier extends Notifier<ShopListState> {
  final ApiService _api = ApiService();

  @override
  ShopListState build() => const ShopListState();

  /// 加载门店数量统计
  Future<void> loadNum() async {
    final response = await _api.get<ShopNum>(
      ApiPath.shopQueryList,
      queryParameters: {'type': 'num'},
      parser: (json) =>
          ShopNum.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    state = state.copyWith(num: response.result);
  }

  /// 加载门店列表
  Future<void> loadList({int page = 1, int? type}) async {
    final queryType = type ?? state.type;
    state = state.copyWith(loading: true, page: page, type: queryType);

    final params = <String, dynamic>{'pageNum': page, 'pageSize': 20};
    if (queryType > 0) {
      params['type'] = queryType;
    }

    final response = await _api.get<Map<String, dynamic>>(
      ApiPath.shopQueryList,
      queryParameters: params,
      parser: (json) => Map<String, dynamic>.from(json as Map),
    );

    final result = response.result;
    final list =
        (result?['list'] as List<dynamic>?)
            ?.map((e) => ShopItem.fromJson(e as Map<String, dynamic>))
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

/// 门店详情状态
class ShopDetailState {
  final bool loading;
  final bool updating;
  final ShopDetail? detail;

  const ShopDetailState({
    this.loading = false,
    this.updating = false,
    this.detail,
  });

  ShopDetailState copyWith({
    bool? loading,
    bool? updating,
    ShopDetail? detail,
  }) {
    return ShopDetailState(
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      detail: detail ?? this.detail,
    );
  }
}

final shopDetailProvider =
    NotifierProvider<ShopDetailNotifier, ShopDetailState>(
      ShopDetailNotifier.new,
    );

class ShopDetailNotifier extends Notifier<ShopDetailState> {
  final ApiService _api = ApiService();

  @override
  ShopDetailState build() => const ShopDetailState();

  /// 加载门店详情
  Future<void> load(String shopNo) async {
    if (shopNo.isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _api.get<ShopDetail>(
      ApiPath.shopQueryDetail,
      queryParameters: {'shopNo': shopNo},
      parser: (json) =>
          ShopDetail.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, detail: response.result);
  }

  /// 创建门店
  Future<bool> create({
    required String name,
    required String cityCode,
    required String address,
    required double latitude,
    required double longitude,
    required int type,
    String? managerPhone,
    String? shopManager,
    String? remark,
    String? imgList,
  }) async {
    state = state.copyWith(updating: true);
    final data = <String, dynamic>{
      'name': name,
      'cityCode': cityCode,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
    };
    if (managerPhone != null) data['managerPhone'] = managerPhone;
    if (shopManager != null) data['shopManager'] = shopManager;
    if (remark != null) data['remark'] = remark;
    if (imgList != null) data['imgList'] = imgList;

    final response = await _api.post<Object>(
      ApiPath.shopCreate,
      data: data,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);
    return response.isSuccess;
  }

  /// 编辑门店
  Future<bool> edit({
    required String shopNo,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? managerPhone,
    String? shopManager,
    String? remark,
    String? imgList,
  }) async {
    state = state.copyWith(updating: true);
    final data = <String, dynamic>{'shopNo': shopNo};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (managerPhone != null) data['managerPhone'] = managerPhone;
    if (shopManager != null) data['shopManager'] = shopManager;
    if (remark != null) data['remark'] = remark;
    if (imgList != null) data['imgList'] = imgList;

    final response = await _api.post<Object>(
      ApiPath.shopEdit,
      data: data,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);
    return response.isSuccess;
  }

  /// 切换门店状态
  Future<bool> turnStatus(String shopNo) async {
    if (shopNo.isEmpty) return false;
    state = state.copyWith(updating: true);
    final response = await _api.post<Object>(
      ApiPath.shopTurn,
      data: {'shopNo': shopNo},
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(updating: false);
    if (response.isSuccess && state.detail != null) {
      // 更新本地状态
      await load(shopNo);
    }
    return response.isSuccess;
  }
}

/// 门店搜索 Provider
final shopSearchProvider = FutureProvider.family<List<Shop>, String>((
  ref,
  keyword,
) async {
  if (keyword.isEmpty) return [];
  final api = ApiService();
  final response = await api.get<List<dynamic>>(
    ApiPath.stockQueryShopByName,
    queryParameters: {'shopName': keyword},
    parser: (json) => (json as List<dynamic>?) ?? [],
    showHud: false,
  );
  return response.result
          ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [];
});
