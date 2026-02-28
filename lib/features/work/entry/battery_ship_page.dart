import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/features/work/warehouse/transport_create_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_list_page.dart';

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
  int _deviceType = 0;
  bool _opening = false;
  late final List<String> _initialSns;

  @override
  void initState() {
    super.initState();
    _deviceType = widget.deviceType ?? 0;
    _initialSns = widget.initialSns
        .map((sn) => sn.trim())
        .where((sn) => sn.isNotEmpty)
        .toSet()
        .toList();
    if (_deviceType != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openTransport());
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.deviceType != null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.batteryShipTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  onTap: () => setState(() => _deviceType = 1),
                ),
                _TypeChip(
                  label: l10n.warehouseDeviceTypeVehicle,
                  selected: _deviceType == 2,
                  onTap: () => setState(() => _deviceType = 2),
                ),
                _TypeChip(
                  label: l10n.warehouseDeviceTypeStation,
                  selected: _deviceType == 3,
                  onTap: () => setState(() => _deviceType = 3),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _opening ? null : _goToTransfer,
                child: Text(l10n.shipNextAction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToTransfer() async {
    final l10n = context.l10n;
    if (_deviceType == 0) {
      showToast(l10n.shipDeviceTypeRequired);
      return;
    }
    await _openTransport();
  }

  Future<void> _openTransport() async {
    if (_opening) return;
    _opening = true;
    final l10n = context.l10n;
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransportCreatePage(
          deviceType: _deviceType,
          initialSns: _initialSns,
        ),
      ),
    );
    if (!mounted) return;
    if (created == true) {
      showToast(l10n.entrySubmitSuccess);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const TransportListPage(
            initialTabIndex: 0,
            mode: TransportMode.issue,
          ),
        ),
        (route) => route.isFirst,
      );
      return;
    }
    if (widget.deviceType != null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _opening = false);
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
