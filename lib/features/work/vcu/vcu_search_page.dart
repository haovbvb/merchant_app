import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';

class VcuSearchPage extends ConsumerStatefulWidget {
  const VcuSearchPage({super.key});

  @override
  ConsumerState<VcuSearchPage> createState() => _VcuSearchPageState();
}

class _VcuSearchPageState extends ConsumerState<VcuSearchPage> {
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  String? _selectedVersion;

  @override
  void dispose() {
    _vinController.dispose();
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(vcuProvider);
    final notifier = ref.read(vcuProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vcuSearchTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _vinController,
            decoration: InputDecoration(
              labelText: l10n.vcuVinLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: state.loading ? null : notifier.loadVersions,
            child: state.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.vcuLoadVersions),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: l10n.vcuVersionLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: state.versions
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.version ?? item.name ?? '',
                    child: Text(item.version ?? item.name ?? '-'),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedVersion = value),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commandController,
            decoration: InputDecoration(
              labelText: l10n.vcuCommandLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.sending
                ? null
                : () => _send(context, notifier),
            child: state.sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.vcuSendCommand),
          ),
        ],
      ),
    );
  }

  Future<void> _send(BuildContext context, VcuNotifier notifier) async {
    final l10n = context.l10n;
    final ok = await notifier.sendCommand(
      vin: _vinController.text.trim(),
      command: _commandController.text.trim(),
      version: _selectedVersion,
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.vcuSendSuccess : l10n.vcuSendFailed);
  }
}
