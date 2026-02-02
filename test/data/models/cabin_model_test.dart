import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/cabin.dart';

void main() {
  group('Cabin', () {
    test('fromJson should parse all fields correctly', () {
      final json = {
        'portNo': 1,
        'portName': 'Port 1',
        'batterySn': 'BAT001',
        'status': 1,
        'doorStatus': 0,
        'lockStatus': 1,
        'chargeStatus': 2,
        'batterySoc': 85,
        'voltage': 48.5,
        'temperature': 25.3,
      };

      final cabin = Cabin.fromJson(json);

      expect(cabin.portNo, 1);
      expect(cabin.portName, 'Port 1');
      expect(cabin.batterySn, 'BAT001');
      expect(cabin.status, 1);
      expect(cabin.doorStatus, 0);
      expect(cabin.lockStatus, 1);
      expect(cabin.chargeStatus, 2);
      expect(cabin.batterySoc, 85);
      expect(cabin.voltage, 48.5);
      expect(cabin.temperature, 25.3);
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final cabin = Cabin.fromJson(json);

      expect(cabin.portNo, isNull);
      expect(cabin.portName, isNull);
      expect(cabin.batterySn, isNull);
      expect(cabin.status, isNull);
      expect(cabin.doorStatus, isNull);
      expect(cabin.lockStatus, isNull);
      expect(cabin.chargeStatus, isNull);
      expect(cabin.batterySoc, isNull);
      expect(cabin.voltage, isNull);
      expect(cabin.temperature, isNull);
    });

    test('fromJson should parse int values for voltage and temperature', () {
      final json = {
        'voltage': 48,
        'temperature': 25,
      };

      final cabin = Cabin.fromJson(json);

      expect(cabin.voltage, 48.0);
      expect(cabin.temperature, 25.0);
    });

    test('toJson should serialize all fields correctly', () {
      const cabin = Cabin(
        portNo: 1,
        portName: 'Port 1',
        batterySn: 'BAT001',
        status: 1,
        doorStatus: 0,
        lockStatus: 1,
        chargeStatus: 2,
        batterySoc: 85,
        voltage: 48.5,
        temperature: 25.3,
      );

      final json = cabin.toJson();

      expect(json['portNo'], 1);
      expect(json['portName'], 'Port 1');
      expect(json['batterySn'], 'BAT001');
      expect(json['status'], 1);
      expect(json['doorStatus'], 0);
      expect(json['lockStatus'], 1);
      expect(json['chargeStatus'], 2);
      expect(json['batterySoc'], 85);
      expect(json['voltage'], 48.5);
      expect(json['temperature'], 25.3);
    });

    test('toJson should serialize null values', () {
      const cabin = Cabin();
      final json = cabin.toJson();

      expect(json['portNo'], isNull);
      expect(json['portName'], isNull);
      expect(json['batterySn'], isNull);
    });

    test('fromJson/toJson round trip', () {
      final originalJson = {
        'portNo': 5,
        'portName': 'Port 5',
        'batterySn': 'BAT005',
        'status': 2,
        'batterySoc': 90,
        'voltage': 52.0,
      };

      final cabin = Cabin.fromJson(originalJson);
      final resultJson = cabin.toJson();

      expect(resultJson['portNo'], originalJson['portNo']);
      expect(resultJson['portName'], originalJson['portName']);
      expect(resultJson['batterySn'], originalJson['batterySn']);
      expect(resultJson['status'], originalJson['status']);
      expect(resultJson['batterySoc'], originalJson['batterySoc']);
      expect(resultJson['voltage'], originalJson['voltage']);
    });
  });
}
