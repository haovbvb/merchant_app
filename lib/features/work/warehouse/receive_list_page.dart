import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
import 'package:merchant_app/features/work/warehouse/receive_controller.dart';
import 'package:merchant_app/features/work/warehouse/receive_detail_page.dart';
import 'package:merchant_app/features/work/warehouse/receive_search_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ReceiveListPage extends ConsumerStatefulWidget {
  const ReceiveListPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  ConsumerState<ReceiveListPage> createState() => _ReceiveListPageState();
}

class _ReceiveListPageState extends ConsumerState<ReceiveListPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiveListProvider.notifier).refresh(
            keyword: '',
            resetStatus: true,
          );
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
    final state = ref.watch(receiveListProvider);
    final notifier = ref.read(receiveListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(l10n.deviceReceiveTitle),
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReceiveSearchPage(),
                  ),
                );
                // 从搜索页返回时，清空关键字并刷新列表
                ref.read(receiveListProvider.notifier).refresh(
                      status: _mapStatus(_selectedTabIndex),
                      keyword: '',
                    );
              },
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
                      l10n.deviceReceiveSearchHint,
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
                await notifier.refresh(
                  status: state.status,
                  resetStatus: state.status == null,
                );
                _refreshController.refreshCompleted();
                if (!ref.read(receiveListProvider).hasMore) {
                  _refreshController.loadNoData();
                }
              },
              onLoading: () async {
                await notifier.loadMore();
                if (ref.read(receiveListProvider).hasMore) {
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
                        return _ReceiveCard(
                          item: item,
                          l10n: l10n,
                          onTap: () => _navigateToDetail(item),
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
              'assets/android/mipmap-xxhdpi/icon_empty_receive_device.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deviceReceiveEmpty,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(int index, ReceiveListNotifier notifier) {
    setState(() => _selectedTabIndex = index);
    final status = _mapStatus(index);
    notifier.refresh(status: status, resetStatus: status == null);
  }

  void _navigateToDetail(DeviceTransport item) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReceiveDetailPage(
          transferNo: item.transferNo,
          status: item.status,
        ),
      ),
    );
    if (result == true) {
      final status = _mapStatus(_selectedTabIndex);
      ref.read(receiveListProvider.notifier).refresh(
            status: status,
            resetStatus: status == null,
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F5E9) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primaryColor : const Color(0xFFE5E5E5),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: selected ? AppColors.primaryColor : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiveCard extends StatelessWidget {
  const _ReceiveCard({
    required this.item,
    required this.l10n,
    required this.onTap,
  });

  final DeviceTransport item;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final warehouseName = _formatWarehouseName(item.outWarehouseName, l10n);
    final recallNum = item.deviceNum - item.inTransitNum - item.receivedNum;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单号和箭头
            Row(
              children: [
                Text(
                  item.transferNo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFF999999),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 状态标签
            Row(
              children: [
                _StatusTag(status: item.status, l10n: l10n),
                const SizedBox(width: 8),
                _DeviceTypeTag(deviceType: item.deviceType, l10n: l10n),
              ],
            ),
            const SizedBox(height: 12),
            // 仓库信息
            Row(
              children: [
                Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_device_issuse_state.png',
                  width: 16,
                  height: 16,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.home_outlined,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    warehouseName,
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
            const SizedBox(height: 12),
            // 数量统计
            Row(
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
                  value: (recallNum >= 0 ? recallNum : 0).toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatWarehouseName(String name, AppLocalizations l10n) {
    if (name.trim().isEmpty) return '-';
    if (name.toLowerCase().contains('platform')) {
      return l10n.commonPlatform;
    }
    return name;
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.status, required this.l10n});

  final int status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (text, color) = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo() {
    switch (status) {
      case 0:
        return (l10n.deviceIssueStatusInTransit, const Color(0xFFED942F));
      case 1:
        return (l10n.deviceIssueStatusReceiveAll, AppColors.primaryColor);
      case 2:
        return (l10n.deviceIssueStatusPartial, const Color(0xFF2196F3));
      case 3:
        return (l10n.deviceIssueStatusWithdrawn, const Color(0xFFE25C5C));
      default:
        return (l10n.deviceIssueStatusInTransit, const Color(0xFFED942F));
    }
  }
}

class _DeviceTypeTag extends StatelessWidget {
  const _DeviceTypeTag({required this.deviceType, required this.l10n});

  final int deviceType;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    String text;
    switch (deviceType) {
      case 1:
        text = l10n.warehouseDeviceTypeBattery;
        break;
      case 2:
        text = l10n.warehouseDeviceTypeVehicle;
        break;
      case 3:
        text = l10n.warehouseDeviceTypeStation;
        break;
      default:
        text = l10n.warehouseDeviceTypeBattery;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
