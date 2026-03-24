class PersonalInfo {
  const PersonalInfo({
    this.accountNo,
    this.workNo,
    this.username,
    this.phone,
    this.status,
    this.showStatus,
    this.avatarUrl,
    this.nickName,
    this.userId,
  });

  final String? accountNo;
  final String? workNo;
  final String? username;
  final String? phone;
  final int? status;
  final String? showStatus;
  final String? avatarUrl;
  final String? nickName;
  final String? userId;

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      accountNo: json['accountNo']?.toString(),
      workNo: json['workNo']?.toString(),
      username: json['username']?.toString(),
      phone: json['phone']?.toString(),
      status: json['status'] is num ? (json['status'] as num).toInt() : null,
      showStatus: json['showStatus']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      nickName: json['nickName']?.toString(),
      userId: json['userId']?.toString(),
    );
  }

  String get displayName {
    if (nickName != null && nickName!.isNotEmpty) return nickName!;
    if (username != null && username!.isNotEmpty) return username!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return '';
  }
}
