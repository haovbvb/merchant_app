import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/data/models/sales_bar_data.dart';
import 'package:merchant_app/data/models/sell_data_list_response.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class SaleSummaryState {
  final bool loadingSummary;
  final bool loadingList;
  final bool loadingChart;
  final DateTime startDate;
  final DateTime endDate;
  final int? payWay;
  final SaleSumPageData? summary;
  final SalesBarData? chartData;
  final List<OrderItem> orders;
  final int total;

  const SaleSummaryState({
    required this.startDate,
    required this.endDate,
    this.loadingSummary = false,
    this.loadingList = false,
    this.loadingChart = false,
    this.payWay,
    this.summary,
    this.chartData,
    this.orders = const [],
    this.total = 0,
  });

  SaleSummaryState copyWith({
    bool? loadingSummary,
    bool? loadingList,
    bool? loadingChart,
    DateTime? startDate,
    DateTime? endDate,
    int? payWay,
    SaleSumPageData? summary,
    SalesBarData? chartData,
    List<OrderItem>? orders,
    int? total,
  }) {
    return SaleSummaryState(
      loadingSummary: loadingSummary ?? this.loadingSummary,
      loadingList: loadingList ?? this.loadingList,
      loadingChart: loadingChart ?? this.loadingChart,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      payWay: payWay ?? this.payWay,
      summary: summary ?? this.summary,
      chartData: chartData ?? this.chartData,
      orders: orders ?? this.orders,
      total: total ?? this.total,
    );
  }
}

final saleSummaryProvider =
    NotifierProvider<SaleSummaryNotifier, SaleSummaryState>(
  SaleSummaryNotifier.new,
);

class SaleSummaryNotifier extends Notifier<SaleSummaryState> {
  final ApiService _api = ApiService();

  @override
  SaleSummaryState build() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return SaleSummaryState(startDate: start, endDate: now);
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchSummary(),
      fetchChartData(),
      fetchList(),
    ]);
  }

  void updateDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void updatePayWay(int? payWay) {
    state = state.copyWith(payWay: payWay);
  }

  Future<void> fetchSummary() async {
    state = state.copyWith(loadingSummary: true);
    final response = await _api.get<SaleSumPageData>(
      ApiPath.saleSummaryRank,
      queryParameters: {
        'startDate': _formatDate(state.startDate),
        'endDate': _formatDate(state.endDate),
      },
      parser: (json) => SaleSumPageData.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingSummary: false,
      summary: response.result,
    );
  }

  Future<void> fetchChartData() async {
    state = state.copyWith(loadingChart: true);
    final response = await _api.get<SalesBarData>(
      ApiPath.saleSummaryLast12MonthOrderData,
      parser: (json) => SalesBarData.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingChart: false,
      chartData: response.result,
    );
  }

  Future<void> fetchList({int pageNum = 1, int pageSize = 20}) async {
    state = state.copyWith(loadingList: true);
    final params = <String, dynamic>{
      'startDate': _formatDate(state.startDate),
      'endDate': _formatDate(state.endDate),
      'pageNum': pageNum,
      'pageSize': pageSize,
    };
    if (state.payWay != null) {
      params['payWay'] = state.payWay;
    }
    final response = await _api.get<SellDataListResponse>(
      ApiPath.saleSummaryQueryShopSaleData,
      queryParameters: params,
      parser: (json) => SellDataListResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );
    state = state.copyWith(
      loadingList: false,
      orders: response.result?.list ?? const [],
      total: response.result?.total ?? 0,
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
