import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/new_cabinet_bean.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_unshelve_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class CabinetUnshelvePage extends ConsumerStatefulWidget {
  const CabinetUnshelvePage({super.key});

  @override
  ConsumerState<CabinetUnshelvePage> createState() =>
      _CabinetUnshelvePageState();
}

class _CabinetUnshelvePageState extends ConsumerState<CabinetUnshelvePage> {
  final _snController = TextEditingController();
  final _snFocusNode = FocusNode();
  final _reasonController = TextEditingController();
  String? _selectedReason;
  String _lastQueriedSn = '';

  @override
  void initState() {
    super.initState();
    ref.read(cabinetUnshelveProvider.notifier).clearState();
    _snController.clear();
    _reasonController.clear();
    _selectedReason = null;
    _lastQueriedSn = '';
    _snFocusNode.addListener(_onSnFocusChanged);
  }

  void _onSnFocusChanged() {
    if (!_snFocusNode.hasFocus) {
      _handleSnBlur();
    }
  }

  bool get _canSubmit {
    final state = ref.read(cabinetUnshelveProvider);
    return !state.submitting &&
        state.cabinet != null &&
        _snController.text.trim().isNotEmpty &&
        _reasonController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    ref.read(cabinetUnshelveProvider.notifier).clearState();
    _snFocusNode.removeListener(_onSnFocusChanged);
    _snFocusNode.dispose();
    _snController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetUnshelveProvider);
    final notifier = ref.read(cabinetUnshelveProvider.notifier);
    final cabinet = state.cabinet;

    // 常见原因列表
    final commonReasons = [
      l10n.cabinetUnshelveReason1,
      l10n.cabinetUnshelveReason2,
      l10n.cabinetUnshelveReason3,
    ];

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
                            'assets/android/mipmap-xxhdpi/icon_unshelve.png',
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.cabinetUnshelveTitle,
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
                        label: l10n.cabinetUnshelveSn,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _snController,
                                focusNode: _snFocusNode,
                                decoration: InputDecoration(
                                  hintText: l10n.cabinetUnshelveSnHint,
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
                        child: cabinet == null
                            ? Text(
                                l10n.cabinetUnshelveInfoEmpty,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF999999),
                                  fontSize: 14,
                                ),
                              )
                            : _CabinetInfoWidget(cabinet: cabinet),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Reasons 卡片
                _CardSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InputRow(
                        label: l10n.cabinetUnshelveReasonLabel,
                        child: TextField(
                          controller: _reasonController,
                          onChanged: (_) => setState(() {}),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(200),
                          ],
                          decoration: InputDecoration(
                            hintText: l10n.cabinetUnshelveReasonHint,
                            hintStyle: const TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 15),
                          maxLines: 2,
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.cabinetUnshelveCommonReasons,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF999999),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: commonReasons.map((reason) {
                          final isSelected = _selectedReason == reason;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedReason = reason;
                                _reasonController.text = reason;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : const Color(0xFFEEEEEE),
                                ),
                              ),
                              child: Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.black06Text,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                onPressed: _canSubmit
                    ? () => _showConfirmDialog(context)
                    : null,
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
                        l10n.cabinetUnshelveSubmit,
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
    ref.read(cabinetUnshelveProvider.notifier).queryCabinet(result);
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
    ref.read(cabinetUnshelveProvider.notifier).queryCabinet(sn);
  }

  void _resetBySnCleared() {
    ref.read(cabinetUnshelveProvider.notifier).clearState();
    _reasonController.clear();
    setState(() {
      _selectedReason = null;
    });
  }

  Future<void> _showConfirmDialog(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.cabinetUnshelveConfirmTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.cabinetUnshelveConfirmMessage,
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
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFF5F5F5),
                          foregroundColor: AppColors.black06Text,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
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
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
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
    );

    if (confirmed == true && mounted) {
      _submit(context);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = context.l10n;
    final notifier = ref.read(cabinetUnshelveProvider.notifier);
    final ok = await notifier.submit(
      sn: _snController.text.trim(),
      reason: _reasonController.text.trim(),
    );
    if (!context.mounted) return;
    if (ok) {
      showToast(l10n.cabinetUnshelveSuccess);
      Navigator.of(context).pop();
    } else {
      showToast(l10n.cabinetUnshelveFailed);
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
  const _InputRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: AppColors.black06Text),
        ),
        const SizedBox(height: 8),
        child,
        const SizedBox(height: 8),
      ],
    );
  }
}

/// 电柜信息组件
class _CabinetInfoWidget extends StatelessWidget {
  const _CabinetInfoWidget({required this.cabinet});

  final NewCabinetBean cabinet;

  @override
  Widget build(BuildContext context) {
    final modelInfo = [
      (cabinet.stationModel ?? '').trim(),
      (cabinet.stationModelName ?? '').trim(),
    ].where((e) => e.isNotEmpty).join(' | ');
    final address = (cabinet.address ?? '').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: const Color(0xFFEEEEEE),
                  child: (cabinet.standardImg ?? '').trim().isNotEmpty
                      ? Image.network(
                          cabinet.standardImg!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.ev_station,
                            color: Color(0xFF999999),
                            size: 32,
                          ),
                        )
                      : const Icon(
                          Icons.ev_station,
                          color: Color(0xFF999999),
                          size: 32,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cabinet.stationName ?? '-',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black06Text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modelInfo.isEmpty ? '-' : modelInfo,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (address.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/android/mipmap-xxhdpi/locate_tag_1.webp',
                  width: 16,
                  height: 16,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
