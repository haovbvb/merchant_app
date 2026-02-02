import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/user_info.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';

void main() {
  group('UserListState', () {
    test('should have correct default values', () {
      const state = UserListState();
      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.keyword, '');
      expect(state.status, isNull);
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('should create with provided values', () {
      const state = UserListState(
        loading: true,
        loadingMore: true,
        page: 2,
        keyword: 'test',
        status: 1,
        total: 100,
      );
      expect(state.loading, true);
      expect(state.loadingMore, true);
      expect(state.page, 2);
      expect(state.keyword, 'test');
      expect(state.status, 1);
      expect(state.total, 100);
    });

    test('hasMore should return true when items < total', () {
      const state = UserListState(
        items: [],
        total: 10,
      );
      expect(state.hasMore, true);
    });

    test('hasMore should return false when items >= total', () {
      final items = List.generate(
        10,
        (i) => UserInfo.fromJson({'cardNum': 'CARD$i'}),
      );
      final state = UserListState(items: items, total: 10);
      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const original = UserListState();
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
    });

    test('copyWith should update loadingMore', () {
      const original = UserListState();
      final updated = original.copyWith(loadingMore: true);
      expect(updated.loadingMore, true);
    });

    test('copyWith should update page', () {
      const original = UserListState(page: 1);
      final updated = original.copyWith(page: 5);
      expect(updated.page, 5);
    });

    test('copyWith should update keyword', () {
      const original = UserListState();
      final updated = original.copyWith(keyword: 'search');
      expect(updated.keyword, 'search');
    });

    test('copyWith should update status', () {
      const original = UserListState();
      final updated = original.copyWith(status: 2);
      expect(updated.status, 2);
    });

    test('copyWith with clearStatus should set status to null', () {
      const original = UserListState(status: 1);
      final updated = original.copyWith(clearStatus: true);
      expect(updated.status, isNull);
    });

    test('copyWith should update items list', () {
      const original = UserListState();
      final items = [
        UserInfo.fromJson({'cardNum': 'CARD1'}),
        UserInfo.fromJson({'cardNum': 'CARD2'}),
      ];
      final updated = original.copyWith(items: items);
      expect(updated.items.length, 2);
    });

    test('copyWith should update total', () {
      const original = UserListState();
      final updated = original.copyWith(total: 50);
      expect(updated.total, 50);
    });

    test('copyWith should preserve values when not provided', () {
      const original = UserListState(
        loading: true,
        page: 3,
        keyword: 'test',
        status: 1,
        total: 50,
      );
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.page, original.page);
      expect(copy.keyword, original.keyword);
      expect(copy.status, original.status);
      expect(copy.total, original.total);
    });
  });
}
