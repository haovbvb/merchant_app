import 'package:flutter/foundation.dart';

@immutable
class Cabin {
  final int? portNo;

  const Cabin({this.portNo});

  factory Cabin.fromJson(Map<String, dynamic> json) {
    return Cabin(
      portNo: (json['portNo'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'portNo': portNo,
      };
}
