import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/device_fix.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class RepairRecordCreatePage extends ConsumerStatefulWidget {
  const RepairRecordCreatePage({super.key});

  @override
  ConsumerState<RepairRecordCreatePage> createState() =>
      _RepairRecordCreatePageState();
}

class _RepairRecordCreatePageState
    extends ConsumerState<RepairRecordCreatePage> {
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(repairRecordCreateProvider);
    final notifier = ref.read(repairRecordCreateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.repairRecordAddTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.repairRecordDeviceSnLabel,
              hintText: l10n.repairRecordDeviceSnHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: _scanSn,
              ),
            ),
            onChanged: notifier.updateSn,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.loading
                  ? null
                  : () async {
                      _remarkController.clear();
                      notifier.updateRemark('');
                      await notifier.fetchDeviceInfo();
                    },
              child: state.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.repairRecordFetchDeviceInfo),
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: l10n.repairRecordDeviceInfoTitle,
            content: state.deviceFix == null
                ? l10n.repairRecordDeviceInfoEmpty
                : _buildDeviceInfo(l10n, state.deviceFix!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<DeviceFixProject>(
            initialValue: state.selectedProject,
            items: state.deviceFix?.itemList
                    .map(
                      (item) => DropdownMenuItem<DeviceFixProject>(
                        value: item,
                        child: Text(item.itemName),
                      ),
                    )
                    .toList() ??
                const [],
            onChanged: state.deviceFix?.itemList.isNotEmpty == true
                ? notifier.selectProject
                : null,
            decoration: InputDecoration(
              labelText: l10n.repairRecordProjectLabel,
              hintText: l10n.repairRecordProjectHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<DeviceFixResult>(
            initialValue: state.selectedResult,
            items: state.deviceFix?.resultList
                    .map(
                      (item) => DropdownMenuItem<DeviceFixResult>(
                        value: item,
                        child: Text(item.result),
                      ),
                    )
                    .toList() ??
                const [],
            onChanged: state.deviceFix?.resultList.isNotEmpty == true
                ? notifier.selectResult
                : null,
            decoration: InputDecoration(
              labelText: l10n.repairRecordResultLabel,
              hintText: l10n.repairRecordResultHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarkController,
            decoration: InputDecoration(
              labelText: l10n.repairRecordRemarkLabel,
              hintText: l10n.repairRecordRemarkHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
            onChanged: notifier.updateRemark,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.canSubmit
                  ? () async {
                      final success =
                          await notifier.submitFixRecord();
                      if (!mounted) return;
                      if (success) {
                        showToast(l10n.repairRecordSubmitSuccess);
                        Navigator.of(context).pop(true);
                      }
                    }
                  : null,
              child: state.submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.repairRecordSubmit),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          parseDeviceSn: true,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    ref.read(repairRecordCreateProvider.notifier).updateSn(result);
  }

  String _buildDeviceInfo(
    AppLocalizations l10n,
    DeviceFix fix,
  ) {
    switch (fix.deviceType) {
      case 1:
        final battery = fix.batteryVo;
        return '${l10n.repairRecordDeviceSnLabel}: ${battery?.sn ?? '-'}\n'
            '${l10n.repairRecordDeviceModelLabel}: ${battery?.model ?? battery?.batModel ?? '-'}\n'
            '${l10n.repairRecordDeviceSpecLabel}: ${battery?.spec ?? battery?.batSpec ?? '-'}';
      case 2:
        final car = fix.carVo;
        return '${l10n.repairRecordDeviceSnLabel}: ${car?.sn ?? '-'}\n'
            '${l10n.repairRecordDeviceModelLabel}: ${car?.model ?? '-'}\n'
            '${l10n.repairRecordDeviceCardNumLabel}: ${car?.cardNum ?? '-'}';
      case 3:
        final station = fix.stationVo;
        return '${l10n.repairRecordDeviceSnLabel}: ${station?.sn ?? '-'}\n'
            '${l10n.repairRecordDeviceNameLabel}: ${station?.name ?? '-'}';
      default:
        return l10n.repairRecordDeviceInfoEmpty;
    }
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}

