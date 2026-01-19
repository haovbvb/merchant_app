import 'package:flutter/foundation.dart';

@immutable
class DeviceInventoryDetail {
  final String? createTime;
  final DeviceInventoryDataResp? detailPage;
  final int deviceType;
  final int diff;
  final int inventory;
  final String? inventoryNo;
  final int status;
  final int stock;
  final String? warehouseAddress;
  final String? warehouseName;
  final String warehouseNo;
  final int warehouseType;

  const DeviceInventoryDetail({
    required this.createTime,
    required this.detailPage,
    required this.deviceType,
    required this.diff,
    required this.inventory,
    required this.inventoryNo,
    required this.status,
    required this.stock,
    required this.warehouseAddress,
    required this.warehouseName,
    required this.warehouseNo,
    required this.warehouseType,
  });

  factory DeviceInventoryDetail.fromJson(Map<String, dynamic> json) {
    return DeviceInventoryDetail(
      createTime: json['createTime']?.toString(),
      detailPage: json['detailPage'] is Map<String, dynamic>
          ? DeviceInventoryDataResp.fromJson(
              Map<String, dynamic>.from(json['detailPage'] as Map),
            )
          : null,
      deviceType: (json['deviceType'] as num?)?.toInt() ?? 0,
      diff: (json['diff'] as num?)?.toInt() ?? 0,
      inventory: (json['inventory'] as num?)?.toInt() ?? 0,
      inventoryNo: json['inventoryNo']?.toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      warehouseAddress: json['warehouseAddress']?.toString(),
      warehouseName: json['warehouseName']?.toString(),
      warehouseNo: (json['warehouseNo'] ?? '').toString(),
      warehouseType: (json['warehouseType'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'createTime': createTime,
        'detailPage': detailPage?.toJson(),
        'deviceType': deviceType,
        'diff': diff,
        'inventory': inventory,
        'inventoryNo': inventoryNo,
        'status': status,
        'stock': stock,
        'warehouseAddress': warehouseAddress,
        'warehouseName': warehouseName,
        'warehouseNo': warehouseNo,
        'warehouseType': warehouseType,
      };
}

@immutable
class DeviceInventoryDataResp {
  final List<DeviceInventoryData> list;
  final int total;

  const DeviceInventoryDataResp({
    required this.list,
    required this.total,
  });

  factory DeviceInventoryDataResp.fromJson(Map<String, dynamic> json) {
    return DeviceInventoryDataResp(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => DeviceInventoryData.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceInventoryData>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class DeviceInventoryData {
  final String accountName;
  final String deviceSn;
  final String inventoryTime;
  final String remark;
  final int status;

  const DeviceInventoryData({
    required this.accountName,
    required this.deviceSn,
    required this.inventoryTime,
    required this.remark,
    required this.status,
  });

  factory DeviceInventoryData.fromJson(Map<String, dynamic> json) {
    return DeviceInventoryData(
      accountName: (json['accountName'] ?? '').toString(),
      deviceSn: (json['deviceSn'] ?? '').toString(),
      inventoryTime: (json['inventoryTime'] ?? '').toString(),
      remark: (json['remark'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'deviceSn': deviceSn,
        'inventoryTime': inventoryTime,
        'remark': remark,
        'status': status,
      };
}
