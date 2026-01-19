import 'package:flutter/foundation.dart';

@immutable
class BatterOrVehicleInfo {
  final BatteryVo? batteryVo;
  final CarVo? carVo;
  final int deviceType;

  const BatterOrVehicleInfo({
    required this.batteryVo,
    required this.carVo,
    required this.deviceType,
  });

  factory BatterOrVehicleInfo.fromJson(Map<String, dynamic> json) {
    return BatterOrVehicleInfo(
      batteryVo: json['batteryVo'] is Map<String, dynamic>
          ? BatteryVo.fromJson(
              Map<String, dynamic>.from(json['batteryVo'] as Map),
            )
          : null,
      carVo: json['carVo'] is Map<String, dynamic>
          ? CarVo.fromJson(Map<String, dynamic>.from(json['carVo'] as Map))
          : null,
      deviceType: (json['deviceType'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'batteryVo': batteryVo?.toJson(),
        'carVo': carVo?.toJson(),
        'deviceType': deviceType,
      };
}

@immutable
class BatteryVo {
  final int? cycle;
  final String? img;
  final String? lastSignalTime;
  final int onlineFlag;
  final String? sn;
  final int? soc;
  final int? soh;
  final bool isSelected;
  final String? model;
  final int? rentDay;
  final String? spec;
  final String? cardNum;
  final String? createTime;
  final String? batteryType;
  final int bindSource;
  final String? batModel;
  final String? batSpec;

  const BatteryVo({
    required this.cycle,
    required this.img,
    required this.lastSignalTime,
    required this.onlineFlag,
    required this.sn,
    required this.soc,
    required this.soh,
    required this.isSelected,
    required this.model,
    required this.rentDay,
    required this.spec,
    required this.cardNum,
    required this.createTime,
    required this.batteryType,
    required this.bindSource,
    required this.batModel,
    required this.batSpec,
  });

  factory BatteryVo.fromJson(Map<String, dynamic> json) {
    return BatteryVo(
      cycle: (json['cycle'] as num?)?.toInt(),
      img: json['img']?.toString(),
      lastSignalTime: json['lastSignalTime']?.toString(),
      onlineFlag: (json['onlineFlag'] as num?)?.toInt() ?? 0,
      sn: json['sn']?.toString(),
      soc: (json['soc'] as num?)?.toInt(),
      soh: (json['soh'] as num?)?.toInt(),
      isSelected: json['isSelected'] == true,
      model: json['model']?.toString(),
      rentDay: (json['rentDay'] as num?)?.toInt(),
      spec: json['spec']?.toString(),
      cardNum: json['cardNum']?.toString(),
      createTime: json['createTime']?.toString(),
      batteryType: json['batteryType']?.toString(),
      bindSource: (json['bindSource'] as num?)?.toInt() ?? 0,
      batModel: json['batModel']?.toString(),
      batSpec: json['batSpec']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cycle': cycle,
        'img': img,
        'lastSignalTime': lastSignalTime,
        'onlineFlag': onlineFlag,
        'sn': sn,
        'soc': soc,
        'soh': soh,
        'isSelected': isSelected,
        'model': model,
        'rentDay': rentDay,
        'spec': spec,
        'cardNum': cardNum,
        'createTime': createTime,
        'batteryType': batteryType,
        'bindSource': bindSource,
        'batModel': batModel,
        'batSpec': batSpec,
      };
}

@immutable
class CarVo {
  final String? carModel;
  final String? carNumber;
  final String? carSpec;
  final String? img;
  final String? sn;
  final String? vin;
  final bool isSelected;
  final String model;
  final int? rentDay;
  final String spec;
  final String cardNum;
  final String? createTime;
  final String? carType;
  final int bindSource;

  const CarVo({
    required this.carModel,
    required this.carNumber,
    required this.carSpec,
    required this.img,
    required this.sn,
    required this.vin,
    required this.isSelected,
    required this.model,
    required this.rentDay,
    required this.spec,
    required this.cardNum,
    required this.createTime,
    required this.carType,
    required this.bindSource,
  });

  factory CarVo.fromJson(Map<String, dynamic> json) {
    return CarVo(
      carModel: json['carModel']?.toString(),
      carNumber: json['carNumber']?.toString(),
      carSpec: json['carSpec']?.toString(),
      img: json['img']?.toString(),
      sn: json['sn']?.toString(),
      vin: json['vin']?.toString(),
      isSelected: json['isSelected'] == true,
      model: (json['model'] ?? '-').toString(),
      rentDay: (json['rentDay'] as num?)?.toInt(),
      spec: (json['spec'] ?? '-').toString(),
      cardNum: (json['cardNum'] ?? '-').toString(),
      createTime: json['createTime']?.toString(),
      carType: json['carType']?.toString(),
      bindSource: (json['bindSource'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'carModel': carModel,
        'carNumber': carNumber,
        'carSpec': carSpec,
        'img': img,
        'sn': sn,
        'vin': vin,
        'isSelected': isSelected,
        'model': model,
        'rentDay': rentDay,
        'spec': spec,
        'cardNum': cardNum,
        'createTime': createTime,
        'carType': carType,
        'bindSource': bindSource,
      };
}

@immutable
class StationVo {
  final String? address;
  final String? createTime;
  final String? img;
  final String? name;
  final int? onlineFlag;
  final String? sn;
  final String? storeNum;

  const StationVo({
    required this.address,
    required this.createTime,
    required this.img,
    required this.name,
    required this.onlineFlag,
    required this.sn,
    required this.storeNum,
  });

  factory StationVo.fromJson(Map<String, dynamic> json) {
    return StationVo(
      address: json['address']?.toString(),
      createTime: json['createTime']?.toString(),
      img: json['img']?.toString(),
      name: json['name']?.toString(),
      onlineFlag: (json['onlineFlag'] as num?)?.toInt(),
      sn: json['sn']?.toString(),
      storeNum: json['storeNum']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'createTime': createTime,
        'img': img,
        'name': name,
        'onlineFlag': onlineFlag,
        'sn': sn,
        'storeNum': storeNum,
      };
}
