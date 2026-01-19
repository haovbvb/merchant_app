import 'package:flutter/foundation.dart';

@immutable
class BookMaintenanceBean {
  final String? address;
  final String? avatar;
  final String? carModel;
  final String? carNumber;
  final String? carSpec;
  final String? cardNum;
  final int? day30Mile;
  final int? dayMile;
  final String? firstName;
  final String? img;
  final String? lastName;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? reservationDate;
  final String? reservationNo;
  final String? sn;
  final String? speedRange;
  final String? username;
  final String? vin;
  final double? day30AvgMilePerDay;
  final double? day30AvgSpeed;
  final double? day30AvgSwapCount;

  const BookMaintenanceBean({
    this.address,
    this.avatar,
    this.carModel,
    this.carNumber,
    this.carSpec,
    this.cardNum,
    this.day30Mile,
    this.dayMile,
    this.firstName,
    this.img,
    this.lastName,
    this.latitude,
    this.longitude,
    this.phone,
    this.reservationDate,
    this.reservationNo,
    this.sn,
    this.speedRange,
    this.username,
    this.vin,
    this.day30AvgMilePerDay,
    this.day30AvgSpeed,
    this.day30AvgSwapCount,
  });

  factory BookMaintenanceBean.fromJson(Map<String, dynamic> json) {
    return BookMaintenanceBean(
      address: json['address']?.toString(),
      avatar: json['avatar']?.toString(),
      carModel: json['carModel']?.toString(),
      carNumber: json['carNumber']?.toString(),
      carSpec: json['carSpec']?.toString(),
      cardNum: json['cardNum']?.toString(),
      day30Mile: (json['day30Mile'] as num?)?.toInt(),
      dayMile: (json['dayMile'] as num?)?.toInt(),
      firstName: json['firstName']?.toString(),
      img: json['img']?.toString(),
      lastName: json['lastName']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone']?.toString(),
      reservationDate: json['reservationDate']?.toString(),
      reservationNo: json['reservationNo']?.toString(),
      sn: json['sn']?.toString(),
      speedRange: json['speedRange']?.toString(),
      username: json['username']?.toString(),
      vin: json['vin']?.toString(),
      day30AvgMilePerDay: (json['day30AvgMilePerDay'] as num?)?.toDouble(),
      day30AvgSpeed: (json['day30AvgSpeed'] as num?)?.toDouble(),
      day30AvgSwapCount: (json['day30AvgSwapCount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'avatar': avatar,
        'carModel': carModel,
        'carNumber': carNumber,
        'carSpec': carSpec,
        'cardNum': cardNum,
        'day30Mile': day30Mile,
        'dayMile': dayMile,
        'firstName': firstName,
        'img': img,
        'lastName': lastName,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'reservationDate': reservationDate,
        'reservationNo': reservationNo,
        'sn': sn,
        'speedRange': speedRange,
        'username': username,
        'vin': vin,
        'day30AvgMilePerDay': day30AvgMilePerDay,
        'day30AvgSpeed': day30AvgSpeed,
        'day30AvgSwapCount': day30AvgSwapCount,
      };
}

@immutable
class DeviceMaintenanceResponse {
  final List<MaintenanceRecord> list;
  final int total;

  const DeviceMaintenanceResponse({
    required this.list,
    required this.total,
  });

  factory DeviceMaintenanceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceMaintenanceResponse(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => MaintenanceRecord.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <MaintenanceRecord>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

@immutable
class MaintenanceRecord {
  final String? username;
  final String? img;
  final String? itemName;
  final String? log;
  final String? chargeTime;
  final String? date;
  final int? createTime;

  const MaintenanceRecord({
    required this.username,
    required this.img,
    required this.itemName,
    required this.log,
    required this.chargeTime,
    required this.date,
    required this.createTime,
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      username: json['username']?.toString(),
      img: json['img']?.toString(),
      itemName: json['itemName']?.toString(),
      log: json['log']?.toString(),
      chargeTime: json['chargeTime']?.toString(),
      date: json['date']?.toString(),
      createTime: (json['createTime'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'img': img,
        'itemName': itemName,
        'log': log,
        'chargeTime': chargeTime,
        'date': date,
        'createTime': createTime,
      };
}
