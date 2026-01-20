import 'package:flutter/foundation.dart';

@immutable
class NewCabinetBean {
  final String? stationModel;
  final String? stationName;
  final String? stationModelName;
  final String? standardImg;
  final String? address;
  final String? pid;
  final String? sn;

  const NewCabinetBean({
    this.stationModel,
    this.stationName,
    this.stationModelName,
    this.standardImg,
    this.address,
    this.pid,
    this.sn,
  });

  factory NewCabinetBean.fromJson(Map<String, dynamic> json) {
    return NewCabinetBean(
      stationModel: json['stationModel']?.toString(),
      stationName: json['stationName']?.toString(),
      stationModelName: json['stationModelName']?.toString(),
      standardImg: json['standardImg']?.toString(),
      address: json['address']?.toString(),
      pid: json['pid']?.toString(),
      sn: json['sn']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'stationModel': stationModel,
        'stationName': stationName,
        'stationModelName': stationModelName,
        'standardImg': standardImg,
        'address': address,
        'pid': pid,
        'sn': sn,
      };
}
