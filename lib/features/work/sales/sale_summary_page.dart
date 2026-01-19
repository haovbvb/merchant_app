import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/sales_bar_data.dart';
import 'package:merchant_app/data/models/sell_data_list_response.dart';
import 'package:merchant_app/features/work/sales/sale_summary_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class SaleSummaryPage extends ConsumerStatefulWidget {
  const SaleSummaryPage({super.key});

  @override
  ConsumerState<SaleSummaryPage> createState() => _SaleSummaryPageState();
}

class _SaleSummaryPageState extends ConsumerState<SaleSummaryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(saleSummaryProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(saleSummaryProvider);
    final notifier = ref.read(saleSummaryProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.saleSummaryTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DateRangeTile(
            l10n: l10n,
            start: state.startDate,
            end: state.endDate,
            onTap: () => _pickDateRange(context, notifier, state),
          ),
          const SizedBox(height: 12),
          _PayWayFilters(
            l10n: l10n,
            payWay: state.payWay,
            onChange: (value) {
              notifier.updatePayWay(value);
              notifier.fetchList();
            },
          ),
          const SizedBox(height: 16),
          _SummaryCard(l10n: l10n, summary: state.summary),
          const SizedBox(height: 16),
          _ChartHint(l10n: l10n, data: state.chartData),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.saleSummaryListSection),
          const SizedBox(height: 8),
          if (state.loadingList)
            const Center(child: CircularProgressIndicator())
          else
            _OrderList(l10n: l10n, orders: state.orders),
        ],
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
      initialDateRange: DateTimeRange(start: state.startDate, end: state.endDate),
    );
    if (!mounted || range == null) return;
    notifier.updateDateRange(range.start, range.end);
    await notifier.refresh();
  }
}

class _DateRangeTile extends StatelessWidget {
  const _DateRangeTile({
    required this.l10n,
    required this.start,
    required this.end,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final DateTime start;
  final DateTime end;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rangeText = '${_format(start)} ~ ${_format(end)}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(l10n.saleSummaryDateRange),
      subtitle: Text(rangeText),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(l10n.saleSummarySelectDate),
      ),
    );
  }

  String _format(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

class _PayWayFilters extends StatelessWidget {
  const _PayWayFilters({
    required this.l10n,
    required this.payWay,
    required this.onChange,
  });

  final AppLocalizations l10n;
  final int? payWay;
  final ValueChanged<int?> onChange;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text(l10n.saleSummaryPayWayAll),
          selected: payWay == null,
          onSelected: (_) => onChange(null),
        ),
        ChoiceChip(
          label: Text(l10n.saleSummaryPayWayCash),
          selected: payWay == 1,
          onSelected: (_) => onChange(1),
        ),
        ChoiceChip(
          label: Text(l10n.saleSummaryPayWayOnline),
          selected: payWay == 2,
          onSelected: (_) => onChange(2),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.l10n, required this.summary});

  final AppLocalizations l10n;
  final SaleSumPageData? summary;

  @override
  Widget build(BuildContext context) {
    if (summary == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row(l10n.saleSummaryIncome, summary?.orderIncome),
            _row(l10n.saleSummaryOrderCount, summary?.orderNum),
            _row(l10n.saleSummaryAvgOrder, summary?.avgOrderAmount),
            _row(l10n.saleSummarySignRate, summary?.signRate),
            _row(l10n.saleSummaryIncomeRank, summary?.incomeRank),
            _row(l10n.saleSummaryNumRank, summary?.numRank),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label: ${value ?? '-'}'),
    );
  }
}

class _ChartHint extends StatelessWidget {
  const _ChartHint({required this.l10n, required this.data});

  final AppLocalizations l10n;
  final SalesBarData? data;

  @override
  Widget build(BuildContext context) {
    final chartData = data;
    if (chartData == null || chartData.timeList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Text(
      '${l10n.saleSummaryChartHint}: ${chartData.timeList.length}',
      style: const TextStyle(color: Colors.grey),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.l10n, required this.orders});

  final AppLocalizations l10n;
  final List<OrderItem> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Text(l10n.saleSummaryListEmpty);
    }
    return Column(
      children: orders
          .map(
            (order) => Card(
              child: ListTile(
                title: Text('${l10n.saleSummaryOrderNo}: ${order.orderNo ?? '-'}'),
                subtitle: Text(
                  '${l10n.saleSummaryAmount}: ${order.amount?.toStringAsFixed(2) ?? '-'}\n'
                  '${l10n.saleSummaryPayWay}: ${_payWayText(l10n, order.payWay)}',
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _payWayText(AppLocalizations l10n, int? payWay) {
    if (payWay == 1) return l10n.orderPayCash;
    if (payWay == 2) return l10n.orderPayOnline;
    return '-';
  }
}
