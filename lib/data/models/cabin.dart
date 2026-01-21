import 'package:flutter/foundation.dart';

@immutable
class Cabin {
  final int? portNo;
  final String? portName;
  final String? batterySn;
  final int? status;
  final int? doorStatus;
  final int? lockStatus;
  final int? chargeStatus;
  final int? batterySoc;
  final double? voltage;
  final double? temperature;

  const Cabin({
    this.portNo,
    this.portName,
    this.batterySn,
    this.status,
    this.doorStatus,
    this.lockStatus,
    this.chargeStatus,
    this.batterySoc,
    this.voltage,
    this.temperature,
  });

  factory Cabin.fromJson(Map<String, dynamic> json) {
    return Cabin(
      portNo: (json['portNo'] as num?)?.toInt(),
      portName: json['portName']?.toString(),
      batterySn: json['batterySn']?.toString(),
      status: (json['status'] as num?)?.toInt(),
      doorStatus: (json['doorStatus'] as num?)?.toInt(),
      lockStatus: (json['lockStatus'] as num?)?.toInt(),
      chargeStatus: (json['chargeStatus'] as num?)?.toInt(),
      batterySoc: (json['batterySoc'] as num?)?.toInt(),
      voltage: (json['voltage'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'portNo': portNo,
        'portName': portName,
        'batterySn': batterySn,
        'status': status,
        'doorStatus': doorStatus,
        'lockStatus': lockStatus,
        'chargeStatus': chargeStatus,
        'batterySoc': batterySoc,
        'voltage': voltage,
        'temperature': temperature,
      };
}
