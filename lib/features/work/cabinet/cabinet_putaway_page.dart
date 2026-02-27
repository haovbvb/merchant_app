import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_putaway_controller.dart';
import 'package:merchant_app/features/work/map/address_picker_page.dart';
import 'package:merchant_app/features/work/map/address_result.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class CabinetPutawayPage extends ConsumerStatefulWidget {
  const CabinetPutawayPage({super.key});

  @override
  ConsumerState<CabinetPutawayPage> createState() => _CabinetPutawayPageState();
}

class _CabinetPutawayPageState extends ConsumerState<CabinetPutawayPage> {
  final _snController = TextEditingController();
  final _snFocusNode = FocusNode();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _swapTimeController = TextEditingController();

  double? _latitude;
  double? _longitude;
  final List<String> _localImages = [];
  String _lastQueriedSn = '';

  @override
  void initState() {
    super.initState();
    _snFocusNode.addListener(_onSnFocusChanged);
    _nameController.addListener(_onFormChanged);
    _addressController.addListener(_onFormChanged);
    _swapTimeController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  void _onSnFocusChanged() {
    if (!_snFocusNode.hasFocus) {
      _handleSnBlur();
    }
  }

  bool get _canSubmit {
    final state = ref.read(cabinetPutawayProvider);
    final swapTime = int.tryParse(_swapTimeController.text.trim()) ?? 0;
    return !state.submitting &&
        state.cabinet != null &&
        _snController.text.trim().isNotEmpty &&
        _nameController.text.trim().isNotEmpty &&
        _addressController.text.trim().isNotEmpty &&
        _latitude != null &&
        _longitude != null &&
        swapTime > 0 &&
        state.images.isNotEmpty;
  }

  @override
  void dispose() {
    _snFocusNode.removeListener(_onSnFocusChanged);
    _snFocusNode.dispose();
    _nameController.removeListener(_onFormChanged);
    _addressController.removeListener(_onFormChanged);
    _swapTimeController.removeListener(_onFormChanged);
    _snController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _swapTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetPutawayProvider);
    final notifier = ref.read(cabinetPutawayProvider.notifier);
    final cabinet = state.cabinet;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // 顶部图标和标题
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: ClipRRect(
                          child: Image.asset(
                            'assets/android/mipmap-xxhdpi/icon_release_station.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.cabinetPutawayTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Station SN 卡片
                _CardSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InputRow(
                        label: l10n.cabinetPutawaySn,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _snController,
                                focusNode: _snFocusNode,
                                decoration: InputDecoration(
                                  hintText: l10n.cabinetPutawaySnHint,
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 15),
                                onChanged: (value) {
                                  if (value.trim().isEmpty) {
                                    _lastQueriedSn = '';
                                    _resetBySnCleared();
                                  }
                                },
                                onSubmitted: (_) => notifier.queryCabinet(
                                  _snController.text.trim(),
                                ),
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
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      // 设备参数信息区
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(top: 16),
                        child: Text(
                          cabinet == null
                              ? l10n.cabinetPutawayInfoEmpty
                              : '${cabinet.stationName ?? '-'}\n${cabinet.stationModel ?? '-'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Station Name / Address / Coordinates
                _CardSection(
                  child: Column(
                    children: [
                      _InputRow(
                        label: l10n.cabinetPutawayName,
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: l10n.cabinetPutawayNameHint,
                            hintStyle: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _InputRow(
                        label: l10n.cabinetPutawayAddress,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  hintText: l10n.cabinetPutawayAddressHint,
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 15,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _selectAddress(context),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.black06Text,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _DisplayRow(
                        label: l10n.cabinetPutawayCoordinates,
                        value: _latitude != null && _longitude != null
                            ? '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'
                            : '- -',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Battery Exchange Indicator
                _CardSection(
                  child: Column(
                    children: [
                      _InputRow(
                        label: l10n.cabinetPutawaySwapTime,
                        labelSuffix: ' (${l10n.cabinetPutawayTimesPerDay})',
                        child: TextField(
                          controller: _swapTimeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            counterText: '',
                          ),
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Photo
                _CardSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l10n.cabinetPutawayImages,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.black06Text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${state.images.length + _localImages.length}/4)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // 已上传的图片
                          ...state.images.map(
                            (url) => _ImageItem(
                              imageUrl: url,
                              onDelete: () => notifier.removeImage(url),
                            ),
                          ),
                          // 本地待上传图片
                          ..._localImages.map(
                            (path) => _ImageItem(
                              localPath: path,
                              onDelete: () {
                                setState(() => _localImages.remove(path));
                              },
                            ),
                          ),
                          // 添加按钮
                          if (state.images.length + _localImages.length < 4)
                            GestureDetector(
                              onTap: state.uploading
                                  ? null
                                  : () => _pickImages(
                                      context,
                                      notifier,
                                      state.images.length + _localImages.length,
                                    ),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF999999),
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // 底部按钮
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _canSubmit ? () => _submit(context, notifier) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: const Color(0xFFB8E6B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: state.submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: SizedBox.shrink(),
                      )
                    : Text(
                        l10n.cabinetPutawaySubmit,
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

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true, deviceType: 3),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _snController.text = result;
    _lastQueriedSn = result;
    ref.read(cabinetPutawayProvider.notifier).queryCabinet(result);
  }

  Future<void> _selectAddress(BuildContext context) async {
    final initial = _buildAddressResult();
    final result = await Navigator.of(context).push<AddressResult>(
      MaterialPageRoute(builder: (_) => AddressPickerPage(initial: initial)),
    );
    if (!mounted || result == null) return;
    _addressController.text = result.address;
    setState(() {
      _latitude = result.latitude;
      _longitude = result.longitude;
    });
  }

  AddressResult? _buildAddressResult() {
    final address = _addressController.text.trim();
    if (address.isEmpty || _latitude == null || _longitude == null) return null;
    return AddressResult(
      address: address,
      latitude: _latitude!,
      longitude: _longitude!,
    );
  }

  Future<void> _pickImages(
    BuildContext context,
    CabinetPutawayNotifier notifier,
    int currentCount,
  ) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    final remaining = 4 - currentCount;
    if (remaining <= 0) {
      showToast(l10n.cabinetPutawayImageLimit);
      return;
    }
    final picks = await picker.pickMultiImage();
    if (!mounted || picks.isEmpty) return;

    for (final item in picks.take(remaining)) {
      // 先添加本地预览
      setState(() => _localImages.add(item.path));
      // 上传图片
      final url = await notifier.uploadImage(item.path);
      if (url != null && url.isNotEmpty) {
        notifier.addImage(url);
        setState(() => _localImages.remove(item.path));
      } else {
        if (!mounted) return;
        setState(() => _localImages.remove(item.path));
        showToast(l10n.orderVoucherUploadFailed);
      }
    }
  }

  void _handleSnBlur() {
    final sn = _snController.text.trim();
    if (sn.isEmpty) {
      _lastQueriedSn = '';
      _resetBySnCleared();
      return;
    }
    if (sn == _lastQueriedSn) return;
    _lastQueriedSn = sn;
    ref.read(cabinetPutawayProvider.notifier).queryCabinet(sn);
  }

  void _resetBySnCleared() {
    ref.read(cabinetPutawayProvider.notifier).clearState();
    _nameController.clear();
    _addressController.clear();
    _swapTimeController.clear();
    setState(() {
      _latitude = null;
      _longitude = null;
      _localImages.clear();
    });
  }

  Future<void> _submit(
    BuildContext context,
    CabinetPutawayNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final swapTime = int.tryParse(_swapTimeController.text.trim()) ?? 0;
    final ok = await notifier.submit(
      sn: _snController.text.trim(),
      name: _nameController.text.trim(),
      latitude: _latitude ?? 0,
      longitude: _longitude ?? 0,
      swapTime: swapTime,
      storeNum: 0,
      address: _addressController.text.trim(),
    );
    if (!context.mounted) return;
    if (ok) {
      showToast(l10n.cabinetPutawaySuccess);
      Navigator.of(context).pop();
    } else {
      showToast(l10n.cabinetPutawayFailed);
    }
  }
}

/// 卡片容器
class _CardSection extends StatelessWidget {
  const _CardSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// 输入行
class _InputRow extends StatelessWidget {
  const _InputRow({required this.label, required this.child, this.labelSuffix});

  final String label;
  final String? labelSuffix;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppColors.black06Text),
            ),
            if (labelSuffix != null)
              Text(
                labelSuffix!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 8),
      ],
    );
  }
}

/// 显示行（只读）
class _DisplayRow extends StatelessWidget {
  const _DisplayRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.black06Text),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}

/// 图片项
class _ImageItem extends StatelessWidget {
  const _ImageItem({this.imageUrl, this.localPath, required this.onDelete});

  final String? imageUrl;
  final String? localPath;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: localPath != null
                  ? FileImage(File(localPath!))
                  : NetworkImage(imageUrl!) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
