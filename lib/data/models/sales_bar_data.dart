import 'package:flutter/foundation.dart';

@immutable
class SalesBarData {
  final List<double> amountList;
  final List<int> numList;
  final List<String> timeList;

  const SalesBarData({
    required this.amountList,
    required this.numList,
    required this.timeList,
  });

  factory SalesBarData.fromJson(Map<String, dynamic> json) {
    return SalesBarData(
      amountList: (json['amountList'] as List<dynamic>?)
              ?.map((item) => (item as num?)?.toDouble() ?? 0)
              .toList() ??
          const <double>[],
      numList: (json['numList'] as List<dynamic>?)
              ?.map((item) => (item as num?)?.toInt() ?? 0)
              .toList() ??
          const <int>[],
      timeList: (json['timeList'] as List<dynamic>?)
              ?.map((item) => (item ?? '').toString())
              .toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'amountList': amountList,
        'numList': numList,
        'timeList': timeList,
      };
}

@immutable
class OrderListResp {
  final String? time;
  final int? order;

  const OrderListResp({
    required this.time,
    required this.order,
  });

  factory OrderListResp.fromJson(Map<String, dynamic> json) {
    return OrderListResp(
      time: json['time']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'order': order,
      };
}

@immutable
class AmountListResp {
  final String? time;
  final double? amount;

  const AmountListResp({
    required this.time,
    required this.amount,
  });

  factory AmountListResp.fromJson(Map<String, dynamic> json) {
    return AmountListResp(
      time: json['time']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'time': time,
        'amount': amount,
      };
}

@immutable
class SalesListBean {
  final int payType;
  final int status;
  final String? orderNo;
  final double price;
  final String? attachment;

  const SalesListBean({
    required this.payType,
    required this.status,
    required this.orderNo,
    required this.price,
    required this.attachment,
  });

  factory SalesListBean.fromJson(Map<String, dynamic> json) {
    return SalesListBean(
      payType: (json['payType'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      orderNo: json['orderNo']?.toString() ?? '-',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      attachment: json['attachment']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'payType': payType,
        'status': status,
        'orderNo': orderNo,
        'price': price,
        'attachment': attachment,
      };
}

@immutable
class SaleSumPageData {
  final double? avgOrderAmount;
  final int? incomeRank;
  final int? numRank;
  final double? orderIncome;
  final int? orderNum;
  final double? signRate;

  const SaleSumPageData({
    required this.avgOrderAmount,
    required this.incomeRank,
    required this.numRank,
    required this.orderIncome,
    required this.orderNum,
    required this.signRate,
  });

  factory SaleSumPageData.fromJson(Map<String, dynamic> json) {
    return SaleSumPageData(
      avgOrderAmount: (json['avgOrderAmount'] as num?)?.toDouble(),
      incomeRank: (json['incomeRank'] as num?)?.toInt(),
      numRank: (json['numRank'] as num?)?.toInt(),
      orderIncome: (json['orderIncome'] as num?)?.toDouble(),
      orderNum: (json['orderNum'] as num?)?.toInt(),
      signRate: (json['signRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'avgOrderAmount': avgOrderAmount,
        'incomeRank': incomeRank,
        'numRank': numRank,
        'orderIncome': orderIncome,
        'orderNum': orderNum,
        'signRate': signRate,
      };
}
