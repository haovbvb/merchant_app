import 'package:flutter/foundation.dart';

@immutable
class DeviceInventoryResp {
  final List<DeviceInventory> list;
  final int total;

  const DeviceInventoryResp({
    required this.list,
    required this.total,
  });

  factory DeviceInventoryResp.fromJson(Map<String, dynamic> json) {
    return DeviceInventoryResp(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => DeviceInventory.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceInventory>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class DeviceInventory {
  final int? deviceType;
  final int? inventory;
  final String? inventoryNo;
  final int? status;
  final int? stock;
  final String? warehouseName;

  const DeviceInventory({
    required this.deviceType,
    required this.inventory,
    required this.inventoryNo,
    required this.status,
    required this.stock,
    required this.warehouseName,
  });

  factory DeviceInventory.fromJson(Map<String, dynamic> json) {
    return DeviceInventory(
      deviceType: (json['deviceType'] as num?)?.toInt(),
      inventory: (json['inventory'] as num?)?.toInt(),
      inventoryNo: json['inventoryNo']?.toString(),
      status: (json['status'] as num?)?.toInt(),
      stock: (json['stock'] as num?)?.toInt(),
      warehouseName: json['warehouseName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceType': deviceType,
        'inventory': inventory,
        'inventoryNo': inventoryNo,
        'status': status,
        'stock': stock,
        'warehouseName': warehouseName,
      };
}
