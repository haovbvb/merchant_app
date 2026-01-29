import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/service_plan.dart';
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

  @override
  void dispose() {
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
      backgroundColor: const Color(0xFFF5F5F5),
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
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
            color: Color(0xFF333333),
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
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showPackageSheet(context, notifier),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE)),
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
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _snController,
                  decoration: InputDecoration(
                    hintText: l10n.sellBindDeviceSnHint,
                    hintStyle: const TextStyle(color: Color(0xFF999999)),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
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
                child: AppIcons.scanIcon(
                  size: 24,
                  color: const Color(0xFF333333),
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
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
          ),
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
          onPressed: isEnabled
              ? () => _handleSubmit(context, state, notifier)
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
          child: Text(
            l10n.sellBindSubmit,
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
    ref.read(sellBindProvider.notifier).queryDevice(result);
  }

  Future<void> _showPackageSheet(
    BuildContext context,
    SellBindNotifier notifier,
  ) async {
    final selected = await PackageSheet.show(context, notifier);
    if (selected != null) {
      notifier.selectPlan(selected);
    }
  }

  Future<void> _handleSubmit(
    BuildContext context,
    SellBindState state,
    SellBindNotifier notifier,
  ) async {
    final l10n = context.l10n;

    // Step 1: Select Applicant
    final applicantResult = await ApplicantSheet.show(context, notifier);
    if (applicantResult == null || !mounted) return;

    // Step 2: Select Payment
    final paymentResult = await PaymentSheet.show(
      context,
      notifier,
      state.selectedPlan!.packageAmount ?? 0,
    );
    if (paymentResult == null || !mounted) return;

    // Step 3: Validate device matches package
    final device = state.deviceInfo;
    final plan = state.selectedPlan;
    if (device != null && plan != null) {
      final deviceModel = device.batteryVo?.model ?? device.carVo?.model;
      final planModel = plan.batteryType ?? plan.carType;
      if (deviceModel != null && planModel != null && deviceModel != planModel) {
        _showModelMismatchDialog(context, l10n);
        return;
      }
    }

    // Step 4: Submit
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

  void _showModelMismatchDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.sellBindUnableSubmit,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.sellBindModelMismatch,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.confirm),
            ),
          ),
        ],
      ),
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
    final modelType = plan.batteryType != null ? 'Battery' : 'Vehicle';
    final model = plan.batteryType ?? plan.carType ?? '-';

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
          Row(
            children: [
              Text(
                'Applicable Models:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$modelType · $model',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
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
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag('Battery · ${battery.model ?? '-'}'),
                          const SizedBox(width: 8),
                          _buildTag(battery.spec ?? '-'),
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
                _buildMetric('SOC', '${battery.soc ?? 0}%'),
                _buildMetric('SOH', '${battery.soh ?? 0}'),
                _buildMetric('Cycle', '${battery.cycle ?? 0}'),
              ],
            ),
          ),
        ],
      ),
    );
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
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
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
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag('Vehicle · ${car.model}'),
                          const SizedBox(width: 8),
                          _buildTag(car.spec),
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

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDDDDDD)),
        borderRadius: BorderRadius.circular(4),
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

  Widget _buildMetric(String label, String value) {
    return Expanded(
      child: Column(
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
      ),
    );
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
      backgroundColor: const Color(0xFFF5F5F5),
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
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.sellBindSuccessTitle,
                style: const TextStyle(
                  fontSize: 20,
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
                  ),
                  children: [
                    TextSpan(text: message.split('30')[0]),
                    const TextSpan(
                      text: '30 minutes',
                      style: TextStyle(color: Color(0xFFFF9800)),
                    ),
                    if (message.split('30').length > 1)
                      TextSpan(text: message.split('30')[1].replaceFirst(' minutes', '')),
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
                            color: Color(0xFF333333),
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
                child: Text(l10n.sellBindReturnWorkbench),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
