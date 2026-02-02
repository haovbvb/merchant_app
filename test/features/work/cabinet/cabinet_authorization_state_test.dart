import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_authorization_controller.dart';

void main() {
  group('CabinetAuthorizationState', () {
    test('copyWith should update loadingCabinet', () {
      const state = CabinetAuthorizationState();
      final updated = state.copyWith(loadingCabinet: true);
      expect(updated.loadingCabinet, true);
      expect(updated.loadingUsers, false);
      expect(updated.loadingRecords, false);
    });

    test('copyWith should update loadingUsers', () {
      const state = CabinetAuthorizationState();
      final updated = state.copyWith(loadingUsers: true);
      expect(updated.loadingUsers, true);
    });

    test('copyWith should update loadingRecords', () {
      const state = CabinetAuthorizationState();
      final updated = state.copyWith(loadingRecords: true);
      expect(updated.loadingRecords, true);
    });

    test('copyWith should update submitting', () {
      const state = CabinetAuthorizationState();
      final updated = state.copyWith(submitting: true);
      expect(updated.submitting, true);
    });

    test('default values should be correct', () {
      const state = CabinetAuthorizationState();
      expect(state.loadingCabinet, false);
      expect(state.loadingUsers, false);
      expect(state.loadingRecords, false);
      expect(state.submitting, false);
      expect(state.cabinetList, null);
      expect(state.userList, null);
      expect(state.recordList, null);
    });

    test('copyWith should preserve unchanged values', () {
      const state = CabinetAuthorizationState(
        loadingCabinet: true,
        loadingUsers: true,
        loadingRecords: true,
        submitting: true,
      );
      final updated = state.copyWith(loadingCabinet: false);
      expect(updated.loadingCabinet, false);
      expect(updated.loadingUsers, true);
      expect(updated.loadingRecords, true);
      expect(updated.submitting, true);
    });

    test('copyWith with no arguments should return equivalent state', () {
      const state = CabinetAuthorizationState(
        loadingCabinet: true,
        submitting: true,
      );
      final updated = state.copyWith();
      expect(updated.loadingCabinet, true);
      expect(updated.submitting, true);
    });

    test('multiple copyWith calls should chain correctly', () {
      const state = CabinetAuthorizationState();
      final updated = state
          .copyWith(loadingCabinet: true)
          .copyWith(loadingUsers: true)
          .copyWith(submitting: true);
      expect(updated.loadingCabinet, true);
      expect(updated.loadingUsers, true);
      expect(updated.submitting, true);
      expect(updated.loadingRecords, false);
    });
  });
}
