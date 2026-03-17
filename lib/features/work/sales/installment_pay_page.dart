import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/ui.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/image_source_action_sheet.dart';
import 'package:merchant_app/data/models/installment_payment_response.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/installment_pay_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/installment_order_sheet.dart';
import 'package:merchant_app/features/work/user/user_detail_page.dart';

class InstallmentPayPage extends ConsumerStatefulWidget {
  const InstallmentPayPage({super.key});

  @override
  ConsumerState<InstallmentPayPage> createState() => _InstallmentPayPageState();
}

class _InstallmentPayPageState extends ConsumerState<InstallmentPayPage> {
  final _userIdController = TextEditingController();
  final _userIdFocusNode = FocusNode();
  String _lastQueriedUserId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(installmentPayProvider.notifier).reset();
      _userIdController.clear();
      _lastQueriedUserId = '';
    });
    _userIdFocusNode.addListener(_onUserIdFocusChanged);
  }

  void _onUserIdFocusChanged() {
    if (!_userIdFocusNode.hasFocus) {
      _handleUserIdBlur();
    }
  }

  @override
  void dispose() {
    _userIdFocusNode.removeListener(_onUserIdFocusChanged);
    _userIdFocusNode.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(installmentPayProvider);

    // 成功页面
    if (state.submitSuccess) {
      return _SuccessPage(
        documentNo: state.documentNo ?? '',
        onReturn: () {
          ref.read(installmentPayProvider.notifier).reset();
          Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildUserIdSection(context),
                    const SizedBox(height: 8),
                    _buildOrderSection(context),
                    const SizedBox(height: 8),
                    _buildVoucherSection(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      child: Column(
        children: [
          // 返回按钮
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            ),
          ),
          // 绿色钱包图标
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_installmentpage.png',
            height: 120,
          ),
          Text(
            context.l10n.installmentPayTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black06Text,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserIdSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(installmentPayProvider);
    final notifier = ref.read(installmentPayProvider.notifier);
    final info = state.info;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.installmentPayUserId,
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userIdController,
                  focusNode: _userIdFocusNode,
                  decoration: InputDecoration(
                    hintText: l10n.installmentPayUserIdHint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFCCCCCC),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.black06Text,
                  ),
                  onChanged: (value) {
                    if (value.trim().isEmpty) {
                      _lastQueriedUserId = '';
                      ref.read(installmentPayProvider.notifier).reset();
                    }
                  },
                  onSubmitted: (_) => _searchUser(notifier),
                ),
              ),
              GestureDetector(
                onTap: () => _scanUserId(notifier),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: AppIcons.scanIcon(
                    size: 24,
                    color: AppColors.black06Text,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          // 用户信息区域
          if (state.loadingUser)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox.shrink(),
              ),
            )
          else if (info != null)
            _buildUserInfoCard(context, info)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.installmentPayUserEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(
    BuildContext context,
    InstallmentPaymentResponse info,
  ) {
    final l10n = context.l10n;
    final fullName = '${info.firstName ?? ''} ${info.lastName ?? ''}'.trim();
    final account = (info.username ?? '').trim();
    final displayName = account.isNotEmpty ? account : fullName;
    final status = _resolveStatusPresentation(context, info.userOrderStatus);
    final tipText = _resolveStatusTip(context, info.userOrderStatus);
    final userCardNum = (info.cardNum ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 用户头像和名称行
          GestureDetector(
            onTap: userCardNum.isEmpty
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => UserDetailPage(cardNum: userCardNum),
                      ),
                    );
                  },
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEEEEEE),
                    image: (info.personImg ?? '').isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(info.personImg!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (info.personImg ?? '').isEmpty
                      ? const Icon(Icons.person, color: Color(0xFF999999))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isEmpty ? '-' : displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                      ),
                      if (status != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status.backgroundColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: status.borderColor),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: status.textColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 统计行
          Row(
            children: [
              _buildStatItem(l10n.installmentPayOrder, '${info.orderNum ?? 0}'),
              Container(width: 1, height: 32, color: const Color(0xFFEEEEEE)),
              _buildStatItem(
                l10n.installmentPayTotalConsumption,
                '\$ ${(info.totalAmount ?? 0).toStringAsFixed(2)}',
              ),
              Container(width: 1, height: 32, color: const Color(0xFFEEEEEE)),
              _buildStatItem(
                l10n.installmentPayAssets,
                '${info.deviceNum ?? 0}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 提示文字
          if (tipText.isNotEmpty)
            Row(
              children: [
                Image.asset(
                  'assets/android/mipmap-xxhdpi/icon_order_notify.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tipText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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

  _StatusPresentation? _resolveStatusPresentation(
    BuildContext context,
    int? status,
  ) {
    final l10n = context.l10n;
    switch (status) {
      case 1:
        return const _StatusPresentation(
          label: '',
          textColor: Color(0xFFF49300),
          borderColor: Color(0xFFF49300),
          backgroundColor: Color(0x1AF49300),
        ).copyWith(label: l10n.orderStatusFullPayment);
      case 2:
        return _StatusPresentation(
          label: l10n.orderStatusPaidUp,
          textColor: AppColors.primaryColor,
          borderColor: AppColors.primaryColor,
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
        );
      case 3:
        return const _StatusPresentation(
          label: '',
          textColor: Color(0xFF1184F7),
          borderColor: Color(0xFF1184F7),
          backgroundColor: Color(0x1A1184F7),
        ).copyWith(label: l10n.orderStatusInstallments);
      case 4:
        return const _StatusPresentation(
          label: '',
          textColor: Color(0xFFFA4332),
          borderColor: Color(0xFFFA4332),
          backgroundColor: Color(0x1AFA4332),
        ).copyWith(label: l10n.orderStatusOverdue);
      case 5:
        return const _StatusPresentation(
          label: '',
          textColor: Color(0xFFFA4332),
          borderColor: Color(0xFFFA4332),
          backgroundColor: Color(0x1AFA4332),
        ).copyWith(label: l10n.orderStatusDishonest);
      default:
        return null;
    }
  }

  String _resolveStatusTip(BuildContext context, int? status) {
    final l10n = context.l10n;
    switch (status) {
      case 1:
        return l10n.orderStatusFullPayment;
      case 2:
        return l10n.orderStatusPaidUp;
      case 3:
        return l10n.installmentPayNoOverdue;
      case 4:
        return l10n.userTipOverdue;
      case 5:
        return l10n.userTipDishonest;
      default:
        return '';
    }
  }

  Widget _buildOrderSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(installmentPayProvider);
    final notifier = ref.read(installmentPayProvider.notifier);
    final orders = state.orders;
    final selected = state.selectedOrder;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.installmentPayPaymentOrder,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (selected != null)
            _buildSelectedOrder(context, selected, orders, notifier)
          else
            GestureDetector(
              onTap: orders.isNotEmpty
                  ? () => _selectOrder(context, orders, notifier)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.installmentPaySelectOrder,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF999999),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedOrder(
    BuildContext context,
    PeriodOrder order,
    List<PeriodOrder> orders,
    InstallmentPayNotifier notifier,
  ) {
    final l10n = context.l10n;
    final orderDate = _formatDateTime(order.orderDate);

    return Column(
      children: [
        // 订单头部
        Row(
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_installpayment_order.png',
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.orderNo ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black06Text,
                ),
              ),
            ),
            Text(
              orderDate,
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 设备信息卡片
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // 设备图片和信息
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      image: (order.img ?? '').isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(order.img!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (order.img ?? '').isEmpty
                        ? Icon(
                            order.type == 1
                                ? Icons.directions_bike
                                : Icons.battery_full,
                            color: const Color(0xFF999999),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.sn ?? '-',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black06Text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // 标签
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (_resolveStatusPresentation(
                                  context,
                                  order.status,
                                )
                                case final status?)
                              _buildTag(
                                status.label,
                                status.textColor,
                                borderColor: status.borderColor,
                                backgroundColor: status.backgroundColor,
                              ),
                            _buildTag(
                              _resolvePaySourceText(context, order.paySource),
                              const Color(0xFF666666),
                            ),
                            _buildTag(
                              (order.model ?? '').trim().isEmpty
                                  ? '-'
                                  : order.model!.trim(),
                              const Color(0xFF999999),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 12),
              // Remaining amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.installmentPayRemainingAmount,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Text(
                    '\$${(order.remainPay ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.black06Text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Remaining installments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.installmentPayRemainingInstallments,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Text(
                    '${order.remainPeriod ?? 0}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.black06Text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // The latest due date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.installmentPayDueDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Text(
                    _formatDate(order.rePaymentDate),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.black06Text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Monthly repayment amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.installmentPayMonthlyAmount,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Text(
                    '\$ ${(order.amount ?? 0).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Reselect 按钮
        GestureDetector(
          onTap: () => _selectOrder(context, orders, notifier),
          child: Text(
            l10n.installmentPayReselect,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2196F3)),
          ),
        ),
      ],
    );
  }

  String _resolvePaySourceText(BuildContext context, int? paySource) {
    final l10n = context.l10n;
    final paySourceText = paySource == 2
        ? l10n.orderPayOnline
        : l10n.orderPayCash;
    return '$paySourceText ${l10n.orderPayInstallment}';
  }

  Widget _buildTag(
    String text,
    Color color, {
    Color? borderColor,
    Color? backgroundColor,
  }) {
    final effectiveBorderColor = borderColor ?? color.withValues(alpha: 0.5);
    final effectiveBackgroundColor =
        backgroundColor ?? color.withValues(alpha: 0.1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: effectiveBorderColor),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return '-';
    if (_isZhLocale()) {
      return DateFormatUtils.formatTimestamp(timestamp, pattern: 'yyyy/MM/dd');
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy', 'en').format(date);
  }

  String _formatDateTime(int? timestamp) {
    if (timestamp == null || timestamp <= 0) return '-';
    if (_isZhLocale()) {
      return DateFormatUtils.formatTimestamp(
        timestamp,
        pattern: 'yyyy/MM/dd HH:mm:ss',
      );
    }
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy HH:mm:ss', 'en').format(date);
  }

  bool _isZhLocale() {
    return Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('zh');
  }

  Widget _buildVoucherSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(installmentPayProvider);
    final notifier = ref.read(installmentPayProvider.notifier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.installmentPayVoucher} (${state.attachments.length}/5)',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.black06Text,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...state.attachments.map(
                  (url) => _buildImagePreview(
                    url,
                    () => notifier.removeAttachment(url),
                  ),
                ),
                if (state.attachments.length < 5)
                  _buildAddButton(
                    state.uploading,
                    () => _pickAttachments(context, notifier, state),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String url, VoidCallback onRemove) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: url.startsWith('http')
                  ? NetworkImage(url) as ImageProvider
                  : FileImage(File(url)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton(bool uploading, VoidCallback onTap) {
    return GestureDetector(
      onTap: uploading ? null : onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: uploading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: SizedBox.shrink(),
                ),
              )
            : const Icon(
                Icons.camera_alt_outlined,
                size: 28,
                color: Color(0xFF999999),
              ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(installmentPayProvider);
    final notifier = ref.read(installmentPayProvider.notifier);
    final canSubmit =
        state.selectedOrder != null &&
        state.attachments.isNotEmpty &&
        !state.submitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _submit(context, notifier) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              disabledBackgroundColor: const Color(0xFFB8D8B8),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: state.submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: SizedBox.shrink(),
                  )
                : Text(
                    l10n.installmentPaySubmit,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // === 辅助方法 ===

  void _searchUser(InstallmentPayNotifier notifier) {
    final userId = ScanUtils.getUserCarNum(_userIdController.text.trim());
    if (userId.isNotEmpty) {
      _userIdController.text = userId;
      _lastQueriedUserId = userId;
      notifier.queryUser(userId);
    }
  }

  void _handleUserIdBlur() {
    final notifier = ref.read(installmentPayProvider.notifier);
    final userId = ScanUtils.getUserCarNum(_userIdController.text.trim());
    if (userId.isEmpty) {
      _lastQueriedUserId = '';
      notifier.reset();
      return;
    }
    if (userId == _lastQueriedUserId) {
      return;
    }
    _userIdController.text = userId;
    _lastQueriedUserId = userId;
    notifier.queryUser(userId);
  }

  Future<void> _scanUserId(InstallmentPayNotifier notifier) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (result != null && result.isNotEmpty) {
      final userId = ScanUtils.getUserCarNum(result);
      if (userId.isEmpty) return;
      _userIdController.text = userId;
      _lastQueriedUserId = userId;
      notifier.queryUser(userId);
    }
  }

  Future<void> _selectOrder(
    BuildContext context,
    List<PeriodOrder> orders,
    InstallmentPayNotifier notifier,
  ) async {
    if (orders.isEmpty) return;
    final selected = await InstallmentOrderSheet.show(
      context,
      orders,
      ref.read(installmentPayProvider).selectedOrder,
    );
    if (selected != null) {
      notifier.selectOrder(selected);
    }
  }

  Future<void> _pickAttachments(
    BuildContext context,
    InstallmentPayNotifier notifier,
    InstallmentPayState state,
  ) async {
    final l10n = context.l10n;
    final picker = ImagePicker();
    final remaining = 5 - state.attachments.length;
    if (remaining <= 0) {
      showToast(l10n.installmentPayUploadLimit);
      return;
    }

    final source = await ImageSourceActionSheet.show(context);
    if (!mounted || source == null) return;

    List<XFile> picks;
    if (source == ImageSource.camera) {
      final cameraPick = await picker.pickImage(source: ImageSource.camera);
      if (!mounted || cameraPick == null) return;
      picks = [cameraPick];
    } else {
      if (remaining == 1) {
        final singlePick = await picker.pickImage(source: ImageSource.gallery);
        if (!mounted || singlePick == null) return;
        picks = [singlePick];
      } else {
        final galleryPicks = await picker.pickMultiImage();
        if (!mounted || galleryPicks.isEmpty) return;
        if (galleryPicks.length > remaining) {
          showToast(l10n.installmentPayUploadLimit);
        }
        picks = galleryPicks.take(remaining).toList();
      }
    }

    var failed = 0;
    for (final item in picks) {
      final url = await notifier.uploadAttachment(item.path);
      if (url == null || url.isEmpty) {
        failed += 1;
        continue;
      }
      notifier.addAttachment(url);
    }
    if (!mounted) return;
    if (failed == picks.length) {
      showToast(l10n.installmentPayUploadFailed);
    } else if (failed > 0) {
      showToast(l10n.installmentPayUploadPartialFailed);
    }
  }

  Future<void> _submit(
    BuildContext context,
    InstallmentPayNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final ok = await notifier.submit(_userIdController.text.trim());
    if (!context.mounted) return;
    if (!ok) {
      showToast(l10n.installmentPayFailed);
    }
  }
}

class _SuccessPage extends StatelessWidget {
  const _SuccessPage({required this.documentNo, required this.onReturn});

  final String documentNo;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: onReturn,
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          l10n.installmentPayTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.black06Text,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 成功图标
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.installmentPaySuccessTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.installmentPaySuccessHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
              ),
              const SizedBox(height: 24),
              // Document Number
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.installmentPayDocumentNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          documentNo.isNotEmpty ? documentNo : '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black06Text,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            if (documentNo.isNotEmpty) {
                              Clipboard.setData(
                                ClipboardData(text: documentNo),
                              );
                              showToast(l10n.installmentPayCopied);
                            }
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
              // 返回工作台按钮
              OutlinedButton(
                onPressed: onReturn,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  l10n.installmentPayReturnWorkbench,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPresentation {
  final String label;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  const _StatusPresentation({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  _StatusPresentation copyWith({String? label}) {
    return _StatusPresentation(
      label: label ?? this.label,
      textColor: textColor,
      borderColor: borderColor,
      backgroundColor: backgroundColor,
    );
  }
}
