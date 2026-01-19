import 'package:flutter/foundation.dart';

import 'bind_device.dart';

@immutable
class UserDetail {
  final String? avatar;
  final String? cardNum;
  final String? firstName;
  final String? lastName;
  final String? createTime;
  final String? birthday;
  final String? email;
  final bool? highPrivacy;
  final String? idNumber;
  final String? imgList;
  final String? phone;
  final String? remark;
  final int? status;
  final int? type;
  final String? username;
  final List<BindDevice>? batteryList;
  final List<BindDevice>? vehicleList;

  const UserDetail({
    this.avatar,
    this.cardNum,
    this.firstName,
    this.lastName,
    this.createTime,
    this.birthday,
    this.email,
    this.highPrivacy,
    this.idNumber,
    this.imgList,
    this.phone,
    this.remark,
    this.status,
    this.type,
    this.username,
    this.batteryList,
    this.vehicleList,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    List<BindDevice>? parseBindList(dynamic value) {
      if (value is List) {
        return value
            .whereType<Map<String, dynamic>>()
            .map(BindDevice.fromJson)
            .toList();
      }
      return null;
    }

    return UserDetail(
      avatar: json['avatar']?.toString(),
      cardNum: json['cardNum']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      createTime: json['createTime']?.toString(),
      birthday: json['birthday']?.toString(),
      email: json['email']?.toString(),
      highPrivacy: json['highPrivacy'] as bool?,
      idNumber: json['idNumber']?.toString(),
      imgList: json['imgList']?.toString(),
      phone: json['phone']?.toString(),
      remark: json['remark']?.toString(),
      status: (json['status'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      username: json['username']?.toString(),
      batteryList: parseBindList(json['batteryList']),
      vehicleList: parseBindList(json['vehicleList']),
    );
  }

  Map<String, dynamic> toJson() => {
        'avatar': avatar,
        'cardNum': cardNum,
        'firstName': firstName,
        'lastName': lastName,
        'createTime': createTime,
        'birthday': birthday,
        'email': email,
        'highPrivacy': highPrivacy,
        'idNumber': idNumber,
        'imgList': imgList,
        'phone': phone,
        'remark': remark,
        'status': status,
        'type': type,
        'username': username,
        'batteryList': batteryList?.map((e) => e.toJson()).toList(),
        'vehicleList': vehicleList?.map((e) => e.toJson()).toList(),
      };
}
