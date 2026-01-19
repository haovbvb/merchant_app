import 'package:flutter/foundation.dart';

@immutable
class PurchasingUser {
  final String? address;
  final String? avatar;
  final String? birthday;
  final String? cardImg;
  final String? cardNum;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? idNumber;
  final String? phone;
  final String? username;
  final String? personImg;

  const PurchasingUser({
    this.address,
    this.avatar,
    this.birthday,
    this.cardImg,
    this.cardNum,
    this.email,
    this.firstName,
    this.lastName,
    this.idNumber,
    this.phone,
    this.username,
    this.personImg,
  });

  factory PurchasingUser.fromJson(Map<String, dynamic> json) {
    return PurchasingUser(
      address: json['address']?.toString(),
      avatar: json['avatar']?.toString(),
      birthday: json['birthday']?.toString(),
      cardImg: json['cardImg']?.toString(),
      cardNum: json['cardNum']?.toString(),
      email: json['email']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      idNumber: json['idNumber']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString(),
      personImg: json['personImg']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'avatar': avatar,
        'birthday': birthday,
        'cardImg': cardImg,
        'cardNum': cardNum,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'idNumber': idNumber,
        'phone': phone,
        'username': username,
        'personImg': personImg,
      };
}
