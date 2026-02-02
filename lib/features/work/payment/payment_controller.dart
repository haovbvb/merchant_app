import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/payment_order.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

/// 收款订单列表状态
class PaymentListState {
  final bool loading;
  final int page;
  final List<PaymentOrder> items;
  final int total;
  final int status; // 0=待审核 1=已确认 2=已拒绝 -1=全部

  const PaymentListState({
    this.loading = false,
    this.page = 1,
    this.items = const [],
    this.total = 0,
    this.status = -1,
  });

  bool get hasMore => items.length < total;

  PaymentListState copyWith({
    bool? loading,
    int? page,
    List<PaymentOrder>? items,
    int? total,
    int? status,
  }) {
    return PaymentListState(
      loading: loading ?? this.loading,
      page: page ?? this.page,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }
}

final paymentListProvider =
    NotifierProvider<PaymentListNotifier, PaymentListState>(
      PaymentListNotifier.new,
    );

class PaymentListNotifier extends Notifier<PaymentListState> {
  final ApiService _api = ApiService();

  @override
  PaymentListState build() => const PaymentListState();

  /// 加载收款订单列表
  Future<void> loadList({int page = 1, int? status}) async {
    final queryStatus = status ?? state.status;
    state = state.copyWith(loading: true, page: page, status: queryStatus);

    final params = <String, dynamic>{'pageNum': page, 'pageSize': 20};
    if (queryStatus >= 0) {
      params['status'] = queryStatus;
    }

    final response = await _api.get<PaymentOrderListResponse>(
      ApiPath.paymentQueryList,
      queryParameters: params,
      parser: (json) => PaymentOrderListResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final result = response.result;
    state = state.copyWith(
      loading: false,
      items: page == 1
          ? (result?.list ?? [])
          : [...state.items, ...?result?.list],
      total: result?.total ?? 0,
    );
  }

  /// 刷新
  Future<void> refresh({int? status}) async {
    await loadList(page: 1, status: status);
  }

  /// 加载更多
  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    await loadList(page: state.page + 1);
  }

  /// 切换状态筛选
  void setStatus(int status) {
    if (status == state.status) return;
    loadList(page: 1, status: status);
  }
}

/// 收款确认状态
class PaymentConfirmState {
  final bool loading;
  final bool confirming;
  final PaymentOrder? order;

  const PaymentConfirmState({
    this.loading = false,
    this.confirming = false,
    this.order,
  });

  PaymentConfirmState copyWith({
    bool? loading,
    bool? confirming,
    PaymentOrder? order,
  }) {
    return PaymentConfirmState(
      loading: loading ?? this.loading,
      confirming: confirming ?? this.confirming,
      order: order ?? this.order,
    );
  }
}

final paymentConfirmProvider =
    NotifierProvider<PaymentConfirmNotifier, PaymentConfirmState>(
      PaymentConfirmNotifier.new,
    );

class PaymentConfirmNotifier extends Notifier<PaymentConfirmState> {
  final ApiService _api = ApiService();

  @override
  PaymentConfirmState build() => const PaymentConfirmState();

  /// 根据订单号查询订单
  Future<bool> queryByOrderNo(String orderNo) async {
    if (orderNo.isEmpty) return false;
    state = state.copyWith(loading: true);
    final response = await _api.get<PaymentOrder>(
      ApiPath.paymentQueryOrderByNo,
      queryParameters: {'orderNo': orderNo},
      parser: (json) =>
          PaymentOrder.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    state = state.copyWith(loading: false, order: response.result);
    return response.isSuccess && response.result != null;
  }

  /// 确认收款
  Future<bool> confirm({
    required String orderNo,
    required int result, // 1=确认 2=拒绝
    String? remark,
  }) async {
    if (orderNo.isEmpty) return false;
    state = state.copyWith(confirming: true);
    final data = <String, dynamic>{'orderNo': orderNo, 'result': result};
    if (remark != null && remark.isNotEmpty) {
      data['remark'] = remark;
    }
    final response = await _api.post<Object>(
      ApiPath.paymentConfirm,
      data: data,
      parser: (json) => json ?? Object(),
    );
    state = state.copyWith(confirming: false);
    return response.isSuccess;
  }

  /// 清除
  void clear() {
    state = const PaymentConfirmState();
  }
}
