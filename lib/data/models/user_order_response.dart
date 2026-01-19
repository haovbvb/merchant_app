import 'package:flutter/foundation.dart';

@immutable
class UserOrderResponse {
  final List<OrderItem>? list;
  final int total;

  const UserOrderResponse({
    required this.list,
    required this.total,
  });

  factory UserOrderResponse.fromJson(Map<String, dynamic> json) {
    return UserOrderResponse(
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list?.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class OrderItem {
  final String attachment;
  final int? createTime;
  final double orderAmount;
  final String orderNo;
  final int payWay;
  final int orderType;
  final OtherOrder? otherOrder;
  final RentOrder? rentOrder;
  final SaleOrder? saleOrder;

  const OrderItem({
    required this.attachment,
    required this.createTime,
    required this.orderAmount,
    required this.orderNo,
    required this.payWay,
    required this.orderType,
    required this.otherOrder,
    required this.rentOrder,
    required this.saleOrder,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      attachment: (json['attachment'] ?? '').toString(),
      createTime: (json['createTime'] as num?)?.toInt(),
      orderAmount: (json['orderAmount'] as num?)?.toDouble() ?? 0,
      orderNo: (json['orderNo'] ?? '').toString(),
      payWay: (json['payWay'] as num?)?.toInt() ?? 0,
      orderType: (json['orderType'] as num?)?.toInt() ?? 0,
      otherOrder: json['otherOrder'] is Map<String, dynamic>
          ? OtherOrder.fromJson(
              Map<String, dynamic>.from(json['otherOrder'] as Map),
            )
          : null,
      rentOrder: json['rentOrder'] is Map<String, dynamic>
          ? RentOrder.fromJson(
              Map<String, dynamic>.from(json['rentOrder'] as Map),
            )
          : null,
      saleOrder: json['saleOrder'] is Map<String, dynamic>
          ? SaleOrder.fromJson(
              Map<String, dynamic>.from(json['saleOrder'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'attachment': attachment,
        'createTime': createTime,
        'orderAmount': orderAmount,
        'orderNo': orderNo,
        'payWay': payWay,
        'orderType': orderType,
        'otherOrder': otherOrder?.toJson(),
        'rentOrder': rentOrder?.toJson(),
        'saleOrder': saleOrder?.toJson(),
      };
}

@immutable
class OtherOrder {
  final int? batteryNum;
  final String? batteryType;
  final String? carType;
  final int? duration;
  final int? expireDate;
  final int? remainDuration;
  final int? remainTime;
  final double? serviceAmount;
  final int? status;
  final int? times;
  final String? attachment;
  final int? createTime;
  final double? orderAmount;
  final String? orderNo;
  final int? payWay;
  final int? payType;
  final String? infoName;

  const OtherOrder({
    required this.batteryNum,
    required this.batteryType,
    required this.carType,
    required this.duration,
    required this.expireDate,
    required this.remainDuration,
    required this.remainTime,
    required this.serviceAmount,
    required this.status,
    required this.times,
    required this.attachment,
    required this.createTime,
    required this.orderAmount,
    required this.orderNo,
    required this.payWay,
    required this.payType,
    required this.infoName,
  });

  factory OtherOrder.fromJson(Map<String, dynamic> json) {
    return OtherOrder(
      batteryNum: (json['batteryNum'] as num?)?.toInt(),
      batteryType: json['batteryType']?.toString() ?? '',
      carType: json['carType']?.toString() ?? '',
      duration: (json['duration'] as num?)?.toInt(),
      expireDate: (json['expireDate'] as num?)?.toInt(),
      remainDuration: (json['remainDuration'] as num?)?.toInt(),
      remainTime: (json['remainTime'] as num?)?.toInt(),
      serviceAmount: (json['serviceAmount'] as num?)?.toDouble(),
      status: (json['status'] as num?)?.toInt(),
      times: (json['times'] as num?)?.toInt(),
      attachment: json['attachment']?.toString() ?? '',
      createTime: (json['createTime'] as num?)?.toInt(),
      orderAmount: (json['orderAmount'] as num?)?.toDouble(),
      orderNo: json['orderNo']?.toString() ?? '',
      payWay: (json['payWay'] as num?)?.toInt(),
      payType: (json['payType'] as num?)?.toInt(),
      infoName: json['infoName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'batteryNum': batteryNum,
        'batteryType': batteryType,
        'carType': carType,
        'duration': duration,
        'expireDate': expireDate,
        'remainDuration': remainDuration,
        'remainTime': remainTime,
        'serviceAmount': serviceAmount,
        'status': status,
        'times': times,
        'attachment': attachment,
        'createTime': createTime,
        'orderAmount': orderAmount,
        'orderNo': orderNo,
        'payWay': payWay,
        'payType': payType,
        'infoName': infoName,
      };
}

@immutable
class RentOrder {
  final double? depositAmount;
  final String? deviceImg;
  final String? deviceModel;
  final String? deviceSn;
  final int? deviceType;
  final int? duration;
  final int? expireDate;
  final int? remainDuration;
  final double? serviceAmount;
  final int? status;
  final String? attachment;
  final int? createTime;
  final double? orderAmount;
  final String? orderNo;
  final int? payWay;
  final int? payType;
  final String? infoName;

  const RentOrder({
    required this.depositAmount,
    required this.deviceImg,
    required this.deviceModel,
    required this.deviceSn,
    required this.deviceType,
    required this.duration,
    required this.expireDate,
    required this.remainDuration,
    required this.serviceAmount,
    required this.status,
    required this.attachment,
    required this.createTime,
    required this.orderAmount,
    required this.orderNo,
    required this.payWay,
    required this.payType,
    required this.infoName,
  });

  factory RentOrder.fromJson(Map<String, dynamic> json) {
    return RentOrder(
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      deviceImg: json['deviceImg']?.toString() ?? '',
      deviceModel: json['deviceModel']?.toString(),
      deviceSn: json['deviceSn']?.toString(),
      deviceType: (json['deviceType'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      expireDate: (json['expireDate'] as num?)?.toInt(),
      remainDuration: (json['remainDuration'] as num?)?.toInt(),
      serviceAmount: (json['serviceAmount'] as num?)?.toDouble(),
      status: (json['status'] as num?)?.toInt(),
      attachment: json['attachment']?.toString() ?? '',
      createTime: (json['createTime'] as num?)?.toInt(),
      orderAmount: (json['orderAmount'] as num?)?.toDouble(),
      orderNo: json['orderNo']?.toString(),
      payWay: (json['payWay'] as num?)?.toInt(),
      payType: (json['payType'] as num?)?.toInt(),
      infoName: json['infoName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'depositAmount': depositAmount,
        'deviceImg': deviceImg,
        'deviceModel': deviceModel,
        'deviceSn': deviceSn,
        'deviceType': deviceType,
        'duration': duration,
        'expireDate': expireDate,
        'remainDuration': remainDuration,
        'serviceAmount': serviceAmount,
        'status': status,
        'attachment': attachment,
        'createTime': createTime,
        'orderAmount': orderAmount,
        'orderNo': orderNo,
        'payWay': payWay,
        'payType': payType,
        'infoName': infoName,
      };
}

@immutable
class SaleOrder {
  final String deviceImg;
  final String deviceModel;
  final String? deviceSn;
  final int deviceType;
  final int payType;
  final double? perAmount;
  final int? period;
  final double? rate;
  final int? status;
  final String? attachment;
  final int? createTime;
  final double? orderAmount;
  final String? orderNo;
  final int? payWay;

  const SaleOrder({
    required this.deviceImg,
    required this.deviceModel,
    required this.deviceSn,
    required this.deviceType,
    required this.payType,
    required this.perAmount,
    required this.period,
    required this.rate,
    required this.status,
    required this.attachment,
    required this.createTime,
    required this.orderAmount,
    required this.orderNo,
    required this.payWay,
  });

  factory SaleOrder.fromJson(Map<String, dynamic> json) {
    return SaleOrder(
      deviceImg: (json['deviceImg'] ?? '').toString(),
      deviceModel: (json['deviceModel'] ?? '').toString(),
      deviceSn: json['deviceSn']?.toString(),
      deviceType: (json['deviceType'] as num?)?.toInt() ?? 0,
      payType: (json['payType'] as num?)?.toInt() ?? 0,
      perAmount: (json['perAmount'] as num?)?.toDouble(),
      period: (json['period'] as num?)?.toInt(),
      rate: (json['rate'] as num?)?.toDouble(),
      status: (json['status'] as num?)?.toInt(),
      attachment: json['attachment']?.toString() ?? '',
      createTime: (json['createTime'] as num?)?.toInt(),
      orderAmount: (json['orderAmount'] as num?)?.toDouble(),
      orderNo: json['orderNo']?.toString(),
      payWay: (json['payWay'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceImg': deviceImg,
        'deviceModel': deviceModel,
        'deviceSn': deviceSn,
        'deviceType': deviceType,
        'payType': payType,
        'perAmount': perAmount,
        'period': period,
        'rate': rate,
        'status': status,
        'attachment': attachment,
        'createTime': createTime,
        'orderAmount': orderAmount,
        'orderNo': orderNo,
        'payWay': payWay,
      };
}
