import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';

void main() {
  group('CabinetDetailBaseInfoBean', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'id': 1,
        'createTime': '2024-01-01 10:00:00',
        'installImgSet': ['img1.jpg', 'img2.jpg'],
        'standardImg': 'standard.jpg',
        'latitude': 31.2304,
        'longitude': 121.4737,
        'stationAddress': 'Shanghai, China',
        'stationPid': 'PID001',
        'stationSn': 'SN001',
        'useCount': '100',
        'cityName': 'Shanghai',
        'stationStatus': 1,
        'showOnlineStatus': 'online',
        'cityCode': 310000,
        'maxC': '10',
        'portStatus': '1,1,0,1',
        'isRecycling': 0,
        'storeNum': 5,
        'label': 1,
        'labelStr': 'VIP',
        'lastHbTime': '2024-01-01 12:00:00',
        'hide': 0,
        'businessHours': '08:00-22:00',
        'iccid': 'ICCID001',
        'vpcId': 'VPC001',
        'putOnShelvesTime': 1704067200000,
        'address': 'Address 123',
        'location': '31.2304,121.4737',
        'stationName': 'Station Alpha',
        'stationSpec': '6-port',
        'type': 1,
        'stationModel': 'Model A',
        'lockDevId': 'LOCK001',
        'lockIcId': 'IC001',
        'macId': 'MAC001',
        'mark': 'Test mark',
        'online': '1',
        'stationManagerList': [
          {'name': 'Manager1'},
        ],
      };

      final cabinet = CabinetDetailBaseInfoBean.fromJson(json);

      expect(cabinet.id, 1);
      expect(cabinet.createTime, '2024-01-01 10:00:00');
      expect(cabinet.installImgSet.length, 2);
      expect(cabinet.standardImg, 'standard.jpg');
      expect(cabinet.latitude, 31.2304);
      expect(cabinet.longitude, 121.4737);
      expect(cabinet.stationAddress, 'Shanghai, China');
      expect(cabinet.stationPid, 'PID001');
      expect(cabinet.stationSn, 'SN001');
      expect(cabinet.useCount, '100');
      expect(cabinet.cityName, 'Shanghai');
      expect(cabinet.stationStatus, 1);
      expect(cabinet.showOnlineStatus, 'online');
      expect(cabinet.cityCode, 310000);
      expect(cabinet.maxC, '10');
      expect(cabinet.portStatus, '1,1,0,1');
      expect(cabinet.isRecycling, 0);
      expect(cabinet.storeNum, 5);
      expect(cabinet.label, 1);
      expect(cabinet.labelStr, 'VIP');
      expect(cabinet.lastHbTime, '2024-01-01 12:00:00');
      expect(cabinet.hide, 0);
      expect(cabinet.businessHours, '08:00-22:00');
      expect(cabinet.iccid, 'ICCID001');
      expect(cabinet.vpcId, 'VPC001');
      expect(cabinet.putOnShelvesTime, 1704067200000);
      expect(cabinet.address, 'Address 123');
      expect(cabinet.location, '31.2304,121.4737');
      expect(cabinet.stationName, 'Station Alpha');
      expect(cabinet.stationSpec, '6-port');
      expect(cabinet.type, 1);
      expect(cabinet.stationModel, 'Model A');
      expect(cabinet.lockDevId, 'LOCK001');
      expect(cabinet.lockIcId, 'IC001');
      expect(cabinet.macId, 'MAC001');
      expect(cabinet.mark, 'Test mark');
      expect(cabinet.online, '1');
      expect(cabinet.stationManagerList.length, 1);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final cabinet = CabinetDetailBaseInfoBean.fromJson(json);

      expect(cabinet.id, isNull);
      expect(cabinet.createTime, isNull);
      expect(cabinet.installImgSet, isEmpty);
      expect(cabinet.standardImg, isNull);
      expect(cabinet.latitude, isNull);
      expect(cabinet.longitude, isNull);
      expect(cabinet.stationAddress, isNull);
      expect(cabinet.stationSn, isNull);
      expect(cabinet.stationManagerList, isEmpty);
    });

    test('fromJson should handle empty installImgSet', () {
      final json = {'installImgSet': []};

      final cabinet = CabinetDetailBaseInfoBean.fromJson(json);

      expect(cabinet.installImgSet, isEmpty);
    });

    test('fromJson should handle null installImgSet', () {
      final json = {'installImgSet': null};

      final cabinet = CabinetDetailBaseInfoBean.fromJson(json);

      expect(cabinet.installImgSet, isEmpty);
    });

    test('fromJson should handle empty stationManagerList', () {
      final json = {'stationManagerList': []};

      final cabinet = CabinetDetailBaseInfoBean.fromJson(json);

      expect(cabinet.stationManagerList, isEmpty);
    });

    test('fromJson should parse coordinates from int', () {
      final json = {'latitude': 31, 'longitude': 121};

      final cabinet = CabinetDetailBaseInfoBean.fromJson(json);

      expect(cabinet.latitude, 31.0);
      expect(cabinet.longitude, 121.0);
    });

    test('toJson should serialize all fields correctly', () {
      const cabinet = CabinetDetailBaseInfoBean(
        id: 1,
        stationSn: 'SN001',
        stationName: 'Test Station',
        latitude: 31.23,
        longitude: 121.47,
        installImgSet: ['img1.jpg'],
        stationManagerList: [],
      );

      final json = cabinet.toJson();

      expect(json['id'], 1);
      expect(json['stationSn'], 'SN001');
      expect(json['stationName'], 'Test Station');
      expect(json['latitude'], 31.23);
      expect(json['longitude'], 121.47);
      expect(json['installImgSet'], ['img1.jpg']);
    });

    test('fromJson/toJson round trip', () {
      final originalJson = {
        'id': 123,
        'stationSn': 'SN123',
        'stationName': 'Round Trip Station',
        'latitude': 30.5,
        'longitude': 120.5,
        'installImgSet': ['a.jpg', 'b.jpg'],
        'stationManagerList': [],
      };

      final cabinet = CabinetDetailBaseInfoBean.fromJson(originalJson);
      final resultJson = cabinet.toJson();

      expect(resultJson['id'], originalJson['id']);
      expect(resultJson['stationSn'], originalJson['stationSn']);
      expect(resultJson['stationName'], originalJson['stationName']);
      expect(resultJson['latitude'], originalJson['latitude']);
      expect(resultJson['longitude'], originalJson['longitude']);
    });
  });
}
