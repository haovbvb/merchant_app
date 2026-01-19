import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
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

class _TransportListPageState extends ConsumerState<TransportListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transportListProvider.notifier).refresh(mode: widget.mode);
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
    final state = ref.watch(transportListProvider);
    final notifier = ref.read(transportListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouseTransportTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransportSearchPage(mode: widget.mode),
                ),
              );
            },
          ),
          if (widget.mode == TransportMode.issue)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final deviceType = await _showDeviceTypeSheet(context);
                if (deviceType == null || !context.mounted) return;
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => TransportCreatePage(deviceType: deviceType),
                  ),
                );
                if (created == true) {
                  await notifier.refresh(status: state.status, mode: widget.mode);
                }
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          onTap: (index) {
            notifier.refresh(status: _mapStatus(index), mode: widget.mode);
          },
          tabs: [
            Tab(text: l10n.warehouseTabAll),
            Tab(text: l10n.warehouseTransportTabInTransit),
            Tab(text: l10n.warehouseTransportTabReceived),
            Tab(text: l10n.warehouseTransportTabPartial),
            Tab(text: l10n.warehouseTransportTabWithdrawn),
          ],
        ),
      ),
      body: SmartRefresher(
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
          ? _TransportEmptyState(
            text: l10n.warehouseTransportEmpty,
            iconPath: widget.mode == TransportMode.issue
              ? 'assets/android/mipmap-xxhdpi/icon_empty_device_issue.png'
              : 'assets/android/mipmap-xxhdpi/icon_empty_receive_device.png',
            )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  final recallNum =
                      (item.deviceNum - item.inTransitNum - item.receivedNum)
                          .clamp(0, item.deviceNum);
                  final statusColors = _statusColors(context, item.status);
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TransportDetailPage(
                          transferNo: item.transferNo,
                          mode: widget.mode,
                          status: item.status,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.transferNo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _StatusChip(
                                label:
                                    _transportStatusLabel(l10n, item.status),
                                textColor: statusColors.text,
                                backgroundColor: statusColors.background,
                              ),
                              _StatusChip(
                                label: _deviceTypeLabel(l10n, item.deviceType),
                                textColor: const Color(0x990C0C0D),
                                backgroundColor: const Color(0xFFF2F4F7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade200, height: 1),
                          const SizedBox(height: 12),
                          Text(
                            '${l10n.warehouseTransportFrom}: ${item.outWarehouseName}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${l10n.warehouseTransportTo}: ${item.inWarehouseName}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (item.trackingNumber.trim().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              '${l10n.warehouseTransportTrackingNumber}: ${item.trackingNumber}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _MetricColumn(
                                label: l10n.warehouseTransportCountLabel,
                                value: item.deviceNum.toString(),
                              ),
                              _MetricColumn(
                                label: l10n.warehouseTransportReceivedLabel,
                                value: item.receivedNum.toString(),
                              ),
                              _MetricColumn(
                                label: l10n.warehouseTransportWithdrawLabel,
                                value: recallNum.toString(),
                              ),
                            ],
                          ),
                        ],
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

  String _transportStatusLabel(AppLocalizations l10n, int status) {
    switch (status) {
      case 0:
        return l10n.warehouseTransportStatusInTransit;
      case 1:
        return l10n.warehouseTransportStatusReceived;
      case 2:
        return l10n.warehouseTransportStatusPartial;
      case 3:
        return l10n.warehouseTransportStatusWithdrawn;
      default:
        return '-';
    }
  }
}

class _StatusColors {
  const _StatusColors({required this.text, required this.background});

  final Color text;
  final Color background;
}

_StatusColors _statusColors(BuildContext context, int status) {
  switch (status) {
    case 0:
      return const _StatusColors(
        text: Color(0xFFED942F),
        background: Color(0xFFFEF7EA),
      );
    case 1:
      return _StatusColors(
        text: Theme.of(context).colorScheme.primary,
        background: const Color(0xFFEEF7E9),
      );
    case 2:
      return const _StatusColors(
        text: Color(0xFF2F7FEA),
        background: Color(0xFFF0F7FF),
      );
    case 3:
      return const _StatusColors(
        text: Color(0xFF8C8C8C),
        background: Color(0xFFF2F4F7),
      );
    default:
      return const _StatusColors(
        text: Color(0xFF8C8C8C),
        background: Color(0xFFF2F4F7),
      );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
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

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

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
              color: Color(0x800C0C0D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0C0C0D),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportEmptyState extends StatelessWidget {
  const _TransportEmptyState({
    required this.text,
    required this.iconPath,
  });

  final String text;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 160,
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
