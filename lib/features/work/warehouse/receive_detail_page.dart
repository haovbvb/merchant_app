import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/receive_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class ReceiveDetailPage extends ConsumerStatefulWidget {
  const ReceiveDetailPage({super.key, required this.transferNo, this.status});

  final String transferNo;
  final int? status;

  @override
  ConsumerState<ReceiveDetailPage> createState() => _ReceiveDetailPageState();
}

class _ReceiveDetailPageState extends ConsumerState<ReceiveDetailPage> {
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.transferNo.isNotEmpty) {
        ref.read(receiveDetailProvider.notifier).loadDetail(widget.transferNo);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(receiveDetailProvider);
    final detail = state.detail;
    final notifier = ref.read(receiveDetailProvider.notifier);
    final totalCount = state.total > 0 ? state.total : state.items.length;

    // Android 接收详情页始终展示扫码入口；具体操作按钮仍按 item 状态控制
    const canReceive = true;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanged) {
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          title: Text(l10n.deviceReceiveDetailTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_hasChanged),
          ),
        ),
        body: state.loading
            ? const Center(child: SizedBox.shrink())
            : NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 120) {
                    notifier.loadMoreDetail();
                  }
                  return false;
                },
                child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 订单头部卡片
                    _OrderHeaderCard(
                      detail: detail,
                      transferNo: widget.transferNo,
                      l10n: l10n,
                    ),
                    // 物流单号
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2196F3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.deviceIssueTrackingNumber,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (detail?.trackingNumber.isNotEmpty ?? false)
                                  ? detail!.trackingNumber
                                  : '',
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 设备列表
                    _DeviceListSection(
                      detail: detail,
                      items: state.items,
                      totalCount: totalCount,
                      loadingMore: state.loadingMore,
                      l10n: l10n,
                      canReceive: canReceive,
                      onScanToReceive: () => _navigateToScan(context),
                      onReceive: (sn) => _handleReceive(context, sn),
                      onWithdraw: (sn) => _handleWithdraw(context, sn),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ),
      ),
    );
  }

  Future<void> _navigateToScan(BuildContext context) async {
    final detail = ref.read(receiveDetailProvider).detail;
    final sn = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          allowManualInput: true,
          parseDeviceSn: true,
          deviceType: detail?.deviceType,
        ),
      ),
    );
    if (sn != null && sn.isNotEmpty && mounted) {
      await _handleReceive(context, sn);
    }
  }

  Future<void> _handleReceive(BuildContext context, String deviceSn) async {
    final result = await ref
        .read(receiveDetailProvider.notifier)
        .receiveDevice(deviceSn);
    if (mounted && context.mounted) {
      if (result.success) {
        _hasChanged = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppColors.primaryColor : Colors.red,
        ),
      );

      if (result.success) {
        final listState = ref.read(receiveListProvider);
        ref.read(receiveListProvider.notifier).refresh(
              status: listState.status,
              resetStatus: listState.status == null,
              keyword: listState.keyword,
            );
      }
    }
  }

  Future<void> _handleWithdraw(BuildContext context, String deviceSn) async {
    final success = await ref
        .read(receiveDetailProvider.notifier)
        .withdrawDevice(deviceSn);
    if (mounted && context.mounted) {
      if (success) {
        _hasChanged = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Withdrawn successfully' : 'Withdraw failed'),
          backgroundColor: success ? AppColors.primaryColor : Colors.red,
        ),
      );
    }
  }
}

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({
    required this.detail,
    required this.transferNo,
    required this.l10n,
  });

  final DeviceTransportDetail? detail;
  final String transferNo;
  final AppLocalizations l10n;

  String _formatTimestamp(int? timestamp) {
    return DateFormatUtils.formatTimestamp(
      timestamp,
      pattern: DateFormatUtils.defaultPattern,
      fallback: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final outWarehouseName = _formatWarehouseName(
      detail?.outWarehouseName ?? '',
      l10n,
    );
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 头部：订单号和日期
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    detail?.transferNo ?? transferNo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatTimestamp(detail?.sendTime),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 仓库信息
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // 发出仓库
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFED942F),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: const Color(0xFFE5E5E5),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.deviceIssueWarehouse,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            outWarehouseName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black06Text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // 接收仓库
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.deviceReceiveWarehouse,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            detail?.inWarehouseName ?? '',
                            style: const TextStyle(
                              fontSize: 14,
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
        ],
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

class _DeviceListSection extends StatelessWidget {
  const _DeviceListSection({
    required this.detail,
    required this.items,
    required this.totalCount,
    required this.loadingMore,
    required this.l10n,
    required this.canReceive,
    required this.onScanToReceive,
    required this.onReceive,
    required this.onWithdraw,
  });

  final DeviceTransportDetail? detail;
  final List<DeviceTransportDetailPageData> items;
  final int totalCount;
  final bool loadingMore;
  final AppLocalizations l10n;
  final bool canReceive;
  final VoidCallback onScanToReceive;
  final void Function(String) onReceive;
  final void Function(String) onWithdraw;

  String _getDeviceTypeName() {
    switch (detail?.deviceType) {
      case 1:
        return l10n.warehouseDeviceTypeBattery;
      case 2:
        return l10n.warehouseDeviceTypeVehicle;
      case 3:
        return l10n.warehouseDeviceTypeStation;
      default:
        return l10n.warehouseDeviceTypeBattery;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 设备类型标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '${_getDeviceTypeName()} ($totalCount)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // 统计栏
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _StatItem(
                  label: l10n.deviceIssueStatusInTransit,
                  value: detail?.inTransitNum.toString() ?? '0',
                ),
                _StatItem(
                  label: l10n.deviceIssueReceived,
                  value: detail?.receivedNum.toString() ?? '0',
                ),
                _StatItem(
                  label: l10n.deviceIssueWithdrawn,
                  value: detail?.withdrawNum.toString() ?? '0',
                ),
              ],
            ),
          ),
          // 扫码接收按钮
          if (canReceive)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: onScanToReceive,
                  icon: AppIcons.scanIcon(size: 18, color: Colors.white),
                  label: Text(l10n.deviceReceiveScanToReceive),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          // 设备列表
          ...items.map(
            (item) => _DeviceItem(
              item: item,
              l10n: l10n,
              canOperate: canReceive,
              onReceive: onReceive,
              onWithdraw: onWithdraw,
            ),
          ),
          if (loadingMore)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({
    required this.item,
    required this.l10n,
    required this.canOperate,
    required this.onReceive,
    required this.onWithdraw,
  });

  final DeviceTransportDetailPageData item;
  final AppLocalizations l10n;
  final bool canOperate;
  final void Function(String) onReceive;
  final void Function(String) onWithdraw;

  (String, Color) _getStatusInfo() {
    switch (item.status) {
      case 0:
        return (l10n.deviceIssueStatusInTransit, const Color(0xFFED942F));
      case 1:
        return (l10n.deviceIssueReceived, AppColors.primaryColor);
      case 2:
        return (l10n.deviceIssueWithdrawn, const Color(0xFFE25C5C));
      default:
        return (l10n.deviceIssueStatusInTransit, const Color(0xFFED942F));
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusText, statusColor) = _getStatusInfo();
    final isInTransit = item.status == 0;
    final opTimeText = DateFormatUtils.formatString(
      item.opTime,
      pattern: DateFormatUtils.defaultPattern,
      fallback: '',
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.deviceSn,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (opTimeText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        opTimeText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 12, color: statusColor),
                ),
              ),
            ],
          ),
          // 操作按钮（仅在途状态显示）
          if (canOperate && isInTransit)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => onWithdraw(item.deviceSn),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: const Color(0xE6000000),
                        side: const BorderSide(color: Color(0x66000000)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: Text(l10n.deviceReceiveWithdraw),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => onReceive(item.deviceSn),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        foregroundColor: const Color(0xE6000000),
                        side: const BorderSide(color: Color(0x66000000)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: Text(l10n.deviceReceiveAction),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
