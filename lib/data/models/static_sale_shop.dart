/// 门店销售统计模型 - 对应 Android 的 StaticSaleShop.kt
library;

/// 销售统计数量
class StaticSaleNum {
  final int sell;

  const StaticSaleNum({this.sell = 0});

  factory StaticSaleNum.fromJson(Map<String, dynamic> json) {
    return StaticSaleNum(sell: (json['sell'] as num?)?.toInt() ?? 0);
  }
}

/// 门店销售统计列表项
class StaticSaleShop {
  final int batNum;
  final String cityName;
  final String img;
  final String manager;
  final String shopName;
  final String shopNo;

  const StaticSaleShop({
    this.batNum = 0,
    this.cityName = '',
    this.img = '',
    this.manager = '',
    this.shopName = '',
    this.shopNo = '',
  });

  factory StaticSaleShop.fromJson(Map<String, dynamic> json) {
    return StaticSaleShop(
      batNum: (json['batNum'] as num?)?.toInt() ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
      manager: json['manager']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      shopNo: json['shopNo']?.toString() ?? '',
    );
  }
}

/// 门店销售统计详情
class StaticSaleShopDetail {
  final String address;
  final int batNum;
  final String cityName;
  final String shopName;
  final String shopManager;
  final String shopNo;
  final String img;
  final double totalAmount;

  const StaticSaleShopDetail({
    this.address = '',
    this.batNum = 0,
    this.cityName = '',
    this.shopName = '',
    this.shopManager = '',
    this.shopNo = '',
    this.img = '',
    this.totalAmount = 0.0,
  });

  factory StaticSaleShopDetail.fromJson(Map<String, dynamic> json) {
    return StaticSaleShopDetail(
      address: json['address']?.toString() ?? '',
      batNum: (json['batNum'] as num?)?.toInt() ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      shopName: json['shopName']?.toString() ?? '',
      shopManager: json['shopManager']?.toString() ?? '',
      shopNo: json['shopNo']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// 门店销售日期数据
class StaticSaleShopDate {
  final List<double> amountList;
  final List<int> batList;
  final List<String> times;

  const StaticSaleShopDate({
    this.amountList = const [],
    this.batList = const [],
    this.times = const [],
  });

  factory StaticSaleShopDate.fromJson(Map<String, dynamic> json) {
    return StaticSaleShopDate(
      amountList:
          (json['amountList'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toDouble() ?? 0.0)
              .toList() ??
          [],
      batList:
          (json['batList'] as List<dynamic>?)
              ?.map((e) => (e as num?)?.toInt() ?? 0)
              .toList() ??
          [],
      times:
          (json['times'] as List<dynamic>?)
              ?.map((e) => e?.toString() ?? '')
              .toList() ??
          [],
    );
  }
}
