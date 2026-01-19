import 'package:flutter/foundation.dart';

@immutable
class ChargeHistory {
  final String? chargeValue;
  final String? chargeTime;
  final String? date;

  const ChargeHistory({
    this.chargeValue,
    this.chargeTime,
    this.date,
  });

  factory ChargeHistory.fromJson(Map<String, dynamic> json) {
    return ChargeHistory(
      chargeValue: json['chargeValue']?.toString(),
      chargeTime: json['chargeTime']?.toString(),
      date: json['date']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'chargeValue': chargeValue,
        'chargeTime': chargeTime,
        'date': date,
      };
}
