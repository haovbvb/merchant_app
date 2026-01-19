import 'package:flutter/foundation.dart';
import 'package:merchant_app/data/models/charge_history.dart';

@immutable
class ChargeHistoryResponse {
  final List<ChargeHistory> list;
  final int total;

  const ChargeHistoryResponse({
    required this.list,
    required this.total,
  });

  factory ChargeHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChargeHistoryResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => ChargeHistory.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}
