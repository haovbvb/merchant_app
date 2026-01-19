import 'package:flutter/foundation.dart';

@immutable
class RoadSideListResp {
  final List<RoadSideInfo> list;
  final int total;

  const RoadSideListResp({
    required this.list,
    required this.total,
  });

  factory RoadSideListResp.fromJson(Map<String, dynamic> json) {
    return RoadSideListResp(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => RoadSideInfo.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class RoadSideInfo {
  final String? createTime;
  final String? description;
  final String? deviceSn;
  final int? deviceType;
  final String? img;
  final String? recordNo;
  final int? result;
  final int? status;
  final String? completetime;
  final String? processTime;

  const RoadSideInfo({
    required this.createTime,
    required this.description,
    required this.deviceSn,
    required this.deviceType,
    required this.img,
    required this.recordNo,
    required this.result,
    required this.status,
    required this.completetime,
    required this.processTime,
  });

  factory RoadSideInfo.fromJson(Map<String, dynamic> json) {
    return RoadSideInfo(
      createTime: json['createTime']?.toString(),
      description: json['description']?.toString(),
      deviceSn: json['deviceSn']?.toString(),
      deviceType: (json['deviceType'] as num?)?.toInt(),
      img: json['img']?.toString(),
      recordNo: json['recordNo']?.toString(),
      result: (json['result'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      completetime: json['completetime']?.toString(),
      processTime: json['processTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'createTime': createTime,
        'description': description,
        'deviceSn': deviceSn,
        'deviceType': deviceType,
        'img': img,
        'recordNo': recordNo,
        'result': result,
        'status': status,
        'completetime': completetime,
        'processTime': processTime,
      };
}
