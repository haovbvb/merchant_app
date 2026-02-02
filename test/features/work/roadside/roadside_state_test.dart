import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/roadside/roadside_controller.dart';

void main() {
  group('RoadSideListState', () {
    test('should have correct default values', () {
      const state = RoadSideListState();

      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.status, isNull);
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('hasMore should return true when items less than total', () {
      const state = RoadSideListState(items: [], total: 10);

      expect(state.hasMore, true);
    });

    test('hasMore should return false when items equal to total', () {
      const state = RoadSideListState(items: [], total: 0);

      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const state = RoadSideListState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.loadingMore, false);
    });

    test('copyWith should update loadingMore', () {
      const state = RoadSideListState();
      final updated = state.copyWith(loadingMore: true);

      expect(updated.loadingMore, true);
      expect(updated.loading, false);
    });

    test('copyWith should update page', () {
      const state = RoadSideListState();
      final updated = state.copyWith(page: 5);

      expect(updated.page, 5);
    });

    test('copyWith should update status', () {
      const state = RoadSideListState();
      final updated = state.copyWith(status: 1);

      expect(updated.status, 1);
    });

    test('copyWith should update total', () {
      const state = RoadSideListState();
      final updated = state.copyWith(total: 100);

      expect(updated.total, 100);
      expect(updated.hasMore, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = RoadSideListState(
        loading: true,
        loadingMore: true,
        page: 3,
        status: 2,
        total: 50,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.loadingMore, true);
      expect(updated.page, 3);
      expect(updated.status, 2);
      expect(updated.total, 50);
    });
  });

  group('RoadSideDetailState', () {
    test('should have correct default values', () {
      const state = RoadSideDetailState();

      expect(state.loading, false);
      expect(state.detail, isNull);
    });

    test('copyWith should update loading', () {
      const state = RoadSideDetailState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = RoadSideDetailState(loading: true);
      final updated = state.copyWith();

      expect(updated.loading, true);
    });
  });
}
