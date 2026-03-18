import 'package:flutter/foundation.dart';

@immutable
class CabinetDetailBaseInfoBean {
  final int? id;
  final String? createTime;
  final List<String> installImgSet;
  final String? standardImg;
  final double? latitude;
  final double? longitude;
  final String? stationAddress;
  final String? stationPid;
  final String? stationSn;
  final String? useCount;
  final String? cityName;
  final int? stationStatus;
  final String? showOnlineStatus;
  final int? cityCode;
  final String? maxC;
  final String? portStatus;
  final int? isRecycling;
  final int? storeNum;
  final int? label;
  final String? labelStr;
  final String? lastHbTime;
  final int? hide;
  final String? businessHours;
  final String? iccid;
  final String? vpcId;
  final int? putOnShelvesTime;
  final String? address;
  final String? location;
  final String? stationName;
  final String? stationSpec;
  final int? type;
  final String? stationModel;
  final String? lockDevId;
  final String? lockIcId;
  final String? macId;
  final String? mark;
  final String? online;
  final String? stationModelName;
  final int? swapThreshold;
  final String? apn;
  final int? volume;
  final String? platformUrl;
  final int? maxChargeSoc;
  final int? hasPermission;
  final int? installStatus;
  final String? installTime;
  final int? onlineStatus;
  final String? simNo;
  final List<Map<String, dynamic>> stationManagerList;
  final String? softwareVersion;
  final String? backupPowerStatus;
  final int? batteryInSlot;

  const CabinetDetailBaseInfoBean({
    this.id,
    this.createTime,
    this.installImgSet = const [],
    this.standardImg,
    this.latitude,
    this.longitude,
    this.stationAddress,
    this.stationPid,
    this.stationSn,
    this.useCount,
    this.cityName,
    this.stationStatus,
    this.showOnlineStatus,
    this.cityCode,
    this.maxC,
    this.portStatus,
    this.isRecycling,
    this.storeNum,
    this.label,
    this.labelStr,
    this.lastHbTime,
    this.hide,
    this.businessHours,
    this.iccid,
    this.vpcId,
    this.putOnShelvesTime,
    this.address,
    this.location,
    this.stationName,
    this.stationSpec,
    this.type,
    this.stationModel,
    this.lockDevId,
    this.lockIcId,
    this.macId,
    this.mark,
    this.online,
    this.stationModelName,
    this.swapThreshold,
    this.apn,
    this.volume,
    this.platformUrl,
    this.maxChargeSoc,
    this.hasPermission,
    this.installStatus,
    this.installTime,
    this.onlineStatus,
    this.simNo,
    this.stationManagerList = const [],
    this.softwareVersion,
    this.backupPowerStatus,
    this.batteryInSlot,
  });

