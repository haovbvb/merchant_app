import 'package:flutter/foundation.dart';

@immutable
class WarehouseInfo {
  final String? cityName;
  final String? outWarehouseName;
  final String? outWarehouseNo;
  final String? inWarehouseName;
  final String inWarehouseNo;
  final int? warehouseType;
  final String? img;
  final String? warehouseName;
  final String? warehouseNo;

  const WarehouseInfo({
    required this.cityName,
    required this.outWarehouseName,
    required this.outWarehouseNo,
    required this.inWarehouseName,
    required this.inWarehouseNo,
    required this.warehouseType,
    required this.img,
    required this.warehouseName,
    required this.warehouseNo,
  });

  factory WarehouseInfo.fromJson(Map<String, dynamic> json) {
    return WarehouseInfo(
      cityName: json['cityName']?.toString(),
      outWarehouseName: json['outWarehouseName']?.toString(),
      outWarehouseNo: json['outWarehouseNo']?.toString(),
      inWarehouseName: json['inWarehouseName']?.toString(),
      inWarehouseNo: (json['inWarehouseNo'] ?? '').toString(),
      warehouseType: (json['warehouseType'] as num?)?.toInt(),
      img: json['img']?.toString(),
      warehouseName: json['warehouseName']?.toString(),
      warehouseNo: json['warehouseNo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'outWarehouseName': outWarehouseName,
        'outWarehouseNo': outWarehouseNo,
        'inWarehouseName': inWarehouseName,
        'inWarehouseNo': inWarehouseNo,
        'warehouseType': warehouseType,
        'img': img,
        'warehouseName': warehouseName,
        'warehouseNo': warehouseNo,
      };
}
