import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/root_tab_scaffold.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/station_type.dart';
import 'package:merchant_app/features/work/entry/battery_ship_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class StationEntryPageNew extends StatefulWidget {
  const StationEntryPageNew({super.key, this.selectedType});

  final StationType? selectedType;

  @override
  State<StationEntryPageNew> createState() => _StationEntryPageNewState();
}

class _StationEntryPageNewState extends State<StationEntryPageNew> {
  final ApiService _api = ApiService();
  final List<_StationItem> _items = [];
  StationType? _selected;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = _selected;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.stationEntryTitle,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 型号信息头部
          if (type != null) _buildModelHeader(type),

          // 设备列表
          Expanded(
            child: Container(
              color: const Color(0xFFF5F6F7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Station 标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Station  ${_items.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black06Text,
                      ),
                    ),
                  ),

                  // 列表内容
                  Expanded(
                    child: _items.isEmpty
                        ? _buildEmptyState(l10n)
                        : _buildDeviceList(l10n),
                  ),
                ],
              ),
            ),
          ),

          // 底部提交按钮
          _buildBottomButton(l10n),
        ],
      ),
    );
  }

  Widget _buildModelHeader(StationType type) {
    final l10n = context.l10n;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 型号信息行
          Row(
            children: [
              // 型号图片
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: type.img != null && type.img!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          type.img!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholderImage(),
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${type.model ?? '-'} (${type.storeNum ?? 0}-Port)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.remark ?? '4G/GPS/OTA optional',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dimension / Net Weight
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        l10n.entryDimensionLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.dimension ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        l10n.entryNetWeightLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.weight ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black06Text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Manual Entry / Scan Entry 按钮
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addManual,
                  icon: Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_enter_sn.png',
                    width: 18,
                    height: 18,
                  ),
                  label: Text(l10n.entryManualEntryButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black06Text,
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _addByScan,
                  icon: Image.asset(
                    'assets/android/mipmap-xxhdpi/ic_scan_white.webp',
                    width: 18,
                    height: 18,
                  ),
                  label: Text(l10n.entryScanEntryButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F322C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.ev_station, size: 40, color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildEmptyState(dynamic l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_battery.png',
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) => Icon(
                Icons.storage_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.entryEmptyDeviceHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(dynamic l10n) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _DeviceCard(
          item: item,
          l10n: l10n,
          onEdit: () => _editItem(index),
          onDelete: () => _deleteItem(index),
        );
      },
    );
  }

  Widget _buildBottomButton(dynamic l10n) {
    final hasItems = _items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: hasItems && !_submitting ? _submit : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: const Color(0xFFCCEECC),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.entrySubmitAction,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: hasItems ? Colors.white : const Color(0xFF88CC88),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addByScan() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(
          allowManualInput: true,
          deviceType: 3,
          returnRaw: true,
        ),
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final parsed = ScanUtils.parseStationQr(result);
    final sn = (parsed.sn ?? '').trim();
    if (sn.isEmpty) return;
    // 重复检查
    if (_items.any((item) => item.sn == sn)) {
      showToast(context.l10n.warehouseInventoryScanRepeat);
      return;
    }
    final lockDevId = (parsed.lockDevId ?? '').trim();
    setState(() {
      _items.add(_StationItem(sn: sn, lockDevId: lockDevId));
    });
  }

  Future<void> _addManual() async {
    final item = await _showManualEntrySheet();
    if (item == null) return;
    setState(() => _items.add(item));
  }

  Future<void> _editItem(int index) async {
    final item = await _showManualEntrySheet(initial: _items[index]);
    if (item == null) return;
    setState(() => _items[index] = item);
  }

  void _deleteItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<_StationItem?> _showManualEntrySheet({_StationItem? initial}) async {
    final l10n = context.l10n;
    final snController = TextEditingController(text: initial?.sn ?? '');
    final lockDevIdController = TextEditingController(
      text: initial?.lockDevId ?? '',
    );

    return showModalBottomSheet<_StationItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Center(
                child: Text(
                  l10n.entryManualEntryTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Station SN
              _buildInputField(
                label: l10n.entryStationSnLabel,
                hint: l10n.entryStationSnHint,
                controller: snController,
                isRequired: true,
                onScan: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) =>
                          const QrScanPage(parseDeviceSn: true, deviceType: 3),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    snController.text = result;
                  }
                },
              ),
              const SizedBox(height: 16),

              // LockDevId
              _buildInputField(
                label: l10n.entryLockDevIdLabel,
                hint: '请输入锁编号（可选）',
                controller: lockDevIdController,
                onScan: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const QrScanPage(parseDeviceSn: false),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    lockDevIdController.text = result;
                  }
                },
              ),
              const SizedBox(height: 24),

              // Confirm 按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    final sn = snController.text.trim();
                    if (sn.isEmpty) {
                      showToast(l10n.entrySnRequired);
                      return;
                    }
                    Navigator.of(context).pop(
                      _StationItem(
                        sn: sn,
                        lockDevId: lockDevIdController.text.trim(),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.confirm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = false,
    VoidCallback? onScan,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 14, color: AppColors.black06Text),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Color(0xFFE57373)),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (onScan != null)
                IconButton(
                  onPressed: onScan,
                  icon: AppIcons.scanIcon(
                    color: const Color(0xFF666666),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_selected == null) {
      showToast(l10n.entryModelRequired);
      return;
    }
    if (_items.isEmpty) {
      showToast(l10n.entryListEmpty);
      return;
    }

    // 显示确认弹窗
    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      await _api.post<Object>(
        ApiPath.stationRegister,
        data: {
          'model': _selected?.model ?? '',
          'list': _items.map((item) => item.toJson()).toList(),
        },
        parser: (json) => json ?? Object(),
      );

      final sns = _items.map((item) => item.sn).toList();
      if (!mounted) return;

      // 显示成功弹窗
      final goToShip = await _showSuccessDialog();
      if (!mounted) return;

      if (goToShip == true) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BatteryShipPage(deviceType: 3, initialSns: sns),
          ),
        );
      } else {
        _goToWorkbenchHome();
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog() async {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.entryConfirmSubmitTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: l10n.entryConfirmSubmitPrefix,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: '${_items.length} station',
                        style: const TextStyle(
                          color: Color(0xFFFFA000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: l10n.entryConfirmSubmitSuffix),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.black06Text,
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showSuccessDialog() async {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.entrySubmissionCompleted,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.entryShipPromptMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.black06Text,
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.entryCloseButton),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.entryShipButton),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToWorkbenchHome() {
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(bottomNavIndexProvider.notifier).setIndex(1);
    AppRouter.goHome();
  }
}

class _StationItem {
  final String sn;
  final String lockDevId;

  const _StationItem({required this.sn, this.lockDevId = ''});

  Map<String, dynamic> toJson() => {
    'sn': sn,
    'imei': '',
    'iccid': '',
    'lockDevId': lockDevId,
  };
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.item,
    required this.l10n,
    required this.onEdit,
    required this.onDelete,
  });

  final _StationItem item;
  final dynamic l10n;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SN
          Text(
            'SN: ${item.sn}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
          const SizedBox(height: 8),

          // LockDevId
          Text(
            '${l10n.entryLockDevIdLabel}: ${item.lockDevId.isNotEmpty ? item.lockDevId : '-'}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 12),

          // 分割线
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 12),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onEdit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.entryEditAction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: const Color(0xFFEEEEEE)),
              Expanded(
                child: GestureDetector(
                  onTap: onDelete,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.entryDeleteAction,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
