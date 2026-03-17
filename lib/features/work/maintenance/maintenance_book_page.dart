import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/image_source_action_sheet.dart';
import 'package:merchant_app/data/models/maintenance.dart';
import 'package:merchant_app/features/work/device/device_search_page.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';
import 'package:merchant_app/features/work/payment/widgets/work_payment_sheet.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MaintenanceBookPage extends ConsumerStatefulWidget {
  const MaintenanceBookPage({super.key});

  @override
  ConsumerState<MaintenanceBookPage> createState() =>
      _MaintenanceBookPageState();
}

class _MaintenanceBookPageState extends ConsumerState<MaintenanceBookPage> {
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _snFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(maintenanceBookProvider.notifier).clearAll();
    });
    _snController.clear();
    _noteController.clear();
    _snFocusNode.addListener(_onSnFocusChanged);
  }

  void _onSnFocusChanged() {
    if (_snFocusNode.hasFocus) return;
    final text = _snController.text.trim();
    if (text.isEmpty) return;
    _fetchAppointmentAndResetInput();
  }

  Future<void> _fetchAppointmentAndResetInput() async {
    final notifier = ref.read(maintenanceBookProvider.notifier);
    await notifier.fetchAppointment();
    if (!mounted) return;
    _noteController.clear();
  }

  @override
  void dispose() {
    _snFocusNode
      ..removeListener(_onSnFocusChanged)
      ..dispose();
    _snController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(maintenanceBookProvider);
    final notifier = ref.read(maintenanceBookProvider.notifier);

    final canConfirm = state.appointment != null && state.note.trim().isNotEmpty;

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
                                'assets/android/mipmap-xxhdpi/icon_schedule_maintenance.png',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.maintenanceBookTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xE6000000),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Vehicle SN section
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
                            label: l10n.maintenanceSnLabel,
                            hint: l10n.maintenanceSnHint,
                            controller: _snController,
                            focusNode: _snFocusNode,
                            onChanged: notifier.updateSn,
                            onScan: _scanSn,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          // Vehicle info card
                          if (state.appointment != null)
                            _VehicleInfoCard(
                              appointment: state.appointment!,
                              l10n: l10n,
                              onCallPhone: _callPhone,
                              onViewRecords: _viewRecords,
                            )
                          else
                            _EmptyInfoCard(text: l10n.maintenanceEmptyInfo),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Maintenance Log section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.maintenanceNoteLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _noteController,
                              decoration: InputDecoration(
                                hintText: l10n.maintenanceNoteHint,
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 4,
                              maxLength: 200,
                              onChanged: notifier.updateNote,
                            ),
                          ],
                        ),
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
                  onPressed: canConfirm
                      ? () => _showCostDialog(context, l10n, notifier)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    disabledBackgroundColor:
                        AppColors.primaryColor.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    l10n.maintenanceSubmit,
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
    FocusNode? focusNode,
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
              fontSize: 14,
              color: Color(0xE6000000),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) {
                    _fetchAppointmentAndResetInput();
                  },
                ),
              ),
              if (onScan != null)
                GestureDetector(
                  onTap: onScan,
                  child: AppIcons.scanIcon(
                    size: 24,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          allowManualInput: false,
          parseDeviceSn: true,
          // deviceType: 2,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    final notifier = ref.read(maintenanceBookProvider.notifier);
    notifier.updateSn(result);
    await _fetchAppointmentAndResetInput();
  }

  Future<void> _callPhone(String phone) async {
    if (phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _viewRecords(String sn) {
    if (sn.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeviceSearchPage(
          readOnly: true,
          initialKeyword: sn,
          deviceType: 2,
          initialTabIndex: 2,
        ),
      ),
    );
  }

  Future<void> _showCostDialog(
    BuildContext context,
    AppLocalizations l10n,
    MaintenanceBookNotifier notifier,
  ) async {
    notifier.clearCostDialog();
    final result = await showWorkPaymentSheet(
      context: context,
      l10n: l10n,
      title: l10n.maintenanceCostsTitle,
      totalLabel: l10n.maintenanceTotalLabel,
      amountHint: l10n.maintenanceTotalHint,
      paymentMethodsLabel: l10n.maintenancePaymentMethods,
      payTypeCashText: l10n.maintenancePayCash,
      payTypeOnlineText: l10n.maintenancePayOnline,
      uploadVoucherText: l10n.maintenanceUploadVoucher,
      confirmButtonText: l10n.maintenanceSubmit,
      initialPayType: 2,
      maxAttachments: 5,
      showUploadCount: true,
      requireAttachmentsForCash: false,
      onUploadImage: notifier.uploadVoucher,
      onConfirmPayment: (submit) async {
        notifier.updateAmount(submit.fee);
        notifier.updatePaySource(submit.payType);
        notifier.replaceVoucherImages(submit.attachments);
        return true;
      },
    );
    if (!mounted || result != true) return;

    final success = await notifier.submitMaintenance();
    if (!mounted) return;
    if (success) {
      notifier.clearAll();
      _snController.clear();
      _noteController.clear();
      Navigator.of(context).pop(true);
    }
  }
}

class _EmptyInfoCard extends StatelessWidget {
  const _EmptyInfoCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({
    required this.appointment,
    required this.l10n,
    required this.onCallPhone,
    required this.onViewRecords,
  });

  final BookMaintenanceBean appointment;
  final AppLocalizations l10n;
  final ValueChanged<String> onCallPhone;
  final ValueChanged<String> onViewRecords;

  @override
  Widget build(BuildContext context) {
    final username = (appointment.username ?? '').trim();
    final fullName = '${appointment.firstName ?? ''} ${appointment.lastName ?? ''}'.trim();
    final displayName = username.isNotEmpty
        ? username
        : (fullName.isNotEmpty ? fullName : '-');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Vehicle info row
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Vehicle image, SN, model, spec
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: appointment.img != null && appointment.img!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(appointment.img!, fit: BoxFit.contain),
                              )
                            : const Icon(Icons.electric_moped, size: 32, color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.sn ?? '-',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _Tag(text: appointment.carModel ?? '-'),
                                const SizedBox(width: 8),
                                _Tag(text: appointment.carSpec ?? '-'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bind User section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.maintenanceBindUser,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: appointment.avatar != null &&
                                      appointment.avatar!.isNotEmpty
                                  ? NetworkImage(appointment.avatar!)
                                  : null,
                              child: appointment.avatar == null ||
                                      appointment.avatar!.isEmpty
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'ID: ${appointment.cardNum ?? '-'}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => onCallPhone(appointment.phone ?? ''),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primaryColor),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: AppColors.primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Appointment info
                  _InfoRow(
                    label: l10n.maintenanceAppointmentNo,
                    value: appointment.reservationNo ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: l10n.maintenanceAppointmentDate,
                    value: _formatDate(appointment.reservationDate),
                  ),
                  const SizedBox(height: 8),
                  // Maintenance Records
                  GestureDetector(
                    onTap: () => onViewRecords(appointment.sn ?? ''),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _maintenanceRecordsText(context, l10n),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Riding behavior section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_box_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.maintenanceRidingBehavior,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        label: l10n.maintenanceAvgMileage,
                        value: _formatTwoDecimals(appointment.day30AvgMilePerDay),
                        unit: 'km',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    Expanded(
                      child: _StatItem(
                        label: l10n.maintenanceAvgSpeed,
                        value: _formatTwoDecimals(appointment.day30AvgSpeed),
                        unit: 'km/hr',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    Expanded(
                      child: _StatItem(
                        label: l10n.maintenanceAvgSwapCount,
                        value: _formatTwoDecimals(appointment.day30AvgSwapCount),
                        unit: '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    return DateFormatUtils.formatString(
      dateStr,
      pattern: 'dd MMM, yyyy',
      fallback: dateStr,
    );
  }

  String _formatTwoDecimals(num? value) {
    return (value ?? 0).toDouble().toStringAsFixed(2);
  }
}

String _maintenanceRecordsText(BuildContext context, AppLocalizations l10n) {
  final isZh = Localizations.localeOf(context).languageCode
      .toLowerCase()
      .startsWith('zh');
  return isZh ? '保养记录' : l10n.maintenanceRecords;
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MaintenanceCostSheet extends ConsumerStatefulWidget {
  const _MaintenanceCostSheet({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_MaintenanceCostSheet> createState() =>
      _MaintenanceCostSheetState();
}

class _MaintenanceCostSheetState extends ConsumerState<_MaintenanceCostSheet> {
  final TextEditingController _amountController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(maintenanceBookProvider);
    final notifier = ref.read(maintenanceBookProvider.notifier);
    final isCash = state.paySource == 1;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        widget.l10n.maintenanceCostsTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: const Icon(Icons.close, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                // Total amount
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.maintenanceTotalLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.l10n.maintenanceTotalHint,
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                        onChanged: notifier.updateAmount,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Payment Methods
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.maintenancePaymentMethods,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _PaymentOption(
                        label: widget.l10n.maintenancePayOnline,
                        selected: !isCash,
                        onTap: () => notifier.updatePaySource(2),
                      ),
                      const Divider(height: 1),
                      _PaymentOption(
                        label: widget.l10n.maintenancePayCash,
                        selected: isCash,
                        onTap: () => notifier.updatePaySource(1),
                      ),
                    ],
                  ),
                ),
                // Upload Voucher (only for Cash)
                if (isCash) ...[
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.l10n.maintenanceUploadVoucher,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _VoucherGrid(
                          images: state.voucherImages,
                          uploading: _uploading,
                          onAdd: _pickImage,
                          onRemove: notifier.removeVoucherImage,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Confirm button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                      onPressed: state.canConfirmCost && !state.submitting
                          ? () => _submit(context)
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        disabledBackgroundColor:
                            AppColors.primaryColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: state.submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: SizedBox.shrink(),
                            )
                          : Text(
                              widget.l10n.maintenanceSubmit,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final notifier = ref.read(maintenanceBookProvider.notifier);
    final source = await ImageSourceActionSheet.show(context);
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    final url = await notifier.uploadVoucher(picked.path);
    if (!mounted) return;
    setState(() => _uploading = false);

    if (url != null) {
      notifier.addVoucherImage(url);
    } else {
      showToast('Upload failed');
    }
  }

  void _submit(BuildContext context) {
    Navigator.of(context).pop(true);
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.primaryColor : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherGrid extends StatelessWidget {
  const _VoucherGrid({
    required this.images,
    required this.uploading,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> images;
  final bool uploading;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...images.asMap().entries.map((entry) {
          return Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(entry.value),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => onRemove(entry.key),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }),
        if (images.length < 5)
          GestureDetector(
            onTap: uploading ? null : onAdd,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: uploading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: SizedBox.shrink(),
                      ),
                    )
                  : const Icon(Icons.camera_alt, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
