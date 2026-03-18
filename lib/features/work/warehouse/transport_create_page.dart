import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/city.dart';
import 'package:merchant_app/data/models/warehouse_info.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/warehouse/transport_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class TransportCreatePage extends ConsumerStatefulWidget {
  const TransportCreatePage({
    super.key,
    required this.deviceType,
    this.initialSns = const [],
  });

  final int deviceType;
  final List<String> initialSns;

  @override
  ConsumerState<TransportCreatePage> createState() =>
      _TransportCreatePageState();
}

class _TransportCreatePageState extends ConsumerState<TransportCreatePage> {
  final TextEditingController _trackingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(transportCreateProvider.notifier);
      notifier.resetCreateState();
      notifier.setDeviceType(widget.deviceType);
      notifier.setInitialSns(widget.initialSns);
      notifier.loadMyWarehouse();
      notifier.loadInWarehouseList();
      notifier.loadCities();
    });
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(transportCreateProvider);
    final notifier = ref.read(transportCreateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: Text(_getCreateTitle(l10n))),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 发出仓库
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.deviceIssueWarehouse,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/android/mipmap-xxhdpi/icon_issue_warehouse.webp',
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getWarehouseName(state.myWarehouse),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.myWarehouse?.cityName ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 接收仓库
                  _SectionCard(
                    child: _SelectField(
                      icon:
                          'assets/android/mipmap-xxhdpi/icon_receive_warehouse.png',
                      label: l10n.deviceReceiveWarehouse,
                      value: state.selectedInWarehouse != null
                          ? (state.selectedInWarehouse!.inWarehouseName ??
                                state.selectedInWarehouse!.warehouseName ??
                                '')
                          : l10n.deviceIssuePleaseSelectWarehouse,
                      valueColor: state.selectedInWarehouse != null
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF999999),
                      onTap: () =>
                          _showWarehousePicker(context, l10n, notifier),
                    ),
                  ),
                  // 物流单号
                  _SectionCard(
                    child: _InputField(
                      icon: 'assets/android/mipmap-xxhdpi/icon_tacking.png',
                      label: l10n.deviceIssueTrackingNumber,
                      hintText: l10n.deviceIssuePleaseEnterTracking,
                      value: state.trackingNumber,
                      onTap: () => _showTrackingInputSheet(context, notifier),
                    ),
                  ),
                  // 选择设备
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getSelectDeviceLabel(l10n),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Image.asset(
                                  'assets/android/mipmap-xxhdpi/icon_enter_sn.png',
                                  width: 16,
                                  height: 16,
                                ),
                                label: l10n.deviceIssueEnterSn,
                                outlined: true,
                                onTap: () =>
                                    _showSnInputDialog(context, l10n, notifier),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: Image.asset(
                                  'assets/android/mipmap-xxhdpi/icon_blue_scan.png',
                                  width: 16,
                                  height: 16,
                                ),
                                label: l10n.deviceIssueScanQrCode,
                                outlined: false,
                                onTap: () => _scanAndAdd(context, notifier),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 设备列表
                  if (state.sns.isNotEmpty)
                    Container(
                      color: Colors.white,
                      margin: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: state.sns.asMap().entries.map((entry) {
                          final sn = entry.value;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sn,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.black06Text,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => notifier.removeSn(sn),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: Colors.grey.shade400,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (entry.key < state.sns.length - 1)
                                const Divider(height: 1, indent: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // 底部栏
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.sns.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      l10n.deviceIssueTotalIssued,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: FilledButton(
                    onPressed:
                        state.submitting ||
                            state.sns.isEmpty ||
                            state.selectedInWarehouse == null
                        ? null
                        : () => _submit(context, notifier),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      disabledBackgroundColor: const Color(0xFFCCE5C0),
                    ),
                    child: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCreateTitle(AppLocalizations l10n) {
    switch (widget.deviceType) {
      case 1:
        return l10n.deviceIssueCreateBattery;
      case 2:
        return l10n.deviceIssueCreateVehicle;
      case 3:
        return l10n.deviceIssueCreateStation;
      default:
        return l10n.deviceIssueCreate;
    }
  }

  String _getSelectDeviceLabel(AppLocalizations l10n) {
    switch (widget.deviceType) {
      case 1:
        return l10n.deviceIssueSelectBattery;
      case 2:
        return l10n.deviceIssueSelectVehicle;
      case 3:
        return l10n.deviceIssueSelectStation;
      default:
        return l10n.deviceIssueSelectDevice;
    }
  }

  String _getWarehouseName(WarehouseInfo? info) {
    if (info == null) return '-';
    return info.warehouseName ?? info.outWarehouseName ?? '-';
  }

  Future<void> _showWarehousePicker(
    BuildContext context,
    AppLocalizations l10n,
    TransportCreateNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _WarehousePickerSheet(l10n: l10n, notifier: notifier),
    );
  }

  Future<void> _showSnInputDialog(
    BuildContext context,
    AppLocalizations l10n,
    TransportCreateNotifier notifier,
  ) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              l10n.deviceIssueEnterDeviceSn,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xE60C0C0D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 40,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller: controller,
                                autofocus: true,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                onChanged: (_) => setModalState(() {}),
                                decoration: InputDecoration(
                                  hintText: l10n.deviceIssueEnterDeviceSn,
                                  hintStyle: const TextStyle(
                                    color: Color(0x4D0C0C0D),
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F4F7),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    40,
                                    8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  counterText: '',
                                ),
                                style: const TextStyle(
                                  color: Color(0xE60C0C0D),
                                  fontSize: 15,
                                ),
                              ),
                              if (controller.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    controller.clear();
                                    setModalState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Image.asset(
                                      'assets/android/mipmap-xxhdpi/icon_clear.webp',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFF2F4F7),
                                    foregroundColor: const Color(0xE6000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(l10n.cancel),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(controller.text.trim());
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(l10n.confirm),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    if (result != null && result.isNotEmpty) {
      await notifier.addSn(result);
    }
  }

  Future<void> _showTrackingInputSheet(
    BuildContext context,
    TransportCreateNotifier notifier,
  ) async {
    final l10n = context.l10n;
    _trackingController.value = TextEditingValue(
      text: ref.read(transportCreateProvider).trackingNumber,
      selection: TextSelection.collapsed(
        offset: ref.read(transportCreateProvider).trackingNumber.length,
      ),
    );

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              l10n.deviceIssueTrackingNumber,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Color(0xE60C0C0D),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 40,
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              TextField(
                                controller: _trackingController,
                                autofocus: true,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                onChanged: (_) => setModalState(() {}),
                                decoration: InputDecoration(
                                  hintText: l10n.deviceIssuePleaseEnterTracking,
                                  hintStyle: const TextStyle(
                                    color: Color(0x4D0C0C0D),
                                    fontSize: 15,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F4F7),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    12,
                                    8,
                                    40,
                                    8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  counterText: '',
                                ),
                                style: const TextStyle(
                                  color: Color(0xE60C0C0D),
                                  fontSize: 15,
                                ),
                              ),
                              if (_trackingController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _trackingController.clear();
                                    setModalState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Image.asset(
                                      'assets/android/mipmap-xxhdpi/icon_clear.webp',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(0xFFF2F4F7),
                                    foregroundColor: const Color(0xE6000000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(l10n.cancel),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop(_trackingController.text.trim());
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(l10n.confirm),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null) return;
    notifier.setTrackingNumber(result);
  }

  Future<void> _scanAndAdd(
    BuildContext context,
    TransportCreateNotifier notifier,
  ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          allowManualInput: true,
          parseDeviceSn: true,
          continuousScan: true,
          onContinuousScan: _handleContinuousTransportScan,
        ),
      ),
    );
  }

  Future<String> _handleContinuousTransportScan(String value) async {
    final sn = value.trim();
    if (sn.isEmpty) {
      return context.l10n.scanInvalidQr;
    }

    final currentState = ref.read(transportCreateProvider);
    if (currentState.sns.contains(sn)) {
      return context.l10n.scanAlreadyScanned;
    }

    final notifier = ref.read(transportCreateProvider.notifier);
    await notifier.addSn(sn);
    final updatedState = ref.read(transportCreateProvider);
    if (updatedState.sns.contains(sn)) {
      return context.l10n.scanSuccessEntry;
    }
    return context.l10n.scanEntryFailed;
  }

  Future<void> _submit(
    BuildContext context,
    TransportCreateNotifier notifier,
  ) async {
    final created = await notifier.createIssue();
    if (!context.mounted) return;
    if (created) {
      Navigator.of(context).pop(true);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: child,
    );
  }
}

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(icon, width: 20, height: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.black06Text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(fontSize: 14, color: valueColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.icon,
    required this.label,
    required this.hintText,
    required this.value,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String hintText;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(icon, width: 20, height: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.black06Text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 44,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value.isEmpty ? hintText : value,
                style: TextStyle(
                  fontSize: 14,
                  color: value.isEmpty
                      ? const Color(0x4D0C0C0D)
                      : const Color(0xE60C0C0D),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.outlined,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: outlined ? const Color(0x66000000) : const Color(0xFF56B327),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: outlined
                    ? const Color(0xE60C0C0D)
                    : const Color(0xFF56B327),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WarehousePickerSheet extends ConsumerStatefulWidget {
  const _WarehousePickerSheet({required this.l10n, required this.notifier});

  final AppLocalizations l10n;
  final TransportCreateNotifier notifier;

  @override
  ConsumerState<_WarehousePickerSheet> createState() =>
      _WarehousePickerSheetState();
}

class _WarehousePickerSheetState extends ConsumerState<_WarehousePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCityCode = '';
  String _selectedCityName = '';

  @override
  void initState() {
    super.initState();
    // Reset filters on each open to align with Android behavior.
    _selectedCityCode = '';
    _selectedCityName = '';
    widget.notifier.loadInWarehouseList(keyword: '', cityCode: '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transportCreateProvider);
    final warehouses = state.inWarehouses;
    final selectedWarehouse = state.selectedInWarehouse;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  widget.l10n.deviceIssueChooseWarehouse,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  widget.notifier.loadInWarehouseList(
                    keyword: value,
                    cityCode: _selectedCityCode,
                  );
                },
                decoration: InputDecoration(
                  hintText: widget.l10n.deviceIssueSearchWarehouse,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 城市筛选
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _showCitySheet,
              child: SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Text(
                      _selectedCityName.isEmpty
                          ? widget.l10n.deviceIssueAllCity
                          : _selectedCityName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xFF666666),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // 仓库列表
          Expanded(
            child: _buildWarehouseContent(
              warehouses: warehouses,
              selectedWarehouse: selectedWarehouse,
              loading: state.loading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseContent({
    required List<WarehouseInfo> warehouses,
    required WarehouseInfo? selectedWarehouse,
    required bool loading,
  }) {
    if (warehouses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_search.png',
              width: 96,
              height: 96,
            ),
            const SizedBox(height: 10),
            Text(
              widget.l10n.deviceIssueSearchEmpty,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: warehouses.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        final warehouse = warehouses[index];
        final isSelected =
            selectedWarehouse?.inWarehouseNo == warehouse.inWarehouseNo;
        return ListTile(
          tileColor: isSelected ? const Color(0xFFF5FCF2) : null,
          title: Text(
            warehouse.inWarehouseName ?? warehouse.warehouseName ?? '-',
            style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
          ),
          subtitle: Text(
            warehouse.cityName ?? '',
            style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          trailing: isSelected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () {
            widget.notifier.selectInWarehouse(warehouse);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _showCitySheet() async {
    // Trigger one query as if the user typed a single blank in the search box.
    await widget.notifier.loadInWarehouseList(
      keyword: ' ',
      cityCode: _selectedCityCode,
      preserveKeyword: true,
    );
    await widget.notifier.loadCities();
    if (!mounted) return;
    final cities = ref.read(transportCreateProvider).cities;
    final sheetHeight = MediaQuery.of(context).size.height * 0.7;

    final selected = await showModalBottomSheet<_CityPickerResult>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              children: [
                ListTile(
                  title: Text(widget.l10n.deviceIssueAllCity),
                  trailing: _selectedCityCode.isEmpty
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(
                    ctx,
                  ).pop(const _CityPickerResult(cityCode: '', cityName: '')),
                ),
                const Divider(height: 1),
                Expanded(
                  child: cities.isEmpty
                      ? Center(
                          child: Text(
                            widget.l10n.deviceIssueSearchEmpty,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: cities.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final city = cities[index];
                            final cityTitle = city.name.trim().isNotEmpty
                                ? city.name
                                : city.code;
                            final selected = city.code == _selectedCityCode;
                            return ListTile(
                              title: Text(cityTitle),
                              trailing: selected
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                              onTap: () => Navigator.of(ctx).pop(
                                _CityPickerResult(
                                  cityCode: city.code,
                                  cityName: cityTitle,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    if (selected == null) return;
    await _applyCityFilter(selected.cityCode, selected.cityName);
  }

  Future<void> _applyCityFilter(String cityCode, String cityName) async {
    setState(() {
      _selectedCityCode = cityCode;
      _selectedCityName = cityName;
    });

    await widget.notifier.loadInWarehouseList(
      keyword: _searchController.text.trim(),
      cityCode: _selectedCityCode,
    );
  }
}

class _CityPickerResult {
  const _CityPickerResult({required this.cityCode, required this.cityName});

  final String cityCode;
  final String cityName;
}
