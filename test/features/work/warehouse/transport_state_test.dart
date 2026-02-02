import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';

void main() {
  group('TransportMode', () {
    test('should have issue and receive values', () {
      expect(TransportMode.values.length, 2);
      expect(TransportMode.issue, isNotNull);
      expect(TransportMode.receive, isNotNull);
    });
  });

  group('TransportListState', () {
    test('should have correct default values', () {
      const state = TransportListState();
      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.status, isNull);
      expect(state.mode, TransportMode.issue);
      expect(state.keyword, '');
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('should create with provided values', () {
      const state = TransportListState(
        loading: true,
        page: 2,
        status: 1,
        mode: TransportMode.receive,
        keyword: 'test',
        total: 100,
      );
      expect(state.loading, true);
      expect(state.page, 2);
      expect(state.status, 1);
      expect(state.mode, TransportMode.receive);
      expect(state.keyword, 'test');
      expect(state.total, 100);
    });

    test('hasMore should return true when items < total', () {
      const state = TransportListState(
        items: [],
        total: 10,
      );
      expect(state.hasMore, true);
    });

    test('hasMore should return false when items >= total', () {
      final items = List.generate(
        10,
        (i) => DeviceTransport.fromJson({'transportNo': 'TRN$i'}),
      );
      final state = TransportListState(items: items, total: 10);
      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const original = TransportListState();
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
    });

    test('copyWith should update page', () {
      const original = TransportListState(page: 1);
      final updated = original.copyWith(page: 5);
      expect(updated.page, 5);
    });

    test('copyWith should update mode', () {
      const original = TransportListState();
      final updated = original.copyWith(mode: TransportMode.receive);
      expect(updated.mode, TransportMode.receive);
    });

    test('copyWith should update status', () {
      const original = TransportListState();
      final updated = original.copyWith(status: 2);
      expect(updated.status, 2);
    });

    test('copyWith should update keyword', () {
      const original = TransportListState();
      final updated = original.copyWith(keyword: 'search');
      expect(updated.keyword, 'search');
    });

    test('copyWith should preserve values when not provided', () {
      const original = TransportListState(
        loading: true,
        page: 3,
        status: 1,
        mode: TransportMode.receive,
        keyword: 'test',
        total: 50,
      );
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.page, original.page);
      expect(copy.status, original.status);
      expect(copy.mode, original.mode);
      expect(copy.keyword, original.keyword);
      expect(copy.total, original.total);
    });
  });
}
