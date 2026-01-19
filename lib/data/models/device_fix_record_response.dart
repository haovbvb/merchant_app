import 'package:flutter/foundation.dart';

@immutable
class DeviceFixRecordResponse {
  final List<DeviceFixRecord> list;
  final int total;

  const DeviceFixRecordResponse({
    required this.list,
    required this.total,
  });

  factory DeviceFixRecordResponse.fromJson(Map<String, dynamic> json) {
    return DeviceFixRecordResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => DeviceFixRecord.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceFixRecord>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class DeviceFixRecord {
  final String? fixMan;
  final String? fixManAvatar;
  final String? itemName;
  final String? remark;
  final String? result;
  final int? createTime;

  const DeviceFixRecord({
    required this.fixMan,
    required this.fixManAvatar,
    required this.itemName,
    required this.remark,
    required this.result,
    required this.createTime,
  });

  factory DeviceFixRecord.fromJson(Map<String, dynamic> json) {
    return DeviceFixRecord(
      fixMan: json['fixMan']?.toString() ?? '',
      fixManAvatar: json['fixManAvatar']?.toString(),
      itemName: json['itemName']?.toString(),
      remark: json['remark']?.toString(),
      result: json['result']?.toString(),
      createTime: (json['createTime'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'fixMan': fixMan,
        'fixManAvatar': fixManAvatar,
        'itemName': itemName,
        'remark': remark,
        'result': result,
        'createTime': createTime,
      };
}
