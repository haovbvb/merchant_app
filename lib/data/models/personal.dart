import 'package:flutter/foundation.dart';

@immutable
class Personal {
  final String accountNo;
  final dynamic workNo;
  final String username;
  final String phone;
  final int status;
  final String showStatus;
  final String avatarUrl;
  final String nickName;
  final String userId;

  const Personal({
    required this.accountNo,
    required this.workNo,
    required this.username,
    required this.phone,
    required this.status,
    required this.showStatus,
    required this.avatarUrl,
    required this.nickName,
    required this.userId,
  });

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      accountNo: (json['accountNo'] ?? '').toString(),
      workNo: json['workNo'],
      username: (json['username'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      status: (json['status'] as num?)?.toInt() ?? 0,
      showStatus: (json['showStatus'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      nickName: (json['nickName'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'accountNo': accountNo,
        'workNo': workNo,
        'username': username,
        'phone': phone,
        'status': status,
        'showStatus': showStatus,
        'avatarUrl': avatarUrl,
        'nickName': nickName,
        'userId': userId,
      };
}
