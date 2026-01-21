import 'package:flutter/foundation.dart';

@immutable
class LayoutCabinetInfo {
  final int total;
  final List<LayoutCabinetItem> list;

  const LayoutCabinetInfo({
    required this.total,
    required this.list,
  });

  factory LayoutCabinetInfo.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'] as List<dynamic>? ?? const [];
    return LayoutCabinetInfo(
      total: (json['total'] as num?)?.toInt() ?? 0,
      list: rawList
          .map(
            (item) => LayoutCabinetItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'list': list.map((item) => item.toJson()).toList(),
      };
}

@immutable
class LayoutCabinetItem {
  final String? id;
  final String? pid;
  final String? sn;
  final String? status;
  final int? cityCode;
  final String? latitude;
  final String? longitude;
  final String? opPhone;
  final String? opName;
  final int? createTime;
  final String? address;

  const LayoutCabinetItem({
    this.id,
    this.pid,
    this.sn,
    this.status,
    this.cityCode,
    this.latitude,
    this.longitude,
    this.opPhone,
    this.opName,
    this.createTime,
    this.address,
  });

  factory LayoutCabinetItem.fromJson(Map<String, dynamic> json) {
    return LayoutCabinetItem(
      id: json['id']?.toString(),
      pid: json['pid']?.toString(),
      sn: json['sn']?.toString(),
      status: json['status']?.toString(),
      cityCode: (json['cityCode'] as num?)?.toInt(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      opPhone: json['opPhone']?.toString(),
      opName: json['opName']?.toString(),
      createTime: (json['createTime'] as num?)?.toInt(),
      address: json['address']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pid': pid,
        'sn': sn,
        'status': status,
        'cityCode': cityCode,
        'latitude': latitude,
        'longitude': longitude,
        'opPhone': opPhone,
        'opName': opName,
        'createTime': createTime,
        'address': address,
      };
}
