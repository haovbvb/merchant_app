import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/warehouse/receive_controller.dart';

void main() {
  group('ReceiveListState', () {
    test('should have correct default values', () {
      const state = ReceiveListState();

      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.status, isNull);
      expect(state.keyword, '');
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('hasMore should return true when items less than total', () {
      const state = ReceiveListState(items: [], total: 10);

      expect(state.hasMore, true);
    });

    test('hasMore should return false when items equal to total', () {
      const state = ReceiveListState(items: [], total: 0);

      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const state = ReceiveListState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.loadingMore, false);
    });

    test('copyWith should update loadingMore', () {
      const state = ReceiveListState();
      final updated = state.copyWith(loadingMore: true);

      expect(updated.loadingMore, true);
      expect(updated.loading, false);
    });

    test('copyWith should update page', () {
      const state = ReceiveListState();
      final updated = state.copyWith(page: 5);

      expect(updated.page, 5);
    });

    test('copyWith should update status', () {
      const state = ReceiveListState();
      final updated = state.copyWith(status: 1);

      expect(updated.status, 1);
    });

    test('copyWith should update keyword', () {
      const state = ReceiveListState();
      final updated = state.copyWith(keyword: 'search term');

      expect(updated.keyword, 'search term');
    });

    test('copyWith should update total', () {
      const state = ReceiveListState();
      final updated = state.copyWith(total: 100);

      expect(updated.total, 100);
      expect(updated.hasMore, true);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = ReceiveListState(
        loading: true,
        loadingMore: true,
        page: 3,
        status: 2,
        keyword: 'test',
        total: 50,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.loadingMore, true);
      expect(updated.page, 3);
      expect(updated.status, 2);
      expect(updated.keyword, 'test');
      expect(updated.total, 50);
    });
  });

  group('ReceiveDetailState', () {
    test('should have correct default values', () {
      const state = ReceiveDetailState();

      expect(state.loading, false);
      expect(state.transferNo, '');
      expect(state.detail, isNull);
      expect(state.items, isEmpty);
    });

    test('copyWith should update loading', () {
      const state = ReceiveDetailState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
    });

    test('copyWith should update transferNo', () {
      const state = ReceiveDetailState();
      final updated = state.copyWith(transferNo: 'TF001');

      expect(updated.transferNo, 'TF001');
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = ReceiveDetailState(
        loading: true,
        transferNo: 'TF002',
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.transferNo, 'TF002');
    });
  });
}
