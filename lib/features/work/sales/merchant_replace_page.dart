import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/merchant_replace_controller.dart';

class MerchantReplacePage extends ConsumerStatefulWidget {
  const MerchantReplacePage({super.key});

  @override
  ConsumerState<MerchantReplacePage> createState() => _MerchantReplacePageState();
}

class _MerchantReplacePageState extends ConsumerState<MerchantReplacePage> {
  final _cardController = TextEditingController();
  final _oldSnController = TextEditingController();
  final _newSnController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _oldSnController.dispose();
    _newSnController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(merchantReplaceProvider);
    final notifier = ref.read(merchantReplaceProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.merchantReplaceTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInput(
            controller: _cardController,
            label: l10n.merchantReplaceCardNum,
            onScan: () => _scanTo(_cardController),
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _oldSnController,
            label: l10n.merchantReplaceOldSn,
            onScan: () => _scanTo(_oldSnController),
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _newSnController,
            label: l10n.merchantReplaceNewSn,
            onScan: () => _scanTo(_newSnController),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.merchantReplaceReason,
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
                : Text(l10n.merchantReplaceSubmit),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required VoidCallback onScan,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: onScan,
        ),
      ),
    );
  }

  Future<void> _scanTo(TextEditingController controller) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    controller.text = result;
  }

  Future<void> _submit(
    BuildContext context,
    MerchantReplaceNotifier notifier,
  ) async {
    final l10n = context.l10n;
    if (_oldSnController.text.trim() == _newSnController.text.trim()) {
      showToast(l10n.merchantReplaceSameSn);
      return;
    }
    final ok = await notifier.submit(
      cardNum: _cardController.text.trim(),
      oldSn: _oldSnController.text.trim(),
      newSn: _newSnController.text.trim(),
      reason: _reasonController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.merchantReplaceSuccess : l10n.merchantReplaceFailed);
  }
}
