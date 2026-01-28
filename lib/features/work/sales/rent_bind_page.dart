import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/rent_applicant_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/rent_package_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/rent_payment_sheet.dart';

class RentBindPage extends ConsumerStatefulWidget {
  const RentBindPage({super.key});

  @override
  ConsumerState<RentBindPage> createState() => _RentBindPageState();
}

class _RentBindPageState extends ConsumerState<RentBindPage> {
  final _snController = TextEditingController();

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(rentBindProvider);
    final notifier = ref.read(rentBindProvider.notifier);

    // Show success page
    if (state.submitSuccess) {
      return _SuccessPage(
        paySource: state.paySource,
        documentNo: state.documentNo ?? '',
        onReturn: () {
          notifier.reset();
          Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDeviceSection(l10n, state, notifier),
                  const SizedBox(height: 8),
                  _buildPackageSection(l10n, state, notifier),
                ],
              ),
            ),
          ),
          _buildSubmitButton(l10n, state, notifier),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = context.l10n;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFFFA726),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.vpn_key,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.rentBindTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSection(
    dynamic l10n,
    RentBindState state,
    RentBindNotifier notifier,
  ) {
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
            l10n.rentBindDeviceSn,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _snController,
                  decoration: InputDecoration(
                    hintText: l10n.rentBindDeviceSnHint,
                    hintStyle: const TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      notifier.queryDevice(value.trim());
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: _scanSn,
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF333333),
                  size: 24,
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFEEEEEE)),
          if (state.deviceInfo != null) ...[
            _buildDeviceCard(state),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.rentBindNoDeviceInfo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCCCCCC),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(RentBindState state) {
    final device = state.deviceInfo!;
    final car = device.carVo;
    final battery = device.batteryVo;

    if (car != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.electric_moped,
                    size: 40,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.sn ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag('Vehicle · ${car.model}'),
                          _buildTag(car.spec),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoItem('VIN', car.vin ?? '-'),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: _buildInfoItem('Plate Number', car.carNumber ?? '-'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (battery != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.battery_charging_full,
                    size: 40,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        battery.sn ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag('Battery · ${battery.model ?? ''}'),
                          _buildTag(battery.spec ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoItem('SOC', '${battery.soc ?? '-'}%'),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: _buildInfoItem('SOH', '${battery.soh ?? '-'}%'),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: _buildInfoItem('Cycle', '${battery.cycle ?? '-'}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildPackageSection(
    dynamic l10n,
    RentBindState state,
    RentBindNotifier notifier,
  ) {
    final selectedPack = state.selectedPack;

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
            l10n.rentBindPackage,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 12),
          if (selectedPack != null) ...[
            _PackageCard(pack: selectedPack),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => _selectPackage(notifier, state),
                child: Text(
                  l10n.rentBindReselect,
                  style: const TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: () => _selectPackage(notifier, state),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.rentBindPackageHint,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    dynamic l10n,
    RentBindState state,
    RentBindNotifier notifier,
  ) {
    final canSubmit = state.deviceInfo != null && state.selectedPack != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: canSubmit && !state.submitting
              ? () => _showApplicantSheet(notifier, state)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            disabledBackgroundColor: const Color(0xFFE8F5E9),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: state.submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  l10n.rentBindSubmit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    ref.read(rentBindProvider.notifier).queryDevice(result);
  }

  Future<void> _selectPackage(
    RentBindNotifier notifier,
    RentBindState state,
  ) async {
    final packs = state.deviceInfo?.packList ?? [];
    if (packs.isEmpty) {
      showToast(context.l10n.rentBindNoPackageInfo);
      return;
    }

    final selected = await RentPackageSheet.show(
      context,
      packs,
      state.selectedPack,
    );
    if (selected != null) {
      notifier.selectPack(selected);
    }
  }

  Future<void> _showApplicantSheet(
    RentBindNotifier notifier,
    RentBindState state,
  ) async {
    final result = await RentApplicantSheet.show(context, notifier);
    if (result == null || !mounted) return;

    // Show payment sheet
    await _showPaymentSheet(notifier, state, result);
  }

  Future<void> _showPaymentSheet(
    RentBindNotifier notifier,
    RentBindState state,
    RentApplicantResult applicantResult,
  ) async {
    final pack = state.selectedPack;
    if (pack == null) return;

    final paymentResult = await RentPaymentSheet.show(
      context,
      notifier,
      pack.packageAmount ?? 0,
      pack.depositAmount ?? 0,
    );
    if (paymentResult == null || !mounted) return;

    // Submit
    final l10n = context.l10n;
    final success = await notifier.submit(
      address: applicantResult.address,
      birthday: applicantResult.birthday,
      cardNum: applicantResult.cardNum,
      email: applicantResult.email,
      firstName: applicantResult.firstName,
      lastName: applicantResult.lastName,
      idNumber: applicantResult.idNumber,
      phone: applicantResult.phone,
      deviceSn: _snController.text.trim(),
      cardImgUrl: applicantResult.cardImgUrl,
      personImgUrl: applicantResult.personImgUrl,
    );

    if (!mounted) return;
    if (!success) {
      showToast(l10n.rentBindFailed);
    }
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.pack});

  final Pack pack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D4A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.infoName ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${(pack.packageAmount ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.rentBindServicePeriod,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _buildPeriodText(pack),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.rentBindDeposit,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(pack.depositAmount ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildPeriodText(Pack pack) {
    final periodValue = pack.duration ?? 30;
    return 'Fixed period · ${periodValue}days';
  }
}

class _SuccessPage extends StatelessWidget {
  const _SuccessPage({
    required this.paySource,
    required this.documentNo,
    required this.onReturn,
  });

  final int paySource;
  final String documentNo;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.rentBindTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: onReturn,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.rentBindSuccessTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                  children: [
                    TextSpan(
                      text: paySource == 2
                          ? l10n.rentBindSuccessMessageOnline
                          : l10n.rentBindSuccessMessageCash,
                    ),
                    const TextSpan(
                      text: ' 30 minutes',
                      style: TextStyle(
                        color: Color(0xFFFF9800),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.rentBindDocumentNumber,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          documentNo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: documentNo));
                            showToast(l10n.rentBindCopied);
                          },
                          child: const Icon(
                            Icons.copy,
                            size: 18,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(l10n.rentBindReturnWorkbench),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
