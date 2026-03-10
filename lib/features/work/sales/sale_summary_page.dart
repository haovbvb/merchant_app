import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/core/widgets/photo_gallery_viewer.dart';
import 'package:merchant_app/data/models/sales_bar_data.dart';
import 'package:merchant_app/data/models/sell_data_list_response.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/sales/sale_summary_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class SaleSummaryPage extends ConsumerStatefulWidget {
  const SaleSummaryPage({super.key});

  @override
  ConsumerState<SaleSummaryPage> createState() => _SaleSummaryPageState();
}

class _SaleSummaryPageState extends ConsumerState<SaleSummaryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);
    Future.microtask(() async {
      final isManager = AuthSession.instance.current?.managerFlag == true;
      final notifier = ref.read(saleSummaryProvider.notifier);
      notifier.resetForEnter();
      if (!isManager) {
        notifier.setShowSalesData(true);
      }
      await notifier.refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 120;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(saleSummaryProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(saleSummaryProvider);
    final notifier = ref.read(saleSummaryProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          // 深绿色顶部区域
          _buildHeader(context, l10n, state, notifier),
          // 白色内容区域
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSigningRateCard(context, l10n, state),
                    const SizedBox(height: 16),
                    _buildDataSection(context, l10n, state),
                    if (state.loadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    if (!state.loadingList && !state.loadingMore && !state.hasMore)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          _noMoreDataText(context),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    SaleSummaryState state,
    SaleSummaryNotifier notifier,
  ) {
    final summary = state.summary;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B3D2F), Color(0xFF2D5A45)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    l10n.workbenchSalesStatistics,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 8),
            // 日期选择
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => _pickDateRange(context, notifier, state),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_formatDate(state.startDate)}~${_formatDate(state.endDate)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 总销售额和交易订单
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatColumn(
                      l10n.saleSummaryTotalSalesAmount,
                      _formatAmount(summary?.orderIncome ?? 0),
                      summary?.incomeRank ?? 0,
                      true,
                    ),
                  ),
                  Expanded(
                    child: _buildStatColumn(
                      l10n.saleSummaryTransactionOrder,
                      '${summary?.orderNum ?? 0}',
                      summary?.numRank ?? 0,
                      false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, int rank, bool showInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _showInfoDialog(
                showInfo ? 'Total Sales Amount' : 'Transaction Order',
                showInfo
                    ? 'The cumulative amount of orders executed within the selected time period'
                    : 'The number of successfully executed orders within the selected time period',
              ),
              child: const Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/android/mipmap-xxhdpi/icon_rank.png',
                width: 12,
                height: 12,
              ),
              const SizedBox(width: 4),
              Text(
                _storeRankingText(context),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSigningRateCard(
    BuildContext context,
    AppLocalizations l10n,
    SaleSummaryState state,
  ) {
    final summary = state.summary;
    final chartData = state.chartData;
    final normalizedChartData = chartData == null
        ? null
        : _normalizeChartData(chartData);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Signing rate & Order value 标题
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 18,
                color: AppColors.black06Text,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.saleSummarySigningRateTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black06Text,
                ),
              ),
            ],
          ),
            const SizedBox(height: 16),
          // 签约率和平均订单价格
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${((summary?.signRate ?? 0) * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          l10n.saleSummaryOrderSigningRate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _showInfoDialog(
                            _orderSigningRateTitle(context),
                            _orderSigningRateContent(context),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$${(summary?.avgOrderAmount ?? 0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          l10n.saleSummaryAverageOrderPrice,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _showInfoDialog(
                            _averageOrderAmountTitle(context),
                            _averageOrderAmountContent(context),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          // Tab切换：Sales Amount / Transaction Order
          TabBar(
            controller: _tabController,
            labelColor: AppColors.black06Text,
            unselectedLabelColor: const Color(0xFF999999),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            indicatorColor: AppColors.primaryColor,
            indicatorWeight: 2,
            tabs: [
              Tab(text: l10n.saleSummarySalesAmount),
              Tab(text: l10n.saleSummaryTransactionOrderTab),
            ],
          ),
          const SizedBox(height: 16),
          // 图表
          SizedBox(
            height: 220,
            child: normalizedChartData == null || normalizedChartData.timeList.isEmpty
                ? Center(child: Text(l10n.saleSummaryListEmpty))
                : AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, child) {
                      return _tabController.index == 0
                          ? _AmountLineChart(data: normalizedChartData)
                          : _OrderBarChart(data: normalizedChartData);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(
    BuildContext context,
    AppLocalizations l10n,
    SaleSummaryState state,
  ) {
    final notifier = ref.read(saleSummaryProvider.notifier);
    final isManager = AuthSession.instance.current?.managerFlag == true;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sales Data / After-Sales Data 选择器
          GestureDetector(
            onTap: isManager
                ? () => _showDataTypeSelector(context, l10n, state, notifier)
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.showSalesData
                      ? l10n.saleSummarySalesData
                      : l10n.saleSummaryAfterSalesData,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                if (isManager) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppColors.black06Text,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 支付方式筛选
          _buildPayWayFilter(l10n, state, notifier),
          const SizedBox(height: 16),
          // 订单列表
          if (state.loadingList)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            _buildOrderList(l10n, state.orders, state.showSalesData),
        ],
      ),
    );
  }

  Widget _buildPayWayFilter(
    AppLocalizations l10n,
    SaleSummaryState state,
    SaleSummaryNotifier notifier,
  ) {
    return Row(
      children: [
        _buildFilterChip(l10n.saleSummaryPayWayAll, state.payWay == null, () {
          notifier.updatePayWay(null);
          notifier.fetchList(reset: true);
        }),
        const SizedBox(width: 8),
        _buildFilterChip(l10n.saleSummaryPayWayCash, state.payWay == 1, () {
          notifier.updatePayWay(1);
          notifier.fetchList(reset: true);
        }),
        const SizedBox(width: 8),
        _buildFilterChip(l10n.saleSummaryPayWayOnline, state.payWay == 2, () {
          notifier.updatePayWay(2);
          notifier.fetchList(reset: true);
        }),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: AppColors.primaryColor) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFF666666),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(
    AppLocalizations l10n,
    List<OrderItem> orders,
    bool isSalesData,
  ) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            l10n.saleSummaryListEmpty,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
        ),
      );
    }

    return Column(
      children: orders
          .map((order) => _buildOrderItem(l10n, order, isSalesData))
          .toList(),
    );
  }

  Widget _buildOrderItem(
    AppLocalizations l10n,
    OrderItem order,
    bool isSalesData,
  ) {
    final orderTypeInfo = _getOrderTypeInfo(
      l10n,
      order.orderType ?? 0,
      isAfterSalesData: !isSalesData,
    );
    final orderMeta = _buildOrderMetaText(l10n, order, isSalesData);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          // 图标
          SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              orderTypeInfo['iconPath'] as String,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderTypeInfo['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black06Text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  orderMeta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          // 金额
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${(order.amount ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              if (!isSalesData && (order.attachment ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => PhotoGalleryViewer.show(
                    context,
                    _splitAttachmentUrls(order.attachment),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.saleSummaryViewVoucher,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getOrderTypeInfo(
    AppLocalizations l10n,
    int orderType, {
    required bool isAfterSalesData,
  }) {
    if (isAfterSalesData) {
      switch (orderType) {
        case 1:
          return {
            'name': l10n.workbenchScheduleMaintenance,
            'iconPath':
                'assets/android/mipmap-xxhdpi/icon_roadside_assistance.png',
          };
        case 2:
          return {
            'name': l10n.workbenchRoadsideAssistance,
            'iconPath':
                'assets/android/mipmap-xxhdpi/icon_schedule_maintenance.png',
          };
        default:
          return {
            'name': l10n.saleSummaryTransactionOrder,
            'iconPath': 'assets/android/mipmap-xxhdpi/icon_sale_bind.webp',
          };
      }
    }

    switch (orderType) {
      case 1:
        return {
          'name': _saleTypeText(context),
          'iconPath': 'assets/android/mipmap-xxhdpi/icon_sale_bind.webp',
        };
      case 2:
        return {
          'name': _leaseTypeText(context),
          'iconPath': 'assets/android/mipmap-xxhdpi/icon_lease_bind.png',
        };
      case 3:
        return {
          'name': l10n.userOrderTabSwap,
          'iconPath': 'assets/android/mipmap-xxhdpi/icon_swap_bind.webp',
        };
      case 4:
        return {
          'name': l10n.workbenchRoadsideAssistance,
          'iconPath':
              'assets/android/mipmap-xxhdpi/icon_roadside_assistance.png',
        };
      case 5:
        return {
          'name': l10n.workbenchScheduleMaintenance,
          'iconPath':
              'assets/android/mipmap-xxhdpi/icon_schedule_maintenance.png',
        };
      default:
        return {
          'name': l10n.saleSummaryTransactionOrder,
          'iconPath': 'assets/android/mipmap-xxhdpi/icon_sale_bind.webp',
        };
    }
  }

  String _buildOrderMetaText(
    AppLocalizations l10n,
    OrderItem order,
    bool isSalesData,
  ) {
    final payWay = order.payWay;
    final payWayText = payWay == 2
        ? l10n.saleSummaryPayWayOnline
        : l10n.saleSummaryPayWayCash;
    final orderNoText = '${l10n.saleSummaryOrderNo}:${order.orderNo ?? '-'}';
    if (!isSalesData) {
      return '$payWayText | $orderNoText';
    }
    final installmentText = (order.payType ?? 0) == 2
        ? l10n.orderPayInstallment
        : l10n.orderPayFull;
    return '$payWayText $installmentText | $orderNoText';
  }

  void _showInfoDialog(String title, String content) {
    ConfirmDialog.alert(context: context, message: content);
  }

  void _showDataTypeSelector(
    BuildContext context,
    AppLocalizations l10n,
    SaleSummaryState state,
    SaleSummaryNotifier notifier,
  ) {
    final showSalesData = state.showSalesData;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.saleSummarySelectData,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  l10n.saleSummarySalesData,
                  style: TextStyle(
                    color: showSalesData
                        ? AppColors.black06Text
                        : const Color(0xFF666666),
                  ),
                ),
                onTap: () {
                  notifier.setShowSalesData(true);
                  Navigator.of(context).pop();
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(
                  l10n.saleSummaryAfterSalesData,
                  style: TextStyle(
                    color: !showSalesData
                        ? AppColors.primaryColor
                        : const Color(0xFF666666),
                  ),
                ),
                onTap: () {
                  notifier.setShowSalesData(false);
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black06Text,
                      side: const BorderSide(color: Color(0xFFEEEEEE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateRange(
    BuildContext context,
    SaleSummaryNotifier notifier,
    SaleSummaryState state,
  ) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: state.startDate,
        end: state.endDate,
      ),
    );
    if (!mounted || range == null) return;
    final days = range.end.difference(range.start).inDays + 1;
    if (days > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_dateRangeExceededText(context))),
      );
      return;
    }
    notifier.updateDateRange(range.start, range.end);
    await notifier.fetchSummary();
    await notifier.fetchList(reset: true);
  }

  String _formatDate(DateTime date) {
    return DateFormatUtils.format(date, pattern: 'MMM d');
  }

  String _formatAmount(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  List<String> _splitAttachmentUrls(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

// ===== 图表组件 =====

class _AmountLineChart extends StatelessWidget {
  const _AmountLineChart({required this.data});

  final SalesBarData data;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.amountList.length; i++) {
      spots.add(FlSpot(i.toDouble(), data.amountList[i]));
    }
    final maxY = _calcMaxY(data.amountList.map((e) => e.toDouble()).toList());
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _leftInterval(maxY),
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFFEEEEEE),
            strokeWidth: 1,
            dashArray: [4, 2],
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: _leftInterval(maxY),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _bottomInterval(data.timeList.length),
              getTitlesWidget: (value, meta) =>
                  _buildBottomTitle(value, meta, data.timeList),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: AppColors.primaryColor,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

class _OrderBarChart extends StatelessWidget {
  const _OrderBarChart({required this.data});

  final SalesBarData data;

  @override
  Widget build(BuildContext context) {
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < data.numList.length; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data.numList[i].toDouble(),
              color: const Color(0xFF3FA9FC),
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }
    final maxY = _calcMaxY(data.numList.map((e) => e.toDouble()).toList());
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _leftInterval(maxY),
          getDrawingHorizontalLine: (value) => const FlLine(
            color: Color(0xFFEEEEEE),
            strokeWidth: 1,
            dashArray: [4, 2],
          ),
        ),
        borderData: FlBorderData(show: false),
        minY: 0,
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: _leftInterval(maxY),
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _bottomInterval(data.timeList.length),
              getTitlesWidget: (value, meta) =>
                  _buildBottomTitle(value, meta, data.timeList),
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: bars,
      ),
    );
  }
}

// ===== 辅助函数 =====

double _bottomInterval(int length) {
  if (length <= 12) return 1;
  return (length / 12).ceilToDouble();
}

String _formatDateLabel(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return '-';
  final parts = value.split('-');
  if (parts.length >= 2) {
    final month = parts[1].padLeft(2, '0');
    if (int.tryParse(month) != null) {
      return month;
    }
  }
  return value;
}

SalesBarData _normalizeChartData(SalesBarData source) {
  final minLength = [
    source.timeList.length,
    source.amountList.length,
    source.numList.length,
  ].reduce(math.min);
  if (minLength <= 0) {
    return const SalesBarData(amountList: [], numList: [], timeList: []);
  }

  final list = <_ChartPoint>[];
  for (var index = 0; index < minLength; index++) {
    list.add(
      _ChartPoint(
        time: source.timeList[index],
        amount: source.amountList[index],
        num: source.numList[index],
        parsed: _parseChartDate(source.timeList[index]),
      ),
    );
  }

  list.sort((a, b) {
    final aDate = a.parsed;
    final bDate = b.parsed;
    if (aDate != null && bDate != null) {
      return aDate.compareTo(bDate);
    }
    if (aDate != null) return -1;
    if (bDate != null) return 1;
    return 0;
  });

  final now = DateTime.now();
  final start = DateTime(now.year, now.month - (list.length - 1), 1);
  final timeline = <String>[];
  for (var index = 0; index < list.length; index++) {
    final pointDate = DateTime(start.year, start.month + index, 1);
    timeline.add(
      '${pointDate.year}-${pointDate.month.toString().padLeft(2, '0')}',
    );
  }

  return SalesBarData(
    amountList: list.map((item) => item.amount).toList(),
    numList: list.map((item) => item.num).toList(),
    timeList: timeline,
  );
}

DateTime? _parseChartDate(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  final normalized = value.contains('-') ? value : value.replaceAll('.', '-');
  final parts = normalized.split('-').where((item) => item.isNotEmpty).toList();
  if (parts.length >= 2) {
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year != null && month != null && month >= 1 && month <= 12) {
      return DateTime(year, month, 1);
    }
  }
  return DateTime.tryParse(value);
}

String _noMoreDataText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '暂无更多数据' : 'No more data';
}

String _dateRangeExceededText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '时间范围不能超过30天' : 'Date range cannot exceed 30 days';
}

String _orderSigningRateTitle(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '订单签约率' : 'Order Signing Rate';
}

String _storeRankingText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '门店排名' : 'Store Ranking';
}

String _saleTypeText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '销售' : 'Sale';
}

