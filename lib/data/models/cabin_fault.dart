import 'package:flutter/foundation.dart';

@immutable
class CabinFaultBean {
  final List<CabinFaultItem> list;
  final int total;

  const CabinFaultBean({
    this.list = const [],
    this.total = 0,
  });

  factory CabinFaultBean.fromJson(Map<String, dynamic> json) {
    final items = json['list'];
    return CabinFaultBean(
      list: items is List
          ? items
              .whereType<Map<String, dynamic>>()
              .map(CabinFaultItem.fromJson)
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list.map((e) => e.toJson()).toList(),
        'total': total,
      };
}

@immutable
class CabinFaultItem {
  final String? sn;
  final String? site;
  final String? faultDesc;
  final int? createTime;
  final int? type;
  final int? port;

  const CabinFaultItem({
    this.sn,
    this.site,
    this.faultDesc,
    this.createTime,
    this.type,
    this.port,
  });

  factory CabinFaultItem.fromJson(Map<String, dynamic> json) {
    return CabinFaultItem(
      sn: json['sn']?.toString(),
      site: json['site']?.toString(),
      faultDesc: json['faultDesc']?.toString(),
      createTime: (json['createTime'] as num?)?.toInt(),
      type: (json['type'] as num?)?.toInt(),
      port: (json['port'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sn': sn,
        'site': site,
        'faultDesc': faultDesc,
        'createTime': createTime,
        'type': type,
        'port': port,
      };
}
