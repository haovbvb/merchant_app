import 'package:flutter/foundation.dart';

@immutable
class WorkOrderReport {
  final String imgList;
  final String processDesc;
  final int result;
  final String sheetNo;

  const WorkOrderReport({
    required this.imgList,
    required this.processDesc,
    required this.result,
    required this.sheetNo,
  });

  Map<String, dynamic> toJson() => {
        'imgList': imgList,
        'processDesc': processDesc,
        'result': result,
        'sheetNo': sheetNo,
      };
}
