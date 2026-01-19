import 'package:flutter/foundation.dart';

@immutable
class InstallmentPaymentResponse {
  final String? address;
  final String? avatar;
  final String? birthday;
  final String? cardImg;
  final String? cardNum;
  final String createTime;
  final int? deviceNum;
  final String? email;
  final String? firstName;
  final String? idNumber;
  final String? lastName;
  final int? orderNum;
  final List<PeriodOrder>? periodOrderList;
  final String? personImg;
  final String? phone;
  final double? totalAmount;
  final int? userOrderStatus;
  final String? username;

  const InstallmentPaymentResponse({
    required this.address,
    required this.avatar,
    required this.birthday,
    required this.cardImg,
    required this.cardNum,
    required this.createTime,
    required this.deviceNum,
    required this.email,
    required this.firstName,
    required this.idNumber,
    required this.lastName,
    required this.orderNum,
    required this.periodOrderList,
    required this.personImg,
    required this.phone,
    required this.totalAmount,
    required this.userOrderStatus,
    required this.username,
  });

  factory InstallmentPaymentResponse.fromJson(Map<String, dynamic> json) {
    return InstallmentPaymentResponse(
      address: json['address']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      birthday: json['birthday']?.toString() ?? '',
      cardImg: json['cardImg']?.toString() ?? '',
      cardNum: json['cardNum']?.toString() ?? '',
      createTime: (json['createTime'] ?? '').toString(),
      deviceNum: (json['deviceNum'] as num?)?.toInt(),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      idNumber: json['idNumber']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      orderNum: (json['orderNum'] as num?)?.toInt(),
      periodOrderList: (json['periodOrderList'] as List<dynamic>?)
          ?.map((item) => PeriodOrder.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      personImg: json['personImg']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      userOrderStatus: (json['userOrderStatus'] as num?)?.toInt(),
      username: json['username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'avatar': avatar,
        'birthday': birthday,
        'cardImg': cardImg,
        'cardNum': cardNum,
        'createTime': createTime,
        'deviceNum': deviceNum,
        'email': email,
        'firstName': firstName,
        'idNumber': idNumber,
        'lastName': lastName,
        'orderNum': orderNum,
        'periodOrderList': periodOrderList?.map((item) => item.toJson()).toList(),
        'personImg': personImg,
        'phone': phone,
        'totalAmount': totalAmount,
        'userOrderStatus': userOrderStatus,
        'username': username,
      };
}

@immutable
class PeriodOrder {
  final int? type;
  final String? img;
  final String? model;
  final String? orderNo;
  final int? paySource;
  final int? rePaymentDate;
  final double? remainPay;
  final int? remainPeriod;
  final String? sn;
  final String? spec;
  final int? status;
  final int? period;
  final double? amount;
  final int? orderDate;
  final bool isSelected;

  const PeriodOrder({
    required this.type,
    required this.img,
    required this.model,
    required this.orderNo,
    required this.paySource,
    required this.rePaymentDate,
    required this.remainPay,
    required this.remainPeriod,
    required this.sn,
    required this.spec,
    required this.status,
    required this.period,
    required this.amount,
    required this.orderDate,
    required this.isSelected,
  });

  factory PeriodOrder.fromJson(Map<String, dynamic> json) {
    return PeriodOrder(
      type: (json['type'] as num?)?.toInt(),
      img: json['img']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      orderNo: json['orderNo']?.toString() ?? '',
      paySource: (json['paySource'] as num?)?.toInt(),
      rePaymentDate: (json['rePaymentDate'] as num?)?.toInt(),
      remainPay: (json['remainPay'] as num?)?.toDouble(),
      remainPeriod: (json['remainPeriod'] as num?)?.toInt(),
      sn: json['sn']?.toString() ?? '',
      spec: json['spec']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt(),
      period: (json['period'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
      orderDate: (json['orderDate'] as num?)?.toInt(),
      isSelected: json['isSelected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'img': img,
        'model': model,
        'orderNo': orderNo,
        'paySource': paySource,
        'rePaymentDate': rePaymentDate,
        'remainPay': remainPay,
        'remainPeriod': remainPeriod,
        'sn': sn,
        'spec': spec,
        'status': status,
        'period': period,
        'amount': amount,
        'orderDate': orderDate,
        'isSelected': isSelected,
      };
}
