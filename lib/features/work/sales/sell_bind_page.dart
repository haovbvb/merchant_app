import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/service_plan.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/applicant_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/bind_success_page.dart';
import 'package:merchant_app/features/work/sales/widgets/package_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/payment_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/select_applicant_sheet.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class SellBindPage extends ConsumerStatefulWidget {
  const SellBindPage({super.key});

  @override
  ConsumerState<SellBindPage> createState() => _SellBindPageState();
}

class _SellBindPageState extends ConsumerState<SellBindPage> {
  final _snController = TextEditingController();
  final _snFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(sellBindProvider.notifier);
      notifier.reset();
      final shopNo = AuthSession.instance.current?.shopNo ?? '';
      if (shopNo.isNotEmpty) {
        notifier.loadShopPayConfig(shopNo);
      }
    });
    _snController.clear();
    _snFocusNode.addListener(() {
      if (!_snFocusNode.hasFocus) {
        _queryDeviceByInput();
      }
    });
  }

  @override
  void dispose() {
    ref.read(sellBindProvider.notifier).reset();
    _snFocusNode.dispose();
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(sellBindProvider);
    final notifier = ref.read(sellBindProvider.notifier);

    // 成功页面
    if (state.submitSuccess && state.documentNo != null) {
      return _SuccessPage(
        documentNo: state.documentNo!,
        paySource: state.paySource,
        onBack: () {
          notifier.reset();
          _snController.clear();
        },
        onReturn: () {
          notifier.reset();
          _snController.clear();
          Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Header
                  _buildHeader(l10n),
                  const SizedBox(height: 24),

                  // Package Section
                  _buildPackageSection(l10n, state, notifier),
                  const SizedBox(height: 16),

                  // Device SN Section
                  _buildDeviceSection(l10n, state, notifier),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Submit Button
          _buildSubmitButton(l10n, state, notifier),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/android/mipmap-xxhdpi/icon_sale_bind.webp',
              width: 64,
              height: 64,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.sellBindTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.black06Text,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageSection(
    AppLocalizations l10n,
    SellBindState state,
    SellBindNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sellBindPackage,
            style: const TextStyle(fontSize: 14, color: AppColors.black06Text),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showPackageSheet(context, notifier),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.selectedPlan?.infoName?.trim().isNotEmpty == true
                          ? state.selectedPlan!.infoName!
                          : l10n.sellBindPackageHint,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            state.selectedPlan?.infoName?.trim().isNotEmpty ==
                                true
                            ? AppColors.black06Text
                            : const Color(0xFF999999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (state.selectedPlan != null)
            _PackageCard(plan: state.selectedPlan!)
          else
            _buildEmptyCard(l10n.sellBindNoPackageInfo),
        ],
      ),
    );
  }

  Widget _buildDeviceSection(
    AppLocalizations l10n,
    SellBindState state,
    SellBindNotifier notifier,
  ) {
    if (state.selectedPlan == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sellBindDeviceSn,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black06Text,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmptyCard(l10n.sellBindChoosePackage),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sellBindDeviceSn,
            style: const TextStyle(fontSize: 14, color: AppColors.black06Text),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _snController,
                  focusNode: _snFocusNode,
                  decoration: InputDecoration(
                    hintText: l10n.sellBindDeviceSnHint,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                  onChanged: (value) {
                    final sn = value.trim();
                    final currentSn =
                        state.deviceInfo?.batteryVo?.sn ??
                        state.deviceInfo?.carVo?.sn ??
                        '';
                    if (sn.isEmpty ||
                        (currentSn.isNotEmpty && sn != currentSn)) {
                      notifier.clearDeviceInfo();
                    }
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _queryDevice(value.trim(), notifier);
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
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          if (state.deviceInfo != null)
            _DeviceInfoCard(deviceInfo: state.deviceInfo!)
          else
            _buildEmptyCard(l10n.sellBindNoDeviceInfo),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    AppLocalizations l10n,
    SellBindState state,
    SellBindNotifier notifier,
  ) {
    final isEnabled = state.selectedPlan != null && state.deviceInfo != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: const Color(0xFFF5F5F5),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isEnabled ? () => _handleSubmit(state, notifier) : null,
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
          child: Text(
            l10n.sellBindSubmit,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            const QrScanPage(allowManualInput: false, parseDeviceSn: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    await _queryDevice(result, ref.read(sellBindProvider.notifier));
  }

  void _queryDeviceByInput() {
    final sn = _snController.text.trim();
    final notifier = ref.read(sellBindProvider.notifier);
    if (sn.isEmpty) {
      notifier.clearDeviceInfo();
      return;
    }
    _queryDevice(sn, notifier);
  }

  Future<void> _queryDevice(String sn, SellBindNotifier notifier) async {
    final ok = await notifier.queryDevice(sn);
    if (!mounted || ok) return;
    showToast(context.l10n.sellBindNoDeviceInfo);
  }

  Future<void> _showPackageSheet(
    BuildContext context,
    SellBindNotifier notifier,
  ) async {
    final selected = await PackageSheet.show(context, notifier);
    if (selected != null) {
      notifier.selectPlan(selected);
      _snController.clear();
    }
  }

  Future<void> _handleSubmit(
    SellBindState state,
    SellBindNotifier notifier,
  ) async {
    final pageContext = context;
    final l10n = pageContext.l10n;

    // Step 1: Select Payment
    final paymentResult = await PaymentSheet.show(
      pageContext,
      notifier,
      state.selectedPlan!.packageAmount ?? 0,
      state.shopPaymentMethod,
    );
    if (paymentResult == null || !mounted || !pageContext.mounted) return;

    // Step 2: Select Applicant
    final useAdvancedApplicant =
        !(paymentResult.paySource == 2 && paymentResult.payType == 1);

    // Step 2.1: Search applicant in lightweight selector first.
    final selectedCardNum = await SelectApplicantSheet.show(
      pageContext,
      title: pageContext.l10n.sellBindSelectApplicant,
      hintText: pageContext.l10n.sellBindUserIdHint,
      submitText: pageContext.l10n.sellBindSubmit,
      onQueryUser: (cardNum) async {
        await notifier.queryUser(cardNum);
        if (!mounted) return false;
        final user = ref.read(sellBindProvider).user;
        return user?.cardNum == cardNum;
      },
    );
    if (selectedCardNum == null || !mounted || !pageContext.mounted) return;

    // Step 2.2: Open applicant detail page when user exists.
    final applicantResult = await ApplicantSheet.show(
      pageContext,
      notifier,
      useAdvancedApplicant,
      initialCardNum: selectedCardNum,
    );
    if (applicantResult == null || !mounted || !pageContext.mounted) return;

    final latestState = ref.read(sellBindProvider);

    // Step 3: Validate required data
    final device = latestState.deviceInfo;
    final plan = latestState.selectedPlan;
    if (device == null || plan == null) {
      showToast(l10n.sellBindUnableSubmit);
      return;
    }

    // Step 4: Submit directly from applicant flow and show success page on state change.
    final email = applicantResult.email.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      showToast(l10n.offlineRegisterEmailInvalid);
      return;
    }

    final ok = await notifier.submit(
      address: applicantResult.address,
      birthday: applicantResult.birthday,
      cardNum: applicantResult.cardNum,
      email: applicantResult.email,
      firstName: applicantResult.firstName,
      lastName: applicantResult.lastName,
      idNumber: applicantResult.idNumber,
      phone: applicantResult.phone,
      cardImgUrl: applicantResult.cardImgUrl,
      personImgUrl: applicantResult.personImgUrl,
    );
    if (!mounted) return;
    if (!ok) {
      showToast(l10n.sellBindFailed);
    }
  }
}

// Package Card
class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.plan});

  final ServicePlanBean plan;

  @override
  Widget build(BuildContext context) {
    final price = plan.packageAmount?.toStringAsFixed(2) ?? '0.00';
    final applicableModel = _resolveApplicableModelValue(plan);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              image: DecorationImage(
                image: AssetImage(
                  'assets/android/mipmap-xxhdpi/icon_bind_package_topbg.webp',
                ),
                fit: BoxFit.contain,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.infoName ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFCCCCCC),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F8FC),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: _buildInfoRow(
              context,
              label: _applicableModelLabel(context),
              value: applicableModel,
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == '-') {
      return '-';
    }
    return value;
  }

  String? _resolveTypeValue(ServicePlanBean plan) {
    final carType = plan.carType?.trim();
    if (carType != null && carType.isNotEmpty && carType != '-') {
      return carType;
    }
    final batteryType = plan.batteryType?.trim();
    if (batteryType != null && batteryType.isNotEmpty && batteryType != '-') {
      return batteryType;
    }
    return null;
  }

  String _resolveApplicableModelValue(ServicePlanBean plan) {
    final typeValue = _valueOrDash(_resolveTypeValue(plan));
    final hasCarType =
        plan.carType != null &&
        plan.carType!.trim().isNotEmpty &&
        plan.carType!.trim() != '-';
    final hasBatteryType =
        plan.batteryType != null &&
        plan.batteryType!.trim().isNotEmpty &&
        plan.batteryType!.trim() != '-';

    final category = hasCarType && hasBatteryType
        ? '车辆/电池'
        : hasCarType
        ? '车辆'
        : hasBatteryType
        ? '电池'
        : '车辆/电池';

    return '$category · $typeValue';
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: Color(0xFF8B94A3)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.black06Text),
          ),
        ),
      ],
    );
  }

  String _applicableModelLabel(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode.toLowerCase().startsWith('zh')) {
      return '适用机型';
    }
    return 'Applicable Model';
  }
}