String _leaseTypeText(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '租赁' : 'Lease';
}

String _orderSigningRateContent(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh
      ? '订单签约率 = (成交订单数/总订单数)×100%'
      : 'Order signing rate = (Transaction order quantity / Total order quantity) * 100%';
}

String _averageOrderAmountTitle(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '平均订单金额' : 'Average order amount';
}

String _averageOrderAmountContent(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh
      ? '平均订单金额 = 总销售额 ÷ 成交订单数'
      : 'Average order amount = Total sales amount ÷ Transaction order';
}

class _ChartPoint {
  const _ChartPoint({
    required this.time,
    required this.amount,
    required this.num,
    required this.parsed,
  });

  final String time;
  final double amount;
  final int num;
  final DateTime? parsed;
}

SideTitleWidget _buildBottomTitle(
  double value,
  TitleMeta meta,
  List<String> labels,
) {
  final index = value.toInt();
  if (index < 0 || index >= labels.length) {
    return const SideTitleWidget(
      axisSide: AxisSide.bottom,
      child: SizedBox.shrink(),
    );
  }
  final text = labels[index];
  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: Text(
      _formatDateLabel(text),
      style: const TextStyle(fontSize: 10, color: Color(0xFF999999)),
    ),
  );
}

double _calcMaxY(List<double> values) {
  if (values.isEmpty) return 400;
  final maxValue = values.reduce(math.max);
  if (maxValue <= 100) return 100;
  // 向上取整到 100 的倍数
  return ((maxValue / 100).ceil() * 100).toDouble();
}

double _leftInterval(double maxY) {
  if (maxY <= 100) return 25;
  return (maxY / 4).ceilToDouble();
}
