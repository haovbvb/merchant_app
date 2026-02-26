import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/purchasing_user.dart';
import 'package:merchant_app/data/models/service_plan.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/applicant_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/package_sheet.dart';
import 'package:merchant_app/features/work/sales/widgets/payment_sheet.dart';
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
    final notifier = ref.read(sellBindProvider.notifier);
    notifier.reset();
    final shopNo = AuthSession.instance.current?.shopNo ?? '';
    if (shopNo.isNotEmpty) {
      notifier.loadShopPayConfig(shopNo);
    }
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
        onReturn: () {
          notifier.reset();
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
                      l10n.sellBindPackageHint,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
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
                      notifier.queryDevice(value.trim());
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
      MaterialPageRoute(builder: (_) => const QrScanPage(parseDeviceSn: true)),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    ref.read(sellBindProvider.notifier).queryDevice(result);
  }

  void _queryDeviceByInput() {
    final sn = _snController.text.trim();
    final notifier = ref.read(sellBindProvider.notifier);
    if (sn.isEmpty) {
      notifier.clearDeviceInfo();
      return;
    }
    notifier.queryDevice(sn);
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
    final applicantResult = await ApplicantSheet.show(
      pageContext,
      notifier,
      false,
    );
    if (applicantResult == null || !mounted || !pageContext.mounted) return;

    final latestState = ref.read(sellBindProvider);

    // Step 3: Validate device matches package
    final device = latestState.deviceInfo;
    final plan = latestState.selectedPlan;
    if (device == null || plan == null) {
      showToast(l10n.sellBindUnableSubmit);
      return;
    }
    final deviceModel =
        device.batteryVo?.batModel ??
        device.batteryVo?.model ??
        device.carVo?.carModel ??
        device.carVo?.model;
    final planModel = plan.batteryType ?? plan.carType;
    if (deviceModel != null && planModel != null && deviceModel != planModel) {
      _showModelMismatchDialog(pageContext, l10n);
      return;
    }

    // Step 4: Confirm and Submit
    await Navigator.of(pageContext).push<bool>(
      MaterialPageRoute(
        builder: (_) => _SellBindConfirmPage(
          applicant: applicantResult,
          payment: paymentResult,
          plan: plan,
          device: device,
          user: latestState.user,
        ),
      ),
    );
  }

  void _showModelMismatchDialog(BuildContext context, AppLocalizations l10n) {
    ConfirmDialog.alert(
      context: context,
      message: l10n.sellBindModelMismatch,
      buttonText: l10n.confirm,
    );
  }
}

// Package Card
class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.plan});

  final ServicePlanBean plan;

  @override
  Widget build(BuildContext context) {
    final price = plan.packageAmount?.toStringAsFixed(2) ?? '0.00';
    final hasBatteryType = (plan.batteryType ?? '').isNotEmpty;
    final hasCarType = (plan.carType ?? '').isNotEmpty;
    final typeLabel = hasBatteryType
        ? 'Battery'
        : hasCarType
        ? 'Vehicle'
        : 'Device';
    final typeValue = _valueOrDash(_resolveTypeValue(plan));
    final modelValue = _valueOrDash(_resolveModelValue(plan));

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D4A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildInfoTag('$typeLabel · $typeValue'),
              _buildInfoTag('Model · $modelValue'),
            ],
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

  String? _resolveModelValue(ServicePlanBean plan) {
    final model = plan.deviceModel?.trim();
    if (model != null && model.isNotEmpty && model != '-') {
      return model;
    }
    return _resolveTypeValue(plan);
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
    );
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

class _SellBindConfirmPage extends ConsumerStatefulWidget {
  const _SellBindConfirmPage({
    required this.applicant,
    required this.payment,
    required this.plan,
    required this.device,
    required this.user,
  });

  final ApplicantResult applicant;
  final PaymentResult payment;
  final ServicePlanBean plan;
  final BatterOrVehicleInfo device;
  final PurchasingUser? user;

  @override
  ConsumerState<_SellBindConfirmPage> createState() =>
      _SellBindConfirmPageState();
}

