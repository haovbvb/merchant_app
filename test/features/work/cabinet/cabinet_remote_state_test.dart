import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/cabinet_version_bean.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_remote_controller.dart';

void main() {
  group('CabinetRemoteState', () {
    test('should have correct default values', () {
      const state = CabinetRemoteState();
      expect(state.operating, false);
      expect(state.result, isNull);
      expect(state.version, isNull);
      expect(state.androidTime, isNull);
    });

    test('should create with provided values', () {
      const state = CabinetRemoteState(
        operating: true,
        result: 'Success',
        androidTime: '2024-01-01 12:00:00',
      );
      expect(state.operating, true);
      expect(state.result, 'Success');
      expect(state.androidTime, '2024-01-01 12:00:00');
    });

    test('copyWith should update operating', () {
      const original = CabinetRemoteState();
      final updated = original.copyWith(operating: true);
      expect(updated.operating, true);
    });

    test('copyWith should update result', () {
      const original = CabinetRemoteState();
      final updated = original.copyWith(result: 'OK');
      expect(updated.result, 'OK');
    });

    test('copyWith should update version', () {
      const original = CabinetRemoteState();
      final version = CabinetVersionBean.fromJson({'version': '1.0.0'});
      final updated = original.copyWith(version: version);
      expect(updated.version, isNotNull);
    });

    test('copyWith should update androidTime', () {
      const original = CabinetRemoteState();
      final updated = original.copyWith(androidTime: '2024-01-15 10:30:00');
      expect(updated.androidTime, '2024-01-15 10:30:00');
    });

    test('copyWith should preserve values when not provided', () {
      const original = CabinetRemoteState(
        operating: true,
        result: 'Test',
        androidTime: '2024-01-01',
      );
      final copy = original.copyWith();
      expect(copy.operating, original.operating);
      expect(copy.result, original.result);
      expect(copy.androidTime, original.androidTime);
    });
  });
}
