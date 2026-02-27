import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/device_type_sheet.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/features/work/warehouse/transport_create_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_detail_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_search_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TransportListPage extends ConsumerStatefulWidget {
  const TransportListPage({
    super.key,
    required this.initialTabIndex,
    required this.mode,
  });

  final int initialTabIndex;
  final TransportMode mode;

  @override
  ConsumerState<TransportListPage> createState() => _TransportListPageState();
}

class _TransportListPageState extends ConsumerState<TransportListPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transportListProvider.notifier).refresh(mode: widget.mode);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(transportListProvider);
    final notifier = ref.read(transportListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          widget.mode == TransportMode.issue
              ? l10n.deviceIssueTitle
              : l10n.deviceReceiveTitle,
        ),
        actions: [
          if (widget.mode == TransportMode.issue)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showDeviceTypeSheet(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransportSearchPage(mode: widget.mode),
                ),
              ),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.deviceIssueSearchHint,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 筛选标签
          Container(
            color: Colors.white,
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: l10n.warehouseTabAll,
                  selected: _selectedTabIndex == 0,
                  onTap: () => _onTabSelected(0, notifier),
                ),
                _FilterChip(
                  label: l10n.deviceIssueStatusInTransit,
                  selected: _selectedTabIndex == 1,
                  onTap: () => _onTabSelected(1, notifier),
                ),
                _FilterChip(
                  label: l10n.deviceIssueStatusReceiveAll,
                  selected: _selectedTabIndex == 2,
                  onTap: () => _onTabSelected(2, notifier),
                ),
                _FilterChip(
                  label: l10n.deviceIssueStatusPartial,
                  selected: _selectedTabIndex == 3,
                  onTap: () => _onTabSelected(3, notifier),
                ),
                _FilterChip(
                  label: l10n.deviceIssueStatusWithdrawn,
                  selected: _selectedTabIndex == 4,
                  onTap: () => _onTabSelected(4, notifier),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // 列表
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: state.hasMore,
              onRefresh: () async {
                await notifier.refresh(status: state.status, mode: widget.mode);
                _refreshController.refreshCompleted();
                if (!ref.read(transportListProvider).hasMore) {
                  _refreshController.loadNoData();
                }
              },
              onLoading: () async {
                await notifier.loadMore();
                if (ref.read(transportListProvider).hasMore) {
                  _refreshController.loadComplete();
                } else {
                  _refreshController.loadNoData();
                }
              },
              child: state.items.isEmpty
                  ? _buildEmptyState(context, l10n)
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _TransportCard(
                          item: item,
                          mode: widget.mode,
                          l10n: l10n,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TransportDetailPage(
                                transferNo: item.transferNo,
                                mode: widget.mode,
                                status: item.status,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              widget.mode == TransportMode.issue
                  ? 'assets/android/mipmap-xxhdpi/icon_empty_device_issue.png'
                  : 'assets/android/mipmap-xxhdpi/icon_empty_receive_device.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deviceIssueEmpty,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
              ),
            ),
            if (widget.mode == TransportMode.issue && _selectedTabIndex == 0) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 44,
                child: FilledButton.icon(
                  onPressed: () => _showDeviceTypeSheet(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.deviceIssueCreate),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index, TransportListNotifier notifier) {
    setState(() => _selectedTabIndex = index);
    notifier.refresh(status: _mapStatus(index), mode: widget.mode);
  }

  Future<void> _showDeviceTypeSheet(BuildContext context) async {
    final deviceType = await DeviceTypeSheet.show(context);
    if (deviceType == null || !context.mounted) return;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransportCreatePage(deviceType: deviceType),
      ),
    );
    if (created == true) {
      ref.read(transportListProvider.notifier).refresh(
            status: _mapStatus(_selectedTabIndex),
            mode: widget.mode,
          );
    }
  }

  int? _mapStatus(int index) {
    switch (index) {
      case 0:
        return null;
      case 1:
        return 0;
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 3;
      default:
        return null;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEEF7E9) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFFE5E5E5),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0xFF666666),
                fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransportCard extends StatelessWidget {
  const _TransportCard({
    required this.item,
    required this.mode,
    required this.l10n,
    required this.onTap,
  });

  final dynamic item;
  final TransportMode mode;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColors = _getStatusColors(item.status);
    final withdrawnNum =
        (item.deviceNum - item.inTransitNum - item.receivedNum)
            .clamp(0, item.deviceNum);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部：订单号 + 箭头
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.transferNo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFCCCCCC),
                    size: 20,
                  ),
                ],
              ),
            ),
            // 标签行
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatusTag(
                    label: _getStatusLabel(item.status),
                    textColor: statusColors.text,
                    backgroundColor: statusColors.background,
                  ),
                  const SizedBox(width: 8),
                  _StatusTag(
                    label: _getDeviceTypeLabel(item.deviceType),
                    textColor: const Color(0xFF666666),
                    backgroundColor: const Color(0xFFF5F5F5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, indent: 16, endIndent: 16),
            // 仓库信息
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_issue_warehouse.webp',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        item.inWarehouseName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 统计行
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  _MetricItem(
                    label: l10n.deviceIssueQuantity,
                    value: item.deviceNum.toString(),
                  ),
                  _MetricItem(
                    label: l10n.deviceIssueReceived,
                    value: item.receivedNum.toString(),
                  ),
                  _MetricItem(
                    label: l10n.deviceIssueWithdrawn,
                    value: withdrawnNum.toString(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 0:
        return l10n.deviceIssueStatusInTransit;
      case 1:
        return l10n.deviceIssueStatusReceiveAll;
      case 2:
        return l10n.deviceIssueStatusPartial;
      case 3:
        return l10n.deviceIssueStatusWithdrawn;
      default:
        return '-';
    }
  }

  String _getDeviceTypeLabel(int? type) {
    switch (type) {
      case 1:
        return l10n.warehouseDeviceTypeBattery;
      case 2:
        return l10n.warehouseDeviceTypeVehicle;
      case 3:
        return l10n.warehouseDeviceTypeStation;
      default:
        return '-';
    }
  }

  _StatusColors _getStatusColors(int status) {
    switch (status) {
      case 0: // In transit - orange
        return const _StatusColors(
          text: Color(0xFFED942F),
          background: Color(0xFFFEF7EA),
        );
      case 1: // Receive all - green
        return const _StatusColors(
          text: AppColors.primaryColor,
          background: Color(0xFFEEF7E9),
        );
      case 2: // Partial - blue
        return const _StatusColors(
          text: Color(0xFF2196F3),
          background: Color(0xFFE3F2FD),
        );
      case 3: // Withdrawn - red
        return const _StatusColors(
          text: Color(0xFFE25C5C),
          background: Color(0xFFFDECEC),
        );
      default:
        return const _StatusColors(
          text: Color(0xFF999999),
          background: Color(0xFFF5F5F5),
        );
    }
  }
}

class _StatusColors {
  const _StatusColors({required this.text, required this.background});
  final Color text;
  final Color background;
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
