/// 库存模型 - 对应 Android 的 Stock.kt
library;

/// 库存列表项
class Stock {
  final int batteryNum;
  final String cityName;
  final String createTime;
  final String shopName;
  final String transferNo;
  final int transferType; // 1=调入 2=调出

  const Stock({
    this.batteryNum = 0,
    this.cityName = '',
    this.createTime = '',
    this.shopName = '',
    this.transferNo = '',
    this.transferType = 0,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      batteryNum: (json['batteryNum'] as num?)?.toInt() ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      createTime: json['createTime']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      transferNo: json['transferNo']?.toString() ?? '',
      transferType: (json['transferType'] as num?)?.toInt() ?? 0,
    );
  }

  /// 是否调入
  bool get isDispatch => transferType == 1;

  /// 是否调出
  bool get isRecall => transferType == 2;

  /// 类型名称
  String get typeName => isDispatch ? '调入' : (isRecall ? '调出' : '');
}

/// 库存数量统计
class StockNum {
  final int all;
  final int dispatch;
  final int recall;

  const StockNum({this.all = 0, this.dispatch = 0, this.recall = 0});

  factory StockNum.fromJson(Map<String, dynamic> json) {
    return StockNum(
      all: (json['all'] as num?)?.toInt() ?? 0,
      dispatch: (json['dispatch'] as num?)?.toInt() ?? 0,
      recall: (json['recall'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 电池调拨信息
class BatteryTransfer {
  final String batterySn;
  final String model;
  final int soc;

  const BatteryTransfer({this.batterySn = '', this.model = '', this.soc = 0});

  factory BatteryTransfer.fromJson(Map<String, dynamic> json) {
    return BatteryTransfer(
      batterySn: json['batterySn']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      soc: (json['soc'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 库存调拨详情
class StockDetail {
  final int batteryNum;
  final String cityName;
  final String createTime;
  final List<BatteryTransfer> list;
  final String remark;
  final String shopName;
  final String transferNo;
  final int transferType;

  const StockDetail({
    this.batteryNum = 0,
    this.cityName = '',
    this.createTime = '',
    this.list = const [],
    this.remark = '',
    this.shopName = '',
    this.transferNo = '',
    this.transferType = 0,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      batteryNum: (json['batteryNum'] as num?)?.toInt() ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      createTime: json['createTime']?.toString() ?? '',
      list:
          (json['list'] as List<dynamic>?)
              ?.map((e) => BatteryTransfer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      remark: json['remark']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      transferNo: json['transferNo']?.toString() ?? '',
      transferType: (json['transferType'] as num?)?.toInt() ?? 0,
    );
  }
}
