import 'package:flutter/foundation.dart';

import 'batter_or_vehicle_info.dart';
import 'pack.dart';

@immutable
class RentDeviceInfoBean {
  final CarVo? carVo;
  final BatteryVo? batteryVo;
  final List<Pack> packList;

  const RentDeviceInfoBean({
    required this.carVo,
    required this.batteryVo,
    required this.packList,
  });

  factory RentDeviceInfoBean.fromJson(Map<String, dynamic> json) {
    return RentDeviceInfoBean(
      carVo: json['carVo'] is Map<String, dynamic>
          ? CarVo.fromJson(Map<String, dynamic>.from(json['carVo'] as Map))
          : null,
      batteryVo: json['batteryVo'] is Map<String, dynamic>
          ? BatteryVo.fromJson(
              Map<String, dynamic>.from(json['batteryVo'] as Map),
            )
          : null,
      packList: (json['packList'] as List<dynamic>?)
              ?.map((item) => Pack.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <Pack>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'carVo': carVo?.toJson(),
        'batteryVo': batteryVo?.toJson(),
        'packList': packList.map((item) => item.toJson()).toList(),
      };
}
