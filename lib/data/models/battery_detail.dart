import 'package:flutter/foundation.dart';

@immutable
class BatteryDetail {
  final double? avgSpeed;
  final int? color;
  final int? cycle;
  final String? deviceSn;
  final String? img;
  final double? latitude;
  final double? longitude;
  final double? mile;
  final int? online;
  final int? operationDate;
  final int? signalTime;
  final int? soc;
  final int? status;
  final double? todayMile;

  const BatteryDetail({
    this.avgSpeed,
    this.color,
    this.cycle,
    this.deviceSn,
    this.img,
    this.latitude,
    this.longitude,
    this.mile,
    this.online,
    this.operationDate,
    this.signalTime,
    this.soc,
    this.status,
    this.todayMile,
  });

  factory BatteryDetail.fromJson(Map<String, dynamic> json) {
    return BatteryDetail(
      avgSpeed: (json['avgSpeed'] as num?)?.toDouble(),
      color: (json['color'] as num?)?.toInt(),
      cycle: (json['cycle'] as num?)?.toInt(),
      deviceSn: json['deviceSn']?.toString(),
      img: json['img']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mile: (json['mile'] as num?)?.toDouble(),
      online: (json['online'] as num?)?.toInt(),
      operationDate: (json['operationDate'] as num?)?.toInt(),
      signalTime: (json['signalTime'] as num?)?.toInt(),
      soc: (json['soc'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      todayMile: (json['todayMile'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'avgSpeed': avgSpeed,
        'color': color,
        'cycle': cycle,
        'deviceSn': deviceSn,
        'img': img,
        'latitude': latitude,
        'longitude': longitude,
        'mile': mile,
        'online': online,
        'operationDate': operationDate,
        'signalTime': signalTime,
        'soc': soc,
        'status': status,
        'todayMile': todayMile,
      };
}
