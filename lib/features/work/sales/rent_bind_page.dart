import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/pack.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/bind_success_page.dart';
import 'package:merchant_app/features/work/sales/widgets/rent_applicant_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/rent_package_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/rent_payment_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/select_applicant_sheet.dart';

class RentBindPage extends ConsumerStatefulWidget {
  const RentBindPage({super.key});

  @override
  ConsumerState<RentBindPage> createState() => _RentBindPageState();
}

class _RentBindPageState extends ConsumerState<RentBindPage> {
  static const Color _fieldTitleColor = Color(0xFF666666);

  final _snController = TextEditingController();
  final _snFocusNode = FocusNode();
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didInit) return;
      _didInit = true;
      final notifier = ref.read(rentBindProvider.notifier);
      notifier.reset();
      _snController.clear();
    });
    final notifier = ref.read(rentBindProvider.notifier);
    notifier.reset();
    notifier.clearDeviceAndPack();
    final shopNo = AuthSession.instance.current?.shopNo ?? '';
    if (shopNo.isNotEmpty) {
      notifier.loadShopPayConfig(shopNo);
    }
    _snController.clear();
    _snFocusNode.addListener(_onSnFocusChanged);
  }

  void _onSnFocusChanged() {
    if (_snFocusNode.hasFocus) return;
    final sn = _snController.text.trim();
    final notifier = ref.read(rentBindProvider.notifier);
    if (sn.isEmpty) {
      notifier.clearDeviceAndPack();
      return;
    }
    _queryDevice(sn, notifier);
  }

  @override
  void dispose() {
    ref.read(rentBindProvider.notifier).reset();
    _snFocusNode
      ..removeListener(_onSnFocusChanged)
      ..dispose();
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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/android/mipmap-xxhdpi/icon_lease_bind.png',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.rentBindTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black09Text,
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
            style: const TextStyle(fontSize: 14, color: _fieldTitleColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _snController,
                  focusNode: _snFocusNode,
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
                      _queryDevice(value.trim(), notifier);
                    }
                  },
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      notifier.clearDeviceAndPack();
                    }
                  },
                ),
              ),
              GestureDetector(
                onTap: _scanSn,
                child: AppIcons.scanIcon(
                  size: 24,
                  color: AppColors.black06Text,
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
                style: const TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceCard(RentBindState state) {
    final l10n = context.l10n;
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
                  child: _normalizedImageUrl(car.img) != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _normalizedImageUrl(car.img)!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.electric_moped,
                              size: 40,
                              color: Color(0xFF666666),
                            ),
                          ),
                        )
                      : const Icon(
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
                          color: AppColors.black06Text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag(
                            '${l10n.rentBindTagVehicle} · ${_carModelText(car)}',
                          ),
                          _buildTag(_carSpecText(car)),
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
                    child: _buildInfoItem(l10n.rentBindLabelVin, car.vin ?? '-'),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      l10n.rentBindLabelPlateNumber,
                      car.carNumber ?? '-',
                    ),
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
                  child: _normalizedImageUrl(battery.img) != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _normalizedImageUrl(battery.img)!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.battery_charging_full,
                              size: 40,
                              color: Color(0xFF666666),
                            ),
                          ),
                        )
                      : const Icon(
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
                          color: AppColors.black06Text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag(
                            '${l10n.rentBindTagBattery} · ${_batteryModelText(battery)}',
                          ),
                          _buildTag(_batterySpecText(battery)),
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
                    child: _buildInfoItem(
                      l10n.rentBindLabelSoc,
                      _numberOrDash(battery.soc),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      l10n.rentBindLabelSoh,
                      _numberOrDash(battery.soh),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: const Color(0xFFEEEEEE),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      l10n.rentBindLabelCycle,
                      _numberOrDash(battery.cycle),
                    ),
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
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: _fieldTitleColor),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black06Text,
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
            style: const TextStyle(fontSize: 14, color: _fieldTitleColor),
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
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderColor),
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
              ? () => _showPaymentSheet(notifier, state)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            disabledBackgroundColor: const Color(0xFFE8F5E9),
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: state.submitting
              ? const SizedBox(width: 20, height: 20, child: SizedBox.shrink())
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
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    await _queryDevice(result, ref.read(rentBindProvider.notifier));
  }

  Future<void> _queryDevice(String sn, RentBindNotifier notifier) async {
    final ok = await notifier.queryDevice(sn);
    if (!mounted || ok) return;
    showToast(context.l10n.rentBindNoDeviceInfo);
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
    bool advancedMode,
    String initialCardNum,
  ) async {
    final result = await RentApplicantSheet.show(
      context,
      notifier,
      advancedMode: advancedMode,
      initialCardNum: initialCardNum,
    );
    if (result == null || !mounted) return;
    final email = result.email.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      showToast(context.l10n.offlineRegisterEmailInvalid);
      return;
    }
    final latestState = ref.read(rentBindProvider);
    if (latestState.selectedPack == null) return;
    final l10n = context.l10n;
    final success = await notifier.submit(
      address: result.address,
      birthday: result.birthday,
      cardNum: result.cardNum,
      email: result.email,
      firstName: result.firstName,
      lastName: result.lastName,
      idNumber: result.idNumber,
      phone: result.phone,
      deviceSn: _snController.text.trim(),
      cardImgUrl: result.cardImgUrl,
      personImgUrl: result.personImgUrl,
    );

    if (!mounted) return;
    if (!success) {
      showToast(l10n.rentBindFailed);
    }
  }

  Future<void> _showPaymentSheet(
    RentBindNotifier notifier,
    RentBindState state,
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
    final useAdvancedApplicant = paymentResult.paySource != 2;
    final selectedCardNum = await SelectApplicantSheet.show(
      context,
      title: context.l10n.rentBindSelectApplicant,
      hintText: context.l10n.rentBindUserIdHint,
      submitText: context.l10n.rentBindSubmit,
      onQueryUser: (cardNum) async {
        await notifier.queryUser(cardNum);
        if (!mounted) return false;
        final user = ref.read(rentBindProvider).user;
        return user?.cardNum == cardNum;
      },
    );
    if (selectedCardNum == null || !mounted) return;
    await _showApplicantSheet(notifier, useAdvancedApplicant, selectedCardNum);
  }

  String _carModelText(CarVo car) {
    return _firstValid([car.carModel, car.carType, car.model]);
  }

  String _batteryModelText(BatteryVo battery) {
    return _firstValid([battery.batModel, battery.batteryType, battery.model]);
  }

  String _carSpecText(CarVo car) {
    return _firstValid([car.carSpec, car.spec]);
  }

  String _batterySpecText(BatteryVo battery) {
    return _firstValid([battery.batSpec, battery.spec]);
  }

  String _numberOrDash(int? value) {
    return value == null ? '-' : value.toString();
  }

  String _firstValid(List<String?> values) {
    for (final value in values) {
      final current = value?.trim();
      if (current != null &&
          current.isNotEmpty &&
          current != '-' &&
          current.toLowerCase() != 'null') {
        return current;
      }
    }
    return '-';
  }

  String? _normalizedImageUrl(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty || value == '-' || value == 'null') {
      return null;
    }
    final first = value
        .split(',')
        .map((item) => item.trim())
        .firstWhere(
          (item) =>
              item.isNotEmpty && item != '-' && item.toLowerCase() != 'null',
          orElse: () => '',
        );
    return first.isEmpty ? null : first;
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
                              _buildPeriodText(pack, l10n),
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

  String _buildPeriodText(Pack pack, dynamic l10n) {
    final periodValue = pack.duration ?? 30;
    final infoType = pack.infoType;
    if (infoType == 0 || (infoType == null && periodValue == 30)) {
      return l10n.rentBindPeriodMonthly;
    }
    return l10n.rentBindPeriodFixedDays(periodValue);
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
    return BindSuccessPage(
      appBarTitle: l10n.rentBindTitle,
      successTitle: l10n.rentBindSuccessTitle,
      messageSpans: [
        TextSpan(
          text: paySource == 2
              ? l10n.rentBindSuccessMessageOnline
              : l10n.rentBindSuccessMessageCash,
        ),
        TextSpan(
          text: ' ${l10n.rentBindSuccessTimeout}',
          style: TextStyle(
            color: Color(0xFFFF9800),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
      documentNo: documentNo,
      documentNoLabel: l10n.rentBindDocumentNumber,
      copiedToast: l10n.rentBindCopied,
      returnButtonText: l10n.rentBindReturnWorkbench,
      onBack: onReturn,
      onReturn: onReturn,
      successIconSize: 32,
      successTitleSize: 18,
    );
  }
}
