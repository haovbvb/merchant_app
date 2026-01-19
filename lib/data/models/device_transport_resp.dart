import 'package:flutter/foundation.dart';

@immutable
class DeviceTransportResp {
  final List<DeviceTransport> list;
  final int total;

  const DeviceTransportResp({
    required this.list,
    required this.total,
  });

  factory DeviceTransportResp.fromJson(Map<String, dynamic> json) {
    return DeviceTransportResp(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => DeviceTransport.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceTransport>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class DeviceTransport {
  final String transferNo;
  final int status;
  final int deviceNum;
  final int deviceType;
  final int inTransitNum;
  final String inWarehouseName;
  final String inWarehouseNo;
  final int inWarehouseType;
  final String outWarehouseName;
  final String outWarehouseNo;
  final int outWarehouseType;
  final int receivedNum;
  final String receivedTime;
  final String sendTime;
  final String trackingNumber;

  const DeviceTransport({
    required this.transferNo,
    required this.status,
    required this.deviceNum,
    required this.deviceType,
    required this.inTransitNum,
    required this.inWarehouseName,
    required this.inWarehouseNo,
    required this.inWarehouseType,
    required this.outWarehouseName,
    required this.outWarehouseNo,
    required this.outWarehouseType,
    required this.receivedNum,
    required this.receivedTime,
    required this.sendTime,
    required this.trackingNumber,
  });

  factory DeviceTransport.fromJson(Map<String, dynamic> json) {
    return DeviceTransport(
      transferNo: (json['transferNo'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
      deviceNum: (json['deviceNum'] as num?)?.toInt() ?? 0,
      deviceType: (json['deviceType'] as num?)?.toInt() ?? 0,
      inTransitNum: (json['inTransitNum'] as num?)?.toInt() ?? 0,
      inWarehouseName: (json['inWarehouseName'] ?? '').toString(),
      inWarehouseNo: (json['inWarehouseNo'] ?? '').toString(),
      inWarehouseType: (json['inWarehouseType'] as num?)?.toInt() ?? 0,
      outWarehouseName: (json['outWarehouseName'] ?? '').toString(),
      outWarehouseNo: (json['outWarehouseNo'] ?? '').toString(),
      outWarehouseType: (json['outWarehouseType'] as num?)?.toInt() ?? 0,
      receivedNum: (json['receivedNum'] as num?)?.toInt() ?? 0,
      receivedTime: (json['receivedTime'] ?? '').toString(),
      sendTime: (json['sendTime'] ?? '').toString(),
      trackingNumber: (json['trackingNumber'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'transferNo': transferNo,
        'status': status,
        'deviceNum': deviceNum,
        'deviceType': deviceType,
        'inTransitNum': inTransitNum,
        'inWarehouseName': inWarehouseName,
        'inWarehouseNo': inWarehouseNo,
        'inWarehouseType': inWarehouseType,
        'outWarehouseName': outWarehouseName,
        'outWarehouseNo': outWarehouseNo,
        'outWarehouseType': outWarehouseType,
        'receivedNum': receivedNum,
        'receivedTime': receivedTime,
        'sendTime': sendTime,
        'trackingNumber': trackingNumber,
      };
}

@immutable
class DeviceTransportData {
  final String sn;
  final int status;

  const DeviceTransportData({
    required this.sn,
    required this.status,
  });

  factory DeviceTransportData.fromJson(Map<String, dynamic> json) {
    return DeviceTransportData(
      sn: (json['sn'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'sn': sn,
        'status': status,
      };
}

@immutable
class DeviceTransportDetail {
  final DeviceTransportDetailPage? detailPage;
  final int deviceNum;
  final int deviceType;
  final int inTransitNum;
  final String inWarehouseName;
  final String outWarehouseName;
  final int receivedNum;
  final int sendTime;
  final String trackingNumber;
  final String transferNo;
  final int withdrawNum;

  const DeviceTransportDetail({
    required this.detailPage,
    required this.deviceNum,
    required this.deviceType,
    required this.inTransitNum,
    required this.inWarehouseName,
    required this.outWarehouseName,
    required this.receivedNum,
    required this.sendTime,
    required this.trackingNumber,
    required this.transferNo,
    required this.withdrawNum,
  });

  factory DeviceTransportDetail.fromJson(Map<String, dynamic> json) {
    return DeviceTransportDetail(
      detailPage: json['detailPage'] is Map<String, dynamic>
          ? DeviceTransportDetailPage.fromJson(
              Map<String, dynamic>.from(json['detailPage'] as Map),
            )
          : null,
      deviceNum: (json['deviceNum'] as num?)?.toInt() ?? 0,
      deviceType: (json['deviceType'] as num?)?.toInt() ?? 0,
      inTransitNum: (json['inTransitNum'] as num?)?.toInt() ?? 0,
      inWarehouseName: (json['inWarehouseName'] ?? '').toString(),
      outWarehouseName: (json['outWarehouseName'] ?? '').toString(),
      receivedNum: (json['receivedNum'] as num?)?.toInt() ?? 0,
      sendTime: (json['sendTime'] as num?)?.toInt() ?? 0,
      trackingNumber: (json['trackingNumber'] ?? '').toString(),
      transferNo: (json['transferNo'] ?? '').toString(),
      withdrawNum: (json['withdrawNum'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'detailPage': detailPage?.toJson(),
        'deviceNum': deviceNum,
        'deviceType': deviceType,
        'inTransitNum': inTransitNum,
        'inWarehouseName': inWarehouseName,
        'outWarehouseName': outWarehouseName,
        'receivedNum': receivedNum,
        'sendTime': sendTime,
        'trackingNumber': trackingNumber,
        'transferNo': transferNo,
        'withdrawNum': withdrawNum,
      };
}

@immutable
class DeviceTransportDetailPage {
  final int total;
  final List<DeviceTransportDetailPageData> list;

  const DeviceTransportDetailPage({
    required this.total,
    required this.list,
  });

  factory DeviceTransportDetailPage.fromJson(Map<String, dynamic> json) {
    return DeviceTransportDetailPage(
      total: (json['total'] as num?)?.toInt() ?? 0,
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => DeviceTransportDetailPageData.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <DeviceTransportDetailPageData>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'list': list.map((item) => item.toJson()).toList(),
      };
}

@immutable
class DeviceTransportDetailPageData {
  final String deviceSn;
  final int status;
  final String opTime;

  const DeviceTransportDetailPageData({
    required this.deviceSn,
    required this.status,
    required this.opTime,
  });

  factory DeviceTransportDetailPageData.fromJson(Map<String, dynamic> json) {
    return DeviceTransportDetailPageData(
      deviceSn: (json['deviceSn'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
      opTime: (json['opTime'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'deviceSn': deviceSn,
        'status': status,
        'opTime': opTime,
      };
}
