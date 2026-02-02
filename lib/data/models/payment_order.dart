/// 收款订单模型 - 对应 Android 的 Payment.kt
library;

/// 收款订单
class PaymentOrder {
  final double amount;
  final String cardNum;
  final String firstName;
  final String lastName;
  final int orderDate;
  final String orderNo;
  final int payType; // 支付类型
  final int period;
  final int status; // 0=待审核 1=已确认 2=已拒绝
  final int type; // 订单类型
  final String username;

  const PaymentOrder({
    this.amount = 0.0,
    this.cardNum = '',
    this.firstName = '',
    this.lastName = '',
    this.orderDate = 0,
    this.orderNo = '',
    this.payType = 0,
    this.period = 0,
    this.status = 0,
    this.type = 0,
    this.username = '',
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    return PaymentOrder(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      cardNum: json['cardNum']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      orderDate: (json['orderDate'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo']?.toString() ?? '',
      payType: (json['payType'] as num?)?.toInt() ?? 0,
      period: (json['period'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
    );
  }

  /// 用户全名
  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return username;
    return '$firstName $lastName'.trim();
  }

  /// 是否待审核
  bool get isPending => status == 0;

  /// 是否已确认
  bool get isConfirmed => status == 1;

  /// 是否已拒绝
  bool get isRejected => status == 2;

  /// 状态名称
  String get statusName {
    switch (status) {
      case 0:
        return '待审核';
      case 1:
        return '已确认';
      case 2:
        return '已拒绝';
      default:
        return '';
    }
  }

  /// 订单日期 DateTime
  DateTime? get orderDateTime =>
      orderDate > 0 ? DateTime.fromMillisecondsSinceEpoch(orderDate) : null;
}

/// 收款订单列表响应
class PaymentOrderListResponse {
  final List<PaymentOrder> list;
  final int total;

  const PaymentOrderListResponse({this.list = const [], this.total = 0});

  factory PaymentOrderListResponse.fromJson(Map<String, dynamic> json) {
    return PaymentOrderListResponse(
      list:
          (json['list'] as List<dynamic>?)
              ?.map((e) => PaymentOrder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 保险计划
class Insurance {
  final String beginDate;
  final String endDate;
  final double insuranceAmount;
  final double insuranceFee;
  final int type;

  const Insurance({
    this.beginDate = '',
    this.endDate = '',
    this.insuranceAmount = 0.0,
    this.insuranceFee = 0.0,
    this.type = 0,
  });

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      beginDate: json['beginDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      insuranceAmount: (json['insuranceAmount'] as num?)?.toDouble() ?? 0.0,
      insuranceFee: (json['insuranceFee'] as num?)?.toDouble() ?? 0.0,
      type: (json['type'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'beginDate': beginDate,
    'endDate': endDate,
    'insuranceAmount': insuranceAmount,
    'insuranceFee': insuranceFee,
    'type': type,
  };
}
