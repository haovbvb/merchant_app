import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_unshelve_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class CabinetUnshelvePage extends ConsumerStatefulWidget {
  const CabinetUnshelvePage({super.key});

  @override
  ConsumerState<CabinetUnshelvePage> createState() => _CabinetUnshelvePageState();
}

class _CabinetUnshelvePageState extends ConsumerState<CabinetUnshelvePage> {
  final _snController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetUnshelveProvider);
    final notifier = ref.read(cabinetUnshelveProvider.notifier);
    final cabinet = state.cabinet;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetUnshelveTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.cabinetUnshelveSn,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanSn,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => notifier.queryCabinet(
                      _snController.text.trim(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: l10n.cabinetUnshelveInfoTitle,
            content: cabinet == null
                ? l10n.cabinetUnshelveInfoEmpty
                : '${l10n.cabinetUnshelveName}: ${cabinet.stationName ?? '-'}\n'
                    '${l10n.cabinetUnshelveModel}: ${cabinet.stationModel ?? '-'}',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.cabinetUnshelveReason,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () => _submit(context, notifier),
            child: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.cabinetUnshelveSubmit),
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
          deviceType: 3,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
  }

  Future<void> _submit(
    BuildContext context,
    CabinetUnshelveNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final ok = await notifier.submit(
      sn: _snController.text.trim(),
      reason: _reasonController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.cabinetUnshelveSuccess : l10n.cabinetUnshelveFailed);
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(content),
          ],
        ),
      ),
    );
  }
}
