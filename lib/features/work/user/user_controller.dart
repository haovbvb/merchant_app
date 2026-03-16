// ignore_for_file: uri_does_not_exist, undefined_identifier

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/power_change.dart';
import 'package:merchant_app/data/models/user_detail.dart';
import 'package:merchant_app/data/models/user_info.dart';
import 'package:merchant_app/data/models/user_order_response.dart';
import 'package:merchant_app/data/models/user_payment_record.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

const _userListPageSize = 20;
const _detailPageSize = 10;
const _orderPageSize = 10;

class UserListState {
  final bool loading;
  final bool loadingMore;
  final int page;
  final String keyword;
  final int? status;
  final List<UserInfo> items;
  final int total;

  const UserListState({
    this.loading = false,
    this.loadingMore = false,
    this.page = 1,
    this.keyword = '',
    this.status,
    this.items = const [],
    this.total = 0,
  });

  bool get hasMore => items.length < total;

  UserListState copyWith({
    bool? loading,
    bool? loadingMore,
    int? page,
    String? keyword,
    int? status,
    bool clearStatus = false,
    List<UserInfo>? items,
    int? total,
  }) {
    return UserListState(
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      keyword: keyword ?? this.keyword,
      status: clearStatus ? null : (status ?? this.status),
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

final userListProvider = NotifierProvider<UserListNotifier, UserListState>(
  UserListNotifier.new,
);

class UserListNotifier extends Notifier<UserListState> {
  final ApiService _api = ApiService();

  @override
  UserListState build() => const UserListState();

  Future<void> refresh({String? keyword, int? status}) async {
    final nextKeyword = keyword ?? state.keyword;
    final nextStatus = status;
    state = state.copyWith(
      loading: true,
      page: 1,
      keyword: nextKeyword,
      status: nextStatus,
      clearStatus: status == null,
    );

    final response = await _api.get<_UserListResponse>(
      _endpointForKeyword(nextKeyword),
      queryParameters: {
        'pageNum': 1,
        'pageSize': _userListPageSize,
        if (nextKeyword.trim().isNotEmpty) 'keyword': nextKeyword.trim(),
        if (nextStatus != null) 'type': nextStatus,
      },
      parser: (json) =>
          _UserListResponse.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loading: false,
      items: result?.list ?? const [],
      total: result?.total ?? 0,
    );
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasMore) return;
    final nextPage = state.page + 1;
    state = state.copyWith(loadingMore: true);

    final response = await _api.get<_UserListResponse>(
      _endpointForKeyword(state.keyword),
      queryParameters: {
        'pageNum': nextPage,
        'pageSize': _userListPageSize,
        if (state.keyword.trim().isNotEmpty) 'keyword': state.keyword.trim(),
        if (state.status != null) 'type': state.status,
      },
      parser: (json) =>
          _UserListResponse.fromJson(Map<String, dynamic>.from(json as Map)),
    );

    final result = response.result;
    state = state.copyWith(
      loadingMore: false,
      page: nextPage,
      items: [...state.items, ...?result?.list],
      total: result?.total ?? state.total,
    );
  }

  String _endpointForKeyword(String keyword) {
    return keyword.trim().isEmpty
        ? ApiPath.userQueryList
        : ApiPath.userSearchList;
  }
}

class UserDetailState {
  final bool loading;
  final bool loadingPayments;
  final bool loadingSwaps;
  final String cardNum;
  final UserDetail? detail;
  final List<OrderItem> orders;
  final int total;
  final List<OrderItem> saleOrders;
  final int saleOrdersPage;
  final bool saleOrdersHasMore;
  final List<OrderItem> rentOrders;
  final int rentOrdersPage;
  final bool rentOrdersHasMore;
  final List<OrderItem> swapOrders;
  final int swapOrdersPage;
  final bool swapOrdersHasMore;
  final List<UserPaymentRecord> payments;
  final int paymentsTotal;
  final int paymentsPage;
  final List<PowerChangeItem> swaps;
  final int swapsTotal;
  final int swapsPage;

  const UserDetailState({
    this.loading = false,
    this.loadingPayments = false,
    this.loadingSwaps = false,
    this.cardNum = '',
    this.detail,
    this.orders = const [],
    this.total = 0,
    this.saleOrders = const [],
    this.saleOrdersPage = 1,
    this.saleOrdersHasMore = true,
    this.rentOrders = const [],
    this.rentOrdersPage = 1,
    this.rentOrdersHasMore = true,
    this.swapOrders = const [],
    this.swapOrdersPage = 1,
    this.swapOrdersHasMore = true,
    this.payments = const [],
    this.paymentsTotal = 0,
    this.paymentsPage = 1,
    this.swaps = const [],
    this.swapsTotal = 0,
    this.swapsPage = 1,
  });

  bool get paymentsHasMore {
    if (paymentsTotal > 0) {
      return payments.length < paymentsTotal;
    }
    return payments.isNotEmpty && payments.length % _detailPageSize == 0;
  }

  bool get swapsHasMore {
    if (swapsTotal > 0) {
      return swaps.length < swapsTotal;
    }
    return swaps.isNotEmpty && swaps.length % _detailPageSize == 0;
  }

  UserDetailState copyWith({
    bool? loading,
    bool? loadingPayments,
    bool? loadingSwaps,
    String? cardNum,
    UserDetail? detail,
    List<OrderItem>? orders,
    int? total,
    List<OrderItem>? saleOrders,
    int? saleOrdersPage,
    bool? saleOrdersHasMore,
    List<OrderItem>? rentOrders,
    int? rentOrdersPage,
    bool? rentOrdersHasMore,
    List<OrderItem>? swapOrders,
    int? swapOrdersPage,
    bool? swapOrdersHasMore,
    List<UserPaymentRecord>? payments,
    int? paymentsTotal,
    int? paymentsPage,
    List<PowerChangeItem>? swaps,
    int? swapsTotal,
    int? swapsPage,
  }) {
    return UserDetailState(
      loading: loading ?? this.loading,
      loadingPayments: loadingPayments ?? this.loadingPayments,
      loadingSwaps: loadingSwaps ?? this.loadingSwaps,
      cardNum: cardNum ?? this.cardNum,
      detail: detail ?? this.detail,
      orders: orders ?? this.orders,
      total: total ?? this.total,
      saleOrders: saleOrders ?? this.saleOrders,
      saleOrdersPage: saleOrdersPage ?? this.saleOrdersPage,
      saleOrdersHasMore: saleOrdersHasMore ?? this.saleOrdersHasMore,
      rentOrders: rentOrders ?? this.rentOrders,
      rentOrdersPage: rentOrdersPage ?? this.rentOrdersPage,
      rentOrdersHasMore: rentOrdersHasMore ?? this.rentOrdersHasMore,
      swapOrders: swapOrders ?? this.swapOrders,
      swapOrdersPage: swapOrdersPage ?? this.swapOrdersPage,
      swapOrdersHasMore: swapOrdersHasMore ?? this.swapOrdersHasMore,
      payments: payments ?? this.payments,
      paymentsTotal: paymentsTotal ?? this.paymentsTotal,
      paymentsPage: paymentsPage ?? this.paymentsPage,
      swaps: swaps ?? this.swaps,
      swapsTotal: swapsTotal ?? this.swapsTotal,
      swapsPage: swapsPage ?? this.swapsPage,
    );
  }
}

final userDetailProvider =
    NotifierProvider<UserDetailNotifier, UserDetailState>(
      UserDetailNotifier.new,
    );

class UserDetailNotifier extends Notifier<UserDetailState> {
  final ApiService _api = ApiService();
  bool _loadingSaleOrders = false;
  bool _loadingRentOrders = false;
  bool _loadingSwapOrders = false;
  bool _loadingPayments = false;
  bool _loadingSwaps = false;

  @override
  UserDetailState build() => const UserDetailState();

  Future<void> loadDetail(String cardNum) async {
    if (cardNum.trim().isEmpty) return;
    state = state.copyWith(
      loading: true,
      cardNum: cardNum,
      orders: const [],
      total: 0,
      saleOrders: const [],
      saleOrdersPage: 1,
      saleOrdersHasMore: true,
      rentOrders: const [],
      rentOrdersPage: 1,
      rentOrdersHasMore: true,
      swapOrders: const [],
      swapOrdersPage: 1,
      swapOrdersHasMore: true,
      payments: const [],
      paymentsTotal: 0,
      paymentsPage: 1,
      swaps: const [],
      swapsTotal: 0,
      swapsPage: 1,
    );

    final detailResponse = await _api.get<UserDetail>(
      ApiPath.userGetDetail,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => UserDetail.fromJson(Map<String, dynamic>.from(json)),
    );

    state = state.copyWith(
      loading: false,
      detail: detailResponse.result,
      orders: const [],
      total: 0,
    );

    await loadOrders(orderType: 1, page: 1);
  }

  Future<void> loadOrders({required int orderType, int page = 1}) async {
    final num = state.cardNum;
    if (num.trim().isEmpty) return;

    if (_isOrderLoading(orderType)) {
      return;
    }

    if (page > 1) {
      final hasMore = _orderHasMore(orderType);
      final currentPage = _orderCurrentPage(orderType);
      if (!hasMore || page <= currentPage) {
        return;
      }
    }

    _setOrderLoading(orderType, true);

    try {
      final response = await _api.get<UserOrderResponse>(
        ApiPath.userQueryOrderList,
        queryParameters: {
          'cardNum': num,
          'orderType': orderType,
          'pageNum': page,
          'pageSize': _orderPageSize,
        },
        parser: (json) =>
            UserOrderResponse.fromJson(Map<String, dynamic>.from(json as Map)),
        showHud: false,
      );

      final total = response.result?.total ?? 0;
      final incoming = (response.result?.list ?? const <OrderItem>[])
          .where((item) => item.orderType == orderType)
          .toList();
      final current = _orderCurrentList(orderType);
      final merged = page == 1 ? incoming : [...current, ...incoming];
        final hasMore = total > 0
          ? merged.length < total
          : incoming.length >= _orderPageSize;

      switch (orderType) {
        case 1:
          state = state.copyWith(
            saleOrdersPage: page,
            saleOrders: merged,
            saleOrdersHasMore: hasMore,
          );
          break;
        case 2:
          state = state.copyWith(
            rentOrdersPage: page,
            rentOrders: merged,
            rentOrdersHasMore: hasMore,
          );
          break;
        case 3:
          state = state.copyWith(
            swapOrdersPage: page,
            swapOrders: merged,
            swapOrdersHasMore: hasMore,
          );
          break;
        default:
          break;
      }

      state = state.copyWith(
        orders: [...state.saleOrders, ...state.rentOrders, ...state.swapOrders],
        total: state.saleOrders.length +
            state.rentOrders.length +
            state.swapOrders.length,
      );
    } finally {
      _setOrderLoading(orderType, false);
    }
  }

  bool _isOrderLoading(int orderType) {
    switch (orderType) {
      case 1:
        return _loadingSaleOrders;
      case 2:
        return _loadingRentOrders;
      case 3:
        return _loadingSwapOrders;
      default:
        return false;
    }
  }

  void _setOrderLoading(int orderType, bool loading) {
    switch (orderType) {
      case 1:
        _loadingSaleOrders = loading;
        break;
      case 2:
        _loadingRentOrders = loading;
        break;
      case 3:
        _loadingSwapOrders = loading;
        break;
      default:
        break;
    }
  }

  bool _orderHasMore(int orderType) {
    switch (orderType) {
      case 1:
        return state.saleOrdersHasMore;
      case 2:
        return state.rentOrdersHasMore;
      case 3:
        return state.swapOrdersHasMore;
      default:
        return false;
    }
  }

  int _orderCurrentPage(int orderType) {
    switch (orderType) {
      case 1:
        return state.saleOrdersPage;
      case 2:
        return state.rentOrdersPage;
      case 3:
        return state.swapOrdersPage;
      default:
        return 1;
    }
  }

  List<OrderItem> _orderCurrentList(int orderType) {
    switch (orderType) {
      case 1:
        return state.saleOrders;
      case 2:
        return state.rentOrders;
      case 3:
        return state.swapOrders;
      default:
        return const <OrderItem>[];
    }
  }

  /// 加载用户付款记录
  Future<void> loadPayments({String? cardNum, int page = 1}) async {
    final num = cardNum ?? state.cardNum;
    if (num.trim().isEmpty) return;
    if (_loadingPayments) return;
    if (page > 1 && (!state.paymentsHasMore || page <= state.paymentsPage)) {
      return;
    }
    _loadingPayments = true;
    state = state.copyWith(loadingPayments: true);

    try {
      final response = await _api.get<UserPaymentRecordResponse>(
        ApiPath.userQueryPayList,
        queryParameters: {
          'cardNum': num,
          'pageNum': page,
          'pageSize': _detailPageSize,
        },
        parser: (json) => UserPaymentRecordResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        showHud: false,
      );

      final list = response.result?.list ?? const [];
      state = state.copyWith(
        paymentsPage: page,
        payments: page == 1 ? list : [...state.payments, ...list],
        paymentsTotal: response.result?.total ?? state.paymentsTotal,
      );
    } finally {
      _loadingPayments = false;
      state = state.copyWith(loadingPayments: false);
    }
  }

  /// 加载用户换电记录
  Future<void> loadSwaps({String? cardNum, int page = 1}) async {
    final num = cardNum ?? state.cardNum;
    if (num.trim().isEmpty) return;
    if (_loadingSwaps) return;
    if (page > 1 && (!state.swapsHasMore || page <= state.swapsPage)) {
      return;
    }
    _loadingSwaps = true;
    state = state.copyWith(loadingSwaps: true);

    try {
      final response = await _api.get<PowerChangeResponse>(
        ApiPath.userQuerySwapPage,
        queryParameters: {
          'cardNum': num,
          'pageNum': page,
          'pageSize': _detailPageSize,
        },
        parser: (json) => PowerChangeResponse.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
        showHud: false,
      );

      final list = response.result?.list ?? const [];
      state = state.copyWith(
        swapsPage: page,
        swaps: page == 1 ? list : [...state.swaps, ...list],
        swapsTotal: response.result?.total ?? state.swapsTotal,
      );
    } finally {
      _loadingSwaps = false;
      state = state.copyWith(loadingSwaps: false);
    }
  }

  Future<_UploadResult> uploadOrderVouchers(
    List<String> filePaths, {
    void Function(double progress)? onProgress,
  }) async {
    final urls = <String>[];
    final failed = <String>[];
    final total = filePaths.length;
    for (var index = 0; index < total; index++) {
      final path = filePaths[index];
      final base = index / total;
      final result = await _uploadVoucherWithRetry(
        path,
        onProgress: (sent, totalBytes) {
          if (totalBytes <= 0) return;
          final fraction = sent / totalBytes;
          onProgress?.call((base + fraction / total).clamp(0.0, 1.0));
        },
      );
      if (result == null || result.isEmpty) {
        failed.add(path);
      } else {
        urls.add(result);
      }
      onProgress?.call(((index + 1) / total).clamp(0.0, 1.0));
    }
    return _UploadResult(urls: urls, failed: failed);
  }

  Future<bool> confirmPayOrder({
    required String orderNo,
    required String attachment,
  }) async {
    if (state.cardNum.trim().isEmpty) return false;
    final response = await _api.post<Object>(
      ApiPath.userConfirmPayOrder,
      data: {
        'attachment': attachment,
        'cardNum': state.cardNum,
        'orderNo': orderNo,
      },
      parser: (json) => json ?? Object(),
    );
    return response.isSuccess;
  }

  void updateOrderAttachment({
    required String orderNo,
    required int orderType,
    required String attachment,
    int? newStatus,
  }) {
    List<OrderItem> patch(List<OrderItem> source) {
      return source.map((order) {
        if (order.orderNo != orderNo || order.orderType != orderType) {
          return order;
        }
        return _copyOrderWithAttachment(order, attachment, newStatus);
      }).toList();
    }

    final nextSale = patch(state.saleOrders);
    final nextRent = patch(state.rentOrders);
    final nextSwap = patch(state.swapOrders);
    final nextOrders = patch(state.orders);

    state = state.copyWith(
      saleOrders: nextSale,
      rentOrders: nextRent,
      swapOrders: nextSwap,
      orders: nextOrders,
    );
  }

  OrderItem _copyOrderWithAttachment(
    OrderItem order,
    String attachment,
    int? newStatus,
  ) {
    SaleOrder? saleOrder = order.saleOrder;
    RentOrder? rentOrder = order.rentOrder;
    OtherOrder? otherOrder = order.otherOrder;

    if (order.orderType == 1 && saleOrder != null) {
      saleOrder = SaleOrder(
        deviceImg: saleOrder.deviceImg,
        deviceModel: saleOrder.deviceModel,
        deviceSn: saleOrder.deviceSn,
        deviceType: saleOrder.deviceType,
        payType: saleOrder.payType,
        perAmount: saleOrder.perAmount,
        period: saleOrder.period,
        rate: saleOrder.rate,
        status: newStatus ?? saleOrder.status,
        attachment: attachment,
        createTime: saleOrder.createTime,
        orderAmount: saleOrder.orderAmount,
        orderNo: saleOrder.orderNo,
        payWay: saleOrder.payWay,
      );
    }

    if (order.orderType == 2 && rentOrder != null) {
      rentOrder = RentOrder(
        depositAmount: rentOrder.depositAmount,
        deviceImg: rentOrder.deviceImg,
        deviceModel: rentOrder.deviceModel,
        deviceSn: rentOrder.deviceSn,
        deviceType: rentOrder.deviceType,
        duration: rentOrder.duration,
        expireDate: rentOrder.expireDate,
        remainDuration: rentOrder.remainDuration,
        serviceAmount: rentOrder.serviceAmount,
        status: newStatus ?? rentOrder.status,
        attachment: attachment,
        createTime: rentOrder.createTime,
        orderAmount: rentOrder.orderAmount,
        orderNo: rentOrder.orderNo,
        payWay: rentOrder.payWay,
        payType: rentOrder.payType,
        infoName: rentOrder.infoName,
      );
    }

    if (order.orderType == 3 && otherOrder != null) {
      otherOrder = OtherOrder(
        batteryNum: otherOrder.batteryNum,
        batteryType: otherOrder.batteryType,
        carType: otherOrder.carType,
        duration: otherOrder.duration,
        expireDate: otherOrder.expireDate,
        remainDuration: otherOrder.remainDuration,
        remainTime: otherOrder.remainTime,
        serviceAmount: otherOrder.serviceAmount,
        status: newStatus ?? otherOrder.status,
        times: otherOrder.times,
        attachment: attachment,
        createTime: otherOrder.createTime,
        orderAmount: otherOrder.orderAmount,
        orderNo: otherOrder.orderNo,
        payWay: otherOrder.payWay,
        payType: otherOrder.payType,
        infoName: otherOrder.infoName,
      );
    }

    return OrderItem(
      attachment: attachment,
      createTime: order.createTime,
      orderAmount: order.orderAmount,
      orderNo: order.orderNo,
      payWay: order.payWay,
      orderType: order.orderType,
      otherOrder: otherOrder,
      rentOrder: rentOrder,
      saleOrder: saleOrder,
    );
  }

  Future<String?> _uploadVoucherWithRetry(
    String path, {
    required void Function(int sent, int totalBytes) onProgress,
  }) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final data = await _compressImage(path);
        if (data == null || data.isEmpty) {
          return null;
        }
        final fileName = _buildFileName(path);
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(data, filename: fileName),
        });
        final response = await _api.postForm<String>(
          ApiPath.userUploadAttachment,
          data: formData,
          parser: (json) => json?.toString() ?? '',
          onSendProgress: onProgress,
        );
        if (response.isSuccess && (response.result?.isNotEmpty ?? false)) {
          return response.result;
        }
      } catch (_) {
        if (attempt == maxAttempts) {
          return null;
        }
      }
    }
    return null;
  }

  Future<Uint8List?> _compressImage(String path) async {
    return FlutterImageCompress.compressWithFile(
      path,
      quality: 80,
      minWidth: 612,
      minHeight: 816,
      format: CompressFormat.jpeg,
    );
  }

  String _buildFileName(String path) {
    final segments = path.split('/');
    final last = segments.isEmpty ? '' : segments.last;
    final extIndex = last.lastIndexOf('.');
    final ext = extIndex == -1 ? 'jpg' : last.substring(extIndex + 1);
    return '${DateTime.now().millisecondsSinceEpoch}.$ext';
  }
}

class _UploadResult {
  const _UploadResult({required this.urls, required this.failed});

  final List<String> urls;
  final List<String> failed;
}

class _UserListResponse {
  final List<UserInfo> list;
  final int total;

  const _UserListResponse({required this.list, required this.total});

  factory _UserListResponse.fromJson(Map<String, dynamic> json) {
    return _UserListResponse(
      list:
          (json['list'] as List<dynamic>?)
              ?.map(
                (item) =>
                    UserInfo.fromJson(Map<String, dynamic>.from(item as Map)),
              )
              .toList() ??
          const <UserInfo>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}
