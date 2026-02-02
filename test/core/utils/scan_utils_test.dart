import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';

void main() {
  group('ScanUtils', () {
    group('getDeviceSn', () {
      test('should return empty string for empty input', () {
        expect(ScanUtils.getDeviceSn(''), '');
        expect(ScanUtils.getDeviceSn('   '), '');
      });

      test('should parse B: prefix format', () {
        expect(ScanUtils.getDeviceSn('B:ABC123'), 'ABC123');
        expect(ScanUtils.getDeviceSn('b:xyz456'), 'xyz456');
        expect(ScanUtils.getDeviceSn('B:ABC-123 DEF'), 'ABC123DEF');
      });

      test('should parse sn= format', () {
        expect(ScanUtils.getDeviceSn('sn=BAT001'), 'BAT001');
        expect(ScanUtils.getDeviceSn('SN=BAT002,other=value'), 'BAT002');
      });

      test('should parse sn: format when contains key-value', () {
        // sn: format only works when it's part of key-value structure
        expect(ScanUtils.getDeviceSn('SN:BAT004,imei:123'), 'BAT004');
      });

      test('should parse vin= format', () {
        expect(ScanUtils.getDeviceSn('vin=VEH001'), 'VEH001');
        expect(ScanUtils.getDeviceSn('VIN=VEH002,other=value'), 'VEH002');
      });

      test('should parse vin: format', () {
        expect(ScanUtils.getDeviceSn('vin:VEH003'), 'VEH003');
        expect(ScanUtils.getDeviceSn('VIN:VEH004,vcu:123'), 'VEH004');
      });

      test('should return trimmed input when no pattern matches', () {
        expect(ScanUtils.getDeviceSn('PLAINCODE123'), 'PLAINCODE123');
        expect(ScanUtils.getDeviceSn('  TRIMME  '), 'TRIMME');
      });
    });

    group('parseBatteryQr', () {
      test('should parse B: prefix', () {
        final result = ScanUtils.parseBatteryQr('B:BAT123', 0);
        expect(result.sn, 'BAT123');
        expect(result.imei, '');
        expect(result.iccid, '');
      });

      test('should parse key-value format with comma', () {
        final result = ScanUtils.parseBatteryQr('sn=BAT001,imei=123456,iccid=789', 0);
        expect(result.sn, 'BAT001');
        expect(result.imei, '123456');
        expect(result.iccid, '789');
      });

      test('should parse key-value format with colon', () {
        final result = ScanUtils.parseBatteryQr('SN:BAT002,IMEI:654321,ICCID:999', 0);
        expect(result.sn, 'BAT002');
        expect(result.imei, '654321');
        expect(result.iccid, '999');
      });

      test('should handle clickType=1 for IMEI scan', () {
        final result = ScanUtils.parseBatteryQr('PLAINIMEI', 1);
        expect(result.sn, '');
        expect(result.imei, 'PLAINIMEI');
        expect(result.iccid, '');
      });

      test('should handle clickType=2 for ICCID scan', () {
        final result = ScanUtils.parseBatteryQr('PLAINICCID', 2);
        expect(result.sn, '');
        expect(result.imei, '');
        expect(result.iccid, 'PLAINICCID');
      });

      test('should return sn for clickType=0 with plain value', () {
        final result = ScanUtils.parseBatteryQr('PLAINSN', 0);
        expect(result.sn, 'PLAINSN');
        expect(result.imei, '');
        expect(result.iccid, '');
      });
    });

    group('parseVehicleQr', () {
      test('should parse B: prefix for vehicle', () {
        final result = ScanUtils.parseVehicleQr('B:VEH123', 0);
        expect(result.sn, 'VEH123');
        expect(result.vin, 'VEH123');
        expect(result.vcu, '');
      });

      test('should parse VIN key-value format', () {
        final result = ScanUtils.parseVehicleQr('VIN=VEH001,VCU=VCU001', 0);
        expect(result.sn, 'VEH001');
        expect(result.vin, 'VEH001');
        expect(result.vcu, 'VCU001');
      });

      test('should parse VIN: format', () {
        final result = ScanUtils.parseVehicleQr('VIN:VEH002,VCU:VCU002', 0);
        expect(result.sn, 'VEH002');
        expect(result.vin, 'VEH002');
        expect(result.vcu, 'VCU002');
      });

      test('should handle clickType=2 for VCU scan', () {
        final result = ScanUtils.parseVehicleQr('PLAINVCU', 2);
        expect(result.sn, '');
        expect(result.vin, '');
        expect(result.vcu, 'PLAINVCU');
      });

      test('should return vin for clickType=0 with plain value', () {
        final result = ScanUtils.parseVehicleQr('PLAINVIN', 0);
        expect(result.sn, 'PLAINVIN');
        expect(result.vin, 'PLAINVIN');
        expect(result.vcu, '');
      });
    });

    group('parseStationQr', () {
      test('should parse URL format with sn and bt params', () {
        final result = ScanUtils.parseStationQr('https://example.com?sn=STA001&bt=LOCK01');
        expect(result.sn, 'STA001');
        expect(result.lockDevId, 'LOCK01');
      });

      test('should parse simple sn= format', () {
        final result = ScanUtils.parseStationQr('sn=STA002');
        expect(result.sn, 'STA002');
        expect(result.lockDevId, '');
      });

      test('should parse key-value with comma', () {
        final result = ScanUtils.parseStationQr('sn=STA003,other=value');
        expect(result.sn, 'STA003');
        expect(result.lockDevId, '');
      });

      test('should return plain value as sn', () {
        final result = ScanUtils.parseStationQr('PLAINSN');
        expect(result.sn, 'PLAINSN');
        expect(result.lockDevId, '');
      });
    });

    group('parseSnByDeviceType', () {
      test('should return empty for empty input', () {
        expect(ScanUtils.parseSnByDeviceType('', 1), '');
        expect(ScanUtils.parseSnByDeviceType('  ', 2), '');
      });

      test('should parse battery SN for deviceType=1', () {
        expect(ScanUtils.parseSnByDeviceType('sn=BAT001,imei=123', 1), 'BAT001');
      });

      test('should parse vehicle SN for deviceType=2', () {
        expect(ScanUtils.parseSnByDeviceType('VIN=VEH001,VCU=123', 2), 'VEH001');
      });

      test('should parse station SN for deviceType=3', () {
        expect(ScanUtils.parseSnByDeviceType('sn=STA001&bt=LOCK01', 3), 'STA001');
      });

      test('should use default getDeviceSn for null or other types', () {
        expect(ScanUtils.parseSnByDeviceType('PLAIN123', null), 'PLAIN123');
        expect(ScanUtils.parseSnByDeviceType('PLAIN456', 99), 'PLAIN456');
      });
    });

    group('getUserCarNum', () {
      test('should return empty for empty input', () {
        expect(ScanUtils.getUserCarNum(''), '');
        expect(ScanUtils.getUserCarNum('   '), '');
      });

      test('should parse cardnum format', () {
        expect(ScanUtils.getUserCarNum('cardnum=CARD001'), 'CARD001');
        expect(ScanUtils.getUserCarNum('CARDNUM=CARD002'), 'CARD002');
      });

      test('should return trimmed value when no pattern', () {
        expect(ScanUtils.getUserCarNum('PLAINCARD'), 'PLAINCARD');
        expect(ScanUtils.getUserCarNum('  TRIM  '), 'TRIM');
      });
    });
  });

  group('QrCodeBattery', () {
    test('should create with default values', () {
      const battery = QrCodeBattery();
      expect(battery.sn, isNull);
      expect(battery.imei, isNull);
      expect(battery.iccid, isNull);
    });

    test('should create with provided values', () {
      const battery = QrCodeBattery(sn: 'SN1', imei: 'IMEI1', iccid: 'ICCID1');
      expect(battery.sn, 'SN1');
      expect(battery.imei, 'IMEI1');
      expect(battery.iccid, 'ICCID1');
    });
  });

  group('QrCodeVehicle', () {
    test('should create with default values', () {
      const vehicle = QrCodeVehicle();
      expect(vehicle.sn, isNull);
      expect(vehicle.vin, isNull);
      expect(vehicle.vcu, isNull);
    });

    test('should create with provided values', () {
      const vehicle = QrCodeVehicle(sn: 'SN1', vin: 'VIN1', vcu: 'VCU1');
      expect(vehicle.sn, 'SN1');
      expect(vehicle.vin, 'VIN1');
      expect(vehicle.vcu, 'VCU1');
    });
  });

  group('QrCodeStation', () {
    test('should create with default values', () {
      const station = QrCodeStation();
      expect(station.sn, isNull);
      expect(station.lockDevId, isNull);
    });

    test('should create with provided values', () {
      const station = QrCodeStation(sn: 'SN1', lockDevId: 'LOCK1');
      expect(station.sn, 'SN1');
      expect(station.lockDevId, 'LOCK1');
    });
  });
}
