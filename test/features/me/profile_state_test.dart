import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/me/profile_controller.dart';

void main() {
  group('ProfileState', () {
    test('should have correct default values', () {
      const state = ProfileState();

      expect(state.loading, false);
      expect(state.updating, false);
      expect(state.info, isNull);
      expect(state.unreadMessageCount, 0);
    });

    test('copyWith should update loading', () {
      const state = ProfileState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.updating, false);
    });

    test('copyWith should update updating', () {
      const state = ProfileState();
      final updated = state.copyWith(updating: true);

      expect(updated.updating, true);
      expect(updated.loading, false);
    });

    test('copyWith should update unreadMessageCount', () {
      const state = ProfileState();
      final updated = state.copyWith(unreadMessageCount: 5);

      expect(updated.unreadMessageCount, 5);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = ProfileState(
        loading: true,
        updating: true,
        unreadMessageCount: 10,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.updating, true);
      expect(updated.unreadMessageCount, 10);
    });

    test('copyWith should return new instance with same values when called without arguments', () {
      const state = ProfileState(
        loading: true,
        unreadMessageCount: 3,
      );
      final updated = state.copyWith();

      expect(updated.loading, true);
      expect(updated.unreadMessageCount, 3);
    });
  });
}
