import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';

void main() {
  group('VehicleDetail Model', () {
    test('fromJson should parse complete JSON correctly', () {
      final json = {
        'sn': 'VEH001',
        'vin': 'VIN123456789',
        'carNumber': 'ABC123',
        'cardNum': 'CARD001',
        'model': 'Model X',
        'spec': '72V 20Ah',
        'carModel': 'E-Bike Pro',
        'carSpec': 'Standard',
        'img': 'https://example.com/vehicle.jpg',
        'latitude': 39.9042,
        'longitude': 116.4074,
        'mile': 5000.5,
        'carType': 'Electric Bike',
        'createTime': '2026-01-01 10:00:00',
        'motorNumber': 'MOTOR001',
        'controllerSn': 'CTRL001',
        'batterySn': 'BAT001',
        'ownerName': 'John Doe',
        'phone': '1234567890',
      };

      final vehicle = VehicleDetail.fromJson(json);

      expect(vehicle.sn, 'VEH001');
      expect(vehicle.vin, 'VIN123456789');
      expect(vehicle.carNumber, 'ABC123');
      expect(vehicle.cardNum, 'CARD001');
      expect(vehicle.model, 'Model X');
      expect(vehicle.spec, '72V 20Ah');
      expect(vehicle.carModel, 'E-Bike Pro');
      expect(vehicle.carSpec, 'Standard');
      expect(vehicle.img, 'https://example.com/vehicle.jpg');
      expect(vehicle.latitude, 39.9042);
      expect(vehicle.longitude, 116.4074);
      expect(vehicle.mile, 5000.5);
      expect(vehicle.carType, 'Electric Bike');
      expect(vehicle.createTime, '2026-01-01 10:00:00');
      expect(vehicle.motorNumber, 'MOTOR001');
      expect(vehicle.controllerSn, 'CTRL001');
      expect(vehicle.batterySn, 'BAT001');
      expect(vehicle.ownerName, 'John Doe');
      expect(vehicle.phone, '1234567890');
    });

    test('fromJson should handle null values', () {
      final json = <String, dynamic>{};

      final vehicle = VehicleDetail.fromJson(json);

      expect(vehicle.sn, isNull);
      expect(vehicle.vin, isNull);
      expect(vehicle.carNumber, isNull);
      expect(vehicle.cardNum, isNull);
      expect(vehicle.model, isNull);
      expect(vehicle.spec, isNull);
      expect(vehicle.carModel, isNull);
      expect(vehicle.carSpec, isNull);
      expect(vehicle.img, isNull);
      expect(vehicle.latitude, isNull);
      expect(vehicle.longitude, isNull);
      expect(vehicle.mile, isNull);
      expect(vehicle.carType, isNull);
      expect(vehicle.createTime, isNull);
      expect(vehicle.motorNumber, isNull);
      expect(vehicle.controllerSn, isNull);
      expect(vehicle.batterySn, isNull);
      expect(vehicle.ownerName, isNull);
      expect(vehicle.phone, isNull);
    });

    test('fromJson should handle userName fallback for ownerName', () {
      final json = {
        'sn': 'VEH002',
        'userName': 'Jane Doe', // using userName instead of ownerName
      };

      final vehicle = VehicleDetail.fromJson(json);

      expect(vehicle.ownerName, 'Jane Doe');
    });

    test('fromJson should prefer ownerName over userName', () {
      final json = {
        'sn': 'VEH003',
        'ownerName': 'Owner Name',
        'userName': 'User Name',
      };

      final vehicle = VehicleDetail.fromJson(json);

      expect(vehicle.ownerName, 'Owner Name');
    });

    test('fromJson should handle integer coordinates', () {
      final json = {
        'sn': 'VEH004',
        'latitude': 40, // int instead of double
        'longitude': 116, // int instead of double
        'mile': 1000, // int instead of double
      };

      final vehicle = VehicleDetail.fromJson(json);

      expect(vehicle.latitude, 40.0);
      expect(vehicle.longitude, 116.0);
      expect(vehicle.mile, 1000.0);
    });

    test('toJson should serialize all fields correctly', () {
      const vehicle = VehicleDetail(
        sn: 'VEH005',
        vin: 'VIN987654321',
        carNumber: 'XYZ789',
        cardNum: 'CARD002',
        model: 'Model Y',
        spec: '60V 30Ah',
        carModel: 'E-Scooter',
        carSpec: 'Premium',
        img: 'https://example.com/vehicle2.jpg',
        latitude: 31.2304,
        longitude: 121.4737,
        mile: 8000.0,
        carType: 'Electric Scooter',
        createTime: '2026-02-01 15:00:00',
        motorNumber: 'MOTOR002',
        controllerSn: 'CTRL002',
        batterySn: 'BAT002',
        ownerName: 'Alice Smith',
        phone: '9876543210',
      );

      final json = vehicle.toJson();

      expect(json['sn'], 'VEH005');
      expect(json['vin'], 'VIN987654321');
      expect(json['carNumber'], 'XYZ789');
      expect(json['cardNum'], 'CARD002');
      expect(json['model'], 'Model Y');
      expect(json['spec'], '60V 30Ah');
      expect(json['carModel'], 'E-Scooter');
      expect(json['carSpec'], 'Premium');
      expect(json['img'], 'https://example.com/vehicle2.jpg');
      expect(json['latitude'], 31.2304);
      expect(json['longitude'], 121.4737);
      expect(json['mile'], 8000.0);
      expect(json['carType'], 'Electric Scooter');
      expect(json['createTime'], '2026-02-01 15:00:00');
      expect(json['motorNumber'], 'MOTOR002');
      expect(json['controllerSn'], 'CTRL002');
      expect(json['batterySn'], 'BAT002');
      expect(json['ownerName'], 'Alice Smith');
      expect(json['phone'], '9876543210');
    });

    test('toJson/fromJson should be reversible', () {
      const original = VehicleDetail(
        sn: 'VEH006',
        vin: 'VIN555555555',
        carNumber: 'TEST123',
        cardNum: 'CARD003',
        model: 'Model Z',
        spec: '48V 12Ah',
        carModel: 'City Bike',
        carSpec: 'Basic',
        img: 'https://example.com/vehicle3.jpg',
        latitude: 22.5431,
        longitude: 114.0579,
        mile: 3500.0,
        carType: 'City Electric Bike',
        createTime: '2026-01-15 08:30:00',
        motorNumber: 'MOTOR003',
        controllerSn: 'CTRL003',
        batterySn: 'BAT003',
        ownerName: 'Bob Wilson',
        phone: '5551234567',
      );

      final json = original.toJson();
      final restored = VehicleDetail.fromJson(json);

      expect(restored.sn, original.sn);
      expect(restored.vin, original.vin);
      expect(restored.carNumber, original.carNumber);
      expect(restored.cardNum, original.cardNum);
      expect(restored.model, original.model);
      expect(restored.spec, original.spec);
      expect(restored.carModel, original.carModel);
      expect(restored.carSpec, original.carSpec);
      expect(restored.img, original.img);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.mile, original.mile);
      expect(restored.carType, original.carType);
      expect(restored.createTime, original.createTime);
      expect(restored.motorNumber, original.motorNumber);
      expect(restored.controllerSn, original.controllerSn);
      expect(restored.batterySn, original.batterySn);
      expect(restored.ownerName, original.ownerName);
      expect(restored.phone, original.phone);
    });

    test('fromJson should handle zero mileage', () {
      final json = {
        'sn': 'VEH_NEW',
        'mile': 0.0,
      };

      final vehicle = VehicleDetail.fromJson(json);

      expect(vehicle.mile, 0.0);
    });
  });
}
