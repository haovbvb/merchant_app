import 'package:flutter/foundation.dart';

@immutable
class ServicePlanInfo {
  final List<ServicePlanBean> list;
  final int total;

  const ServicePlanInfo({
    required this.list,
    required this.total,
  });

  factory ServicePlanInfo.fromJson(Map<String, dynamic> json) {
    return ServicePlanInfo(
      list: (json['list'] as List<dynamic>?)
              ?.map((item) => ServicePlanBean.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ))
              .toList() ??
          const <ServicePlanBean>[],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

@immutable
class ServicePlanBean {
  final String? infoName;
  final double? packageAmount;
  final String? batteryType;
  final String? carType;
  final String? infoCode;
  final String? deviceModel;
  final bool isSelected;

  const ServicePlanBean({
    required this.infoName,
    required this.packageAmount,
    required this.batteryType,
    required this.carType,
    required this.infoCode,
    required this.deviceModel,
    required this.isSelected,
  });

  factory ServicePlanBean.fromJson(Map<String, dynamic> json) {
    return ServicePlanBean(
      infoName: json['infoName']?.toString(),
      packageAmount: (json['packageAmount'] as num?)?.toDouble(),
      batteryType: json['batteryType']?.toString(),
      carType: json['carType']?.toString(),
      infoCode: json['infoCode']?.toString(),
      deviceModel: json['deviceModel']?.toString(),
      isSelected: json['isSelected'] == true,
    );
  }
}
