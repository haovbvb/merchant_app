import 'package:flutter/foundation.dart';

@immutable
class NearByVehicle {
  final String? carNumber;
  final String? cardNum;
  final String? img;
  final double? latitude;
  final double? longitude;
  final double? mile;
  final bool? needMaintenance;
  final String? sn;

  const NearByVehicle({
    this.carNumber,
    this.cardNum,
    this.img,
    this.latitude,
    this.longitude,
    this.mile,
    this.needMaintenance,
    this.sn,
  });

  factory NearByVehicle.fromJson(Map<String, dynamic> json) {
    return NearByVehicle(
      carNumber: json['carNumber']?.toString(),
      cardNum: json['cardNum']?.toString(),
      img: json['img']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mile: (json['mile'] as num?)?.toDouble(),
      needMaintenance: json['needMaintenance'] as bool?,
      sn: json['sn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'carNumber': carNumber,
        'cardNum': cardNum,
        'img': img,
        'latitude': latitude,
        'longitude': longitude,
        'mile': mile,
        'needMaintenance': needMaintenance,
        'sn': sn,
      };
}
