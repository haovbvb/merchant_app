/// 设备通用搜索结果
/// 对应 Android 的 EquipmentDeviceSearchBeanNew
class DeviceSearchResult {
  final DeviceInfo? deviceInfo;

  /// 设备类型: 1=电池, 2=车辆, 3=电柜
  final int? type;

  const DeviceSearchResult({this.deviceInfo, this.type});

  factory DeviceSearchResult.fromJson(Map<String, dynamic> json) {
    return DeviceSearchResult(
      deviceInfo: json['deviceInfo'] is Map
          ? DeviceInfo.fromJson(
              Map<String, dynamic>.from(json['deviceInfo'] as Map),
            )
          : null,
      type: json['type'] is num ? (json['type'] as num).toInt() : null,
    );
  }

  /// 是否是电池
  bool get isBattery => type == 1;

  /// 是否是车辆
  bool get isVehicle => type == 2;

  /// 是否是电柜
  bool get isCabinet => type == 3;
}

/// 设备信息
/// 对应 Android 的 DeviceInfo
class DeviceInfo {
  final String? address;
  final String? bindUserId;
  final String? bindUserName;
  final String? bindUserPhone;
  final String? carNumber;
  final String? createTime;
  final int? deviceBindStatus;
  final String? deviceId;
  final String? deviceModel;
  final int? hasPermission;
  final String? img;
  final String? imgList;
  final int? installStatus;
  final String? installTime;
  final String? insuranceNumber;
  final double? latitude;
  final double? longitude;
  final List<ManagerInfo>? managerList;
  final int? onlineStatus;
  final String? showDeviceBindStatus;
  final String? showDeviceModel;
  final String? showDeviceType;
  final String? showInstallStatus;
  final String? showOnlineStatus;
  final String? simNo;
  final String? sn;
  final String? stationName;
  final String? vin;
  final String? ctrlId;
  final int? bindSource;
  final bool? needMaintenance;
  final String? bindTime;

  const DeviceInfo({
    this.address,
    this.bindUserId,
    this.bindUserName,
    this.bindUserPhone,
    this.carNumber,
    this.createTime,
    this.deviceBindStatus,
    this.deviceId,
    this.deviceModel,
    this.hasPermission,
    this.img,
    this.imgList,
    this.installStatus,
    this.installTime,
    this.insuranceNumber,
    this.latitude,
    this.longitude,
    this.managerList,
    this.onlineStatus,
    this.showDeviceBindStatus,
    this.showDeviceModel,
    this.showDeviceType,
    this.showInstallStatus,
    this.showOnlineStatus,
    this.simNo,
    this.sn,
    this.stationName,
    this.vin,
    this.ctrlId,
    this.bindSource,
    this.needMaintenance,
    this.bindTime,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      address: json['address']?.toString(),
      bindUserId: json['bindUserId']?.toString(),
      bindUserName: json['bindUserName']?.toString(),
      bindUserPhone: json['bindUserPhone']?.toString(),
      carNumber: json['carNumber']?.toString(),
      createTime: json['createTime']?.toString(),
      deviceBindStatus: json['deviceBindStatus'] is num
          ? (json['deviceBindStatus'] as num).toInt()
          : null,
      deviceId: json['deviceId']?.toString(),
      deviceModel: json['deviceModel']?.toString(),
      hasPermission: json['hasPermission'] is num
          ? (json['hasPermission'] as num).toInt()
          : null,
      img: json['img']?.toString(),
      imgList: json['imgList']?.toString(),
      installStatus: json['installStatus'] is num
          ? (json['installStatus'] as num).toInt()
          : null,
      installTime: json['installTime']?.toString(),
      insuranceNumber: json['insuranceNumber']?.toString(),
      latitude: json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : null,
      managerList: json['managerList'] is List
          ? (json['managerList'] as List)
                .map(
                  (e) =>
                      ManagerInfo.fromJson(Map<String, dynamic>.from(e as Map)),
                )
                .toList()
          : null,
      onlineStatus: json['onlineStatus'] is num
          ? (json['onlineStatus'] as num).toInt()
          : null,
      showDeviceBindStatus: json['showDeviceBindStatus']?.toString(),
      showDeviceModel: json['showDeviceModel']?.toString(),
      showDeviceType: json['showDeviceType']?.toString(),
      showInstallStatus: json['showInstallStatus']?.toString(),
      showOnlineStatus: json['showOnlineStatus']?.toString(),
      simNo: json['simNo']?.toString(),
      sn: json['sn']?.toString(),
      stationName: json['stationName']?.toString(),
      vin: json['vin']?.toString(),
      ctrlId: json['ctrlId']?.toString(),
      bindSource: json['bindSource'] is num
          ? (json['bindSource'] as num).toInt()
          : null,
      needMaintenance: json['needMaintenance'] == true,
      bindTime: json['bindTime']?.toString(),
    );
  }

  /// 是否在线
  bool get isOnline => onlineStatus == 1 || showOnlineStatus == 'Online';

  /// 是否已上架
  bool get isOnboarded => installStatus == 1;

  /// 获取图片列表
  List<String> get installImgSet {
    if (imgList == null || imgList!.isEmpty) return const [];
    return imgList!.split(',').where((s) => s.isNotEmpty).toList();
  }
}

/// 管理员信息
class ManagerInfo {
  final String? accountNo;
  final String? showName;

  const ManagerInfo({this.accountNo, this.showName});

  factory ManagerInfo.fromJson(Map<String, dynamic> json) {
    return ManagerInfo(
      accountNo: json['accountNo']?.toString() ?? json['id']?.toString(),
      showName: json['showName']?.toString() ?? json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'accountNo': accountNo,
    'showName': showName,
  };
}
