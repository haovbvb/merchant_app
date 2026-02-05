import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
import 'package:merchant_app/features/work/qrcode/qr_batch_scan_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class TransportDetailPage extends ConsumerStatefulWidget {
  const TransportDetailPage({
    super.key,
    this.transferNo = '',
    this.mode = TransportMode.issue,
    this.status,
  });

  final String transferNo;
  final TransportMode mode;
  final int? status;

  @override
  ConsumerState<TransportDetailPage> createState() =>
      _TransportDetailPageState();
}

class _TransportDetailPageState extends ConsumerState<TransportDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.transferNo.isNotEmpty) {
        ref.read(transportDetailProvider.notifier).loadDetail(
              widget.transferNo,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(transportDetailProvider);
    final notifier = ref.read(transportDetailProvider.notifier);
    final detail = state.detail;
    final canEditTracking = widget.mode == TransportMode.issue &&
        (widget.status == null || (widget.status != 1 && widget.status != 3));

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(l10n.deviceIssueDetailTitle),
        actions: [
          if (widget.mode == TransportMode.receive)
            IconButton(
              icon: AppIcons.scanIcon(),
              onPressed: () => _scanAndReceive(context, notifier),
            ),
          if (widget.mode == TransportMode.receive)
            IconButton(
              icon: const Icon(Icons.playlist_add),
              tooltip: l10n.qrcodeBatchScan,
              onPressed: () => _openBatchReceive(context, notifier),
            ),
        ],
      ),
      body: state.loading
          ? const Center(child: const SizedBox.shrink())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 订单信息卡片
                  _OrderHeaderCard(
                    detail: detail,
                    transferNo: widget.transferNo,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 8),
                  // 物流单号
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/android/mipmap-xxhdpi/icon_edt_traknumber.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.deviceIssueTrackingNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.black06Text,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          (detail?.trackingNumber.isNotEmpty ?? false)
                              ? detail!.trackingNumber
                              : '- -',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        if (canEditTracking) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                _showTrackingDialog(context, notifier, detail),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E5E5),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: Color(0xFF666666),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.entryEditAction,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 设备列表
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题行
                        Text(
                          '${_getDeviceTypeLabel(l10n, detail?.deviceType)} (${state.items.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 统计行
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              _StatItem(
                                label: l10n.deviceIssueStatusInTransit,
                                value: _countByStatus(state.items, 0).toString(),
                                color: const Color(0xFFED942F),
                              ),
                              _StatItem(
                                label: l10n.deviceIssueReceived,
                                value: _countByStatus(state.items, 1).toString(),
                                color: AppColors.primaryColor,
                              ),
                              _StatItem(
                                label: l10n.deviceIssueWithdrawn,
                                value: _countByStatus(state.items, 3).toString(),
                                color: const Color(0xFFE25C5C),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 设备列表
                        if (state.items.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.deviceIssueEmpty,
                                style: const TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...state.items.asMap().entries.map((entry) {
                            final item = entry.value;
                            final statusColors = _getItemStatusColors(item.status);
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.deviceSn,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormatUtils.formatString(
                                                item.opTime,
                                                pattern:
                                                    DateFormatUtils.defaultPattern,
                                                fallback: item.opTime,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF999999),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColors.background,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          _getItemStatusLabel(l10n, item.status),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: statusColors.text,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (entry.key < state.items.length - 1)
                                  const Divider(height: 1),
                              ],
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  int _countByStatus(List<DeviceTransportDetailPageData> items, int status) {
    return items.where((item) => item.status == status).length;
  }

  Future<void> _showTrackingDialog(
    BuildContext context,
    TransportDetailNotifier notifier,
    DeviceTransportDetail? detail,
  ) async {
    final l10n = context.l10n;
    final controller =
        TextEditingController(text: detail?.trackingNumber ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deviceIssueTrackingNumber),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.deviceIssueEnterTracking,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );
    if (result == null || result.isEmpty) return;
    await notifier.editTrackingNumber(result);
  }

  Future<void> _scanAndReceive(
    BuildContext context,
    TransportDetailNotifier notifier,
  ) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          parseDeviceSn: true,
          deviceType: ref.read(transportDetailProvider).detail?.deviceType,
        ),
      ),
    );
    if (result == null || result.isEmpty) return;
    await notifier.receiveDevice(result);
  }

  Future<void> _openBatchReceive(
    BuildContext context,
    TransportDetailNotifier notifier,
  ) async {
    final state = ref.read(transportDetailProvider);
    final existing = state.items.map((item) => item.deviceSn).toList();
    final result = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => QrBatchScanPage(
          initialItems: existing,
          fixedDeviceType: state.detail?.deviceType,
        ),
      ),
    );
    if (result == null || result.isEmpty) return;
    for (final sn in result) {
      await notifier.receiveDevice(sn);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(context.l10n.warehouseTransportBatchReceiveComplete)),
    );
  }

  String _getDeviceTypeLabel(AppLocalizations l10n, int? type) {
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

  String _getItemStatusLabel(AppLocalizations l10n, int status) {
    switch (status) {
      case 0:
        return l10n.deviceIssueStatusInTransit;
      case 1:
        return l10n.deviceIssueReceived;
      case 2:
        return l10n.deviceIssueStatusPartial;
      case 3:
        return l10n.deviceIssueWithdrawn;
      default:
        return '-';
    }
  }

  _StatusColors _getItemStatusColors(int status) {
    switch (status) {
      case 0:
        return const _StatusColors(
          text: Color(0xFFED942F),
          background: Color(0xFFFEF7EA),
        );
      case 1:
        return const _StatusColors(
          text: AppColors.primaryColor,
          background: Color(0xFFEEF7E9),
        );
      case 2:
        return const _StatusColors(
          text: Color(0xFF2196F3),
          background: Color(0xFFE3F2FD),
        );
      case 3:
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  detail?.transferNo ?? transferNo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatTimestamp(detail?.sendTime),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
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
                            detail?.outWarehouseName ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
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
                            detail?.inWarehouseName ?? '-',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1A1A1A),
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
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
