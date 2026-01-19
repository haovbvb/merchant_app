import 'package:flutter/foundation.dart';

@immutable
class SellDataListResponse {
  final List<OrderItem>? list;
  final int? total;

  const SellDataListResponse({
    required this.list,
    required this.total,
  });

  factory SellDataListResponse.fromJson(Map<String, dynamic> json) {
    return SellDataListResponse(
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      total: (json['total'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list?.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class OrderItem {
  final double? amount;
  final String? orderNo;
  final int? orderType;
  final int? payType;
  final int? payWay;
  final String? attachment;

  const OrderItem({
    required this.amount,
    required this.orderNo,
    required this.orderType,
    required this.payType,
    required this.payWay,
    required this.attachment,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      amount: (json['amount'] as num?)?.toDouble(),
      orderNo: json['orderNo']?.toString(),
      orderType: (json['orderType'] as num?)?.toInt(),
      payType: (json['payType'] as num?)?.toInt(),
      payWay: (json['payWay'] as num?)?.toInt(),
      attachment: json['attachment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'orderNo': orderNo,
        'orderType': orderType,
        'payType': payType,
        'payWay': payWay,
        'attachment': attachment,
      };
}