// Device Info Card
class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({required this.deviceInfo});

  final BatterOrVehicleInfo deviceInfo;

  @override
  Widget build(BuildContext context) {
    if (deviceInfo.batteryVo != null) {
      return _BatteryCard(battery: deviceInfo.batteryVo!);
    }
    if (deviceInfo.carVo != null) {
      return _VehicleCard(car: deviceInfo.carVo!);
    }
    return const SizedBox.shrink();
  }
}

class _BatteryCard extends StatelessWidget {
  const _BatteryCard({required this.battery});

  final BatteryVo battery;

  @override
  Widget build(BuildContext context) {
    final model = _valueOrDash(
      battery.batModel ?? battery.model ?? battery.batteryType,
    );
    final spec = _valueOrDash(battery.batSpec ?? battery.spec);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Battery image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: battery.img != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            battery.img!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.battery_charging_full,
                              size: 32,
                              color: Color(0xFF999999),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.battery_charging_full,
                          size: 32,
                          color: Color(0xFF999999),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        battery.sn ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag('Battery · $model'),
                          const SizedBox(width: 8),
                          _buildTag(spec),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildMetric('SOC', _formatMetric(battery.soc, suffix: '%')),
                _buildMetric('SOH', _formatMetric(battery.soh)),
                _buildMetric('Cycle', _formatMetric(battery.cycle)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == '-') {
      return '-';
    }
    return value;
  }

