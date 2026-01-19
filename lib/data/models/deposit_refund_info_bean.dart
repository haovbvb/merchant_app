import 'package:flutter/foundation.dart';

@immutable
class DepositRefundInfoBean {
  final String address;
  final String avatar;
  final String birthday;
  final String cardImg;
  final String cardNum;
  final List<Deposit>? depositList;
  final String email;
  final String firstName;
  final String idNumber;
  final String lastName;
  final String personImg;
  final String phone;
  final String username;

  const DepositRefundInfoBean({
    required this.address,
    required this.avatar,
    required this.birthday,
    required this.cardImg,
    required this.cardNum,
    required this.depositList,
    required this.email,
    required this.firstName,
    required this.idNumber,
    required this.lastName,
    required this.personImg,
    required this.phone,
    required this.username,
  });

  factory DepositRefundInfoBean.fromJson(Map<String, dynamic> json) {
    return DepositRefundInfoBean(
      address: (json['address'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
      birthday: (json['birthday'] ?? '').toString(),
      cardImg: (json['cardImg'] ?? '').toString(),
      cardNum: (json['cardNum'] ?? '').toString(),
      depositList: (json['depositList'] as List<dynamic>?)
          ?.map((item) => Deposit.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
      email: (json['email'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      idNumber: (json['idNumber'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      personImg: (json['personImg'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'avatar': avatar,
        'birthday': birthday,
        'cardImg': cardImg,
        'cardNum': cardNum,
        'depositList': depositList?.map((item) => item.toJson()).toList(),
        'email': email,
        'firstName': firstName,
        'idNumber': idNumber,
        'lastName': lastName,
        'personImg': personImg,
        'phone': phone,
        'username': username,
      };
}

@immutable
class Deposit {
  final double depositAmount;
  final String depositImgList;
  final String? orderNo;
  final int? unbindTime;
  final bool isSelected;

  const Deposit({
    required this.depositAmount,
    required this.depositImgList,
    required this.orderNo,
    required this.unbindTime,
    required this.isSelected,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0,
      depositImgList: (json['depositImgList'] ?? '').toString(),
      orderNo: json['orderNo']?.toString(),
      unbindTime: (json['unbindTime'] as num?)?.toInt(),
      isSelected: json['isSelected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'depositAmount': depositAmount,
        'depositImgList': depositImgList,
        'orderNo': orderNo,
        'unbindTime': unbindTime,
        'isSelected': isSelected,
      };
}
