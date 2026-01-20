import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/charge_history.dart';
import 'package:merchant_app/features/work/device/device_detail_controller.dart';
import 'package:merchant_app/features/work/map/battery_location_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class DeviceDetailPage extends ConsumerStatefulWidget {
  const DeviceDetailPage({super.key, this.initialSn});

  final String? initialSn;

  @override
  ConsumerState<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends ConsumerState<DeviceDetailPage> {
  final TextEditingController _controller = TextEditingController();
  bool _autoSearched = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSn?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _autoSearched) return;
        final value = _controller.text.trim();
        if (value.isEmpty) return;
        ref.read(deviceDetailProvider.notifier).searchBattery(value);
        _autoSearched = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(deviceDetailProvider);
    final notifier = ref.read(deviceDetailProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deviceDetailTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.deviceDetailSearchHint,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_search.webp',
                    width: 20,
                    height: 20,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanSn,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.loading
                    ? null
                    : () => _submit(notifier),
                child: state.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.warehouseSearchAction),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.detail == null
                  ? _DeviceDetailEmpty(text: l10n.deviceDetailEmpty)
                  : _DeviceDetailBody(
                      detail: state.detail!,
                      histories: state.histories,
                      historyLoading: state.historyLoading,
                      onToggleDischarge: () => _toggleDischarge(notifier),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
          deviceType: 1,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
  }

  void _submit(DeviceDetailNotifier notifier) {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    notifier.searchBattery(value);
  }

  Future<void> _toggleDischarge(DeviceDetailNotifier notifier) async {
    final l10n = context.l10n;
    final success = await notifier.toggleDischargeStatus();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.deviceDetailToggleSuccess
              : l10n.deviceDetailToggleFailed,
        ),
      ),
    );
  }
}

class _DeviceDetailEmpty extends StatelessWidget {
  const _DeviceDetailEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_record.png',
            width: 160,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _DeviceDetailBody extends StatelessWidget {
  const _DeviceDetailBody({
    required this.detail,
    required this.histories,
    required this.historyLoading,
    required this.onToggleDischarge,
  });

  final BatteryDetail detail;
  final List<ChargeHistory> histories;
  final bool historyLoading;
  final VoidCallback onToggleDischarge;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        detail.deviceSn ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _statusChip(
                      label: _onlineLabel(l10n, detail.online),
                      color: detail.online == 1
                          ? const Color(0xFF00B88A)
                          : const Color(0xFFBDBDBD),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _infoRow(l10n.deviceDetailSoc, _formatValue(detail.soc)),
                _infoRow(l10n.deviceDetailCycle, _formatValue(detail.cycle)),
                _infoRow(l10n.deviceDetailMile, _formatValue(detail.mile)),
                _infoRow(
                  l10n.deviceDetailTodayMile,
                  _formatValue(detail.todayMile),
                ),
                _infoRow(
                  l10n.deviceDetailAvgSpeed,
                  _formatValue(detail.avgSpeed),
                ),
                _infoRow(
                  l10n.deviceDetailSignalTime,
                  _formatValue(detail.signalTime),
                ),
                _infoRow(
                  l10n.deviceDetailStatus,
                  _dischargeLabel(l10n, detail.status),
                ),
                _infoRow(
                  l10n.deviceDetailLocation,
                  _formatLocation(detail.latitude, detail.longitude),
                ),
                const SizedBox(height: 12),
                if (detail.deviceSn != null &&
                    detail.deviceSn!.isNotEmpty &&
                    detail.latitude != null &&
                    detail.longitude != null)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _openLocation(context, detail),
                      child: Text(l10n.deviceDetailViewMap),
                    ),
                  ),
                if (detail.deviceSn != null &&
                    detail.deviceSn!.isNotEmpty &&
                    detail.latitude != null &&
                    detail.longitude != null)
                  const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onToggleDischarge,
                    child: Text(l10n.deviceDetailToggleDischarge),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.deviceDetailChargeHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (historyLoading)
          const Center(child: CircularProgressIndicator())
        else if (histories.isEmpty)
          _DeviceDetailEmpty(text: l10n.deviceDetailChargeHistoryEmpty)
        else
          ...histories.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.date ?? '-'),
                subtitle: Text(
                  '${l10n.deviceDetailChargeValue}: '
                  '${item.chargeValue ?? '-'}\n'
                  '${l10n.deviceDetailChargeTime}: '
                  '${item.chargeTime ?? '-'}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return '-';
    return value.toString();
  }

  void _openLocation(BuildContext context, BatteryDetail detail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BatteryLocationPage(
          initialSn: detail.deviceSn ?? '',
        ),
      ),
    );
  }

  String _formatLocation(double? lat, double? lng) {
    if (lat == null || lng == null) return '-';
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  String _onlineLabel(AppLocalizations l10n, int? online) {
    return online == 1
        ? l10n.deviceDetailOnline
        : l10n.deviceDetailOffline;
  }

  String _dischargeLabel(AppLocalizations l10n, int? status) {
    return status == 1
        ? l10n.deviceDetailDischargeOn
        : l10n.deviceDetailDischargeOff;
  }
}

Widget _statusChip({required String label, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, color: color),
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
