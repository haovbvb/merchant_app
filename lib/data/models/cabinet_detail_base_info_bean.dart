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
  });

  factory CabinetDetailBaseInfoBean.fromJson(Map<String, dynamic> json) {
    final imgSet = json['installImgSet'];
    final managerList = json['stationManagerList'];
    return CabinetDetailBaseInfoBean(
      id: (json['id'] as num?)?.toInt(),
      createTime: json['createTime']?.toString(),
      installImgSet: imgSet is List
          ? imgSet.map((e) => e.toString()).toList()
          : const [],
      standardImg: json['standardImg']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      stationAddress: json['stationAddress']?.toString(),
      stationPid: json['stationPid']?.toString(),
      stationSn: json['stationSn']?.toString(),
      useCount: json['useCount']?.toString(),
      cityName: json['cityName']?.toString(),
      stationStatus: (json['stationStatus'] as num?)?.toInt(),
      showOnlineStatus: json['showOnlineStatus']?.toString(),
      cityCode: (json['cityCode'] as num?)?.toInt(),
      maxC: json['maxC']?.toString(),
      portStatus: json['portStatus']?.toString(),
      isRecycling: (json['isRecycling'] as num?)?.toInt(),
      storeNum: (json['storeNum'] as num?)?.toInt(),
      label: (json['label'] as num?)?.toInt(),
      labelStr: json['labelStr']?.toString(),
      lastHbTime: json['lastHbTime']?.toString(),
      hide: (json['hide'] as num?)?.toInt(),
      businessHours: json['businessHours']?.toString(),
      iccid: json['iccid']?.toString(),
      vpcId: json['vpcId']?.toString(),
      putOnShelvesTime: (json['putOnShelvesTime'] as num?)?.toInt(),
      address: json['address']?.toString(),
      location: json['location']?.toString(),
      stationName: json['stationName']?.toString(),
      stationSpec: json['stationSpec']?.toString(),
      type: (json['type'] as num?)?.toInt(),
      stationModel: json['stationModel']?.toString(),
      lockDevId: json['lockDevId']?.toString(),
      lockIcId: json['lockIcId']?.toString(),
      macId: json['macId']?.toString(),
      mark: json['mark']?.toString(),
      online: json['online']?.toString(),
      stationModelName: json['stationModelName']?.toString(),
      swapThreshold: (json['swapThreshold'] as num?)?.toInt(),
      apn: json['apn']?.toString(),
      volume: (json['volume'] as num?)?.toInt(),
      platformUrl: json['platformUrl']?.toString(),
      maxChargeSoc: (json['maxChargeSoc'] as num?)?.toInt(),
      hasPermission: (json['hasPermission'] as num?)?.toInt(),
      installStatus: (json['installStatus'] as num?)?.toInt(),
      installTime: json['installTime']?.toString(),
      onlineStatus: (json['onlineStatus'] as num?)?.toInt(),
      simNo: json['simNo']?.toString(),
      stationManagerList: managerList is List
          ? managerList
              .whereType<Map<String, dynamic>>()
              .map(Map<String, dynamic>.from)
              .toList()
          : const [],
    );
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
      };
}
