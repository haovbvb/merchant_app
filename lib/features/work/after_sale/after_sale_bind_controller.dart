import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/after_sale_can_bind_order_bean.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/user_detail.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class AfterSaleBindState {
  final bool loading;
  final bool binding;
  final String cardNum;
  final String deviceSn;
  final UserDetail? userDetail;
  final List<AfterSaleCanBindOrderBean> orders;
  final AfterSaleCanBindOrderBean? selectedOrder;
  final BatterOrVehicleInfo? deviceInfo;
  final String? errorMessage;

  const AfterSaleBindState({
    this.loading = false,
    this.binding = false,
    this.cardNum = '',
    this.deviceSn = '',
    this.userDetail,
    this.orders = const [],
    this.selectedOrder,
    this.deviceInfo,
    this.errorMessage,
  });

  AfterSaleBindState copyWith({
    bool? loading,
    bool? binding,
    String? cardNum,
    String? deviceSn,
    UserDetail? userDetail,
    List<AfterSaleCanBindOrderBean>? orders,
    AfterSaleCanBindOrderBean? selectedOrder,
    BatterOrVehicleInfo? deviceInfo,
    String? errorMessage,
  }) {
    return AfterSaleBindState(
      loading: loading ?? this.loading,
      binding: binding ?? this.binding,
      cardNum: cardNum ?? this.cardNum,
      deviceSn: deviceSn ?? this.deviceSn,
      userDetail: userDetail ?? this.userDetail,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      errorMessage: errorMessage,
    );
  }
}

final afterSaleBindProvider =
    NotifierProvider<AfterSaleBindNotifier, AfterSaleBindState>(
  AfterSaleBindNotifier.new,
);

class AfterSaleBindNotifier extends Notifier<AfterSaleBindState> {
  final ApiService _apiService = ApiService();

  @override
  AfterSaleBindState build() => const AfterSaleBindState();

  void updateCardNum(String value) {
    if (value == state.cardNum) return;
    state = state.copyWith(
      cardNum: value,
      errorMessage: null,
    );
  }

  void updateDeviceSn(String value) {
    if (value == state.deviceSn) return;
    state = state.copyWith(
      deviceSn: value,
      errorMessage: null,
    );
  }

  void selectOrder(AfterSaleCanBindOrderBean? order) {
    state = state.copyWith(
      selectedOrder: order,
      deviceSn: '',
      deviceInfo: null,
    );
  }

  Future<bool> fetchUserDetail() async {
    final cardNum = state.cardNum.trim();
    if (cardNum.isEmpty) {
      state = state.copyWith(
        userDetail: null,
        orders: const [],
        selectedOrder: null,
        deviceSn: '',
        deviceInfo: null,
        errorMessage: null,
      );
      return false;
    }

    state = state.copyWith(
      loading: true,
      errorMessage: null,
      userDetail: null,
      orders: const [],
      selectedOrder: null,
      deviceSn: '',
      deviceInfo: null,
    );
    final response = await _apiService.get<UserDetail>(
      ApiPath.afterSaleQueryUserForBindOrder,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => UserDetail.fromJson(Map<String, dynamic>.from(json)),
    );

    if (!response.isSuccess || response.result == null) {
      state = state.copyWith(
        loading: false,
        userDetail: null,
        orders: const [],
        selectedOrder: null,
        deviceInfo: null,
        deviceSn: '',
        errorMessage: response.message,
      );
      return false;
    }

    state = state.copyWith(
      loading: false,
      userDetail: response.result,
      deviceSn: '',
      errorMessage: null,
    );

    final orderSuccess = await fetchOrders(cardNum);
    return orderSuccess;
  }

  Future<bool> fetchOrders(String cardNum) async {
    final response = await _apiService.get<List<AfterSaleCanBindOrderBean>>(
      ApiPath.afterSaleQueryCanBindOrderList,
      queryParameters: {'cardNum': cardNum},
      parser: (json) => (json as List<dynamic>)
          .map((item) => AfterSaleCanBindOrderBean.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );

    if (!response.isSuccess) {
      state = state.copyWith(
        orders: const [],
        selectedOrder: null,
        deviceSn: '',
        deviceInfo: null,
        errorMessage: response.message,
      );
      return false;
    }

    state = state.copyWith(
      orders: response.result ?? const [],
      selectedOrder: null,
      deviceSn: '',
      deviceInfo: null,
      errorMessage: null,
    );
    return true;
  }

  Future<bool> fetchDeviceInfo() async {
    final order = state.selectedOrder;
    final deviceSn = state.deviceSn.trim();
    if (order == null || deviceSn.isEmpty) {
      state = state.copyWith(
        deviceInfo: null,
        errorMessage: null,
      );
      return false;
    }

    final model = order.deviceType == 1 ? order.batteryType : order.carType;
    state = state.copyWith(deviceInfo: null, errorMessage: null);
    final response = await _apiService.get<BatterOrVehicleInfo>(
      ApiPath.afterSaleQueryDeviceForBindOrder,
      queryParameters: {
        'sn': deviceSn,
        'model': model ?? '',
        'deviceType': order.deviceType ?? -1,
      },
      parser: (json) =>
          BatterOrVehicleInfo.fromJson(Map<String, dynamic>.from(json)),
    );

    if (!response.isSuccess || response.result == null) {
      state = state.copyWith(
        deviceInfo: null,
        errorMessage: response.message,
      );
      return false;
    }

    state = state.copyWith(
      deviceInfo: response.result,
      errorMessage: null,
    );
    return true;
  }

  Future<bool> bindOrder() async {
    final order = state.selectedOrder;
    final cardNum = state.cardNum.trim();
    final deviceSn = state.deviceSn.trim();
    if (order == null || cardNum.isEmpty || deviceSn.isEmpty) {
      return false;
    }

    state = state.copyWith(binding: true, errorMessage: null);
    final response = await _apiService.post<String>(
      ApiPath.afterSaleBindOrderDevice,
      data: {
        'cardNum': cardNum,
        'deviceSn': deviceSn,
        'deviceType': order.deviceType ?? -1,
        'orderNo': order.orderNo ?? '',
      },
      parser: (json) => json?.toString() ?? '',
    );

    state = state.copyWith(binding: false);
    if (!response.isSuccess) {
      state = state.copyWith(errorMessage: response.message);
    }
    return response.isSuccess;
  }

  void reset() {
    state = const AfterSaleBindState();
  }
}
