/// 门店模型 - 对应 Android 的 Shop.kt
library;

/// 门店选择列表项
class Shop {
  final String shopName;
  final String shopNo;
  bool selected;

  Shop({required this.shopName, required this.shopNo, this.selected = false});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      shopName: json['shopName']?.toString() ?? '',
      shopNo: json['shopNo']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'shopName': shopName, 'shopNo': shopNo};
}

/// 门店数量统计
class ShopNum {
  final int all;
  final int direct;
  final int franchise;

  const ShopNum({this.all = 0, this.direct = 0, this.franchise = 0});

  factory ShopNum.fromJson(Map<String, dynamic> json) {
    return ShopNum(
      all: (json['all'] as num?)?.toInt() ?? 0,
      direct: (json['direct'] as num?)?.toInt() ?? 0,
      franchise: (json['franchise'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 门店列表项
class ShopItem {
  final int batStock;
  final String cityName;
  final String img;
  final String name;
  final String shopManager;
  final String shopNo;
  final int type; // 1=直营 2=加盟
  final int users;

  const ShopItem({
    this.batStock = 0,
    this.cityName = '',
    this.img = '',
    this.name = '',
    this.shopManager = '',
    this.shopNo = '',
    this.type = 0,
    this.users = 0,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      batStock: (json['batStock'] as num?)?.toInt() ?? 0,
      cityName: json['cityName']?.toString() ?? '',
      img: json['img']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shopManager: json['shopManager']?.toString() ?? '',
      shopNo: json['shopNo']?.toString() ?? '',
      type: (json['type'] as num?)?.toInt() ?? 0,
      users: (json['users'] as num?)?.toInt() ?? 0,
    );
  }

  /// 是否直营店
  bool get isDirect => type == 1;

  /// 是否加盟店
  bool get isFranchise => type == 2;

  /// 类型名称
  String get typeName => isDirect ? '直营' : (isFranchise ? '加盟' : '');
}

/// 门店详情
class ShopDetail {
  final String address;
  final int batStock;
  final String cityCode;
  final String cityName;
  final String imgList;
  final double latitude;
  final double longitude;
  final String managerPhone;
  final String name;
  final String remark;
  final String shopManager;
  final String shopNo;
  final int status; // 0=关闭 1=开启
  final int type; // 1=直营 2=加盟
  final int users;

  const ShopDetail({
    this.address = '',
    this.batStock = 0,
    this.cityCode = '',
    this.cityName = '',
    this.imgList = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.managerPhone = '',
    this.name = '',
    this.remark = '',
    this.shopManager = '',
    this.shopNo = '',
    this.status = 0,
    this.type = 0,
    this.users = 0,
  });

  factory ShopDetail.fromJson(Map<String, dynamic> json) {
    return ShopDetail(
      address: json['address']?.toString() ?? '',
      batStock: (json['batStock'] as num?)?.toInt() ?? 0,
      cityCode: json['cityCode']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      imgList: json['imgList']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      managerPhone: json['managerPhone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      remark: json['remark']?.toString() ?? '',
      shopManager: json['shopManager']?.toString() ?? '',
      shopNo: json['shopNo']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      type: (json['type'] as num?)?.toInt() ?? 0,
      users: (json['users'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'address': address,
    'batStock': batStock,
    'cityCode': cityCode,
    'cityName': cityName,
    'imgList': imgList,
    'latitude': latitude,
    'longitude': longitude,
    'managerPhone': managerPhone,
    'name': name,
    'remark': remark,
    'shopManager': shopManager,
    'shopNo': shopNo,
    'status': status,
    'type': type,
    'users': users,
  };

  /// 是否启用
  bool get isEnabled => status == 1;

  /// 是否直营店
  bool get isDirect => type == 1;

  /// 是否加盟店
  bool get isFranchise => type == 2;

  /// 图片列表
  List<String> get images =>
      imgList.isNotEmpty ? imgList.split(',') : <String>[];
}
