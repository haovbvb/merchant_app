import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/batter_or_vehicle_info.dart';
import 'package:merchant_app/data/models/device_fix.dart';
import 'package:merchant_app/features/work/maintenance/maintenance_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class RepairRecordCreatePage extends ConsumerStatefulWidget {
  const RepairRecordCreatePage({super.key, this.isStation = false});

  final bool isStation;

  @override
  ConsumerState<RepairRecordCreatePage> createState() =>
      _RepairRecordCreatePageState();
}

class _RepairRecordCreatePageState
    extends ConsumerState<RepairRecordCreatePage> {
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();
  final FocusNode _snFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    ref.read(repairRecordCreateProvider.notifier).resetForm();
    _snController.clear();
    _remarkController.clear();
    _snFocusNode.addListener(_handleSnFocusChange);
  }

  @override
  void dispose() {
    _snFocusNode.removeListener(_handleSnFocusChange);
    _snFocusNode.dispose();
    _snController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _handleSnFocusChange() {
    if (_snFocusNode.hasFocus) return;
    final sn = _snController.text.trim();
    if (sn.isEmpty) return;
    ref.read(repairRecordCreateProvider.notifier).fetchDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(repairRecordCreateProvider);
    final notifier = ref.read(repairRecordCreateProvider.notifier);

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
                                'assets/android/mipmap-xxhdpi/icon_repair_registration.png',
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.repairRecordAddTitle,
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
                    // Device SN section
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
                            label: widget.isStation
                                ? l10n.repairRecordStationSnLabel
                                : l10n.repairRecordDeviceSnLabel,
                            hint: widget.isStation
                                ? l10n.repairRecordStationSnHint
                                : l10n.repairRecordDeviceSnHint,
                            controller: _snController,
                            focusNode: _snFocusNode,
                            onChanged: (value) {
                              final oldSn = state.sn.trim();
                              final newSn = value.trim();
                              final changed = oldSn != newSn;
                              if (changed) {
                                notifier.resetForNewSnInput(value);
                                _remarkController.clear();
                              } else {
                                notifier.updateSn(value);
                              }
                            },
                            onScan: _scanSn,
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          // Device info card
                          if (state.deviceFix != null)
                            _DeviceInfoCard(
                              deviceFix: state.deviceFix!,
                              l10n: l10n,
                            )
                          else
                            _EmptyInfoCard(
                              text: l10n.repairRecordDeviceInfoEmpty,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Repair Project section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _DropdownSelector(
                        label: l10n.repairRecordProjectLabel,
                        hint: l10n.repairRecordProjectHint,
                        value: state.selectedProject?.itemName,
                        onTap: () => _showProjectSelector(
                          context,
                          state,
                          notifier,
                          l10n,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Repair Results section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _DropdownSelector(
                        label: l10n.repairRecordResultLabel,
                        hint: l10n.repairRecordResultHint,
                        value: state.selectedResult?.result,
                        onTap: () =>
                            _showResultSelector(context, state, notifier, l10n),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Remark section
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
                              l10n.repairRecordRemarkLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _remarkController,
                              decoration: InputDecoration(
                                hintText: l10n.repairRecordRemarkHint,
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              maxLines: 3,
                              onChanged: notifier.updateRemark,
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
                  onPressed: state.canSubmit
                      ? () => _submit(context, l10n, notifier)
                      : null,
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          l10n.repairRecordSubmit,
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
                  onChanged: onChanged,
                  onSubmitted: (_) {
                    ref
                        .read(repairRecordCreateProvider.notifier)
                        .fetchDeviceInfo();
                  },
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

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            const QrScanPage(allowManualInput: true, parseDeviceSn: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    final notifier = ref.read(repairRecordCreateProvider.notifier);
    notifier.resetForNewSnInput(result);
    _remarkController.clear();
    notifier.updateRemark('');
    await notifier.fetchDeviceInfo();
  }

  void _showProjectSelector(
    BuildContext context,
    RepairRecordCreateState state,
    RepairRecordCreateNotifier notifier,
    AppLocalizations l10n,
  ) {
    if (state.deviceFix == null || state.deviceFix!.itemList.isEmpty) {
      showToast(l10n.deviceSearchEmpty);
      return;
    }
    final items = state.deviceFix!.itemList;
    final selectedIndex = state.selectedProject == null
        ? -1
        : items.indexWhere((e) => e.itemNo == state.selectedProject!.itemNo);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FixSelectionSheet(
        title: l10n.repairRecordSelectProject,
        items: items.map((e) => e.itemName).toList(),
        selectedIndex: selectedIndex,
        onSelected: (index) {
          notifier.selectProject(items[index]);
        },
        cancelText: l10n.repairRecordCancel,
      ),
    );
  }

  void _showResultSelector(
    BuildContext context,
    RepairRecordCreateState state,
    RepairRecordCreateNotifier notifier,
    AppLocalizations l10n,
  ) {
    if (state.deviceFix == null || state.deviceFix!.resultList.isEmpty) {
      showToast(l10n.deviceSearchEmpty);
      return;
    }
    final items = state.deviceFix!.resultList;
    final selectedIndex = state.selectedResult == null
        ? -1
        : items.indexWhere((e) => e.code == state.selectedResult!.code);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FixSelectionSheet(
        title: l10n.repairRecordSelectResult,
        items: items.map((e) => e.result).toList(),
        selectedIndex: selectedIndex,
        onSelected: (index) {
          notifier.selectResult(items[index]);
        },
        cancelText: l10n.repairRecordCancel,
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    AppLocalizations l10n,
    RepairRecordCreateNotifier notifier,
  ) async {
    final success = await notifier.submitFixRecord();
    if (!mounted) return;
    if (success) {
      showToast(l10n.repairRecordSubmitSuccess);
      // Align with Android: clear form and stay on the page for batch processing
      notifier.resetForm();
      _snController.clear();
      _remarkController.clear();
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

class _DropdownSelector extends StatelessWidget {
  const _DropdownSelector({
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String hint;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15,
                      color: value != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FixSelectionSheet extends StatefulWidget {
  const _FixSelectionSheet({
    required this.title,
    required this.items,
    required this.onSelected,
    required this.cancelText,
    this.selectedIndex = -1,
  });

  final String title;
  final List<String> items;
  final ValueChanged<int> onSelected;
  final String cancelText;
  final int selectedIndex;

  @override
  State<_FixSelectionSheet> createState() => _FixSelectionSheetState();
}

class _FixSelectionSheetState extends State<_FixSelectionSheet> {
  late int _currentSelected;

  @override
  void initState() {
    super.initState();
    _currentSelected = widget.selectedIndex;
  }

  void _onItemTap(int index) {
    if (_currentSelected == index) return;
    setState(() {
      _currentSelected = index;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      widget.onSelected(index);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 342,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Title
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // List area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: widget.items.isEmpty
                  ? const Center(
                      child: Text(
                        'No Data',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final isSelected = _currentSelected == index;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => _onItemTap(index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.items[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xE60C0C0D),
                                        ),
                                      ),
                                    ),
                                    Image.asset(
                                      isSelected
                                          ? 'assets/android/mipmap-xxhdpi/icon_green_checked.png'
                                          : 'assets/android/mipmap-xxhdpi/icon_grey_unchecked.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index < widget.items.length - 1)
                              const Divider(
                                height: 0.5,
                                thickness: 0.5,
                                color: Color(0xFFE6E6E6),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          // Cancel button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.cancelText,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xE6000000),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  const _DeviceInfoCard({required this.deviceFix, required this.l10n});

  final DeviceFix deviceFix;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // deviceType: 1=battery, 2=vehicle, 3=station
    if (deviceFix.deviceType == 1) {
      return _BatteryInfoCard(battery: deviceFix.batteryVo, l10n: l10n);
    } else if (deviceFix.deviceType == 2) {
      return _VehicleInfoCard(vehicle: deviceFix.carVo, l10n: l10n);
    } else if (deviceFix.deviceType == 3) {
      return _StationInfoCard(station: deviceFix.stationVo, l10n: l10n);
    }
    return _EmptyInfoCard(text: l10n.repairRecordDeviceInfoEmpty);
  }
}

class _BatteryInfoCard extends StatelessWidget {
  const _BatteryInfoCard({required this.battery, required this.l10n});

  final BatteryVo? battery;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isBound = battery?.cardNum != null && battery!.cardNum!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: battery?.img != null && battery!.img!.isNotEmpty
                        ? Image.network(battery!.img!, fit: BoxFit.contain)
                        : const Icon(
                            Icons.battery_full,
                            size: 32,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          battery?.sn ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _BoundTag(isBound: isBound, l10n: l10n),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Model & Specification
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: l10n.repairRecordDeviceModelLabel,
                      value: battery?.model ?? battery?.batModel ?? '-',
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _StatItem(
                      label: l10n.repairRecordDeviceSpecLabel,
                      value: battery?.spec ?? battery?.batSpec ?? '-',
                    ),
                  ),
                ],
              ),
            ),
            // Binding User ID & Entry Time
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (isBound)
                    _InfoRow(
                      label: l10n.repairRecordDeviceCardNumLabel,
                      value: battery?.cardNum ?? '-',
                    ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: l10n.repairRecordDeviceEntryTime,
                    value: _formatDateValue(battery?.createTime),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  const _VehicleInfoCard({required this.vehicle, required this.l10n});

  final CarVo? vehicle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isBound = vehicle?.cardNum.isNotEmpty == true;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: vehicle?.img != null && vehicle!.img!.isNotEmpty
                        ? Image.network(vehicle!.img!, fit: BoxFit.contain)
                        : const Icon(
                            Icons.electric_moped,
                            size: 32,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle?.sn ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _BoundTag(isBound: isBound, l10n: l10n),
                            const SizedBox(width: 8),
                            _Tag(text: vehicle?.spec ?? '-'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Model & Plate Number
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: l10n.repairRecordDeviceModelLabel,
                      value: vehicle?.model ?? '-',
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.shade200),
                  Expanded(
                    child: _StatItem(
                      label: l10n.repairRecordDevicePlateNumber,
                      value: vehicle?.carNumber ?? '-',
                    ),
                  ),
                ],
              ),
            ),
            // Binding User ID & Entry Time
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    label: l10n.repairRecordDeviceCardNumLabel,
                    value: vehicle?.cardNum ?? '-',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: l10n.repairRecordDeviceEntryTime,
                    value: _formatDateValue(vehicle?.createTime),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationInfoCard extends StatelessWidget {
  const _StationInfoCard({required this.station, required this.l10n});

  final StationVo? station;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isOnline = (station?.onlineFlag ?? 0) != 0;
    final storeNum = station?.storeNum?.trim() ?? '';
    final specText = storeNum.isEmpty ? '-' : '$storeNum plots';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: station?.img != null && station!.img!.isNotEmpty
                        ? Image.network(station!.img!, fit: BoxFit.contain)
                        : const Icon(
                            Icons.ev_station,
                            size: 32,
                            color: Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station?.name ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusTag(isOnline: isOnline, l10n: l10n),
                            const SizedBox(width: 8),
                            _Tag(text: specText),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/android/mipmap-xxhdpi/icon_location_item.webp',
                          width: 14,
                          height: 14,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            (station?.address ?? '-').trim().isEmpty
                                ? '-'
                                : (station?.address ?? '-'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: l10n.repairRecordDeviceEntryTime,
                    value: _formatDateValue(station?.createTime),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

String _formatDateValue(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '-';
  final formatted = DateFormatUtils.formatString(
    raw,
    pattern: 'dd MMM, yyyy',
    fallback: raw,
  );
  return formatted;
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.isOnline, required this.l10n});

  final bool isOnline;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.primaryColor : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        isOnline ? l10n.online : l10n.offline,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}

class _BoundTag extends StatelessWidget {
  const _BoundTag({required this.isBound, required this.l10n});

  final bool isBound;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isBound ? AppColors.primaryColor : Colors.red,
        ),
      ),
      child: Text(
        isBound ? l10n.repairRecordBound : l10n.repairRecordUnbound,
        style: TextStyle(
          fontSize: 12,
          color: isBound ? AppColors.primaryColor : Colors.red,
        ),
      ),
    );
  }
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

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
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
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
