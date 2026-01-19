import 'package:flutter/foundation.dart';

@immutable
class DeviceInventoryScanResult {
  final int result;

  const DeviceInventoryScanResult({
    required this.result,
  });

  factory DeviceInventoryScanResult.fromJson(Map<String, dynamic> json) {
    return DeviceInventoryScanResult(
      result: (json['result'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'result': result,
      };
}
