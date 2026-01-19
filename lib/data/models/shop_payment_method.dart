import 'package:flutter/foundation.dart';

@immutable
class ShopPaymentMethod {
  final String? salePayWay;
  final String? otherPayWay;
  final String? saleCashOption;
  final String? saleOnlineOption;
  final String? shopNo;
  final String? name;

  const ShopPaymentMethod({
    required this.salePayWay,
    required this.otherPayWay,
    required this.saleCashOption,
    required this.saleOnlineOption,
    required this.shopNo,
    required this.name,
  });

  factory ShopPaymentMethod.fromJson(Map<String, dynamic> json) {
    return ShopPaymentMethod(
      salePayWay: json['salePayWay']?.toString(),
      otherPayWay: json['otherPayWay']?.toString(),
      saleCashOption: json['saleCashOption']?.toString(),
      saleOnlineOption: json['saleOnlineOption']?.toString(),
      shopNo: json['shopNo']?.toString(),
      name: json['name']?.toString(),
    );
  }
}
