import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';

class VcuControlPage extends ConsumerStatefulWidget {
  const VcuControlPage({super.key});

  @override
  ConsumerState<VcuControlPage> createState() => _VcuControlPageState();
}

class _VcuControlPageState extends ConsumerState<VcuControlPage> {
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();

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
      appBar: AppBar(title: Text(l10n.vcuControlTitle)),
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
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.vcuSendSuccess : l10n.vcuSendFailed);
  }
}
