import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/inventory_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class InventoryDetailPageNew extends ConsumerStatefulWidget {
  const InventoryDetailPageNew({
    super.key,
    this.inventoryNo,
    this.deviceType,
    this.createMode = false,
  });

  factory InventoryDetailPageNew.create({required int deviceType}) {
    return InventoryDetailPageNew(deviceType: deviceType, createMode: true);
  }

  final String? inventoryNo;
  final int? deviceType;
  final bool createMode;

  @override
  ConsumerState<InventoryDetailPageNew> createState() =>
      _InventoryDetailPageNewState();
}

class _InventoryDetailPageNewState
    extends ConsumerState<InventoryDetailPageNew> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(inventoryDetailProvider);
    final notifier = ref.read(inventoryDetailProvider.notifier);
    final detail = state.detail;
    final canOperate = detail?.status == 0 || widget.createMode;
    final isCreateMode = widget.createMode && detail?.inventoryNo == null;

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
          isCreateMode ? l10n.inventoryCreateTitle : l10n.inventoryDetailTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: state.hasMore,
        onRefresh: () async {
          if (state.inventoryNo.isNotEmpty) {
            await notifier.loadDetail(state.inventoryNo);
          }
          _refreshController.refreshCompleted();
        },
        onLoading: () async {
          await notifier.loadMore();
          if (ref.read(inventoryDetailProvider).hasMore) {
            _refreshController.loadComplete();
          } else {
            _refreshController.loadNoData();
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部信息卡片
              _buildHeaderCard(l10n, detail, state),

              const SizedBox(height: 16),

              // Battery 区域
              _buildBatterySection(l10n, detail, state, canOperate),

              const SizedBox(height: 16),

              // 设备列表
              _buildDeviceList(l10n, state),
            ],
          ),
        ),
      ),
      bottomNavigationBar: canOperate
          ? _buildBottomBar(l10n, detail, notifier)
          : null,
    );
  }

  Widget _buildHeaderCard(
    AppLocalizations l10n,
    dynamic detail,
    InventoryDetailState state,
  ) {
    // 详情模式显示绿色头部
    if (!widget.createMode && detail != null) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 单号和日期
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    detail.inventoryNo ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    detail.createTime ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 仓库信息
            Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.home_work,
                      color: Color(0xFF2196F3),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.warehouseName ?? '-',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black06Text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${detail.warehouseAddress ?? ''} | ${_warehouseTypeLabel(detail.warehouseType)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 创建模式显示仓库卡片
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.home_work,
              color: Color(0xFF2196F3),
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail?.warehouseName ?? l10n.inventorySelectWarehouse,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                if (detail?.warehouseAddress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${detail.warehouseAddress} | ${_warehouseTypeLabel(detail.warehouseType)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatterySection(
    AppLocalizations l10n,
    dynamic detail,
    InventoryDetailState state,
    bool canOperate,
  ) {
    final deviceType = detail?.deviceType ?? state.deviceType ?? 1;
    final deviceLabel = _deviceTypeLabel(l10n, deviceType);
    final stock = detail?.stock ?? 0;
    final inventory = detail?.inventory ?? state.items.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deviceLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
          const SizedBox(height: 16),

          // Stock / Inventory
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Stock',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$stock',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFDDDDDD)),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Inventory',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$inventory',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scan to receive 按钮
          if (canOperate) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => _scanDevice(context),
                icon: AppIcons.scanIcon(color: Colors.white),
                label: Text(l10n.inventoryScanToReceive),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceList(AppLocalizations l10n, InventoryDetailState state) {
    if (state.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: state.items.map((item) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.deviceSn,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ),
                    _buildScanStatusChip(l10n, item.status),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScanStatusChip(AppLocalizations l10n, int status) {
    String label;
    Color textColor;
    Color bgColor;

    switch (status) {
      case 1: // Inventoryed
        label = l10n.inventoryStatusInventoryed;
        textColor = AppColors.primaryColor;
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 2: // Not in stock
        label = l10n.inventoryStatusNotInStock;
        textColor = const Color(0xFFF57C00);
        bgColor = const Color(0xFFFFF3E0);
        break;
      default: // Not counted
        label = l10n.inventoryStatusNotCounted;
        textColor = const Color(0xFF666666);
        bgColor = const Color(0xFFF5F5F5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
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

  Widget _buildBottomBar(
    AppLocalizations l10n,
    dynamic detail,
    InventoryDetailNotifier notifier,
  ) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: detail?.inventoryNo == null
                  ? null
                  : () => _showRevokeConfirm(l10n, notifier),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.black06Text,
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.warehouseInventoryRevoke),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: detail?.inventoryNo == null
                  ? null
                  : () => _showCompleteConfirm(l10n, notifier),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                side: const BorderSide(color: AppColors.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.inventoryCompleted),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanDevice(BuildContext context) async {
    final state = ref.read(inventoryDetailProvider);
    final notifier = ref.read(inventoryDetailProvider.notifier);

    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          parseDeviceSn: true,
          deviceType: state.detail?.deviceType ?? state.deviceType,
        ),
      ),
    );

    if (result == null || result.isEmpty) return;

    final code = await notifier.scanInventory(result);
    if (!mounted) return;

    _showScanResult(context, code);
  }

  void _showScanResult(BuildContext context, int? result) {
    final l10n = context.l10n;
    String message;

    if (result == 1) {
      message = l10n.warehouseInventoryScanSuccess;
    } else if (result == 2) {
      message = l10n.warehouseInventoryScanRepeat;
    } else {
      message = l10n.warehouseInventoryScanFailed;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _showRevokeConfirm(
    AppLocalizations l10n,
    InventoryDetailNotifier notifier,
  ) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      message: l10n.warehouseInventoryRevokeConfirmDesc,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );

    if (confirm) {
      await notifier.revokeInventory();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showCompleteConfirm(
    AppLocalizations l10n,
    InventoryDetailNotifier notifier,
  ) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      message: l10n.warehouseInventoryCompleteConfirmDesc,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );

    if (confirm) {
      await notifier.completeInventory();
      if (mounted) {
        Navigator.of(context).pop();
      }
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
        return 'Battery';
    }
  }

  String _warehouseTypeLabel(int? type) {
    switch (type) {
      case 1:
        return 'Stores';
      case 2:
        return 'Warehouse';
      default:
        return 'Stores';
    }
  }
}
