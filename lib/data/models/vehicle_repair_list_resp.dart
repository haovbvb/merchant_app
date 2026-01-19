import 'package:flutter/foundation.dart';

@immutable
class VehicleRepairListResp {
  final List<VehicleRepair>? list;
  final int total;

  const VehicleRepairListResp({
    required this.list,
    required this.total,
  });

  factory VehicleRepairListResp.fromJson(Map<String, dynamic> json) {
    return VehicleRepairListResp(
      list: (json['list'] as List<dynamic>?)
          ?.map((item) => VehicleRepair.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list?.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class VehicleRepair {
  final String createTime;
  final String fixMan;
  final String fixManAvatar;
  final String imgList;
  final String itemName;
  final String remark;
  final int result;

  const VehicleRepair({
    required this.createTime,
    required this.fixMan,
    required this.fixManAvatar,
    required this.imgList,
    required this.itemName,
    required this.remark,
    required this.result,
  });

  factory VehicleRepair.fromJson(Map<String, dynamic> json) {
    return VehicleRepair(
      createTime: (json['createTime'] ?? '').toString(),
      fixMan: (json['fixMan'] ?? '').toString(),
      fixManAvatar: (json['fixManAvatar'] ?? '').toString(),
      imgList: (json['imgList'] ?? '').toString(),
      itemName: (json['itemName'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
      result: (json['result'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'createTime': createTime,
        'fixMan': fixMan,
        'fixManAvatar': fixManAvatar,
        'imgList': imgList,
        'itemName': itemName,
        'remark': remark,
        'result': result,
      };
}
