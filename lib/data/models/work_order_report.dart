import 'package:flutter/foundation.dart';

@immutable
class WorkOrderReport {
  final String imgList;
  final double latitude;
  final double longitude;
  final String processDesc;
  final int result;
  final String sheetNo;

  const WorkOrderReport({
    required this.imgList,
    this.latitude = 0,
    this.longitude = 0,
    required this.processDesc,
    required this.result,
    required this.sheetNo,
  });

  Map<String, dynamic> toJson() => {
        'imgList': imgList,
        'latitude': latitude,
        'longitude': longitude,
        'processDesc': processDesc,
        'result': result,
        'sheetNo': sheetNo,
      };
}
