import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_app/features/work/sales/sale_summary_controller.dart';

void main() {
  group('SaleSummaryState', () {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);

    test('copyWith should update loadingSummary', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      final updated = state.copyWith(loadingSummary: true);
      expect(updated.loadingSummary, true);
      expect(updated.loadingList, false);
      expect(updated.loadingChart, false);
    });

    test('copyWith should update loadingList', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      final updated = state.copyWith(loadingList: true);
      expect(updated.loadingList, true);
      expect(updated.loadingSummary, false);
    });

    test('copyWith should update loadingChart', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      final updated = state.copyWith(loadingChart: true);
      expect(updated.loadingChart, true);
    });

    test('copyWith should update startDate and endDate', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      final newStart = DateTime(2023, 1, 1);
      final newEnd = DateTime(2023, 12, 31);
      final updated = state.copyWith(startDate: newStart, endDate: newEnd);
      expect(updated.startDate, newStart);
      expect(updated.endDate, newEnd);
    });

    test('copyWith should update payWay', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      final updated = state.copyWith(payWay: 1);
      expect(updated.payWay, 1);
    });

    test('copyWith should update showSalesData', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      expect(state.showSalesData, true);
      final updated = state.copyWith(showSalesData: false);
      expect(updated.showSalesData, false);
    });

    test('copyWith should update orders and total', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      final updated = state.copyWith(total: 100);
      expect(updated.total, 100);
      expect(updated.orders, isEmpty);
    });

    test('default values should be correct', () {
      final state = SaleSummaryState(startDate: start, endDate: now);
      expect(state.loadingSummary, false);
      expect(state.loadingList, false);
      expect(state.loadingChart, false);
      expect(state.payWay, null);
      expect(state.showSalesData, true);
      expect(state.summary, null);
      expect(state.chartData, null);
      expect(state.orders, isEmpty);
      expect(state.total, 0);
    });

    test('copyWith should preserve unchanged values', () {
      final state = SaleSummaryState(
        startDate: start,
        endDate: now,
        loadingSummary: true,
        loadingList: true,
        loadingChart: true,
        payWay: 2,
        showSalesData: false,
        total: 50,
      );
      final updated = state.copyWith(loadingSummary: false);
      expect(updated.loadingSummary, false);
      expect(updated.loadingList, true);
      expect(updated.loadingChart, true);
      expect(updated.payWay, 2);
      expect(updated.showSalesData, false);
      expect(updated.total, 50);
    });
  });
}
