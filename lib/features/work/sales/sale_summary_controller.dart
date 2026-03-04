import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/data/models/sales_bar_data.dart';
import 'package:merchant_app/data/models/sell_data_list_response.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class SaleSummaryState {
  final bool loadingSummary;
  final bool loadingList;
  final bool loadingMore;
  final bool loadingChart;
  final DateTime startDate;
  final DateTime endDate;
  final int? payWay;
  final bool showSalesData; // true=Sales Data, false=After-Sales Data
  final SaleSumPageData? summary;
  final SalesBarData? chartData;
  final List<OrderItem> orders;
  final int total;
  final int pageNum;
  final int pageSize;

  const SaleSummaryState({
    required this.startDate,
    required this.endDate,
    this.loadingSummary = false,
    this.loadingList = false,
    this.loadingMore = false,
    this.loadingChart = false,
    this.payWay,
    this.showSalesData = true,
    this.summary,
    this.chartData,
    this.orders = const [],
    this.total = 0,
    this.pageNum = 1,
    this.pageSize = 10,
  });

  bool get hasMore => orders.length < total;

  static const Object _unset = Object();

  SaleSummaryState copyWith({
    bool? loadingSummary,
    bool? loadingList,
    bool? loadingMore,
    bool? loadingChart,
    DateTime? startDate,
    DateTime? endDate,
    Object? payWay = _unset,
    bool? showSalesData,
    SaleSumPageData? summary,
    SalesBarData? chartData,
    List<OrderItem>? orders,
    int? total,
    int? pageNum,
    int? pageSize,
  }) {
    return SaleSummaryState(
      loadingSummary: loadingSummary ?? this.loadingSummary,
      loadingList: loadingList ?? this.loadingList,
      loadingMore: loadingMore ?? this.loadingMore,
      loadingChart: loadingChart ?? this.loadingChart,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      payWay: payWay == _unset ? this.payWay : payWay as int?,
      showSalesData: showSalesData ?? this.showSalesData,
      summary: summary ?? this.summary,
      chartData: chartData ?? this.chartData,
      orders: orders ?? this.orders,
      total: total ?? this.total,
      pageNum: pageNum ?? this.pageNum,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

final saleSummaryProvider =
    NotifierProvider<SaleSummaryNotifier, SaleSummaryState>(
  SaleSummaryNotifier.new,
);

class SaleSummaryNotifier extends Notifier<SaleSummaryState> {
  final ApiService _api = ApiService();

  SaleSummaryState _initialState() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return SaleSummaryState(startDate: start, endDate: now);
  }

  @override
  SaleSummaryState build() {
    return _initialState();
  }

  void resetForEnter() {
    state = _initialState();
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchSummary(),
      fetchChartData(),
      fetchList(reset: true),
    ]);
  }

  void updateDateRange(DateTime start, DateTime end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void updatePayWay(int? payWay) {
    state = state.copyWith(payWay: payWay);
  }

  /// Toggle between Sales Data and After-Sales Data
  void setShowSalesData(bool showSalesData) {
    if (state.showSalesData != showSalesData) {
      state = state.copyWith(
        showSalesData: showSalesData,
        orders: const [],
        pageNum: 1,
      );
      fetchList(reset: true);
    }
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

  Future<void> fetchList({bool reset = false}) async {
    if (state.loadingList || state.loadingMore) return;
    if (!reset && !state.hasMore) return;

    final nextPage = reset ? 1 : state.pageNum + 1;
    state = state.copyWith(
      loadingList: reset,
      loadingMore: !reset,
    );

    final params = <String, dynamic>{
      'startDate': _formatDate(state.startDate),
      'endDate': _formatDate(state.endDate),
      'pageNum': nextPage,
      'pageSize': state.pageSize,
    };
    if (state.payWay != null) {
      params['payWay'] = state.payWay;
    }
    // Choose API based on showSalesData: true=Sales Data, false=After-Sales Data
    final apiPath = state.showSalesData
        ? ApiPath.saleSummaryQueryShopSaleData
        : ApiPath.saleSummaryQueryAfterSaleData;
    final response = await _api.get<SellDataListResponse>(
      apiPath,
      queryParameters: params,
      parser: (json) => SellDataListResponse.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    );

    final incoming = response.result?.list ?? const <OrderItem>[];
    final merged = reset ? incoming : [...state.orders, ...incoming];
    final total = response.result?.total ?? (reset ? incoming.length : state.total);

    state = state.copyWith(
      loadingList: false,
      loadingMore: false,
      pageNum: nextPage,
      orders: merged,
      total: total,
    );
  }

  Future<void> loadMore() async {
    await fetchList(reset: false);
  }

  String _formatDate(DateTime date) {
    return DateFormatUtils.format(
      date,
      pattern: 'yyyy-MM-dd',
    );
  }
}
