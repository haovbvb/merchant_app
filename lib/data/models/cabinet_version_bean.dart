import 'package:flutter/foundation.dart';

@immutable
class CabinetVersionBean {
  final int? apkCode;
  final int? apkCodeF;
  final String? apkVer;
  final String? charge;
  final String? chargeF;
  final String? ctrl;
  final String? ctrlF;
  final String? pms;
  final String? pmsF;

  const CabinetVersionBean({
    this.apkCode,
    this.apkCodeF,
    this.apkVer,
    this.charge,
    this.chargeF,
    this.ctrl,
    this.ctrlF,
    this.pms,
    this.pmsF,
  });

  factory CabinetVersionBean.fromJson(Map<String, dynamic> json) {
    return CabinetVersionBean(
      apkCode: (json['apkCode'] as num?)?.toInt(),
      apkCodeF: (json['apkCodeF'] as num?)?.toInt(),
      apkVer: json['apkVer']?.toString(),
      charge: json['charge']?.toString(),
      chargeF: json['chargeF']?.toString(),
      ctrl: json['ctrl']?.toString(),
      ctrlF: json['ctrlF']?.toString(),
      pms: json['pms']?.toString(),
      pmsF: json['pmsF']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'apkCode': apkCode,
        'apkCodeF': apkCodeF,
        'apkVer': apkVer,
        'charge': charge,
        'chargeF': chargeF,
        'ctrl': ctrl,
        'ctrlF': ctrlF,
        'pms': pms,
        'pmsF': pmsF,
      };
}
