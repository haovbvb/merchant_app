class VcuDeviceSearchResult {
  final VcuDeviceInfo? deviceInfo;
  final int? type;

  const VcuDeviceSearchResult({this.deviceInfo, this.type});

  factory VcuDeviceSearchResult.fromJson(Map<String, dynamic> json) {
    return VcuDeviceSearchResult(
      deviceInfo: json['deviceInfo'] is Map
          ? VcuDeviceInfo.fromJson(
              Map<String, dynamic>.from(json['deviceInfo'] as Map),
            )
          : null,
      type: json['type'] is num ? (json['type'] as num).toInt() : null,
    );
  }
}

class VcuDeviceInfo {
  final String? ctrlId;
  final String? deviceId;
  final String? sn;
  final String? vin;
  final int? onlineStatus;

  const VcuDeviceInfo({
    this.ctrlId,
    this.deviceId,
    this.sn,
    this.vin,
    this.onlineStatus,
  });

  factory VcuDeviceInfo.fromJson(Map<String, dynamic> json) {
    return VcuDeviceInfo(
      ctrlId: json['ctrlId']?.toString(),
      deviceId: json['deviceId']?.toString(),
      sn: json['sn']?.toString(),
      vin: json['vin']?.toString(),
      onlineStatus: json['onlineStatus'] is num
          ? (json['onlineStatus'] as num).toInt()
          : null,
    );
  }
}
