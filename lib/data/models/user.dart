import 'package:flutter/foundation.dart';

@immutable
class User {
  final String token;
  final String name;
  final String phone;
  final String avatar;
  final int role;
  final String agentNo;
  final String? shopNo;
  final bool managerFlag;
  final String tenantName;
  final String emailCode;
  final String currencyUnit;
  final String areaCode;
  final String appRole;
  final String serviceType;

  const User({
    required this.token,
    required this.name,
    required this.phone,
    required this.avatar,
    required this.role,
    required this.agentNo,
    required this.shopNo,
    required this.managerFlag,
    required this.tenantName,
    required this.emailCode,
    required this.currencyUnit,
    required this.areaCode,
    required this.appRole,
    required this.serviceType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: (json['token'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      role: (json['role'] as num?)?.toInt() ?? 0,
      agentNo: (json['agentNo'] ?? '').toString(),
      shopNo: json['shopNo']?.toString(),
      managerFlag: json['managerFlag'] == true,
      tenantName: (json['tenantName'] ?? '').toString(),
      emailCode: (json['emailCode'] ?? '').toString(),
      currencyUnit: (json['currencyUnit'] ?? '').toString(),
      areaCode: (json['areaCode'] ?? '').toString(),
      appRole: (json['appRole'] ?? '').toString(),
      serviceType: (json['serviceType'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'name': name,
        'phone': phone,
        'avatar': avatar,
        'role': role,
        'agentNo': agentNo,
        'shopNo': shopNo,
        'managerFlag': managerFlag,
        'tenantName': tenantName,
        'emailCode': emailCode,
        'currencyUnit': currencyUnit,
        'areaCode': areaCode,
        'appRole': appRole,
        'serviceType': serviceType,
      };
}
