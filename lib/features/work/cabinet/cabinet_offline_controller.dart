import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/cabin_fault.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class CabinetOfflineState {
  final bool loading;
  final CabinetDetailBaseInfoBean? baseInfo;
  final String? secretKey;

  const CabinetOfflineState({
    this.loading = false,
    this.baseInfo,
    this.secretKey,
  });

  CabinetOfflineState copyWith({
    bool? loading,
    CabinetDetailBaseInfoBean? baseInfo,
    String? secretKey,
  }) {
    return CabinetOfflineState(
      loading: loading ?? this.loading,
      baseInfo: baseInfo ?? this.baseInfo,
      secretKey: secretKey ?? this.secretKey,
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
