import 'package:flutter/foundation.dart';

@immutable
class SettingInfoBean {
  final EmptySpaceDetectionBean? emptySpaceDetection;
  final NoChargingBean? noCharging;
  final RestartTheChargerRegularlyBean? restartTheChargerRegularly;
  final HeatingBean? heating;
  final HomePageDetailsBean? homePageDetails;
  final MicroSwitchBean? microSwitch;
  final BatteryConnectorBean? batteryConnector;
  final ChargingStrategyBean? chargingStrategy;
  final MinimumElectricityBorrowedBean? minimumElectricityBorrowed;
  final MaximumChargeCapacityBean? maximumChargeCapacity;

  const SettingInfoBean({
    required this.emptySpaceDetection,
    required this.noCharging,
    required this.restartTheChargerRegularly,
    required this.heating,
    required this.homePageDetails,
    required this.microSwitch,
    required this.batteryConnector,
    required this.chargingStrategy,
    required this.minimumElectricityBorrowed,
    required this.maximumChargeCapacity,
  });

  factory SettingInfoBean.fromJson(Map<String, dynamic> json) {
    return SettingInfoBean(
      emptySpaceDetection: json['emptySpaceDetection'] is Map<String, dynamic>
          ? EmptySpaceDetectionBean.fromJson(
              Map<String, dynamic>.from(json['emptySpaceDetection'] as Map),
            )
          : null,
      noCharging: json['noCharging'] is Map<String, dynamic>
          ? NoChargingBean.fromJson(
              Map<String, dynamic>.from(json['noCharging'] as Map),
            )
          : null,
      restartTheChargerRegularly:
          json['restartTheChargerRegularly'] is Map<String, dynamic>
              ? RestartTheChargerRegularlyBean.fromJson(
                  Map<String, dynamic>.from(
                    json['restartTheChargerRegularly'] as Map,
                  ),
                )
              : null,
      heating: json['heating'] is Map<String, dynamic>
          ? HeatingBean.fromJson(
              Map<String, dynamic>.from(json['heating'] as Map),
            )
          : null,
      homePageDetails: json['homePageDetails'] is Map<String, dynamic>
          ? HomePageDetailsBean.fromJson(
              Map<String, dynamic>.from(json['homePageDetails'] as Map),
            )
          : null,
      microSwitch: json['microSwitch'] is Map<String, dynamic>
          ? MicroSwitchBean.fromJson(
              Map<String, dynamic>.from(json['microSwitch'] as Map),
            )
          : null,
      batteryConnector: json['batteryConnector'] is Map<String, dynamic>
          ? BatteryConnectorBean.fromJson(
              Map<String, dynamic>.from(json['batteryConnector'] as Map),
            )
          : null,
      chargingStrategy: json['chargingStrategy'] is Map<String, dynamic>
          ? ChargingStrategyBean.fromJson(
              Map<String, dynamic>.from(json['chargingStrategy'] as Map),
            )
          : null,
      minimumElectricityBorrowed:
          json['minimumElectricityBorrowed'] is Map<String, dynamic>
              ? MinimumElectricityBorrowedBean.fromJson(
                  Map<String, dynamic>.from(
                    json['minimumElectricityBorrowed'] as Map,
                  ),
                )
              : null,
      maximumChargeCapacity: json['maximumChargeCapacity'] is Map<String,
              dynamic>
          ? MaximumChargeCapacityBean.fromJson(
              Map<String, dynamic>.from(json['maximumChargeCapacity'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'emptySpaceDetection': emptySpaceDetection?.toJson(),
        'noCharging': noCharging?.toJson(),
        'restartTheChargerRegularly': restartTheChargerRegularly?.toJson(),
        'heating': heating?.toJson(),
        'homePageDetails': homePageDetails?.toJson(),
        'microSwitch': microSwitch?.toJson(),
        'batteryConnector': batteryConnector?.toJson(),
        'chargingStrategy': chargingStrategy?.toJson(),
        'minimumElectricityBorrowed': minimumElectricityBorrowed?.toJson(),
        'maximumChargeCapacity': maximumChargeCapacity?.toJson(),
      };
}

@immutable
class EmptySpaceDetectionBean {
  final int count;

  const EmptySpaceDetectionBean({
    required this.count,
  });

  factory EmptySpaceDetectionBean.fromJson(Map<String, dynamic> json) {
    return EmptySpaceDetectionBean(
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'count': count,
      };
}

@immutable
class NoChargingBean {
  final String? blackoutTime;
  final String? chargingTime;

  const NoChargingBean({
    required this.blackoutTime,
    required this.chargingTime,
  });

  factory NoChargingBean.fromJson(Map<String, dynamic> json) {
    return NoChargingBean(
      blackoutTime: json['blackoutTime']?.toString(),
      chargingTime: json['chargingTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'blackoutTime': blackoutTime,
        'chargingTime': chargingTime,
      };
}

@immutable
class RestartTheChargerRegularlyBean {
  final int open;
  final String? time;

  const RestartTheChargerRegularlyBean({
    required this.open,
    required this.time,
  });

  factory RestartTheChargerRegularlyBean.fromJson(Map<String, dynamic> json) {
    return RestartTheChargerRegularlyBean(
      open: (json['open'] as num?)?.toInt() ?? 0,
      time: json['time']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'open': open,
        'time': time,
      };
}

@immutable
class HeatingBean {
  final int pmsAutoControl;
  final ApkControlBean? apkControl;

  const HeatingBean({
    required this.pmsAutoControl,
    required this.apkControl,
  });

  factory HeatingBean.fromJson(Map<String, dynamic> json) {
    return HeatingBean(
      pmsAutoControl: (json['pmsAutoControl'] as num?)?.toInt() ?? 0,
      apkControl: json['apkControl'] is Map<String, dynamic>
          ? ApkControlBean.fromJson(
              Map<String, dynamic>.from(json['apkControl'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'pmsAutoControl': pmsAutoControl,
        'apkControl': apkControl?.toJson(),
      };
}

@immutable
class ApkControlBean {
  final int open;
  final int permit;
  final int prohibit;

  const ApkControlBean({
    required this.open,
    required this.permit,
    required this.prohibit,
  });

  factory ApkControlBean.fromJson(Map<String, dynamic> json) {
    return ApkControlBean(
      open: (json['open'] as num?)?.toInt() ?? 0,
      permit: (json['permit'] as num?)?.toInt() ?? 0,
      prohibit: (json['prohibit'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'open': open,
        'permit': permit,
        'prohibit': prohibit,
      };
}

@immutable
class HomePageDetailsBean {
  final int show;

  const HomePageDetailsBean({
    required this.show,
  });

  factory HomePageDetailsBean.fromJson(Map<String, dynamic> json) {
    return HomePageDetailsBean(
      show: (json['show'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'show': show,
      };
}

@immutable
class MicroSwitchBean {
  final int open;

  const MicroSwitchBean({
    required this.open,
  });

  factory MicroSwitchBean.fromJson(Map<String, dynamic> json) {
    return MicroSwitchBean(
      open: (json['open'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'open': open,
      };
}

@immutable
class BatteryConnectorBean {
  final int open;

  const BatteryConnectorBean({
    required this.open,
  });

  factory BatteryConnectorBean.fromJson(Map<String, dynamic> json) {
    return BatteryConnectorBean(
      open: (json['open'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'open': open,
      };
}

@immutable
class ChargingStrategyBean {
  final int type;
  final int level;

  const ChargingStrategyBean({
    required this.type,
    required this.level,
  });

  factory ChargingStrategyBean.fromJson(Map<String, dynamic> json) {
    return ChargingStrategyBean(
      type: (json['type'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'level': level,
      };
}

@immutable
class MinimumElectricityBorrowedBean {
  final int level;

  const MinimumElectricityBorrowedBean({
    required this.level,
  });

  factory MinimumElectricityBorrowedBean.fromJson(Map<String, dynamic> json) {
    return MinimumElectricityBorrowedBean(
      level: (json['level'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
      };
}

@immutable
class MaximumChargeCapacityBean {
  final int level;

  const MaximumChargeCapacityBean({
    required this.level,
  });

  factory MaximumChargeCapacityBean.fromJson(Map<String, dynamic> json) {
    return MaximumChargeCapacityBean(
      level: (json['level'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
      };
}
