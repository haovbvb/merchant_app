import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/vcu_version.dart';

void main() {
  group('VcuVersion', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'version': '1.0.0',
        'name': 'VCU Firmware v1',
        'url': 'https://example.com/firmware.bin',
      };

      final version = VcuVersion.fromJson(json);

      expect(version.version, '1.0.0');
      expect(version.name, 'VCU Firmware v1');
      expect(version.url, 'https://example.com/firmware.bin');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final version = VcuVersion.fromJson(json);

      expect(version.version, isNull);
      expect(version.name, isNull);
      expect(version.url, isNull);
    });

    test('fromJson should handle partial data', () {
      final json = {'version': '2.0.0'};

      final version = VcuVersion.fromJson(json);

      expect(version.version, '2.0.0');
      expect(version.name, isNull);
      expect(version.url, isNull);
    });

    test('toJson should serialize all fields correctly', () {
      const version = VcuVersion(
        version: '1.0.0',
        name: 'Test Firmware',
        url: 'https://example.com/fw.bin',
      );

      final json = version.toJson();

      expect(json['version'], '1.0.0');
      expect(json['name'], 'Test Firmware');
      expect(json['url'], 'https://example.com/fw.bin');
    });

    test('toJson should handle null values', () {
      const version = VcuVersion();

      final json = version.toJson();

      expect(json['version'], isNull);
      expect(json['name'], isNull);
      expect(json['url'], isNull);
    });

    test('fromJson/toJson round trip', () {
      final originalJson = {
        'version': '3.0.0',
        'name': 'Latest Firmware',
        'url': 'https://example.com/latest.bin',
      };

      final version = VcuVersion.fromJson(originalJson);
      final resultJson = version.toJson();

      expect(resultJson['version'], originalJson['version']);
      expect(resultJson['name'], originalJson['name']);
      expect(resultJson['url'], originalJson['url']);
    });
  });
}
