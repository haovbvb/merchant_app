import 'package:flutter/foundation.dart';

@immutable
class BatteryType {
  final int? capacity;
  final String? dimension;
  final String? img;
  final String? model;
  final String? modelName;
  final String? remark;
  final int? voltage;
  final String? weight;

  const BatteryType({
    this.capacity,
    this.dimension,
    this.img,
    this.model,
    this.modelName,
    this.remark,
    this.voltage,
    this.weight,
  });

  factory BatteryType.fromJson(Map<String, dynamic> json) {
    return BatteryType(
      capacity: (json['capacity'] as num?)?.toInt(),
      dimension: json['dimension']?.toString(),
      img: json['img']?.toString(),
      model: json['model']?.toString(),
      modelName: json['modelName']?.toString(),
      remark: json['remark']?.toString(),
      voltage: (json['voltage'] as num?)?.toInt(),
      weight: json['weight']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'capacity': capacity,
        'dimension': dimension,
        'img': img,
        'model': model,
        'modelName': modelName,
        'remark': remark,
        'voltage': voltage,
        'weight': weight,
      };
}
