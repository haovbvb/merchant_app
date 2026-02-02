import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/me/message_controller.dart';

void main() {
  group('MessageListState', () {
    test('should have correct default values', () {
      const state = MessageListState();

      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('hasMore should return true when items less than total', () {
      const state = MessageListState(items: [], total: 10);

      expect(state.hasMore, true);
    });

    test('hasMore should return false when items equal to total', () {
      const state = MessageListState(items: [], total: 0);

      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const state = MessageListState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.loadingMore, false);
    });

    test('copyWith should update loadingMore', () {
      const state = MessageListState();
      final updated = state.copyWith(loadingMore: true);

      expect(updated.loadingMore, true);
      expect(updated.loading, false);
    });

    test('copyWith should update page', () {
      const state = MessageListState();
      final updated = state.copyWith(page: 3);

      expect(updated.page, 3);
    });

    test('copyWith should update total', () {
      const state = MessageListState();
      final updated = state.copyWith(total: 50);

      expect(updated.total, 50);
      expect(updated.hasMore, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = MessageListState(
        loading: true,
        loadingMore: true,
        page: 2,
        total: 30,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.loadingMore, true);
      expect(updated.page, 2);
      expect(updated.total, 30);
    });
  });
}
