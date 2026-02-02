import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/battery_detail.dart';

void main() {
  group('BatteryDetail Model', () {
    test('fromJson should parse complete JSON correctly', () {
      final json = {
        'avgSpeed': 25.5,
        'color': 1,
        'cycle': 150,
        'deviceSn': 'BAT001',
        'img': 'https://example.com/battery.jpg',
        'latitude': 39.9042,
        'longitude': 116.4074,
        'mile': 1000.5,
        'online': 1,
        'operationDate': 1706745600,
        'signalTime': 1706832000,
        'soc': 85,
        'status': 1,
        'todayMile': 50.3,
      };

      final battery = BatteryDetail.fromJson(json);

      expect(battery.avgSpeed, 25.5);
      expect(battery.color, 1);
      expect(battery.cycle, 150);
      expect(battery.deviceSn, 'BAT001');
      expect(battery.img, 'https://example.com/battery.jpg');
      expect(battery.latitude, 39.9042);
      expect(battery.longitude, 116.4074);
      expect(battery.mile, 1000.5);
      expect(battery.online, 1);
      expect(battery.operationDate, 1706745600);
      expect(battery.signalTime, 1706832000);
      expect(battery.soc, 85);
      expect(battery.status, 1);
      expect(battery.todayMile, 50.3);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final battery = BatteryDetail.fromJson(json);

      expect(battery.avgSpeed, isNull);
      expect(battery.color, isNull);
      expect(battery.cycle, isNull);
      expect(battery.deviceSn, isNull);
      expect(battery.img, isNull);
      expect(battery.latitude, isNull);
      expect(battery.longitude, isNull);
      expect(battery.mile, isNull);
      expect(battery.online, isNull);
      expect(battery.operationDate, isNull);
      expect(battery.signalTime, isNull);
      expect(battery.soc, isNull);
      expect(battery.status, isNull);
      expect(battery.todayMile, isNull);
    });

    test('fromJson should handle integer values as num', () {
      final json = {
        'avgSpeed': 30, // int instead of double
        'mile': 500, // int instead of double
        'latitude': 40, // int instead of double
        'longitude': 116, // int instead of double
        'todayMile': 25, // int instead of double
      };

      final battery = BatteryDetail.fromJson(json);

      expect(battery.avgSpeed, 30.0);
      expect(battery.mile, 500.0);
      expect(battery.latitude, 40.0);
      expect(battery.longitude, 116.0);
      expect(battery.todayMile, 25.0);
    });

    test('toJson should serialize all fields correctly', () {
      const battery = BatteryDetail(
        avgSpeed: 20.0,
        color: 2,
        cycle: 200,
        deviceSn: 'BAT002',
        img: 'https://example.com/battery2.jpg',
        latitude: 31.2304,
        longitude: 121.4737,
        mile: 2000.0,
        online: 0,
        operationDate: 1706918400,
        signalTime: 1707004800,
        soc: 60,
        status: 2,
        todayMile: 30.0,
      );

      final json = battery.toJson();

      expect(json['avgSpeed'], 20.0);
      expect(json['color'], 2);
      expect(json['cycle'], 200);
      expect(json['deviceSn'], 'BAT002');
      expect(json['img'], 'https://example.com/battery2.jpg');
      expect(json['latitude'], 31.2304);
      expect(json['longitude'], 121.4737);
      expect(json['mile'], 2000.0);
      expect(json['online'], 0);
      expect(json['operationDate'], 1706918400);
      expect(json['signalTime'], 1707004800);
      expect(json['soc'], 60);
      expect(json['status'], 2);
      expect(json['todayMile'], 30.0);
    });

    test('toJson/fromJson should be reversible', () {
      const original = BatteryDetail(
        avgSpeed: 35.5,
        color: 3,
        cycle: 300,
        deviceSn: 'BAT003',
        img: 'https://example.com/battery3.jpg',
        latitude: 22.5431,
        longitude: 114.0579,
        mile: 3000.0,
        online: 1,
        operationDate: 1707091200,
        signalTime: 1707177600,
        soc: 95,
        status: 1,
        todayMile: 75.5,
      );

      final json = original.toJson();
      final restored = BatteryDetail.fromJson(json);

      expect(restored.avgSpeed, original.avgSpeed);
      expect(restored.color, original.color);
      expect(restored.cycle, original.cycle);
      expect(restored.deviceSn, original.deviceSn);
      expect(restored.img, original.img);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.mile, original.mile);
      expect(restored.online, original.online);
      expect(restored.operationDate, original.operationDate);
      expect(restored.signalTime, original.signalTime);
      expect(restored.soc, original.soc);
      expect(restored.status, original.status);
      expect(restored.todayMile, original.todayMile);
    });

    test('fromJson should handle zero soc', () {
      final json = {
        'deviceSn': 'BAT_EMPTY',
        'soc': 0,
        'online': 0,
      };

      final battery = BatteryDetail.fromJson(json);

      expect(battery.soc, 0);
      expect(battery.online, 0);
    });

    test('fromJson should handle 100% soc', () {
      final json = {
        'deviceSn': 'BAT_FULL',
        'soc': 100,
        'online': 1,
      };

      final battery = BatteryDetail.fromJson(json);

      expect(battery.soc, 100);
    });
  });
}
