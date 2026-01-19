import 'package:flutter/foundation.dart';

@immutable
class Pack {
  final double? depositAmount;
  final int? duration;
  final double? haveDeposit;
  final String? infoCode;
  final String? infoName;
  final int? infoType;
  final double? packageAmount;
  final int? batteryNum;
  final String? batteryType;
  final String? carType;
  final int? times;
  final bool isSelected;

  const Pack({
    required this.depositAmount,
    required this.duration,
    required this.haveDeposit,
    required this.infoCode,
    required this.infoName,
    required this.infoType,
    required this.packageAmount,
    required this.batteryNum,
    required this.batteryType,
    required this.carType,
    required this.times,
    required this.isSelected,
  });

  factory Pack.fromJson(Map<String, dynamic> json) {
    return Pack(
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toInt(),
      haveDeposit: (json['haveDeposit'] as num?)?.toDouble(),
      infoCode: json['infoCode']?.toString() ?? '-',
      infoName: json['infoName']?.toString() ?? '-',
      infoType: (json['infoType'] as num?)?.toInt(),
      packageAmount: (json['packageAmount'] as num?)?.toDouble(),
      batteryNum: (json['batteryNum'] as num?)?.toInt(),
      batteryType: json['batteryType']?.toString() ?? '-',
      carType: json['carType']?.toString() ?? '-',
      times: (json['times'] as num?)?.toInt(),
      isSelected: json['isSelected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'depositAmount': depositAmount,
        'duration': duration,
        'haveDeposit': haveDeposit,
        'infoCode': infoCode,
        'infoName': infoName,
        'infoType': infoType,
        'packageAmount': packageAmount,
        'batteryNum': batteryNum,
        'batteryType': batteryType,
        'carType': carType,
        'times': times,
        'isSelected': isSelected,
      };
}
