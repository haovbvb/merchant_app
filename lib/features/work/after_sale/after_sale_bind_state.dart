import 'package:flutter/foundation.dart';
import 'package:merchant_app/data/models/after_sale_can_bind_order_bean.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/user_detail.dart';

@immutable
class AfterSaleBindState {
  final String cardNum;
  final String deviceSn;
  final bool loading;
  final bool binding;
  final UserDetail? userDetail;
  final List<AfterSaleCanBindOrderBean> orders;
  final AfterSaleCanBindOrderBean? selectedOrder;
  final BatterOrVehicleInfo? deviceInfo;

  const AfterSaleBindState({
    this.cardNum = '',
    this.deviceSn = '',
    this.loading = false,
    this.binding = false,
    this.userDetail,
    this.orders = const [],
    this.selectedOrder,
    this.deviceInfo,
  });

  AfterSaleBindState copyWith({
    String? cardNum,
    String? deviceSn,
    bool? loading,
    bool? binding,
    UserDetail? userDetail,
    List<AfterSaleCanBindOrderBean>? orders,
    AfterSaleCanBindOrderBean? selectedOrder,
    BatterOrVehicleInfo? deviceInfo,
  }) {
    return AfterSaleBindState(
      cardNum: cardNum ?? this.cardNum,
      deviceSn: deviceSn ?? this.deviceSn,
      loading: loading ?? this.loading,
      binding: binding ?? this.binding,
      userDetail: userDetail ?? this.userDetail,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
}
