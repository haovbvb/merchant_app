import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/device_type_sheet.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/features/work/warehouse/inventory_detail_page_new.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InventoryListPageNew extends ConsumerStatefulWidget {
  const InventoryListPageNew({super.key});

  @override
  ConsumerState<InventoryListPageNew> createState() =>
      _InventoryListPageNewState();
}

class _InventoryListPageNewState extends ConsumerState<InventoryListPageNew> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  final TextEditingController _searchController = TextEditingController();

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(inventoryListProvider);
    final notifier = ref.read(inventoryListProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.inventoryCountTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.black87),
            onPressed: () => _showCreateSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.inventorySearchHint,
                  hintStyle: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (value) {
                  notifier.refresh(
                    status: _mapStatus(_selectedTabIndex),
                    keyword: value,
                  );
                },
              ),
            ),
          ),

          // Tab 栏
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                _buildTabChip(0, l10n.warehouseTabAll),
                const SizedBox(width: 8),
                _buildTabChip(1, l10n.warehouseTabCompleted),
                const SizedBox(width: 8),
                _buildTabChip(2, l10n.warehouseTabUnfinished),
                const SizedBox(width: 8),
                _buildTabChip(3, l10n.warehouseTabRevoked),
              ],
            ),
          ),

          // 列表内容
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              enablePullUp: state.hasMore,
              onRefresh: () async {
                await notifier.refresh(status: _mapStatus(_selectedTabIndex));
                _refreshController.refreshCompleted();
              },
              onLoading: () async {
                await notifier.loadMore();
                if (ref.read(inventoryListProvider).hasMore) {
                  _refreshController.loadComplete();
                } else {
                  _refreshController.loadNoData();
                }
              },
              child: state.items.isEmpty && !state.loading
                  ? _buildEmptyState(l10n)
                  : _buildListContent(l10n, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        ref
            .read(inventoryListProvider.notifier)
            .refresh(status: _mapStatus(index));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFDDDDDD),
          ),
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            l10n.inventoryEmptyHint,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 48,
            child: FilledButton.icon(
              onPressed: () => _showCreateSheet(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.warehouseTransportCreateAction),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(AppLocalizations l10n, InventoryListState state) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _InventoryCard(
          inventoryNo: item.inventoryNo ?? '-',
          warehouseName: item.warehouseName ?? '-',
          deviceType: _deviceTypeLabel(l10n, item.deviceType),
          stock: item.stock ?? 0,
          inventory: item.inventory ?? 0,
          status: item.status ?? 0,
          statusLabel: _inventoryStatusLabel(l10n, item.status),
          onTap: () => _goToDetail(item.inventoryNo ?? ''),
        );
      },
    );
  }

  void _goToDetail(String inventoryNo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InventoryDetailPageNew(inventoryNo: inventoryNo),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context) async {
    final deviceType = await DeviceTypeSheet.show(context);

    if (deviceType == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InventoryDetailPageNew.create(deviceType: deviceType),
      ),
    );
    ref
        .read(inventoryListProvider.notifier)
        .refresh(status: _mapStatus(_selectedTabIndex));
  }

  int? _mapStatus(int index) {
    switch (index) {
      case 0:
        return null;
      case 1:
        return 1; // Completed
      case 2:
        return 0; // Unfinished
      case 3:
        return 2; // Revoked
      default:
        return null;
    }
  }

  String _deviceTypeLabel(AppLocalizations l10n, int? type) {
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

  String _inventoryStatusLabel(AppLocalizations l10n, int? status) {
    switch (status) {
      case 0:
        return l10n.warehouseInventoryStatusUnfinished;
      case 1:
        return l10n.warehouseInventoryStatusCompleted;
      case 2:
        return l10n.warehouseInventoryStatusRevoked;
      default:
        return '-';
    }
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.inventoryNo,
    required this.warehouseName,
    required this.deviceType,
    required this.stock,
    required this.inventory,
    required this.status,
    required this.statusLabel,
    required this.onTap,
  });

  final String inventoryNo;
  final String warehouseName;
  final String deviceType;
  final int stock;
  final int inventory;
  final int status;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            // 单号和状态
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        inventoryNo,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF999999),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),

            // 仓库信息
            Row(
              children: [
                const Icon(
                  Icons.home_work_outlined,
                  size: 18,
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 8),
                Text(
                  warehouseName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black06Text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Device / Stock / Inventory
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        deviceType,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$stock',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inventory',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$inventory',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color textColor;
    Color bgColor;

    switch (status) {
      case 1: // Completed
        textColor = AppColors.primaryColor;
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 2: // Revoked
        textColor = const Color(0xFFE53935);
        bgColor = const Color(0xFFFFEBEE);
        break;
      default: // Unfinished
        textColor = const Color(0xFFF57C00);
        bgColor = const Color(0xFFFFF3E0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
