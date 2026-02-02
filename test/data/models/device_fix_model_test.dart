import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/device_fix.dart';

void main() {
  group('DeviceFix', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'batteryVo': {'sn': 'BAT001', 'model': 'Model A'},
        'carVo': {'sn': 'CAR001', 'model': 'Model B'},
        'stationVo': {'sn': 'STA001', 'name': 'Station 1'},
        'deviceType': 1,
        'itemList': [
          {'itemNo': 'ITEM001', 'itemName': 'Check battery', 'isSelect': true},
        ],
        'resultList': [
          {'result': 'Pass', 'code': 'R001', 'isSelect': true},
        ],
      };

      final deviceFix = DeviceFix.fromJson(json);

      expect(deviceFix.deviceType, 1);
      expect(deviceFix.itemList.length, 1);
      expect(deviceFix.resultList.length, 1);
    });

    test('fromJson should handle null nested objects', () {
      final json = {
        'batteryVo': null,
        'carVo': null,
        'stationVo': null,
        'deviceType': 0,
        'itemList': [],
        'resultList': [],
      };

      final deviceFix = DeviceFix.fromJson(json);

      expect(deviceFix.batteryVo, isNull);
      expect(deviceFix.carVo, isNull);
      expect(deviceFix.stationVo, isNull);
      expect(deviceFix.deviceType, 0);
      expect(deviceFix.itemList, isEmpty);
      expect(deviceFix.resultList, isEmpty);
    });

    test('fromJson should handle missing lists', () {
      final json = {'deviceType': 2};

      final deviceFix = DeviceFix.fromJson(json);

      expect(deviceFix.deviceType, 2);
      expect(deviceFix.itemList, isEmpty);
      expect(deviceFix.resultList, isEmpty);
    });

    test('toJson should serialize correctly', () {
      const deviceFix = DeviceFix(
        batteryVo: null,
        carVo: null,
        stationVo: null,
        deviceType: 1,
        itemList: [],
        resultList: [],
      );

      final json = deviceFix.toJson();

      expect(json['deviceType'], 1);
      expect(json['itemList'], isEmpty);
      expect(json['resultList'], isEmpty);
    });
  });

  group('DeviceFixProject', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'itemNo': 'ITEM001',
        'itemName': 'Battery Check',
        'isSelect': true,
      };

      final project = DeviceFixProject.fromJson(json);

      expect(project.itemNo, 'ITEM001');
      expect(project.itemName, 'Battery Check');
      expect(project.isSelect, true);
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final project = DeviceFixProject.fromJson(json);

      expect(project.itemNo, '');
      expect(project.itemName, '-');
      expect(project.isSelect, false);
    });

    test('fromJson should handle isSelect false', () {
      final json = {'isSelect': false};

      final project = DeviceFixProject.fromJson(json);

      expect(project.isSelect, false);
    });

    test('toJson should serialize correctly', () {
      const project = DeviceFixProject(
        itemNo: 'ITEM001',
        itemName: 'Test Item',
        isSelect: true,
      );

      final json = project.toJson();

      expect(json['itemNo'], 'ITEM001');
      expect(json['itemName'], 'Test Item');
      expect(json['isSelect'], true);
    });
  });

  group('DeviceFixResult', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'result': 'Pass',
        'code': 'R001',
        'isSelect': true,
      };

      final result = DeviceFixResult.fromJson(json);

      expect(result.result, 'Pass');
      expect(result.code, 'R001');
      expect(result.isSelect, true);
    });

    test('fromJson should handle null values with defaults', () {
      final json = <String, dynamic>{};

      final result = DeviceFixResult.fromJson(json);

      expect(result.result, '-');
      expect(result.code, '-');
      expect(result.isSelect, false);
    });

    test('fromJson should handle isSelect false', () {
      final json = {'isSelect': false};

      final result = DeviceFixResult.fromJson(json);

      expect(result.isSelect, false);
    });

    test('toJson should serialize correctly', () {
      const result = DeviceFixResult(
        result: 'Fail',
        code: 'R002',
        isSelect: false,
      );

      final json = result.toJson();

      expect(json['result'], 'Fail');
      expect(json['code'], 'R002');
      expect(json['isSelect'], false);
    });
  });
}
