import 'package:flutter/foundation.dart';

@immutable
class SNBean {
  final String lockIcId;
  final String lockDevId;

  const SNBean({
    required this.lockIcId,
    required this.lockDevId,
  });

  factory SNBean.fromJson(Map<String, dynamic> json) {
    return SNBean(
      lockIcId: (json['lockIcId'] ?? '').toString(),
      lockDevId: (json['lockDevId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lockIcId': lockIcId,
        'lockDevId': lockDevId,
      };
}
