import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/features/work/after_sale/unbind_device_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class UnbindDevicePage extends ConsumerStatefulWidget {
  const UnbindDevicePage({super.key});

  @override
  ConsumerState<UnbindDevicePage> createState() => _UnbindDevicePageState();
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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (state.loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/android/mipmap-xxhdpi/icon_device_unbinding.webp',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.unbindDeviceTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // User ID and Device SN section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: l10n.unbindDeviceUserIdLabel,
                            hint: l10n.unbindDeviceUserIdHint,
                            controller: _cardController,
                            onChanged: (v) {
                              notifier.updateCardNum(v);
                              _debounceCheck();
                            },
                            onSubmitted: (_) => notifier.checkUnfinishedOrder(),
                            onScan: _scanCardNum,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          _buildInputField(
                            label: l10n.unbindDeviceDeviceSnLabel,
                            hint: l10n.unbindDeviceDeviceSnHint,
                            controller: _deviceController,
                            onChanged: (v) {
                              notifier.updateDeviceSn(v);
                              _debounceCheck();
                            },
                            onSubmitted: (_) => notifier.checkUnfinishedOrder(),
                            onScan: _scanDeviceSn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Check Status section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildInputField(
                        label: l10n.unbindDeviceCheckRemarkLabel,
                        hint: l10n.unbindDeviceCheckRemarkHint,
                        controller: _checkRemarkController,
                        onChanged: notifier.updateCheckRemark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Reason section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputField(
                            label: l10n.unbindDeviceReasonTitle,
                            hint: l10n.unbindDeviceReasonHint,
                            controller: _remarkController,
                            onChanged: notifier.updateRemark,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.unbindDeviceCommonReasons,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    for (final reason in _reasons(l10n))
                                      _ReasonChip(
                                        label: reason,
                                        selected: state.remark == reason,
                                        onTap: () {
                                          notifier.updateRemark(reason);
                                          _remarkController.text = reason;
                                        },
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.hasUnfinishedOrder)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: _WarningCard(
                          title: l10n.unbindDeviceUnfinishedTitle,
                          content: state.appointmentNo.isEmpty
                              ? l10n.unbindDeviceUnfinishedDesc
                              : '${l10n.unbindDeviceUnfinishedDesc}\n'
                                    '${state.appointmentNo}',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Bottom button
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF5F5F5),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: state.submitting
                      ? null
                      : () => _submit(context, l10n, notifier),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.primaryColor.withOpacity(
                      0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: state.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: const SizedBox.shrink(),
                        )
                      : Text(
                          l10n.unbindDeviceConfirmButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onScan,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                ),
              ),
              if (onScan != null)
                GestureDetector(
                  onTap: onScan,
                  child: AppIcons.scanIcon(size: 24, color: Colors.black54),
                ),
            ],
          ),
        ],
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
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    ref.read(unbindDeviceProvider.notifier).updateCardNum(result);
    _debounceCheck();
  }

  Future<void> _scanDeviceSn() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QrScanPage()));
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
      final confirm = await ConfirmDialog.show(
        context: context,
        message: l10n.unbindDeviceUnfinishedDesc,
        confirmText: l10n.unbindDeviceConfirm,
      );
      if (!confirm) return;
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: selected ? AppColors.primaryColor : Colors.black87,
          ),
        ),
      ),
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
