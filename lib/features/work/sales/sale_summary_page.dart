import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/sales_bar_data.dart';
import 'package:merchant_app/data/models/sell_data_list_response.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(saleSummaryProvider.notifier).refresh());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSigningRateCard(context, l10n, state),
                    const SizedBox(height: 16),
                    _buildDataSection(context, l10n, state),
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
                const Expanded(
                  child: Text(
                    'Sales Statistics',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
            GestureDetector(
              onTap: () => _pickDateRange(context, notifier, state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                      '${_formatDate(state.startDate)} ~ ${_formatDate(state.endDate)}',
                      style: const TextStyle(
                        fontSize: 14,
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
              const Icon(
                Icons.emoji_events,
                size: 14,
                color: Color(0xFFFFB800),
              ),
              const SizedBox(width: 4),
              Text(
                'Store Ranking',
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
                      '${(summary?.signRate ?? 0).toStringAsFixed(1)} %',
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
                            'Order Signing Rate',
                            'Order signing rate = (Transaction order quantity / Total order quantity ) *100%',
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
                            'Average Order Price',
                            'Average Order Price = Total Sales Amount ÷ Transaction Order',
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
            child: chartData == null || chartData.timeList.isEmpty
                ? const Center(child: Text('No data'))
                : AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, child) {
                      return _tabController.index == 0
                          ? _AmountLineChart(data: chartData)
                          : _OrderBarChart(data: chartData);
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
            onTap: () => _showDataTypeSelector(context, l10n, state, notifier),
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
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.black06Text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 支付方式筛选
          _buildPayWayFilter(l10n, state, notifier),
          const SizedBox(height: 16),
          // 订单列表
          if (state.loadingList)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: const SizedBox.shrink(),
              ),
            )
          else
            _buildOrderList(l10n, state.orders),
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
          notifier.fetchList();
        }),
        const SizedBox(width: 8),
        _buildFilterChip(l10n.saleSummaryPayWayCash, state.payWay == 1, () {
          notifier.updatePayWay(1);
          notifier.fetchList();
        }),
        const SizedBox(width: 8),
        _buildFilterChip(l10n.saleSummaryPayWayOnline, state.payWay == 2, () {
          notifier.updatePayWay(2);
          notifier.fetchList();
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

  Widget _buildOrderList(AppLocalizations l10n, List<OrderItem> orders) {
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
      children: orders.map((order) => _buildOrderItem(l10n, order)).toList(),
    );
  }

  Widget _buildOrderItem(AppLocalizations l10n, OrderItem order) {
    // orderType: 1=Sale, 2=Lease, 3=Swap Battery, 4=Road rescue, 5=Schedule Maintenance
    final orderTypeInfo = _getOrderTypeInfo(order.orderType ?? 0);
    // payType: 1=Full cash, 2=Full online, 3=Cash installment, 4=Online installment
    final payTypeText = _getPayTypeText(order.payType ?? 0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: orderTypeInfo['bgColor'] as Color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              orderTypeInfo['icon'] as IconData,
              size: 20,
              color: orderTypeInfo['iconColor'] as Color,
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
                  '$payTypeText | Order No:${order.orderNo ?? '-'}',
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
              if ((order.attachment ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    // TODO: View Voucher
                  },
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

  Map<String, dynamic> _getOrderTypeInfo(int orderType) {
    switch (orderType) {
      case 1:
        return {
          'name': 'Sale',
          'icon': Icons.sell,
          'bgColor': const Color(0xFFFFF3E0),
          'iconColor': const Color(0xFFFF9800),
        };
      case 2:
        return {
          'name': 'Lease',
          'icon': Icons.key,
          'bgColor': const Color(0xFFE8F5E9),
          'iconColor': AppColors.primaryColor,
        };
      case 3:
        return {
          'name': 'Swap Battery',
          'icon': Icons.battery_charging_full,
          'bgColor': const Color(0xFFE3F2FD),
          'iconColor': const Color(0xFF2196F3),
        };
      case 4:
        return {
          'name': 'Road rescue',
          'icon': Icons.local_shipping,
          'bgColor': const Color(0xFFFFEBEE),
          'iconColor': const Color(0xFFF44336),
        };
      case 5:
        return {
          'name': 'Schedule Maintenance',
          'icon': Icons.build,
          'bgColor': const Color(0xFFFFF8E1),
          'iconColor': const Color(0xFFFFC107),
        };
      default:
        return {
          'name': 'Order',
          'icon': Icons.receipt,
          'bgColor': const Color(0xFFF5F5F5),
          'iconColor': const Color(0xFF999999),
        };
    }
  }

  String _getPayTypeText(int payType) {
    switch (payType) {
      case 1:
        return 'Full cash';
      case 2:
        return 'Full online';
      case 3:
        return 'Cash installment';
      case 4:
        return 'Online installment';
      default:
        return 'Cash';
    }
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
    notifier.updateDateRange(range.start, range.end);
    await notifier.refresh();
  }

  String _formatDate(DateTime date) {
    return DateFormatUtils.format(
      date,
      pattern: 'MMM d',
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
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
  // 尝试解析日期格式 yyyy-MM 或 yyyy-MM-dd
  if (raw.length >= 7) {
    try {
      final parts = raw.split('-');
      if (parts.length >= 2) {
        final month = int.parse(parts[1]);
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return months[month - 1];
      }
    } catch (_) {}
  }
  return raw;
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
