import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/charge_history.dart';
import 'package:merchant_app/data/models/device_fix_record_response.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';
import 'package:merchant_app/features/work/device/device_detail_controller.dart';

void main() {
  group('DeviceDetailState', () {
    test('should have correct default values', () {
      const state = DeviceDetailState();
      expect(state.loading, false);
      expect(state.historyLoading, false);
      expect(state.toggling, false);
      expect(state.fixLoading, false);
      expect(state.maintenanceLoading, false);
      expect(state.portsLoading, false);
      expect(state.sn, '');
      expect(state.deviceType, 1);
      expect(state.searchResult, isNull);
      expect(state.batteryDetail, isNull);
      expect(state.vehicleDetail, isNull);
      expect(state.cabinetDetail, isNull);
      expect(state.histories, isEmpty);
      expect(state.fixRecords, isEmpty);
      expect(state.maintenanceRecords, isEmpty);
      expect(state.cabinPorts, isEmpty);
      expect(state.total, 0);
    });

    test('should create with provided values', () {
      const state = DeviceDetailState(
        loading: true,
        sn: 'TEST001',
        deviceType: 2,
        total: 100,
      );
      expect(state.loading, true);
      expect(state.sn, 'TEST001');
      expect(state.deviceType, 2);
      expect(state.total, 100);
    });

    test('copyWith should return new instance with updated loading', () {
      const original = DeviceDetailState();
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
      expect(updated.sn, '');
    });

    test('copyWith should update sn', () {
      const original = DeviceDetailState(sn: 'OLD');
      final updated = original.copyWith(sn: 'NEW');
      expect(updated.sn, 'NEW');
    });

    test('copyWith should update deviceType', () {
      const original = DeviceDetailState(deviceType: 1);
      final updated = original.copyWith(deviceType: 3);
      expect(updated.deviceType, 3);
    });

    test('copyWith should update batteryDetail', () {
      const original = DeviceDetailState();
      final battery = BatteryDetail.fromJson({'deviceSn': 'BAT001'});
      final updated = original.copyWith(batteryDetail: battery);
      expect(updated.batteryDetail?.deviceSn, 'BAT001');
    });

    test('copyWith should update vehicleDetail', () {
      const original = DeviceDetailState();
      final vehicle = VehicleDetail.fromJson({'sn': 'VEH001'});
      final updated = original.copyWith(vehicleDetail: vehicle);
      expect(updated.vehicleDetail?.sn, 'VEH001');
    });

    test('copyWith should update histories list', () {
      const original = DeviceDetailState();
      final histories = <ChargeHistory>[
        const ChargeHistory(chargeValue: '100', date: '2024-01-01'),
        const ChargeHistory(chargeValue: '200', date: '2024-01-02'),
      ];
      final updated = original.copyWith(histories: histories);
      expect(updated.histories.length, 2);
      expect(updated.histories[0].chargeValue, '100');
    });

    test('copyWith should update fixRecords list', () {
      const original = DeviceDetailState();
      final records = <DeviceFixRecord>[
        const DeviceFixRecord(
          fixMan: 'User1',
          fixManAvatar: null,
          itemName: 'Item1',
          remark: 'Remark1',
          result: 'OK',
          createTime: 1704067200,
        ),
        const DeviceFixRecord(
          fixMan: 'User2',
          fixManAvatar: null,
          itemName: 'Item2',
          remark: 'Remark2',
          result: 'OK',
          createTime: 1704153600,
        ),
      ];
      final updated = original.copyWith(fixRecords: records);
      expect(updated.fixRecords.length, 2);
    });

    test('copyWith should update cabinPorts list', () {
      const original = DeviceDetailState();
      final ports = <Cabin>[
        const Cabin(portNo: 1),
        const Cabin(portNo: 2),
      ];
      final updated = original.copyWith(cabinPorts: ports);
      expect(updated.cabinPorts.length, 2);
    });

    test('copyWith preserves all values when no params provided', () {
      const original = DeviceDetailState(
        loading: true,
        historyLoading: true,
        toggling: true,
        fixLoading: true,
        maintenanceLoading: true,
        portsLoading: true,
        sn: 'SN001',
        deviceType: 2,
        total: 50,
      );
      
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.historyLoading, original.historyLoading);
      expect(copy.toggling, original.toggling);
      expect(copy.fixLoading, original.fixLoading);
      expect(copy.maintenanceLoading, original.maintenanceLoading);
      expect(copy.portsLoading, original.portsLoading);
      expect(copy.sn, original.sn);
      expect(copy.deviceType, original.deviceType);
      expect(copy.total, original.total);
    });

    test('copyWith should update all loading flags independently', () {
      const original = DeviceDetailState();
      
      final updated = original.copyWith(
        loading: true,
        historyLoading: true,
        toggling: true,
        fixLoading: true,
        maintenanceLoading: true,
        portsLoading: true,
      );
      
      expect(updated.loading, true);
      expect(updated.historyLoading, true);
      expect(updated.toggling, true);
      expect(updated.fixLoading, true);
      expect(updated.maintenanceLoading, true);
      expect(updated.portsLoading, true);
    });
  });
}
