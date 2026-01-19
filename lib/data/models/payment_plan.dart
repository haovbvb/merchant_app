import 'package:flutter/foundation.dart';

@immutable
class PaymentPlan {
  final double? amount;
  final double? fee;
  final double? perAmount;
  final int? period;
  final String? planName;
  final String? planNo;
  final double? rate;
  final double? totalAmount;
  final bool selected;

  const PaymentPlan({
    required this.amount,
    required this.fee,
    required this.perAmount,
    required this.period,
    required this.planName,
    required this.planNo,
    required this.rate,
    required this.totalAmount,
    required this.selected,
  });

  factory PaymentPlan.fromJson(Map<String, dynamic> json) {
    return PaymentPlan(
      amount: (json['amount'] as num?)?.toDouble(),
      fee: (json['fee'] as num?)?.toDouble(),
      perAmount: (json['perAmount'] as num?)?.toDouble(),
      period: (json['period'] as num?)?.toInt(),
      planName: json['planName']?.toString(),
      planNo: json['planNo']?.toString(),
      rate: (json['rate'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      selected: json['selected'] == true,
    );
  }
}