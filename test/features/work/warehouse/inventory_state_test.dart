import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/device_inventory_detail.dart';
import 'package:merchant_app/data/models/device_inventory_resp.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';

void main() {
  group('InventoryListState', () {
    test('should have correct default values', () {
      const state = InventoryListState();
      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.status, isNull);
      expect(state.keyword, '');
      expect(state.items, isEmpty);
      expect(state.total, 0);
    });

    test('should create with provided values', () {
      const state = InventoryListState(
        loading: true,
        page: 2,
        status: 1,
        keyword: 'test',
        total: 100,
      );
      expect(state.loading, true);
      expect(state.page, 2);
      expect(state.status, 1);
      expect(state.keyword, 'test');
      expect(state.total, 100);
    });

    test('hasMore should return true when items < total', () {
      const state = InventoryListState(
        items: [],
        total: 10,
      );
      expect(state.hasMore, true);
    });

    test('hasMore should return false when items >= total', () {
      final items = List.generate(
        10,
        (i) => DeviceInventory.fromJson({'inventoryNo': 'INV$i'}),
      );
      final state = InventoryListState(items: items, total: 10);
      expect(state.hasMore, false);
    });

    test('copyWith should update loading', () {
      const original = InventoryListState();
      final updated = original.copyWith(loading: true);
      expect(updated.loading, true);
    });

    test('copyWith should update page', () {
      const original = InventoryListState(page: 1);
      final updated = original.copyWith(page: 5);
      expect(updated.page, 5);
    });

    test('copyWith should update status', () {
      const original = InventoryListState();
      final updated = original.copyWith(status: 2);
      expect(updated.status, 2);
    });

    test('copyWith should update keyword', () {
      const original = InventoryListState();
      final updated = original.copyWith(keyword: 'search');
      expect(updated.keyword, 'search');
    });

    test('copyWith should preserve values when not provided', () {
      const original = InventoryListState(
        loading: true,
        page: 3,
        status: 1,
        keyword: 'test',
        total: 50,
      );
      final copy = original.copyWith();
      expect(copy.loading, original.loading);
      expect(copy.page, original.page);
      expect(copy.status, original.status);
      expect(copy.keyword, original.keyword);
      expect(copy.total, original.total);
    });
  });

  group('InventoryDetailState', () {
    test('should have correct default values', () {
      const state = InventoryDetailState();
      expect(state.loading, false);
      expect(state.loadingMore, false);
      expect(state.page, 1);
      expect(state.inventoryNo, '');
      expect(state.detail, isNull);
      expect(state.items, isEmpty);
      expect(state.total, 0);
      expect(state.warehouse, isNull);
      expect(state.deviceType, isNull);
    });

    test('should create with provided values', () {
      const state = InventoryDetailState(
        loading: true,
        inventoryNo: 'INV001',
        deviceType: 1,
      );
      expect(state.loading, true);
      expect(state.inventoryNo, 'INV001');
      expect(state.deviceType, 1);
    });

    test('hasMore should return true when items < total', () {
      const state = InventoryDetailState(
        items: [],
        total: 10,
      );
      expect(state.hasMore, true);
    });

    test('hasMore should return false when items >= total', () {
      final items = List.generate(
        10,
        (i) => DeviceInventoryData.fromJson({'deviceSn': 'SN$i'}),
      );
      final state = InventoryDetailState(items: items, total: 10);
      expect(state.hasMore, false);
    });
  });
}
