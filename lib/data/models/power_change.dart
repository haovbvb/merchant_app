/// 换电记录
/// 对应 Android 的 PowerChangeBeanNew
class PowerChangeResponse {
  final List<PowerChangeItem> list;
  final int total;

  const PowerChangeResponse({this.list = const [], this.total = 0});

  factory PowerChangeResponse.fromJson(Map<String, dynamic> json) {
    return PowerChangeResponse(
      list:
          (json['list'] as List<dynamic>?)
              ?.map(
                (e) => PowerChangeItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          const [],
      total: json['total'] is num ? (json['total'] as num).toInt() : 0,
    );
  }
}

/// 换电记录项
class PowerChangeItem {
  final String? cardNum;
  final String? createTime;
  final List<PowerChangeDetail>? details;
  final String? error;
  final String? handlerName;
  final String? handlerPhone;
  final String? inBattery;
  final String? outBattery;
  final String? reason;
  final String? remark;
  final int? rentId;
  final String? showStatusName;
  final String? stationSn;
  final int? status;
  final String? swapTypeName;
  final int? type;

  const PowerChangeItem({
    this.cardNum,
    this.createTime,
    this.details,
    this.error,
    this.handlerName,
    this.handlerPhone,
    this.inBattery,
    this.outBattery,
    this.reason,
    this.remark,
    this.rentId,
    this.showStatusName,
    this.stationSn,
    this.status,
    this.swapTypeName,
    this.type,
  });

  factory PowerChangeItem.fromJson(Map<String, dynamic> json) {
    return PowerChangeItem(
      cardNum: json['cardNum']?.toString(),
      createTime: json['createTime']?.toString(),
      details: (json['details'] as List<dynamic>?)
          ?.map(
            (e) =>
                PowerChangeDetail.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      error: json['error']?.toString(),
      handlerName: json['handlerName']?.toString(),
      handlerPhone: json['handlerPhone']?.toString(),
      inBattery: json['inBattery']?.toString(),
      outBattery: json['outBattery']?.toString(),
      reason: json['reason']?.toString(),
      remark: json['remark']?.toString(),
      rentId: json['rentId'] is num ? (json['rentId'] as num).toInt() : null,
      showStatusName: json['showStatusName']?.toString(),
      stationSn: json['stationSn']?.toString(),
      status: json['status'] is num ? (json['status'] as num).toInt() : null,
      swapTypeName: json['swapTypeName']?.toString(),
      type: json['type'] is num ? (json['type'] as num).toInt() : null,
    );
  }

  /// 是否成功
  bool get isSuccess => status == 1;
}

/// 换电详情
class PowerChangeDetail {
  final String? error;
  final String? inBattery;
  final int? inPort;
  final int? inSoc;
  final String? outBattery;
  final int? outPort;
  final int? outSoc;
  final int? status;

  const PowerChangeDetail({
    this.error,
    this.inBattery,
    this.inPort,
    this.inSoc,
    this.outBattery,
    this.outPort,
    this.outSoc,
    this.status,
  });

  factory PowerChangeDetail.fromJson(Map<String, dynamic> json) {
    return PowerChangeDetail(
      error: json['error']?.toString(),
      inBattery: json['inBattery']?.toString(),
      inPort: json['inPort'] is num ? (json['inPort'] as num).toInt() : null,
      inSoc: json['inSoc'] is num ? (json['inSoc'] as num).toInt() : null,
      outBattery: json['outBattery']?.toString(),
      outPort: json['outPort'] is num ? (json['outPort'] as num).toInt() : null,
      outSoc: json['outSoc'] is num ? (json['outSoc'] as num).toInt() : null,
      status: json['status'] is num ? (json['status'] as num).toInt() : null,
    );
  }
}
