import 'package:flutter/foundation.dart';

@immutable
class RoadSideOrderDetail {
  final int? createTime;
  final String? creator;
  final String? description;
  final String? deviceSn;
  final int? deviceType;
  final String? img;
  final String? imgList;
  final double? latitude;
  final double? longitude;
  final String? opResponse;
  final String? recordNo;
  final String? reportTime;
  final int? result;
  final String? rider;
  final String? avatar;
  final String? cardNum;
  final String? riderPhone;
  final int? source;
  final int? status;
  final int? payWay;
  final String? attachment;
  final int? processTime;
  final double? fee;
  final String? firstName;
  final String? lastName;

  const RoadSideOrderDetail({
    required this.createTime,
    required this.creator,
    required this.description,
    required this.deviceSn,
    required this.deviceType,
    required this.img,
    required this.imgList,
    required this.latitude,
    required this.longitude,
    required this.opResponse,
    required this.recordNo,
    required this.reportTime,
    required this.result,
    required this.rider,
    required this.avatar,
    required this.cardNum,
    required this.riderPhone,
    required this.source,
    required this.status,
    required this.payWay,
    required this.attachment,
    required this.processTime,
    required this.fee,
    required this.firstName,
    required this.lastName,
  });

  factory RoadSideOrderDetail.fromJson(Map<String, dynamic> json) {
    return RoadSideOrderDetail(
      createTime: (json['createTime'] as num?)?.toInt(),
      creator: json['creator']?.toString(),
      description: json['description']?.toString(),
      deviceSn: json['deviceSn']?.toString(),
      deviceType: (json['deviceType'] as num?)?.toInt(),
      img: json['img']?.toString(),
      imgList: json['imgList']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      opResponse: json['opResponse']?.toString(),
      recordNo: json['recordNo']?.toString(),
      reportTime: json['reportTime']?.toString(),
      result: (json['result'] as num?)?.toInt(),
      rider: json['rider']?.toString(),
        avatar: json['avatar']?.toString() ??
          json['riderAvatar']?.toString() ??
          json['userAvatar']?.toString() ??
          json['headImg']?.toString() ??
          json['headUrl']?.toString(),
      cardNum: json['cardNum']?.toString(),
      riderPhone: json['riderPhone']?.toString(),
      source: (json['source'] as num?)?.toInt(),
      status: (json['status'] as num?)?.toInt(),
      payWay: (json['payWay'] as num?)?.toInt(),
      attachment: json['attachment']?.toString(),
      processTime: (json['processTime'] as num?)?.toInt(),
      fee: (json['fee'] as num?)?.toDouble(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'createTime': createTime,
        'creator': creator,
        'description': description,
        'deviceSn': deviceSn,
        'deviceType': deviceType,
        'img': img,
        'imgList': imgList,
        'latitude': latitude,
        'longitude': longitude,
        'opResponse': opResponse,
        'recordNo': recordNo,
        'reportTime': reportTime,
        'result': result,
        'rider': rider,
        'avatar': avatar,
        'cardNum': cardNum,
        'riderPhone': riderPhone,
        'source': source,
        'status': status,
        'payWay': payWay,
        'attachment': attachment,
        'processTime': processTime,
        'fee': fee,
        'firstName': firstName,
        'lastName': lastName,
      };
}
