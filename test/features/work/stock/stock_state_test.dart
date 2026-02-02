import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/stock/stock_controller.dart';

void main() {
  group('StockListState', () {
    test('should have correct default values', () {
      const state = StockListState();

      expect(state.loading, false);
      expect(state.num, isNull);
      expect(state.page, 1);
      expect(state.items, isEmpty);
      expect(state.total, 0);
      expect(state.type, 0);
    });

    test('hasMore should return true when items less than total', () {
      const state = StockListState(items: [], total: 10);

      expect(state.hasMore, true);
    });

    test('hasMore should return false when items equal to total', () {
      const state = StockListState(items: [], total: 0);

      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const state = StockListState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should update page', () {
      const state = StockListState();
      final updated = state.copyWith(page: 3);

      expect(updated.page, 3);
    });

    test('copyWith should update total', () {
      const state = StockListState();
      final updated = state.copyWith(total: 50);

      expect(updated.total, 50);
      expect(updated.hasMore, true);
    });

    test('copyWith should update type', () {
      const state = StockListState();
      final updated = state.copyWith(type: 1);

      expect(updated.type, 1);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = StockListState(
        loading: true,
        page: 2,
        total: 30,
        type: 2,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.page, 2);
      expect(updated.total, 30);
      expect(updated.type, 2);
    });
  });

  group('StockDetailState', () {
    test('should have correct default values', () {
      const state = StockDetailState();

      expect(state.loading, false);
      expect(state.detail, isNull);
    });

    test('copyWith should update loading', () {
      const state = StockDetailState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = StockDetailState(loading: true);
      final updated = state.copyWith();

      expect(updated.loading, true);
    });
  });
}
