import 'package:flutter/foundation.dart';

@immutable
class AuthorizationRecordList {
  final List<Map<String, dynamic>> list;
  final int total;

  const AuthorizationRecordList({
    this.list = const [],
    this.total = 0,
  });

  factory AuthorizationRecordList.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'];
    return AuthorizationRecordList(
      list: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(Map<String, dynamic>.from)
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'list': list,
        'total': total,
      };
}
