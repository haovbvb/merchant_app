import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/ui.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/merchant_replace_controller.dart';

class MerchantReplacePage extends ConsumerStatefulWidget {
  const MerchantReplacePage({super.key});

  @override
  ConsumerState<MerchantReplacePage> createState() =>
      _MerchantReplacePageState();
}

class _MerchantReplacePageState extends ConsumerState<MerchantReplacePage> {
  static const int _reasonMaxLength = 200;

  final _userIdController = TextEditingController();
  final _boundBatterySnController = TextEditingController();
  final _newBatterySnController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _boundBatterySnController.dispose();
    _newBatterySnController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(merchantReplaceProvider);
    final notifier = ref.read(merchantReplaceProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildInputCard(context),
                    const SizedBox(height: 8),
                    _buildReasonCard(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(context, state, notifier),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit {
    return _userIdController.text.trim().isNotEmpty &&
        _boundBatterySnController.text.trim().isNotEmpty &&
        _newBatterySnController.text.trim().isNotEmpty &&
        _reasonController.text.trim().isNotEmpty;
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F5F5), Color(0xFFF5F5F5)],
        ),
      ),
      child: Column(
        children: [
          // 返回按钮
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
          // 绿色图标
          Container(
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/android/mipmap-xxhdpi/icon_manual_swap.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.merchantReplaceTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User ID
          _buildInputField(
            label: l10n.merchantReplaceUserId,
            hint: l10n.merchantReplaceUserIdHint,
            controller: _userIdController,
            onScan: () => _scanTo(
              _userIdController,
              parser: ScanUtils.getUserCarNum,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          // Bound Battery SN
          _buildInputField(
            label: l10n.merchantReplaceBoundBatterySn,
            hint: l10n.merchantReplaceBatterySnHint,
            controller: _boundBatterySnController,
            onScan: () => _scanTo(
              _boundBatterySnController,
              parser: ScanUtils.getDeviceSn,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          // New Battery
          _buildInputField(
            label: l10n.merchantReplaceNewBattery,
            hint: l10n.merchantReplaceBatterySnHint,
            controller: _newBatterySnController,
            onScan: () => _scanTo(
              _newBatterySnController,
              parser: ScanUtils.getDeviceSn,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onScan,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.black06Text,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCCCCCC),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.black06Text,
                ),
              ),
            ),
            GestureDetector(
              onTap: onScan,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: AppIcons.scanIcon(size: 24, color: AppColors.black06Text),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReasonCard(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.merchantReplaceReasons,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            onChanged: (_) => setState(() {}),
            maxLength: _reasonMaxLength,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.merchantReplaceReasonsHint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFCCCCCC),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.black06Text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    MerchantReplaceState state,
    MerchantReplaceNotifier notifier,
  ) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: state.submitting || !_canSubmit
                ? null
                : () => _submit(context, notifier),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: const Color(0xFFB8E6B8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: state.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: SizedBox.shrink(),
                  )
                : Text(
                    l10n.merchantReplaceSubmit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanTo(
    TextEditingController controller, {
    required String Function(String) parser,
  }) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    final parsed = parser(result).trim();
    if (parsed.isEmpty) return;
    controller.text = parsed;
    setState(() {});
  }

  Future<void> _submit(
    BuildContext context,
    MerchantReplaceNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final reason = _reasonController.text.trim().length > _reasonMaxLength
        ? _reasonController.text.trim().substring(0, _reasonMaxLength)
        : _reasonController.text.trim();
    if (_boundBatterySnController.text.trim() ==
        _newBatterySnController.text.trim()) {
      showToast(l10n.merchantReplaceSameSn);
      return;
    }
    final ok = await notifier.submit(
      cardNum: _userIdController.text.trim(),
      oldSn: _boundBatterySnController.text.trim(),
      newSn: _newBatterySnController.text.trim(),
      reason: reason,
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.merchantReplaceSuccess : l10n.merchantReplaceFailed);
    if (ok) {
      Navigator.of(context).pop();
    }
  }
}
