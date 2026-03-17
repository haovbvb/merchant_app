import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/car_type.dart';
import 'package:merchant_app/features/work/entry/battery_ship_page.dart';
import 'package:merchant_app/features/work/entry/entry_success_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';

class VehicleEntryPageNew extends StatefulWidget {
  const VehicleEntryPageNew({super.key, this.selectedType});

  final CarType? selectedType;

  @override
  State<VehicleEntryPageNew> createState() => _VehicleEntryPageNewState();
}

class _VehicleEntryPageNewState extends State<VehicleEntryPageNew> {
  final ApiService _api = ApiService();
  final List<_VehicleItem> _items = [];
  CarType? _selected;
  bool _submitting = false;

  void showToast(String message) {
    Toast.show(message);
  }

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
          l10n.vehicleEntryTitle,
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
                  // Vehicle 标题
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Vehicle  ${_items.length}',
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

  Widget _buildModelHeader(CarType type) {
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
                      _buildVehicleTypeTitle(type),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black06Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.remark ?? '',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetaItem('发动机型号', type.engineModel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetaItem('生产日期', type.engineDate),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Manual Entry 和 Scan Entry 按钮
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
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Icon(
          Icons.electric_moped_outlined,
          size: 40,
          color: Color(0xFFCCCCCC),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          (value == null || value.trim().isEmpty) ? '-' : value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black06Text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _buildVehicleTypeTitle(CarType type) {
    final model = type.model?.trim() ?? '';
    final modelName = type.modelName?.trim() ?? '';
    if (model.isNotEmpty && modelName.isNotEmpty) {
      return '$model ($modelName)';
    }
    if (model.isNotEmpty) return model;
    if (modelName.isNotEmpty) return modelName;
    return '-';
  }

  Widget _buildEmptyState(dynamic l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_battery.png',
            width: 64,
            height: 64,
            errorBuilder: (_, __, ___) => Icon(
              Icons.electric_moped_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.entryEmptyDeviceHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(dynamic l10n) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _DeviceCard(
          item: _items[index],
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          allowManualInput: true,
          deviceType: 2,
          returnRaw: true,
          continuousScan: true,
          onContinuousScan: _handleContinuousVehicleScan,
        ),
      ),
    );
  }

  String _handleContinuousVehicleScan(String rawValue) {
    final parsed = ScanUtils.parseVehicleQr(rawValue, 0);
    final sn = (parsed.sn ?? '').trim();
    if (sn.isEmpty) {
      return context.l10n.scanInvalidQr;
    }

    if (_items.any((item) => item.sn == sn)) {
      return context.l10n.scanAlreadyScanned;
    }

    final vin = (parsed.vin ?? '').trim();
    final ctrlId = (parsed.vcu ?? '').trim();
    setState(() {
      _items.add(_VehicleItem(
        sn: sn,
        vin: vin.isNotEmpty ? vin : sn,
        ctrlId: ctrlId,
      ));
    });

    return context.l10n.scanSuccessEntry;
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

  Future<_VehicleItem?> _showManualEntrySheet({_VehicleItem? initial}) async {
    final l10n = context.l10n;
    final snController = TextEditingController(text: initial?.sn ?? '');
    final vinController = TextEditingController(text: initial?.vin ?? '');
    final ctrlIdController = TextEditingController(text: initial?.ctrlId ?? '');

    return showModalBottomSheet<_VehicleItem>(
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
                  initial == null
                      ? l10n.entryManualEntryTitle
                      : l10n.entryEditDeviceTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle SN
              _buildInputField(
                label: l10n.entryVehicleSnLabel,
                hint: l10n.entryVehicleSnHint,
                controller: snController,
                isRequired: true,
                onScan: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const QrScanPage(
                        parseDeviceSn: false,
                        deviceType: 2,
                        returnRaw: true,
                      ),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    _applyVehicleScanToControllers(
                      raw: result,
                      snController: snController,
                      vinController: vinController,
                      fallbackToRaw: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // VIN
              _buildInputField(
                label: l10n.entryVinLabel,
                hint: l10n.entryVinRequired.replaceAll('请填写', '请输入'),
                controller: vinController,
                isRequired: true,
                onScan: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) =>
                          const QrScanPage(parseDeviceSn: false, returnRaw: true),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    _applyVehicleScanToControllers(
                      raw: result,
                      snController: snController,
                      vinController: vinController,
                      fallbackToRaw: true,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // VCU
              _buildInputField(
                label: 'VCU',
                hint: '请输入VCU（可选）',
                controller: ctrlIdController,
                onScan: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => const QrScanPage(parseDeviceSn: false),
                    ),
                  );
                  if (result != null && result.isNotEmpty) {
                    ctrlIdController.text = result;
                  }
                },
              ),
              const SizedBox(height: 24),

              // 提交按钮
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
                    final vin = vinController.text.trim();
                    if (vin.isEmpty) {
                      showToast(l10n.entryVinRequired);
                      return;
                    }
                    Navigator.of(context).pop(
                      _VehicleItem(
                        sn: sn,
                        vin: vin,
                        ctrlId: ctrlIdController.text.trim(),
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

  String _extractVehicleQrField(String raw, String key) {
    final target = key.toLowerCase();
    final tokens = raw
        .replaceAll(RegExp(r'[\r\n;|]'), ',')
        .replaceAll('&', ',')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);

    for (final token in tokens) {
      final separatorIndex = token.indexOf(RegExp('[:=]'));
      if (separatorIndex <= 0) continue;
      final currentKey = token.substring(0, separatorIndex).trim().toLowerCase();
      if (currentKey != target) continue;
      final value = token.substring(separatorIndex + 1).trim();
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _applyVehicleScanToControllers({
    required String raw,
    required TextEditingController snController,
    required TextEditingController vinController,
    bool fallbackToRaw = false,
  }) {
    final extractedSn = _extractVehicleQrField(raw, 'sn');
    final extractedVin = _extractVehicleQrField(raw, 'vin');
    final parsed = ScanUtils.parseVehicleQr(raw, 0);
    final parsedSn = (parsed.sn ?? '').trim();
    final parsedVin = (parsed.vin ?? '').trim();

    final sn = extractedSn.isNotEmpty ? extractedSn : parsedSn;
    final vin = extractedVin.isNotEmpty ? extractedVin : parsedVin;

    if (sn.isNotEmpty) {
      snController.text = sn;
    }
    if (vin.isNotEmpty) {
      vinController.text = vin;
    }

    if (fallbackToRaw) {
      if (sn.isEmpty) {
        final rawTrimmed = raw.trim();
        if (rawTrimmed.isNotEmpty) {
          snController.text = rawTrimmed;
        }
      }
      if (vin.isEmpty) {
        final rawTrimmed = raw.trim();
        if (rawTrimmed.isNotEmpty) {
          vinController.text = rawTrimmed;
        }
      }
    }
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
                  textAlignVertical: TextAlignVertical.center,
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
                    isCollapsed: true,
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
    if (_items.any((item) => item.vin.trim().isEmpty)) {
      showToast(l10n.entryVinRequired);
      return;
    }

    // 显示确认弹窗
    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;

    setState(() => _submitting = true);
    try {
      final response = await _api.post<Object>(
        ApiPath.vehicleRegister,
        data: {
          'model': _selected?.model ?? '',
          'list': _items.map((item) => item.toJson()).toList(),
        },
        parser: (json) => json ?? Object(),
      );

      if (!response.isSuccess) {
        return;
      }

      final sns = _items.map((item) => item.sn).toList();
      if (!mounted) return;

      // 显示成功弹窗
      final goToShip = await _showSuccessDialog();
      if (!mounted) return;

      if (goToShip == true) {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => BatteryShipPage(deviceType: 2, initialSns: sns),
          ),
        );
      } else {
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => EntrySuccessPage(title: l10n.vehicleEntryTitle),
          ),
        );
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
                        text: '${_items.length} vehicle',
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
                    fontSize: 14,
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
}

class _VehicleItem {
  final String sn;
  final String vin;
  final String ctrlId;

  const _VehicleItem({
    required this.sn,
    this.vin = '',
    this.ctrlId = '',
  });

  Map<String, dynamic> toJson() => {
    'sn': sn,
    'vin': vin,
    'ctrlId': ctrlId,
  };
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.item,
    required this.l10n,
    required this.onEdit,
    required this.onDelete,
  });

  final _VehicleItem item;
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

          // VIN / VCU
          Row(
            children: [
              Expanded(
                child: Text(
                  'VIN: ${item.vin.isNotEmpty ? item.vin : '-'}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Text(
                  'VCU: ${item.ctrlId.isNotEmpty ? item.ctrlId : '-'}',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
