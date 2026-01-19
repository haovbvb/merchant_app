import 'package:flutter/foundation.dart';

@immutable
class AfterSaleCanBindOrderBean {
  final String? batteryType;
  final String? carType;
  final int? deviceType;
  final String? orderNo;
  final int? status;
  final int? type;
  final bool isSelected;

  const AfterSaleCanBindOrderBean({
    this.batteryType,
    this.carType,
    this.deviceType,
    this.orderNo,
    this.status,
    this.type,
    this.isSelected = false,
  });

  factory AfterSaleCanBindOrderBean.fromJson(Map<String, dynamic> json) {
    return AfterSaleCanBindOrderBean(
      batteryType: json['batteryType']?.toString(),
      carType: json['carType']?.toString(),
      deviceType: (json['deviceType'] as num?)?.toInt(),
      orderNo: json['orderNo']?.toString(),
      status: (json['status'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      isSelected: json['isSelected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'batteryType': batteryType,
        'carType': carType,
        'deviceType': deviceType,
        'orderNo': orderNo,
        'status': status,
        'type': type,
        'isSelected': isSelected,
      };
}