  factory CabinetDetailBaseInfoBean.fromJson(Map<String, dynamic> json) {
    final data = _unwrapEnvelope(json);
    final imgSet = data['installImgSet'];
    final managerList = data['stationManagerList'] ?? data['stationManagerLis'];
    final softwareVersion =
        data['softwareVersion']?.toString() ??
        data['softVersion']?.toString() ??
        data['softVer']?.toString() ??
        data['swVersion']?.toString() ??
        data['apkVer']?.toString() ??
        data['version']?.toString();
    final backupPowerStatus =
        data['backupPowerStatus']?.toString() ??
        data['backupBatteryStatus']?.toString() ??
        data['backupStatus']?.toString() ??
        data['showBackupBatteryStatus']?.toString() ??
        data['showBackupPowerStatus']?.toString();
    final batteryInSlot =
        _toInt(data['batteryInSlot']) ??
        _toInt(data['batInSlot']) ??
        _toInt(data['inBatteryCount']) ??
        _toInt(data['batteryCount']) ??
        _toInt(data['inWarehouseBatteryCount']) ??
        _toInt(data['inSlotBatteryCount']);
    final swapThreshold =
        _toInt(data['swapThreshold']) ??
        _toInt(data['threshold']) ??
        _toInt(data['standardSwapTime']) ??
        _toInt(data['cabSoc']) ??
        _toInt(data['swCabSocControl']);
    final apn =
        data['apn']?.toString() ??
        data['APN']?.toString() ??
        data['cabApn']?.toString();
    final volume =
        _toInt(data['volume']) ??
        _toInt(data['cabVolume']) ??
        _toInt(data['swCabVolume']);
    final platformUrl =
        data['platformUrl']?.toString() ??
        data['platformURL']?.toString() ??
        data['cabTcpPort']?.toString() ??
        data['swCabTcpPort']?.toString() ??
        data['tcpPort']?.toString();
    return CabinetDetailBaseInfoBean(
      id: (data['id'] as num?)?.toInt(),
      createTime: data['createTime']?.toString(),
      installImgSet: imgSet is List
          ? imgSet.map((e) => e.toString()).toList()
          : const [],
      standardImg: data['standardImg']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      stationAddress: data['stationAddress']?.toString(),
      stationPid: data['stationPid']?.toString(),
      stationSn: data['stationSn']?.toString(),
      useCount: data['useCount']?.toString(),
      cityName: data['cityName']?.toString(),
      stationStatus: (data['stationStatus'] as num?)?.toInt(),
      showOnlineStatus: data['showOnlineStatus']?.toString(),
      cityCode: (data['cityCode'] as num?)?.toInt(),
      maxC: data['maxC']?.toString(),
      portStatus: data['portStatus']?.toString(),
      isRecycling: (data['isRecycling'] as num?)?.toInt(),
      storeNum: (data['storeNum'] as num?)?.toInt(),
      label: (data['label'] as num?)?.toInt(),
      labelStr: data['labelStr']?.toString(),
      lastHbTime: data['lastHbTime']?.toString(),
      hide: (data['hide'] as num?)?.toInt(),
      businessHours: data['businessHours']?.toString(),
      iccid: data['iccid']?.toString(),
      vpcId: data['vpcId']?.toString(),
      putOnShelvesTime: (data['putOnShelvesTime'] as num?)?.toInt(),
      address: data['address']?.toString(),
      location: data['location']?.toString(),
      stationName: data['stationName']?.toString(),
      stationSpec: data['stationSpec']?.toString(),
      type: (data['type'] as num?)?.toInt(),
      stationModel: data['stationModel']?.toString(),
      lockDevId: data['lockDevId']?.toString(),
      lockIcId: data['lockIcId']?.toString(),
      macId: data['macId']?.toString(),
      mark: data['mark']?.toString(),
      online: data['online']?.toString(),
      stationModelName: data['stationModelName']?.toString(),
      swapThreshold: swapThreshold,
      apn: apn,
      volume: volume,
      platformUrl: platformUrl,
      maxChargeSoc: (data['maxChargeSoc'] as num?)?.toInt(),
      hasPermission: (data['hasPermission'] as num?)?.toInt(),
      installStatus: (data['installStatus'] as num?)?.toInt(),
      installTime: data['installTime']?.toString(),
      onlineStatus: (data['onlineStatus'] as num?)?.toInt(),
      simNo: data['simNo']?.toString(),
      stationManagerList: managerList is List
          ? managerList
                .whereType<Map<String, dynamic>>()
                .map(Map<String, dynamic>.from)
                .toList()
          : const [],
      softwareVersion: softwareVersion,
      backupPowerStatus: backupPowerStatus,
      batteryInSlot: batteryInSlot,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static Map<String, dynamic> _unwrapEnvelope(Map<String, dynamic> source) {
    var current = source;

    for (var i = 0; i < 2; i++) {
      final hasMeta =
          current.containsKey('code') ||
          current.containsKey('msg') ||
          current.containsKey('message') ||
          current.containsKey('statusCode') ||
          current.containsKey('status');

      if (!hasMeta) break;

      final result = current['result'];
      if (result is Map) {
        current = Map<String, dynamic>.from(result);
        continue;
      }

      final data = current['data'];
      if (data is Map) {
        current = Map<String, dynamic>.from(data);
        continue;
      }

      break;
    }

    return current;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'createTime': createTime,
    'installImgSet': installImgSet,
    'standardImg': standardImg,
    'latitude': latitude,
    'longitude': longitude,
    'stationAddress': stationAddress,
    'stationPid': stationPid,
    'stationSn': stationSn,
    'useCount': useCount,
    'cityName': cityName,
    'stationStatus': stationStatus,
    'showOnlineStatus': showOnlineStatus,
    'cityCode': cityCode,
    'maxC': maxC,
    'portStatus': portStatus,
    'isRecycling': isRecycling,
    'storeNum': storeNum,
    'label': label,
    'labelStr': labelStr,
    'lastHbTime': lastHbTime,
    'hide': hide,
    'businessHours': businessHours,
    'iccid': iccid,
    'vpcId': vpcId,
    'putOnShelvesTime': putOnShelvesTime,
    'address': address,
    'location': location,
    'stationName': stationName,
    'stationSpec': stationSpec,
    'type': type,
    'stationModel': stationModel,
    'lockDevId': lockDevId,
    'lockIcId': lockIcId,
    'macId': macId,
    'mark': mark,
    'online': online,
    'stationModelName': stationModelName,
    'swapThreshold': swapThreshold,
    'apn': apn,
    'volume': volume,
    'platformUrl': platformUrl,
    'maxChargeSoc': maxChargeSoc,
    'hasPermission': hasPermission,
    'installStatus': installStatus,
    'installTime': installTime,
    'onlineStatus': onlineStatus,
    'simNo': simNo,
    'stationManagerList': stationManagerList,
    'softwareVersion': softwareVersion,
    'backupPowerStatus': backupPowerStatus,
    'batteryInSlot': batteryInSlot,
  };
}
