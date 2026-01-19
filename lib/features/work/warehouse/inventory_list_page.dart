import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/features/work/warehouse/inventory_detail_page.dart';
import 'package:merchant_app/features/work/warehouse/inventory_search_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InventoryListPage extends ConsumerStatefulWidget {
  const InventoryListPage({super.key});

  @override
  ConsumerState<InventoryListPage> createState() => _InventoryListPageState();
}

class _InventoryListPageState extends ConsumerState<InventoryListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inventoryListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(inventoryListProvider);
    final notifier = ref.read(inventoryListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouseInventoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const InventorySearchPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final deviceType = await _showDeviceTypeSheet(context);
              if (deviceType == null || !context.mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InventoryDetailPage.create(
                    deviceType: deviceType,
                  ),
                ),
              );
              await notifier.refresh(status: state.status);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            final status = _mapStatus(index);
            notifier.refresh(status: status);
          },
          tabs: [
            Tab(text: l10n.warehouseTabAll),
            Tab(text: l10n.warehouseTabCompleted),
            Tab(text: l10n.warehouseTabUnfinished),
            Tab(text: l10n.warehouseTabRevoked),
          ],
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: state.hasMore,
        onRefresh: () async {
          await notifier.refresh(status: state.status);
          _refreshController.refreshCompleted();
          if (!state.hasMore) {
            _refreshController.loadNoData();
          }
        },
        onLoading: () async {
          await notifier.loadMore();
          if (ref.read(inventoryListProvider).hasMore) {
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
          }
        },
        child: state.items.isEmpty
            ? _InventoryEmptyState(text: l10n.warehouseInventoryEmpty)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.inventoryNo ?? '-'),
                      subtitle: Text(
                        '${l10n.warehouseInventoryWarehouseLabel}: ${item.warehouseName ?? '-'}\n'
                        '${l10n.warehouseInventoryTypeLabel}: ${_deviceTypeLabel(l10n, item.deviceType)}\n'
                        '${l10n.warehouseInventoryStatusLabel}: ${_inventoryStatusLabel(l10n, item.status)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => InventoryDetailPage(
                            inventoryNo: item.inventoryNo ?? '',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<int?> _showDeviceTypeSheet(BuildContext context) async {
    final l10n = context.l10n;
    return showModalBottomSheet<int>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.warehouseDeviceTypeBattery),
                onTap: () => Navigator.of(context).pop(1),
              ),
              ListTile(
                title: Text(l10n.warehouseDeviceTypeVehicle),
                onTap: () => Navigator.of(context).pop(2),
              ),
              ListTile(
                title: Text(l10n.warehouseDeviceTypeStation),
                onTap: () => Navigator.of(context).pop(3),
              ),
            ],
          ),
        );
      },
    );
  }

  int? _mapStatus(int index) {
    switch (index) {
      case 0:
        return null;
      case 1:
        return 1;
      case 2:
        return 0;
      case 3:
        return 2;
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

class _InventoryEmptyState extends StatelessWidget {
  const _InventoryEmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text),
    );
  }
}
