import 'package:flutter/foundation.dart';

@immutable
class CarType {
  final String? engineDate;
  final String? engineModel;
  final String? img;
  final String? model;
  final String? modelName;
  final String? remark;

  const CarType({
    this.engineDate,
    this.engineModel,
    this.img,
    this.model,
    this.modelName,
    this.remark,
  });

  factory CarType.fromJson(Map<String, dynamic> json) {
    return CarType(
      engineDate: json['engineDate']?.toString(),
      engineModel: json['engineModel']?.toString(),
      img: json['img']?.toString(),
      model: json['model']?.toString(),
      modelName: json['modelName']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'engineDate': engineDate,
        'engineModel': engineModel,
        'img': img,
        'model': model,
        'modelName': modelName,
        'remark': remark,
      };
}
