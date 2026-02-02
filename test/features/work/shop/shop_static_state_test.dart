import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/shop/shop_static_controller.dart';

void main() {
  group('ShopStaticListState', () {
    test('should have correct default values', () {
      const state = ShopStaticListState();

      expect(state.loading, false);
      expect(state.num, isNull);
      expect(state.page, 1);
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('hasMore should return true when items less than total', () {
      const state = ShopStaticListState(items: [], total: 10);

      expect(state.hasMore, true);
    });

    test('hasMore should return false when items equal to total', () {
      const state = ShopStaticListState(items: [], total: 0);

      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const state = ShopStaticListState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should update page', () {
      const state = ShopStaticListState();
      final updated = state.copyWith(page: 5);

      expect(updated.page, 5);
    });

    test('copyWith should update total', () {
      const state = ShopStaticListState();
      final updated = state.copyWith(total: 100);

      expect(updated.total, 100);
      expect(updated.hasMore, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = ShopStaticListState(
        loading: true,
        page: 3,
        total: 50,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.page, 3);
      expect(updated.total, 50);
    });
  });
}
