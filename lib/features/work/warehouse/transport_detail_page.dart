import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/device_transport_resp.dart';
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
      appBar: AppBar(
        title: Text(l10n.warehouseTransportDetailTitle),
        actions: [
          if (widget.mode == TransportMode.receive)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _scanAndReceive(context, notifier),
            ),
          if (canEditTracking)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showTrackingDialog(context, notifier, detail),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoTile(
            label: l10n.warehouseTransportTransferNo,
            value: detail?.transferNo ?? widget.transferNo,
          ),
          _InfoTile(
            label: l10n.warehouseTransportDeviceType,
            value: _deviceTypeLabel(l10n, detail?.deviceType),
          ),
          _InfoTile(
            label: l10n.warehouseTransportFrom,
            value: detail?.outWarehouseName ?? '-',
          ),
          _InfoTile(
            label: l10n.warehouseTransportTo,
            value: detail?.inWarehouseName ?? '-',
          ),
          _InfoTile(
            label: l10n.warehouseTransportStatus,
            value: detail == null
                ? '-'
                : _transportStatusLabel(l10n, detail.receivedNum, detail),
          ),
          _InfoTile(
            label: l10n.warehouseTransportTrackingNumber,
            value: detail?.trackingNumber ?? '-',
          ),
          const SizedBox(height: 16),
          Text(
            l10n.warehouseTransportDeviceListTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (state.items.isEmpty)
            _EmptyCard(text: l10n.warehouseTransportEmpty)
          else
            ...state.items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.deviceSn),
                  subtitle: Text(
                    '${l10n.warehouseTransportStatus}: '
                    '${_detailStatusLabel(l10n, item.status)}\n'
                    '${l10n.warehouseTransportOperateTime}: ${item.opTime}',
                  ),
                  trailing: widget.mode == TransportMode.receive &&
                          item.status == 0
                      ? _ReceiveActions(
                          onReceive: () => notifier.receiveDevice(item.deviceSn),
                          onWithdraw: () =>
                              notifier.withdrawDevice(item.deviceSn),
                          receiveLabel: l10n.warehouseTransportReceiveAction,
                          withdrawLabel: l10n.warehouseTransportWithdrawAction,
                        )
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showTrackingDialog(
    BuildContext context,
    TransportDetailNotifier notifier,
    DeviceTransportDetail? detail,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: detail?.trackingNumber ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.warehouseTransportEditTrackingNumber),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: l10n.warehouseTransportTrackingNumber,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(l10n.warehouseTransportEditTrackingNumber),
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
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (result == null || result.isEmpty) return;
    await notifier.receiveDevice(result);
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

  String _transportStatusLabel(
    AppLocalizations l10n,
    int receivedNum,
    DeviceTransportDetail detail,
  ) {
    if (detail.withdrawNum > 0) {
      return l10n.warehouseTransportStatusWithdrawn;
    }
    if (receivedNum >= detail.deviceNum) {
      return l10n.warehouseTransportStatusReceived;
    }
    if (receivedNum > 0) {
      return l10n.warehouseTransportStatusPartial;
    }
    return l10n.warehouseTransportStatusInTransit;
  }

  String _detailStatusLabel(AppLocalizations l10n, int status) {
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

class _ReceiveActions extends StatelessWidget {
  const _ReceiveActions({
    required this.onReceive,
    required this.onWithdraw,
    required this.receiveLabel,
    required this.withdrawLabel,
  });

  final VoidCallback onReceive;
  final VoidCallback onWithdraw;
  final String receiveLabel;
  final String withdrawLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: onReceive, child: Text(receiveLabel)),
        const SizedBox(width: 4),
        TextButton(onPressed: onWithdraw, child: Text(withdrawLabel)),
      ],
    );
  }
}