class _SellBindConfirmPageState extends ConsumerState<_SellBindConfirmPage> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = widget.user;
    final deviceSn =
        widget.device.batteryVo?.sn ?? widget.device.carVo?.sn ?? '-';

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.sellBindTitle,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    title: l10n.sellBindDeviceSection,
                    children: [
                      _buildInfoRow(l10n.sellBindDeviceSn, deviceSn),
                      _buildInfoRow(
                        l10n.sellBindPackage,
                        widget.plan.infoName ?? '-',
                      ),
                      _buildInfoRow(
                        l10n.sellBindPlanPrice,
                        '\$${(widget.plan.packageAmount ?? 0).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    title: l10n.sellBindPaymentSection,
                    children: [
                      _buildInfoRow(
                        l10n.sellBindPaymentMethods,
                        widget.payment.paySource == 1
                            ? l10n.sellBindPayCash
                            : l10n.sellBindPayOnline,
                      ),
                      _buildInfoRow(
                        l10n.sellBindPaymentPeriod,
                        widget.payment.paySource == 1
                            ? l10n.sellBindPayFull
                            : (widget.payment.payType == 1
                                  ? l10n.sellBindPayFull
                                  : l10n.sellBindPayInstallment),
                      ),
                      if (widget.payment.paymentPlan != null)
                        _buildInfoRow(
                          l10n.sellBindPlanPeriod,
                          '${widget.payment.paymentPlan!.period ?? '-'} ${l10n.sellBindPeriods}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSection(
                    title: l10n.sellBindUserSection,
                    children: [
                      _buildInfoRow(
                        l10n.sellBindCardNum,
                        _valueOrDash(user?.cardNum ?? widget.applicant.cardNum),
                      ),
                      _buildInfoRow(
                        l10n.sellBindAccount,
                        _valueOrDash(user?.username),
                      ),
                      _buildInfoRow(
                        l10n.sellBindFirstName,
                        _valueOrDash(
                          user?.firstName ?? widget.applicant.firstName,
                        ),
                      ),
                      _buildInfoRow(
                        l10n.sellBindLastName,
                        _valueOrDash(
                          user?.lastName ?? widget.applicant.lastName,
                        ),
                      ),
                      _buildInfoRow(
                        l10n.sellBindPhone,
                        _valueOrDash(user?.phone ?? widget.applicant.phone),
                      ),
                      _buildInfoRow(
                        l10n.sellBindIdNumber,
                        _valueOrDash(
                          user?.idNumber ?? widget.applicant.idNumber,
                        ),
                      ),
                      _buildInfoRow(
                        l10n.sellBindBirthday,
                        _valueOrDash(
                          user?.birthday ?? widget.applicant.birthday,
                        ),
                      ),
                      _buildInfoRow(
                        l10n.sellBindEmail,
                        _valueOrDash(user?.email ?? widget.applicant.email),
                      ),
                      _buildInfoRow(
                        l10n.sellBindAddress,
                        _valueOrDash(user?.address ?? widget.applicant.address),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            color: const Color(0xFFF5F5F5),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
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
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black06Text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _valueOrDash(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }

  Future<void> _submit() async {
    final email = widget.applicant.email.trim();
    if (email.isNotEmpty && !email.contains('@')) {
      showToast(context.l10n.offlineRegisterEmailInvalid);
      return;
    }
    setState(() => _submitting = true);
    final notifier = ref.read(sellBindProvider.notifier);
    final ok = await notifier.submit(
      address: widget.applicant.address,
      birthday: widget.applicant.birthday,
      cardNum: widget.applicant.cardNum,
      email: widget.applicant.email,
      firstName: widget.applicant.firstName,
      lastName: widget.applicant.lastName,
      idNumber: widget.applicant.idNumber,
      phone: widget.applicant.phone,
      cardImgUrl: widget.applicant.cardImgUrl,
      personImgUrl: widget.applicant.personImgUrl,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      showToast(context.l10n.sellBindFailed);
      return;
    }
    Navigator.of(context).pop(true);
  }
}

// Success Page
class _SuccessPage extends StatelessWidget {
  const _SuccessPage({
    required this.documentNo,
    required this.paySource,
    required this.onReturn,
  });

  final String documentNo;
  final int paySource;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final message = paySource == 2
        ? l10n.sellBindSuccessMessageOnline
        : l10n.sellBindSuccessMessageCash;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: onReturn,
        ),
        title: Text(
          l10n.sellBindTitle,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.sellBindSuccessTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                  children: [
                    TextSpan(text: message.split('30')[0]),
                    const TextSpan(
                      text: '30 minutes',
                      style: TextStyle(color: Color(0xFFFF9800)),
                    ),
                    if (message.split('30').length > 1)
                      TextSpan(
                        text: message
                            .split('30')[1]
                            .replaceFirst(' minutes', ''),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Document Number
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.sellBindDocumentNumber,
                      style: const TextStyle(
                        fontSize: 14,
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
                            color: AppColors.black06Text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: documentNo));
                            showToast(l10n.sellBindCopied);
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
              // Return button
              OutlinedButton(
                onPressed: onReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(l10n.sellBindReturnWorkbench),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
