import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/data/models/vcu_history.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';

void main() {
  group('VcuState', () {
    test('should have correct default values', () {
      const state = VcuState();

      expect(state.loading, false);
      expect(state.searching, false);
      expect(state.sending, false);
      expect(state.versions, isEmpty);
      expect(state.history, isEmpty);
      expect(state.historyFilter, VcuHistoryFilter.all);
      expect(state.searchResult, isNull);
    });

    test('copyWith should update loading', () {
      const state = VcuState();
      final updated = state.copyWith(loading: true);

      expect(updated.loading, true);
      expect(updated.searching, false);
      expect(updated.sending, false);
    });

    test('copyWith should update searching', () {
      const state = VcuState();
      final updated = state.copyWith(searching: true);

      expect(updated.searching, true);
      expect(updated.loading, false);
    });

    test('copyWith should update sending', () {
      const state = VcuState();
      final updated = state.copyWith(sending: true);

      expect(updated.sending, true);
    });

    test('copyWith should update historyFilter', () {
      const state = VcuState();
      final updated = state.copyWith(historyFilter: VcuHistoryFilter.request);

      expect(updated.historyFilter, VcuHistoryFilter.request);
    });

    test('copyWith should preserve existing values when not provided', () {
      const state = VcuState(
        loading: true,
        searching: true,
        sending: true,
        historyFilter: VcuHistoryFilter.response,
      );
      final updated = state.copyWith(loading: false);

      expect(updated.loading, false);
      expect(updated.searching, true);
      expect(updated.sending, true);
      expect(updated.historyFilter, VcuHistoryFilter.response);
    });
  });

  group('VcuHistoryFilter', () {
    test('should have all filter options', () {
      expect(VcuHistoryFilter.values.length, 3);
      expect(VcuHistoryFilter.values.contains(VcuHistoryFilter.all), true);
      expect(VcuHistoryFilter.values.contains(VcuHistoryFilter.request), true);
      expect(VcuHistoryFilter.values.contains(VcuHistoryFilter.response), true);
    });
  });
}
