import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_auth_controller.dart';

void main() {
  group('BluetoothAuthState', () {
    test('should have correct default values', () {
      const state = BluetoothAuthState();

      expect(state.loadingLock, false);
      expect(state.loadingUid, false);
      expect(state.submitting, false);
      expect(state.lockInfo, isNull);
      expect(state.uid, isNull);
    });

    test('copyWith should update loadingLock', () {
      const state = BluetoothAuthState();
      final updated = state.copyWith(loadingLock: true);

      expect(updated.loadingLock, true);
      expect(updated.loadingUid, false);
      expect(updated.submitting, false);
    });

    test('copyWith should update loadingUid', () {
      const state = BluetoothAuthState();
      final updated = state.copyWith(loadingUid: true);

      expect(updated.loadingUid, true);
      expect(updated.loadingLock, false);
      expect(updated.submitting, false);
    });

    test('copyWith should update submitting', () {
      const state = BluetoothAuthState();
      final updated = state.copyWith(submitting: true);

      expect(updated.submitting, true);
      expect(updated.loadingLock, false);
      expect(updated.loadingUid, false);
    });

    test('copyWith should update uid', () {
      const state = BluetoothAuthState();
      final updated = state.copyWith(uid: 'user123');

      expect(updated.uid, 'user123');
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = BluetoothAuthState(
        loadingLock: true,
        loadingUid: true,
        submitting: true,
        uid: 'test_uid',
      );
      final updated = state.copyWith(loadingLock: false);

      expect(updated.loadingLock, false);
      expect(updated.loadingUid, true);
      expect(updated.submitting, true);
      expect(updated.uid, 'test_uid');
    });

    test('copyWith should return new instance with same values when called without arguments', () {
      const state = BluetoothAuthState(
        loadingLock: true,
        uid: 'abc',
      );
      final updated = state.copyWith();

      expect(updated.loadingLock, true);
      expect(updated.uid, 'abc');
    });
  });
}
