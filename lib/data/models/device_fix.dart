import 'package:flutter/foundation.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';

@immutable
class DeviceFix {
  final BatteryVo? batteryVo;
  final CarVo? carVo;
  final StationVo? stationVo;
  final int deviceType;
  final List<DeviceFixProject> itemList;
  final List<DeviceFixResult> resultList;

  const DeviceFix({
    required this.batteryVo,
    required this.carVo,
    required this.stationVo,
    required this.deviceType,
    required this.itemList,
    required this.resultList,
  });

  factory DeviceFix.fromJson(Map<String, dynamic> json) {
    return DeviceFix(
      batteryVo: json['batteryVo'] is Map<String, dynamic>
          ? BatteryVo.fromJson(
              Map<String, dynamic>.from(json['batteryVo'] as Map),
            )
          : null,
      carVo: json['carVo'] is Map<String, dynamic>
          ? CarVo.fromJson(Map<String, dynamic>.from(json['carVo'] as Map))
          : null,
      stationVo: json['stationVo'] is Map<String, dynamic>
          ? StationVo.fromJson(
              Map<String, dynamic>.from(json['stationVo'] as Map),
            )
          : null,
      deviceType: (json['deviceType'] as num?)?.toInt() ?? 0,
      itemList: (json['itemList'] as List<dynamic>?)
              ?.map((item) => DeviceFixProject.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceFixProject>[],
      resultList: (json['resultList'] as List<dynamic>?)
              ?.map((item) => DeviceFixResult.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceFixResult>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'batteryVo': batteryVo?.toJson(),
        'carVo': carVo?.toJson(),
        'stationVo': stationVo?.toJson(),
        'deviceType': deviceType,
        'itemList': itemList.map((item) => item.toJson()).toList(),
        'resultList': resultList.map((item) => item.toJson()).toList(),
      };
}

@immutable
class DeviceFixProject {
  final String itemNo;
  final String itemName;
  final bool isSelect;

  const DeviceFixProject({
    required this.itemNo,
    required this.itemName,
    required this.isSelect,
  });

  factory DeviceFixProject.fromJson(Map<String, dynamic> json) {
    return DeviceFixProject(
      itemNo: (json['itemNo'] ?? '').toString(),
      itemName: (json['itemName'] ?? '-').toString(),
      isSelect: json['isSelect'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemNo': itemNo,
        'itemName': itemName,
        'isSelect': isSelect,
      };
}

@immutable
class DeviceFixResult {
  final String result;
  final String code;
  final bool isSelect;

  const DeviceFixResult({
    required this.result,
    required this.code,
    required this.isSelect,
  });

  factory DeviceFixResult.fromJson(Map<String, dynamic> json) {
    return DeviceFixResult(
      result: (json['result'] ?? '-').toString(),
      code: (json['code'] ?? '-').toString(),
      isSelect: json['isSelect'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'result': result,
        'code': code,
        'isSelect': isSelect,
      };
}