  String _formatMetric(int? value, {String suffix = ''}) {
    if (value == null) return '-';
    return '$value$suffix';
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.car});

  final CarVo car;

  @override
  Widget build(BuildContext context) {
    final model = _valueOrDash(_resolveModelValue(car));
    final spec = _valueOrDash(car.carSpec ?? car.spec);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Vehicle image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: car.img != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            car.img!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.electric_moped,
                              size: 32,
                              color: Color(0xFF999999),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.electric_moped,
                          size: 32,
                          color: Color(0xFF999999),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.sn ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag('Vehicle · $model'),
                          const SizedBox(width: 8),
                          _buildTag(spec),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _buildMetric('VIN', car.vin ?? '-'),
                _buildMetric('Plate Number', car.carNumber ?? '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == '-') {
      return '-';
    }
    return value;
  }

  String? _resolveModelValue(CarVo car) {
    final carModel = car.carModel?.trim();
    if (carModel != null && carModel.isNotEmpty && carModel != '-') {
      return carModel;
    }
    final carType = car.carType?.trim();
    if (carType != null && carType.isNotEmpty && carType != '-') {
      return carType;
    }
    return car.model;
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
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
      ),
    );
  }
}

// Success Page
class _SuccessPage extends StatelessWidget {
  const _SuccessPage({
    required this.documentNo,
    required this.paySource,
    required this.onBack,
    required this.onReturn,
  });

  final String documentNo;
  final int paySource;
  final VoidCallback onBack;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = paySource == 2
        ? l10n.sellBindSuccessMessageOnline
        : l10n.sellBindSuccessMessageCash;
    final messageParts = message.split('24');
    return BindSuccessPage(
      appBarTitle: l10n.sellBindTitle,
      successTitle: l10n.sellBindSuccessTitle,
      messageSpans: [
        TextSpan(text: messageParts.isNotEmpty ? messageParts.first : message),
        TextSpan(
          text: l10n.swapBindSuccessTimeout,
          style: const TextStyle(color: Color(0xFFFF9800)),
        ),
        // if (messageParts.length > 1)
        //   TextSpan(text: messageParts[1].replaceFirst(' minutes', '')),
      ],
      documentNo: documentNo,
      documentNoLabel: l10n.sellBindDocumentNumber,
      copiedToast: l10n.sellBindCopied,
      returnButtonText: l10n.sellBindReturnWorkbench,
      onBack: onBack,
      onReturn: onReturn,
      successIconSize: 40,
      successTitleSize: 20,
    );
  }
}
