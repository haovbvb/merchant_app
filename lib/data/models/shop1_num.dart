import 'package:flutter/foundation.dart';

@immutable
class Shop1Num {
  final int? all;
  final int? direct;
  final int? franchise;

  const Shop1Num({
    required this.all,
    required this.direct,
    required this.franchise,
  });

  factory Shop1Num.fromJson(Map<String, dynamic> json) {
    return Shop1Num(
      all: (json['all'] as num?)?.toInt(),
      direct: (json['direct'] as num?)?.toInt(),
      franchise: (json['franchise'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'all': all,
        'direct': direct,
        'franchise': franchise,
      };
}
