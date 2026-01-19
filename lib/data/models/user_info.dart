import 'package:flutter/foundation.dart';

@immutable
class UserInfo {
  final String avatar;
  final String cardNum;
  final String firstName;
  final String lastName;
  final String registerDate;
  final double remainPay;
  final int remainPeriod;
  final double totalPay;
  final int type;
  final String username;
  final String idNumber;
  final int status;
  final int? order;
  final double? orderAmount;
  final int? asset;

  const UserInfo({
    required this.avatar,
    required this.cardNum,
    required this.firstName,
    required this.lastName,
    required this.registerDate,
    required this.remainPay,
    required this.remainPeriod,
    required this.totalPay,
    required this.type,
    required this.username,
    required this.idNumber,
    required this.status,
    this.order,
    this.orderAmount,
    this.asset,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      avatar: (json['avatar'] ?? '').toString(),
      cardNum: (json['cardNum'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      registerDate: (json['registerDate'] ?? '').toString(),
      remainPay: (json['remainPay'] as num?)?.toDouble() ?? 0.0,
      remainPeriod: (json['remainPeriod'] as num?)?.toInt() ?? 0,
      totalPay: (json['totalPay'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      username: (json['username'] ?? '').toString(),
      idNumber: (json['idNumber'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
      order: (json['order'] as num?)?.toInt(),
      orderAmount: (json['orderAmount'] as num?)?.toDouble(),
      asset: (json['asset'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'avatar': avatar,
        'cardNum': cardNum,
        'firstName': firstName,
        'lastName': lastName,
        'registerDate': registerDate,
        'remainPay': remainPay,
        'remainPeriod': remainPeriod,
        'totalPay': totalPay,
        'type': type,
        'username': username,
        'idNumber': idNumber,
        'status': status,
        'order': order,
        'orderAmount': orderAmount,
        'asset': asset,
      };
}
