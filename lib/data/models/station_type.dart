import 'package:flutter/foundation.dart';

@immutable
class StationType {
  final int? bleType;
  final int? protocolType;
  final String? dimension;
  final String? img;
  final String? model;
  final String? modelName;
  final String? remark;
  final int? storeNum;
  final String? weight;

  const StationType({
    this.bleType,
    this.protocolType,
    this.dimension,
    this.img,
    this.model,
    this.modelName,
    this.remark,
    this.storeNum,
    this.weight,
  });

  factory StationType.fromJson(Map<String, dynamic> json) {
    return StationType(
      bleType: (json['bleType'] as num?)?.toInt(),
      protocolType: (json['protocolType'] as num?)?.toInt(),
      dimension: json['dimension']?.toString(),
      img: json['img']?.toString(),
      model: json['model']?.toString(),
      modelName: json['modelName']?.toString(),
      remark: json['remark']?.toString(),
      storeNum: (json['storeNum'] as num?)?.toInt(),
      weight: json['weight']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'bleType': bleType,
        'protocolType': protocolType,
        'dimension': dimension,
        'img': img,
        'model': model,
        'modelName': modelName,
        'remark': remark,
        'storeNum': storeNum,
        'weight': weight,
      };
}
