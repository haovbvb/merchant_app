import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/after_sale/unbind_device_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class UnbindDevicePage extends ConsumerStatefulWidget {
  const UnbindDevicePage({super.key});

  @override
  ConsumerState<UnbindDevicePage> createState() =>
      _UnbindDevicePageState();
}

class _UnbindDevicePageState extends ConsumerState<UnbindDevicePage> {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();
  final TextEditingController _checkRemarkController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _cardController.dispose();
    _deviceController.dispose();
    _checkRemarkController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(unbindDeviceProvider);
    final notifier = ref.read(unbindDeviceProvider.notifier);

    _syncControllers(state);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.unbindDeviceTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionTitle(title: l10n.afterSaleBindUserSectionTitle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cardController,
                    decoration: InputDecoration(
                      labelText: l10n.unbindDeviceUserIdLabel,
                      hintText: l10n.unbindDeviceUserIdHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanCardNum,
                      ),
                    ),
                    onChanged: (value) {
                      notifier.updateCardNum(value);
                      _debounceCheck();
                    },
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: l10n.afterSaleBindDeviceSectionTitle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deviceController,
                    decoration: InputDecoration(
                      labelText: l10n.unbindDeviceDeviceSnLabel,
                      hintText: l10n.unbindDeviceDeviceSnHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: _scanDeviceSn,
                      ),
                    ),
                    onChanged: (value) {
                      notifier.updateDeviceSn(value);
                      _debounceCheck();
                    },
                  ),
                  const SizedBox(height: 12),
                  if (state.hasUnfinishedOrder)
                    _WarningCard(
                      title: l10n.unbindDeviceUnfinishedTitle,
                      content: state.appointmentNo.isEmpty
                          ? l10n.unbindDeviceUnfinishedDesc
                          : '${l10n.unbindDeviceUnfinishedDesc}\n'
                              '${state.appointmentNo}',
                    ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: l10n.unbindDeviceCheckRemarkLabel),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _checkRemarkController,
                    decoration: InputDecoration(
                      hintText: l10n.unbindDeviceCheckRemarkHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: notifier.updateCheckRemark,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: l10n.unbindDeviceReasonTitle),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _reasons(l10n)
                        .map(
                          (reason) => ChoiceChip(
                            label: Text(reason),
                            selected: state.remark == reason,
                            onSelected: (_) {
                              _remarkController.text = reason;
                              notifier.updateRemark(reason);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _remarkController,
                    decoration: InputDecoration(
                      hintText: l10n.unbindDeviceReasonInputHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: notifier.updateRemark,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.submitting
                      ? null
                      : () => _submit(context, l10n, notifier),
                  child: state.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.unbindDeviceConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _syncControllers(UnbindDeviceState state) {
    if (_cardController.text != state.cardNum) {
      _cardController.text = state.cardNum;
    }
    if (_deviceController.text != state.deviceSn) {
      _deviceController.text = state.deviceSn;
    }
    if (_checkRemarkController.text != state.checkRemark) {
      _checkRemarkController.text = state.checkRemark;
    }
    if (_remarkController.text != state.remark) {
      _remarkController.text = state.remark;
    }
  }

  List<String> _reasons(AppLocalizations l10n) {
    return [
      l10n.unbindDeviceReason1,
      l10n.unbindDeviceReason2,
      l10n.unbindDeviceReason3,
    ];
  }

  void _debounceCheck() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(unbindDeviceProvider.notifier).checkUnfinishedOrder();
    });
  }

  Future<void> _scanCardNum() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    ref.read(unbindDeviceProvider.notifier).updateCardNum(result);
    _debounceCheck();
  }

  Future<void> _scanDeviceSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    ref.read(unbindDeviceProvider.notifier).updateDeviceSn(result);
    _debounceCheck();
  }

  Future<void> _submit(
    BuildContext context,
    AppLocalizations l10n,
    UnbindDeviceNotifier notifier,
  ) async {
    final state = ref.read(unbindDeviceProvider);
    if (state.cardNum.trim().isEmpty) {
      _showSnack(context, l10n.unbindDeviceMissingUserId);
      return;
    }
    if (state.deviceSn.trim().isEmpty) {
      _showSnack(context, l10n.unbindDeviceMissingDeviceSn);
      return;
    }
    if (state.checkRemark.trim().isEmpty) {
      _showSnack(context, l10n.unbindDeviceMissingCheckRemark);
      return;
    }
    if (state.remark.trim().isEmpty) {
      _showSnack(context, l10n.unbindDeviceMissingReason);
      return;
    }

    if (state.hasUnfinishedOrder) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.unbindDeviceUnfinishedTitle),
          content: Text(l10n.unbindDeviceUnfinishedDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.unbindDeviceConfirm),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final success = await notifier.unbindDevice();
    if (!context.mounted || !success) return;
    notifier.clearForm();
    _cardController.clear();
    _deviceController.clear();
    _checkRemarkController.clear();
    _remarkController.clear();
    _showSnack(context, l10n.unbindDeviceSuccess);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

class _WarningCard extends StatelessWidget {
  const _WarningCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange.shade700;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, color: color),
                ),
                const SizedBox(height: 4),
                Text(content, style: TextStyle(color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
