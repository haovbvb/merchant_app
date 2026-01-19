import 'package:flutter/foundation.dart';

@immutable
class SaleData {
  final double? orderIncome;
  final int? orderNum;
  final String? today;

  const SaleData({
    required this.orderIncome,
    required this.orderNum,
    required this.today,
  });

  factory SaleData.fromJson(Map<String, dynamic> json) {
    return SaleData(
      orderIncome: (json['orderIncome'] as num?)?.toDouble(),
      orderNum: (json['orderNum'] as num?)?.toInt(),
      today: json['today']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'orderIncome': orderIncome,
        'orderNum': orderNum,
        'today': today,
      };
}
