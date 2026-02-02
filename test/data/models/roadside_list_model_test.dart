import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/roadside_list.dart';

void main() {
  group('RoadSideListResp', () {
    test('fromJson should parse list and total correctly', () {
      final json = {
        'list': [
          {
            'createTime': '2024-01-01 10:00:00',
            'description': 'Test description',
            'deviceSn': 'SN001',
            'deviceType': 1,
            'recordNo': 'REC001',
            'status': 0,
          }
        ],
        'total': 1,
      };

      final resp = RoadSideListResp.fromJson(json);

      expect(resp.list.length, 1);
      expect(resp.total, 1);
    });

    test('fromJson should handle empty list', () {
      final json = {'list': [], 'total': 0};

      final resp = RoadSideListResp.fromJson(json);

      expect(resp.list, isEmpty);
      expect(resp.total, 0);
    });

    test('fromJson should handle null list', () {
      final json = {'list': null, 'total': 0};

      final resp = RoadSideListResp.fromJson(json);

      expect(resp.list, isEmpty);
    });

    test('toJson should serialize correctly', () {
      const resp = RoadSideListResp(list: [], total: 5);

      final json = resp.toJson();

      expect(json['list'], isEmpty);
      expect(json['total'], 5);
    });
  });

  group('RoadSideInfo', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'createTime': '2024-01-01 10:00:00',
        'description': 'Battery issue',
        'deviceSn': 'SN001',
        'deviceType': 1,
        'img': 'http://example.com/img.jpg',
        'recordNo': 'REC001',
        'result': 1,
        'status': 2,
        'completetime': '2024-01-02 12:00:00',
        'processTime': '2024-01-01 11:00:00',
      };

      final info = RoadSideInfo.fromJson(json);

      expect(info.createTime, '2024-01-01 10:00:00');
      expect(info.description, 'Battery issue');
      expect(info.deviceSn, 'SN001');
      expect(info.deviceType, 1);
      expect(info.img, 'http://example.com/img.jpg');
      expect(info.recordNo, 'REC001');
      expect(info.result, 1);
      expect(info.status, 2);
      expect(info.completetime, '2024-01-02 12:00:00');
      expect(info.processTime, '2024-01-01 11:00:00');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final info = RoadSideInfo.fromJson(json);

      expect(info.createTime, isNull);
      expect(info.description, isNull);
      expect(info.deviceSn, isNull);
      expect(info.deviceType, isNull);
      expect(info.img, isNull);
      expect(info.recordNo, isNull);
      expect(info.result, isNull);
      expect(info.status, isNull);
      expect(info.completetime, isNull);
      expect(info.processTime, isNull);
    });

    test('fromJson should parse deviceType from various types', () {
      final jsonInt = {'deviceType': 1};
      final jsonDouble = {'deviceType': 1.0};

      final infoInt = RoadSideInfo.fromJson(jsonInt);
      final infoDouble = RoadSideInfo.fromJson(jsonDouble);

      expect(infoInt.deviceType, 1);
      expect(infoDouble.deviceType, 1);
    });

    test('fromJson should parse status correctly', () {
      final json = {'status': 0};
      final info = RoadSideInfo.fromJson(json);

      expect(info.status, 0);
    });
  });
}
