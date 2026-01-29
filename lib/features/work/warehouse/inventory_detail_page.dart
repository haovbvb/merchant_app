import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/qrcode/qr_batch_scan_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InventoryDetailPage extends ConsumerStatefulWidget {
  const InventoryDetailPage({
    super.key,
    this.inventoryNo,
    this.deviceType,
    this.createMode = false,
  });

  factory InventoryDetailPage.create({required int deviceType}) {
    return InventoryDetailPage(deviceType: deviceType, createMode: true);
  }
  final String? inventoryNo;
  final int? deviceType;
  final bool createMode;

  @override
  ConsumerState<InventoryDetailPage> createState() =>
      _InventoryDetailPageState();
}

class _InventoryDetailPageState extends ConsumerState<InventoryDetailPage> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(inventoryDetailProvider.notifier);
      if (widget.createMode && widget.deviceType != null) {
        notifier.startInventory(widget.deviceType!);
      } else if ((widget.inventoryNo ?? '').isNotEmpty) {
        notifier.loadDetail(widget.inventoryNo ?? '');
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(inventoryDetailProvider);
    final notifier = ref.read(inventoryDetailProvider.notifier);
    final detail = state.detail;
    final canOperate = detail?.status == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.warehouseInventoryDetailTitle),
        actions: [
          if (canOperate)
            IconButton(
              icon: AppIcons.scanIcon(),
              onPressed: () => _scanWithCamera(context, notifier),
            ),
          if (canOperate)
            IconButton(
              icon: const Icon(Icons.playlist_add),
              tooltip: l10n.qrcodeBatchScan,
              onPressed: () => _openBatchScan(context, notifier),
            ),
        ],
      ),
      body: state.loading && detail == null
          ? const Center(child: CircularProgressIndicator())
          : SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: state.hasMore,
        onRefresh: () async {
          if ((state.inventoryNo).isNotEmpty) {
            await notifier.loadDetail(state.inventoryNo);
          }
          _refreshController.refreshCompleted();
          if (!ref.read(inventoryDetailProvider).hasMore) {
            _refreshController.loadNoData();
          }
        },
        onLoading: () async {
          await notifier.loadMore();
          if (ref.read(inventoryDetailProvider).hasMore) {
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _InfoTile(
              label: l10n.warehouseInventoryNoLabel,
              value: detail?.inventoryNo ??
                  (state.inventoryNo.isNotEmpty ? state.inventoryNo : '-'),
            ),
            _InfoTile(
              label: l10n.warehouseInventoryWarehouseLabel,
              value: detail?.warehouseName ?? '-',
            ),
            _InfoTile(
              label: l10n.warehouseInventoryTypeLabel,
              value: _deviceTypeLabel(l10n, detail?.deviceType),
            ),
            _InfoTile(
              label: l10n.warehouseInventoryStatusLabel,
              value: _inventoryStatusLabel(l10n, detail?.status),
            ),
            const SizedBox(height: 12),
            if (canOperate)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _manualController,
                      decoration: InputDecoration(
                        hintText: l10n.warehouseInventoryManualInputHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _scanManual(context, notifier),
                    child: Text(l10n.warehouseInventoryScanManual),
                  ),
                ],
              ),
            if (canOperate) const SizedBox(height: 12),
            if (canOperate)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: detail?.inventoryNo == null
                          ? null
                          : () async {
                              final confirm = await _confirmAction(
                                context,
                                title: l10n.warehouseInventoryRevokeConfirmTitle,
                                message:
                                    l10n.warehouseInventoryRevokeConfirmDesc,
                              );
                              if (confirm == true) {
                                await notifier.revokeInventory();
                              }
                            },
                      child: Text(l10n.warehouseInventoryRevoke),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: detail?.inventoryNo == null
                          ? null
                          : () async {
                              final confirm = await _confirmAction(
                                context,
                                title:
                                    l10n.warehouseInventoryCompleteConfirmTitle,
                                message:
                                    l10n.warehouseInventoryCompleteConfirmDesc,
                              );
                              if (confirm == true) {
                                await notifier.completeInventory();
                              }
                            },
                      child: Text(l10n.warehouseInventoryComplete),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              l10n.warehouseInventoryDetailListTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (state.items.isEmpty)
              _EmptyCard(text: l10n.warehouseInventoryDetailEmpty)
            else
              ...state.items.map(
                (item) => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.deviceSn,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        _scanStatusChip(context, l10n, item.status),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanWithCamera(
    BuildContext context,
    InventoryDetailNotifier notifier,
  ) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          parseDeviceSn: true,
          deviceType: ref.read(inventoryDetailProvider).detail?.deviceType ??
              ref.read(inventoryDetailProvider).deviceType,
        ),
      ),
    );
    if (result == null || result.isEmpty) return;
    final code = await notifier.scanInventory(result);
    if (!mounted) return;
    _showScanResult(context, context.l10n, code);
  }

  Future<void> _scanManual(
    BuildContext context,
    InventoryDetailNotifier notifier,
  ) async {
    final value = _manualController.text.trim();
    if (value.isEmpty) return;
    final code = await notifier.scanInventory(value);
    if (!mounted) return;
    _manualController.clear();
    _showScanResult(context, context.l10n, code);
  }

  Future<void> _openBatchScan(
    BuildContext context,
    InventoryDetailNotifier notifier,
  ) async {
    final state = ref.read(inventoryDetailProvider);
    final existing = state.items.map((item) => item.deviceSn).toList();
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => QrBatchScanPage(
          initialItems: existing,
          fixedDeviceType: state.detail?.deviceType ?? state.deviceType,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    for (final sn in result) {
      await notifier.scanInventory(sn);
    }
    if (!mounted) return;
    _showSnack(context, context.l10n.warehouseInventoryBatchComplete);
  }

  Future<bool?> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showScanResult(
    BuildContext context,
    AppLocalizations l10n,
    int? result,
  ) {
    if (result == 1) {
      _showSnack(context, l10n.warehouseInventoryScanSuccess);
    } else if (result == 2) {
      _showSnack(context, l10n.warehouseInventoryScanRepeat);
    } else if (result != null) {
      _showSnack(context, l10n.warehouseInventoryScanFailed);
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

  String _scanStatusLabel(AppLocalizations l10n, int status) {
    switch (status) {
      case 1:
        return l10n.warehouseInventoryScanStatusScanned;
      case 2:
        return l10n.warehouseInventoryScanStatusSurplus;
      default:
        return l10n.warehouseInventoryScanStatusPending;
    }
  }

  Widget _scanStatusChip(
    BuildContext context,
    AppLocalizations l10n,
    int status,
  ) {
    final label = _scanStatusLabel(l10n, status);
    final colors = _scanStatusColors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: colors.text),
      ),
    );
  }

  _StatusColors _scanStatusColors(int status) {
    switch (status) {
      case 1:
        return const _StatusColors(
          text: Color(0xFF00B88A),
          background: Color(0xFFE9F7F2),
          border: Color(0xFF00B88A),
        );
      case 2:
        return const _StatusColors(
          text: Color(0xFFF49300),
          background: Color(0xFFFFF2E0),
          border: Color(0xFFF49300),
        );
      default:
        return const _StatusColors(
          text: Color(0xFF7A7A7A),
          background: Color(0xFFF2F2F2),
          border: Color(0xFFBDBDBD),
        );
    }
  }
}

class _StatusColors {
  const _StatusColors({
    required this.text,
    required this.background,
    required this.border,
  });

  final Color text;
  final Color background;
  final Color border;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text),
      ),
    );
  }
}
