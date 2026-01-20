import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_fault_page.dart';

class CabinetOfflineDetailPage extends ConsumerStatefulWidget {
  const CabinetOfflineDetailPage({super.key});

  @override
  ConsumerState<CabinetOfflineDetailPage> createState() =>
      _CabinetOfflineDetailPageState();
}

class _CabinetOfflineDetailPageState
    extends ConsumerState<CabinetOfflineDetailPage> {
  final TextEditingController _snController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    final notifier = ref.read(cabinetOfflineProvider.notifier);
    final info = state.baseInfo;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetOfflineDetailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.cabinetOfflineSnLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.loading
                ? null
                : () => notifier.load(_snController.text.trim()),
            child: state.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cabinetOfflineQueryAction),
          ),
          const SizedBox(height: 16),
          if (info == null)
            Text(l10n.cabinetOfflineEmpty)
          else ...[
            _InfoTile(label: l10n.cabinetOfflineName, value: info.stationName),
            _InfoTile(label: l10n.cabinetOfflineSnLabel, value: info.stationSn),
            _InfoTile(label: l10n.cabinetOfflinePidLabel, value: info.stationPid),
            _InfoTile(label: l10n.cabinetOfflineAddressLabel, value: info.stationAddress),
            _InfoTile(label: l10n.cabinetOfflineStatusLabel, value: info.showOnlineStatus ?? info.online),
            _InfoTile(label: l10n.cabinetOfflineLastHbLabel, value: info.lastHbTime),
            _InfoTile(label: l10n.cabinetOfflineLockDevId, value: info.lockDevId),
            _InfoTile(label: l10n.cabinetOfflineLockIcId, value: info.lockIcId),
            _InfoTile(label: l10n.cabinetOfflineSecretKey, value: state.secretKey),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: info.stationSn == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CabinetOfflineFaultPage(
                            sn: info.stationSn ?? '',
                          ),
                        ),
                      ),
              child: Text(l10n.cabinetOfflineFaultEntry),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '-')),
        ],
      ),
    );
  }
}
