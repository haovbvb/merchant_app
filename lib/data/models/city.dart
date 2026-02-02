/// 城市模型
library;

class City {
  final String code;
  final String name;
  final String? parentCode;
  final int? level;

  const City({
    required this.code,
    required this.name,
    this.parentCode,
    this.level,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      code: json['code']?.toString() ?? json['cityCode']?.toString() ?? '',
      name: json['name']?.toString() ?? json['cityName']?.toString() ?? '',
      parentCode: json['parentCode']?.toString(),
      level: (json['level'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    if (parentCode != null) 'parentCode': parentCode,
    if (level != null) 'level': level,
  };
}

/// 运维人员
class OpsAccount {
  final String accountNo;
  final String username;
  final String phone;
  final String? nickName;
  final String? avatarUrl;
  final int? status;

  const OpsAccount({
    required this.accountNo,
    required this.username,
    this.phone = '',
    this.nickName,
    this.avatarUrl,
    this.status,
  });

  factory OpsAccount.fromJson(Map<String, dynamic> json) {
    return OpsAccount(
      accountNo: json['accountNo']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      nickName: json['nickName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      status: (json['status'] as num?)?.toInt(),
    );
  }

  String get displayName => nickName?.isNotEmpty == true ? nickName! : username;
}
