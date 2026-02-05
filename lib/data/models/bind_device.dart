import 'package:flutter/foundation.dart';

@immutable
class BindDevice {
  final int? bindDate;
  final int? bindSource;
  final String? carNumber;
  final String? deviceSn;
  final int? deviceType;
  final String? img;
  final String? model;
  final String? modelName;
  final int? payWay;
  final int? remainTerm;
  final int? rentOrderStatus;
  final int? saleOrderStatus;
  final int? status;
  final int? soc;
  final int? onlineFlag;
  final bool? needMaintenance;

  const BindDevice({
    this.bindDate,
    this.bindSource,
    this.carNumber,
    this.deviceSn,
    this.deviceType,
    this.img,
    this.model,
    this.modelName,
    this.payWay,
    this.remainTerm,
    this.rentOrderStatus,
    this.saleOrderStatus,
    this.status,
    this.soc,
    this.onlineFlag,
    this.needMaintenance,
  });

  factory BindDevice.fromJson(Map<String, dynamic> json) {
    return BindDevice(
      bindDate: (json['bindDate'] as num?)?.toInt(),
      bindSource: (json['bindSource'] as num?)?.toInt(),
      carNumber: json['carNumber']?.toString(),
      deviceSn: json['deviceSn']?.toString(),
      deviceType: (json['deviceType'] as num?)?.toInt(),
      img: json['img']?.toString(),
      model: json['model']?.toString(),
      modelName: json['modelName']?.toString(),
      payWay: (json['payWay'] as num?)?.toInt(),
      remainTerm: (json['remainTerm'] as num?)?.toInt(),
      rentOrderStatus: (json['rentOrderStatus'] as num?)?.toInt(),
      saleOrderStatus: (json['saleOrderStatus'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      soc: (json['soc'] as num?)?.toInt(),
      onlineFlag: (json['onlineFlag'] as num?)?.toInt(),
      needMaintenance: json['needMaintenance'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'bindDate': bindDate,
        'bindSource': bindSource,
        'carNumber': carNumber,
        'deviceSn': deviceSn,
        'deviceType': deviceType,
        'img': img,
        'model': model,
        'modelName': modelName,
        'payWay': payWay,
        'remainTerm': remainTerm,
        'rentOrderStatus': rentOrderStatus,
        'saleOrderStatus': saleOrderStatus,
        'status': status,
        'soc': soc,
        'onlineFlag': onlineFlag,
        'needMaintenance': needMaintenance,
      };
}
