import 'package:flutter/foundation.dart';

/// 电柜仓位信息模型
/// 对应 Android 的 Cabin.java
@immutable
class CabinetCabin {
  /// 仓位号
  final int portNo;
  
  /// 仓位名称
  final String slotName;
  
  /// 电池SN
  final String batterySn;
  
  /// 电池状态 (0: 无电池, 1: 有电池)
  final int batteryStatus;
  
  /// 电池电量 (0-100)
  final int batterySoc;
  
  /// 仓门状态 (0: 禁用, 1: 可用)
  final int status;
  
  /// 是否可换电 (0: 不可换, 1: 可换)
  final int swapFlag;

  const CabinetCabin({
    required this.portNo,
    this.slotName = '',
    this.batterySn = '',
    this.batteryStatus = 0,
    this.batterySoc = 0,
    this.status = 0,
    this.swapFlag = 0,
  });

  CabinetCabin copyWith({
    int? portNo,
    String? slotName,
    String? batterySn,
    int? batteryStatus,
    int? batterySoc,
    int? status,
    int? swapFlag,
  }) {
    return CabinetCabin(
      portNo: portNo ?? this.portNo,
      slotName: slotName ?? this.slotName,
      batterySn: batterySn ?? this.batterySn,
      batteryStatus: batteryStatus ?? this.batteryStatus,
      batterySoc: batterySoc ?? this.batterySoc,
      status: status ?? this.status,
      swapFlag: swapFlag ?? this.swapFlag,
    );
  }

  /// 是否有电池
  bool get hasBattery => batteryStatus != 0;

  /// 是否可用
  bool get isEnabled => status == 1;

  /// 是否可换电
  bool get canSwap => swapFlag == 1 && isEnabled;

  factory CabinetCabin.fromJson(Map<String, dynamic> json) {
    return CabinetCabin(
      portNo: (json['portNo'] as num?)?.toInt() ?? 0,
      slotName: json['slotName']?.toString() ?? '',
      batterySn: json['batterySn']?.toString() ?? '',
      batteryStatus: (json['batteryStatus'] as num?)?.toInt() ?? 0,
      batterySoc: (json['batterySoc'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      swapFlag: (json['swapFlag'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'portNo': portNo,
        'slotName': slotName,
        'batterySn': batterySn,
        'batteryStatus': batteryStatus,
        'batterySoc': batterySoc,
        'status': status,
        'swapFlag': swapFlag,
      };
}
