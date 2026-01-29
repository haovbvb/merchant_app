import 'package:flutter/material.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/entry/ship_success_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_create_page.dart';

class BatteryShipPage extends StatefulWidget {
  const BatteryShipPage({
    super.key,
    this.deviceType,
    this.initialSns = const [],
  });

  final int? deviceType;
  final List<String> initialSns;

  @override
  State<BatteryShipPage> createState() => _BatteryShipPageState();
}

class _BatteryShipPageState extends State<BatteryShipPage> {
  final TextEditingController _snController = TextEditingController();
  late final List<String> _sns;
  int _deviceType = 0;

  @override
  void initState() {
    super.initState();
    _deviceType = widget.deviceType ?? 0;
    _sns = widget.initialSns
        .where((sn) => sn.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batteryShipTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.shipDeviceTypeLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _TypeChip(
                label: l10n.warehouseDeviceTypeBattery,
                selected: _deviceType == 1,
                onTap: widget.deviceType == null
                    ? () => setState(() => _deviceType = 1)
                    : null,
              ),
              _TypeChip(
                label: l10n.warehouseDeviceTypeVehicle,
                selected: _deviceType == 2,
                onTap: widget.deviceType == null
                    ? () => setState(() => _deviceType = 2)
                    : null,
              ),
              _TypeChip(
                label: l10n.warehouseDeviceTypeStation,
                selected: _deviceType == 3,
                onTap: widget.deviceType == null
                    ? () => setState(() => _deviceType = 3)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _snController,
                  decoration: InputDecoration(
                    labelText: l10n.entrySnLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _addSn,
                child: Text(l10n.entryManualAdd),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: AppIcons.scanIcon(),
                onPressed: _scanAndAdd,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.entryDeviceListTitle,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (_sns.isEmpty)
            _EmptyCard(text: l10n.entryListEmpty)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sns
                  .map(
                    (sn) => Chip(
                      label: Text(sn),
                      onDeleted: () => setState(() => _sns.remove(sn)),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _goToTransfer,
            child: Text(l10n.shipNextAction),
          ),
        ],
      ),
    );
  }

  void _addSn() {
    final value = _snController.text.trim();
    if (value.isEmpty) return;
    if (!_sns.contains(value)) {
      setState(() => _sns.add(value));
    }
    _snController.clear();
  }

  Future<void> _scanAndAdd() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
          deviceType: 1,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    if (!_sns.contains(result)) {
      setState(() => _sns.add(result));
    }
  }

  Future<void> _goToTransfer() async {
    final l10n = context.l10n;
    if (_deviceType == 0) {
      showToast(l10n.shipDeviceTypeRequired);
      return;
    }
    if (_sns.isEmpty) {
      showToast(l10n.entryListEmpty);
      return;
    }
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransportCreatePage(
          deviceType: _deviceType,
          initialSns: _sns,
        ),
      ),
    );
    if (!mounted || created != true) return;
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ShipSuccessPage(deviceType: _deviceType),
      ),
    );
    if (!mounted || done != true) return;
    Navigator.of(context).pop();
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
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
