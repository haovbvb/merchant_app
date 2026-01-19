import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/warehouse_info.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class TransportCreatePage extends ConsumerStatefulWidget {
  const TransportCreatePage({
    super.key,
    required this.deviceType,
    this.initialSns = const [],
  });

  final int deviceType;
  final List<String> initialSns;

  @override
  ConsumerState<TransportCreatePage> createState() =>
      _TransportCreatePageState();
}

class _TransportCreatePageState extends ConsumerState<TransportCreatePage> {
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _trackingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(transportCreateProvider.notifier);
      notifier.setDeviceType(widget.deviceType);
      notifier.setInitialSns(widget.initialSns);
      notifier.loadMyWarehouse();
      notifier.loadInWarehouseList();
    });
  }

  @override
  void dispose() {
    _snController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(transportCreateProvider);
    final notifier = ref.read(transportCreateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.warehouseTransportCreateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoTile(
            label: l10n.warehouseTransportSendWarehouse,
            value: _warehouseDisplayName(l10n, state.myWarehouse),
          ),
          _SelectTile(
            label: l10n.warehouseTransportReceiveWarehouse,
            value: _selectedWarehouseName(l10n, state.selectedInWarehouse),
            onTap: () => _showWarehousePicker(
              context,
              l10n,
              state.inWarehouses,
              notifier,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _trackingController,
            decoration: InputDecoration(
              labelText: l10n.warehouseTransportTrackingNumber,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: notifier.setTrackingNumber,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _snController,
                  decoration: InputDecoration(
                    labelText: l10n.warehouseTransportInputDeviceSn,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _addSn(notifier),
                child: Text(l10n.warehouseTransportAddDevice),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () => _scanAndAdd(context, notifier),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.sns.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.sns
                  .map(
                    (sn) => Chip(
                      label: Text(sn),
                      onDeleted: () => notifier.removeSn(sn),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () async {
                    notifier.setTrackingNumber(_trackingController.text.trim());
                    final created = await notifier.createIssue();
                    if (!mounted) return;
                    if (created) {
                      Navigator.of(context).pop(true);
                    }
                  },
            child: Text(l10n.warehouseTransportCreateAction),
          ),
        ],
      ),
    );
  }

  Future<void> _addSn(TransportCreateNotifier notifier) async {
    final sn = _snController.text.trim();
    if (sn.isEmpty) return;
    await notifier.addSn(sn);
    _snController.clear();
  }

  Future<void> _scanAndAdd(
    BuildContext context,
    TransportCreateNotifier notifier,
  ) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (result == null || result.isEmpty) return;
    await notifier.addSn(result);
  }

  String _warehouseDisplayName(AppLocalizations l10n, WarehouseInfo? info) {
    if (info == null) return '-';
    if ((info.warehouseName ?? '').isNotEmpty) {
      return info.warehouseName ?? '-';
    }
    if ((info.outWarehouseName ?? '').isNotEmpty) {
      return info.outWarehouseName ?? '-';
    }
    return '-';
  }

  String _selectedWarehouseName(AppLocalizations l10n, WarehouseInfo? info) {
    if (info == null) return l10n.warehouseTransportSelectReceiveWarehouse;
    return info.inWarehouseName ?? info.warehouseName ?? '-';
  }

  Future<void> _showWarehousePicker(
    BuildContext context,
    AppLocalizations l10n,
    List<WarehouseInfo> list,
    TransportCreateNotifier notifier,
  ) async {
    if (list.isEmpty) {
      await notifier.loadInWarehouseList();
    }
    final updatedList = ref.read(transportCreateProvider).inWarehouses;
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return ListView.separated(
          itemCount: updatedList.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = updatedList[index];
            return ListTile(
              title: Text(item.inWarehouseName ?? item.warehouseName ?? '-'),
              subtitle: Text(item.cityName ?? ''),
              onTap: () {
                notifier.selectInWarehouse(item);
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
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
          SizedBox(width: 120, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(width: 120, child: Text(label)),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
