import 'package:flutter/foundation.dart';

@immutable
class CabinetAuthorizationList {
  final List<CabinetAuthorization> list;
  final int total;

  const CabinetAuthorizationList({
    this.list = const [],
    this.total = 0,
  });

  factory CabinetAuthorizationList.fromJson(Map<String, dynamic> json) {
    final raw = json['list'];
    return CabinetAuthorizationList(
      list: raw is List
          ? raw
              .map((item) => CabinetAuthorization.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((e) => e.toJson()).toList(),
        'total': total,
      };
}

@immutable
class CabinetAuthorization {
  final String? avg7DaySwapTime;
  final int? damageNum;
  final int? offlineNum;
  final int? onlineStatus;
  final String? showOnlineStatus;
  final String? standardImg;
  final String? standardSwapTime;
  final String? stationAddress;
  final String? stationSn;
  final int? storeNum;

  const CabinetAuthorization({
    this.avg7DaySwapTime,
    this.damageNum,
    this.offlineNum,
    this.onlineStatus,
    this.showOnlineStatus,
    this.standardImg,
    this.standardSwapTime,
    this.stationAddress,
    this.stationSn,
    this.storeNum,
  });

  factory CabinetAuthorization.fromJson(Map<String, dynamic> json) {
    return CabinetAuthorization(
      avg7DaySwapTime: json['avg7DaySwapTime']?.toString(),
      damageNum: (json['damageNum'] as num?)?.toInt(),
      offlineNum: (json['offlineNum'] as num?)?.toInt(),
      onlineStatus: (json['onlineStatus'] as num?)?.toInt(),
      showOnlineStatus: json['showOnlineStatus']?.toString(),
      standardImg: json['standardImg']?.toString(),
      standardSwapTime: json['standardSwapTime']?.toString(),
      stationAddress: json['stationAddress']?.toString(),
      stationSn: json['stationSn']?.toString(),
      storeNum: (json['storeNum'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'avg7DaySwapTime': avg7DaySwapTime,
        'damageNum': damageNum,
        'offlineNum': offlineNum,
        'onlineStatus': onlineStatus,
        'showOnlineStatus': showOnlineStatus,
        'standardImg': standardImg,
        'standardSwapTime': standardSwapTime,
        'stationAddress': stationAddress,
        'stationSn': stationSn,
        'storeNum': storeNum,
      };
}
