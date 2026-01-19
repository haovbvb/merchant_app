import 'package:flutter/foundation.dart';

import 'batter_or_vehicle_info.dart';

@immutable
class SwapBindInfo {
  final String? address;
  final String? avatar;
  final List<BatteryVo>? batteryList;
  final String? birthday;
  final String? cardImg;
  final String? cardNum;
  final String? email;
  final String? firstName;
  final String? idNumber;
  final String? lastName;
  final String? personImg;
  final String? phone;
  final String? username;
  final List<CarVo>? vehicleList;

  const SwapBindInfo({
    required this.address,
    required this.avatar,
    required this.batteryList,
    required this.birthday,
    required this.cardImg,
    required this.cardNum,
    required this.email,
    required this.firstName,
    required this.idNumber,
    required this.lastName,
    required this.personImg,
    required this.phone,
    required this.username,
    required this.vehicleList,
  });

  factory SwapBindInfo.fromJson(Map<String, dynamic> json) {
    return SwapBindInfo(
      address: json['address']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      batteryList: (json['batteryList'] as List<dynamic>?)
          ?.map((item) => BatteryVo.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      birthday: json['birthday']?.toString() ?? '',
      cardImg: json['cardImg']?.toString() ?? '',
      cardNum: json['cardNum']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      idNumber: json['idNumber']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      personImg: json['personImg']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      vehicleList: (json['vehicleList'] as List<dynamic>?)
          ?.map((item) => CarVo.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'avatar': avatar,
        'batteryList': batteryList?.map((item) => item.toJson()).toList(),
        'birthday': birthday,
        'cardImg': cardImg,
        'cardNum': cardNum,
        'email': email,
        'firstName': firstName,
        'idNumber': idNumber,
        'lastName': lastName,
        'personImg': personImg,
        'phone': phone,
        'username': username,
        'vehicleList': vehicleList?.map((item) => item.toJson()).toList(),
      };
}
