import 'package:flutter/foundation.dart';

@immutable
class UserAuthorizationList {
  final List<UserAuthorizationBean> list;
  final int total;

  const UserAuthorizationList({
    this.list = const [],
    this.total = 0,
  });

  factory UserAuthorizationList.fromJson(Map<String, dynamic> json) {
    final raw = json['list'];
    return UserAuthorizationList(
      list: raw is List
          ? raw
              .map((item) => UserAuthorizationBean.fromJson(
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
class UserAuthorizationBean {
  final String? avatar;
  final String? username;
  final String? phone;
  final String? accountNo;
  final String? remark;

  const UserAuthorizationBean({
    this.avatar,
    this.username,
    this.phone,
    this.accountNo,
    this.remark,
  });

  factory UserAuthorizationBean.fromJson(Map<String, dynamic> json) {
    return UserAuthorizationBean(
      avatar: json['avatar']?.toString(),
      username: json['username']?.toString(),
      phone: json['phone']?.toString(),
      accountNo: json['accountNo']?.toString(),
      remark: json['remark']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'avatar': avatar,
        'username': username,
        'phone': phone,
        'accountNo': accountNo,
        'remark': remark,
      };
}
