import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';

class CabinetOfflineFaultPage extends ConsumerStatefulWidget {
  const CabinetOfflineFaultPage({super.key, this.sn});

  final String? sn;

  @override
  ConsumerState<CabinetOfflineFaultPage> createState() =>
      _CabinetOfflineFaultPageState();
}

class _CabinetOfflineFaultPageState
    extends ConsumerState<CabinetOfflineFaultPage> {
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if ((widget.sn ?? '').isNotEmpty) {
      _snController.text = widget.sn ?? '';
    }
  }

  @override
  void dispose() {
    _snController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetFaultProvider);
    final notifier = ref.read(cabinetFaultProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetOfflineFaultTitle)),
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
          const SizedBox(height: 8),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.cabinetOfflinePortLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.loading
                ? null
                : () => notifier.query(
                      _snController.text.trim(),
                      int.tryParse(_portController.text.trim()) ?? 0,
                    ),
            child: state.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cabinetOfflineQueryAction),
          ),
          const SizedBox(height: 16),
          if (state.items.isEmpty)
            Text(l10n.cabinetOfflineFaultEmpty)
          else
            ...state.items.map(
              (item) => Card(
                child: ListTile(
                  title: Text(item.faultDesc ?? '-'),
                  subtitle: Text(
                    '${l10n.cabinetOfflineFaultSnLabel}: ${item.sn ?? '-'}\n'
                    '${l10n.cabinetOfflineFaultPortLabel}: ${item.port ?? '-'}\n'
                    '${l10n.cabinetOfflineFaultTimeLabel}: ${item.createTime ?? '-'}\n'
                    '${l10n.cabinetOfflineFaultSiteLabel}: ${item.site ?? '-'}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
