import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/camera/camera_controller.dart';

void main() {
  group('CameraOperationState', () {
    test('copyWith should update loading', () {
      const state = CameraOperationState();
      final updated = state.copyWith(loading: true);
      expect(updated.loading, true);
      expect(updated.verified, false);
      expect(updated.message, null);
    });

    test('copyWith should update verified', () {
      const state = CameraOperationState();
      final updated = state.copyWith(verified: true);
      expect(updated.verified, true);
      expect(updated.loading, false);
    });

    test('copyWith should update message', () {
      const state = CameraOperationState();
      final updated = state.copyWith(message: 'Success');
      expect(updated.message, 'Success');
    });

    test('default values should be correct', () {
      const state = CameraOperationState();
      expect(state.loading, false);
      expect(state.verified, false);
      expect(state.message, null);
    });

    test('copyWith should preserve unchanged values', () {
      const state = CameraOperationState(
        loading: true,
        verified: true,
        message: 'Test message',
      );
      final updated = state.copyWith(loading: false);
      expect(updated.loading, false);
      expect(updated.verified, true);
      expect(updated.message, 'Test message');
    });

    test('copyWith with no arguments should return equivalent state', () {
      const state = CameraOperationState(
        loading: true,
        verified: true,
        message: 'Info',
      );
      final updated = state.copyWith();
      expect(updated.loading, true);
      expect(updated.verified, true);
      expect(updated.message, 'Info');
    });

    test('multiple copyWith calls should chain correctly', () {
      const state = CameraOperationState();
      final updated = state
          .copyWith(loading: true)
          .copyWith(verified: true)
          .copyWith(message: 'Done');
      expect(updated.loading, true);
      expect(updated.verified, true);
      expect(updated.message, 'Done');
    });

    test('copyWith should handle empty message', () {
      const state = CameraOperationState(message: 'Initial');
      final updated = state.copyWith(message: '');
      expect(updated.message, '');
    });
  });
}
