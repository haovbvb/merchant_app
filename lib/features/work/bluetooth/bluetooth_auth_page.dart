import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_auth_controller.dart';

class BluetoothAuthPage extends ConsumerStatefulWidget {
  const BluetoothAuthPage({super.key});

  @override
  ConsumerState<BluetoothAuthPage> createState() =>
      _BluetoothAuthPageState();
}

class _BluetoothAuthPageState extends ConsumerState<BluetoothAuthPage> {
  final _snController = TextEditingController();
  final _phoneController = TextEditingController();
  final _keyIdController = TextEditingController();
  final _daysController = TextEditingController(text: '1');

  @override
  void dispose() {
    _snController.dispose();
    _phoneController.dispose();
    _keyIdController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(bluetoothAuthProvider);
    final notifier = ref.read(bluetoothAuthProvider.notifier);
    final lockInfo = state.lockInfo;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothAuthTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
            controller: _snController,
            label: l10n.bluetoothAuthSn,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.loadingLock
                      ? null
                      : () => notifier.queryLockId(
                            _snController.text.trim(),
                          ),
                  child: state.loadingLock
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.bluetoothAuthQueryLock),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionTitle(title: l10n.bluetoothAuthLockInfo),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'lockIcId',
                    value: lockInfo?.lockIcId ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'lockDevId',
                    value: lockInfo?.lockDevId ?? '-',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: l10n.bluetoothAuthPhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: state.loadingUid
                ? null
                : () => notifier.queryUid(
                      _phoneController.text.trim(),
                    ),
            child: state.loadingUid
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.bluetoothAuthQueryUid),
          ),
          const SizedBox(height: 12),
          _SectionTitle(title: l10n.bluetoothAuthUid),
          const SizedBox(height: 8),
          Text(state.uid?.isNotEmpty == true ? state.uid! : '-'),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _keyIdController,
            label: l10n.bluetoothAuthKeyId,
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _daysController,
            label: l10n.bluetoothAuthDays,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
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
                : Text(l10n.bluetoothAuthSubmit),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    BluetoothAuthNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final sn = _snController.text.trim();
    final phone = _phoneController.text.trim();
    final keyId = _keyIdController.text.trim();
    final days = int.tryParse(_daysController.text.trim()) ?? 1;
    if (sn.isEmpty || phone.isEmpty || keyId.isEmpty) {
      showToast(l10n.bluetoothAuthMissingInput);
      return;
    }
    final ok = await notifier.authorize(
      sn: sn,
      phone: phone,
      keyId: keyId,
      days: days,
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.bluetoothAuthSuccess : l10n.bluetoothAuthFailed);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
