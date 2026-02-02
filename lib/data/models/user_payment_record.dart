/// 用户付款记录
/// 对应 Android 的 UserPaymentRecord
class UserPaymentRecord {
  final double? amount;
  final String? payTime;
  final int? payType;
  final int? period;
  final String? orderNo;
  final String? attachment;
  final int? payWay;

  const UserPaymentRecord({
    this.amount,
    this.payTime,
    this.payType,
    this.period,
    this.orderNo,
    this.attachment,
    this.payWay,
  });

  factory UserPaymentRecord.fromJson(Map<String, dynamic> json) {
    return UserPaymentRecord(
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : null,
      payTime: json['payTime']?.toString(),
      payType: json['payType'] is num ? (json['payType'] as num).toInt() : null,
      period: json['period'] is num ? (json['period'] as num).toInt() : null,
      orderNo: json['orderNo']?.toString(),
      attachment: json['attachment']?.toString(),
      payWay: json['payWay'] is num ? (json['payWay'] as num).toInt() : null,
    );
  }

  /// 付款方式显示文本
  String get payWayText {
    switch (payWay) {
      case 1:
        return 'Cash';
      case 2:
        return 'Transfer';
      case 3:
        return 'Mobile Money';
      default:
        return '-';
    }
  }
}

/// 用户付款记录响应
class UserPaymentRecordResponse {
  final List<UserPaymentRecord> list;
  final int total;

  const UserPaymentRecordResponse({this.list = const [], this.total = 0});

  factory UserPaymentRecordResponse.fromJson(Map<String, dynamic> json) {
    return UserPaymentRecordResponse(
      list:
          (json['list'] as List<dynamic>?)
              ?.map(
                (e) => UserPaymentRecord.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      total: json['total'] is num ? (json['total'] as num).toInt() : 0,
    );
  }
}
