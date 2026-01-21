import 'package:flutter/foundation.dart';

@immutable
class VehicleDetail {
  final String? sn;
  final String? vin;
  final String? carNumber;
  final String? cardNum;
  final String? model;
  final String? spec;
  final String? carModel;
  final String? carSpec;
  final String? img;
  final double? latitude;
  final double? longitude;
  final double? mile;
  final String? carType;
  final String? createTime;
  final String? motorNumber;
  final String? controllerSn;
  final String? batterySn;
  final String? ownerName;
  final String? phone;

  const VehicleDetail({
    this.sn,
    this.vin,
    this.carNumber,
    this.cardNum,
    this.model,
    this.spec,
    this.carModel,
    this.carSpec,
    this.img,
    this.latitude,
    this.longitude,
    this.mile,
    this.carType,
    this.createTime,
    this.motorNumber,
    this.controllerSn,
    this.batterySn,
    this.ownerName,
    this.phone,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) {
    return VehicleDetail(
      sn: json['sn']?.toString(),
      vin: json['vin']?.toString(),
      carNumber: json['carNumber']?.toString(),
      cardNum: json['cardNum']?.toString(),
      model: json['model']?.toString(),
      spec: json['spec']?.toString(),
      carModel: json['carModel']?.toString(),
      carSpec: json['carSpec']?.toString(),
      img: json['img']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      mile: (json['mile'] as num?)?.toDouble(),
      carType: json['carType']?.toString(),
      createTime: json['createTime']?.toString(),
      motorNumber: json['motorNumber']?.toString(),
      controllerSn: json['controllerSn']?.toString(),
      batterySn: json['batterySn']?.toString(),
      ownerName: json['ownerName']?.toString() ?? json['userName']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sn': sn,
        'vin': vin,
        'carNumber': carNumber,
        'cardNum': cardNum,
        'model': model,
        'spec': spec,
        'carModel': carModel,
        'carSpec': carSpec,
        'img': img,
        'latitude': latitude,
        'longitude': longitude,
        'mile': mile,
        'carType': carType,
        'createTime': createTime,
        'motorNumber': motorNumber,
        'controllerSn': controllerSn,
        'batterySn': batterySn,
        'ownerName': ownerName,
        'phone': phone,
      };
}
