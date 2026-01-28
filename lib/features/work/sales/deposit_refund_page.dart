import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/deposit_refund_info_bean.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/deposit_refund_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/deposit_order_sheet.dart';

class DepositRefundPage extends ConsumerStatefulWidget {
  const DepositRefundPage({super.key});

  @override
  ConsumerState<DepositRefundPage> createState() => _DepositRefundPageState();
}

class _DepositRefundPageState extends ConsumerState<DepositRefundPage> {
  final _userIdController = TextEditingController();
  final _remarkController = TextEditingController();

  @override
  void dispose() {
    _userIdController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(depositRefundProvider);

    // 成功页面
    if (state.submitSuccess) {
      return const _SuccessPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                    if (state.selectedDeposit != null) ...[
                      const SizedBox(height: 8),
                      _buildVoucherSection(context),
                      const SizedBox(height: 8),
                      _buildRemarkSection(context),
                    ],
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E8E8), Color(0xFFF5F5F5)],
        ),
      ),
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
          // 图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF3D4A7A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3D4A7A).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.depositRefundTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUserIdSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(depositRefundProvider);
    final notifier = ref.read(depositRefundProvider.notifier);
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
            l10n.depositRefundUserId,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userIdController,
                  decoration: InputDecoration(
                    hintText: l10n.depositRefundUserIdHint,
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
                    color: Color(0xFF333333),
                  ),
                  onSubmitted: (_) => _searchUser(notifier),
                ),
              ),
              GestureDetector(
                onTap: () => _scanUserId(notifier),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 24,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          // 用户信息区域
          if (state.loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (info != null)
            _buildUserInfoCard(info)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.depositRefundUserEmpty,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(DepositRefundInfoBean info) {
    final name = '${info.firstName} ${info.lastName}'.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEEEEE),
              image: info.avatar.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(info.avatar),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: info.avatar.isEmpty
                ? const Icon(Icons.person, color: Color(0xFF999999))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '-' : name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Phone: ${info.phone.isNotEmpty ? info.phone : '-'}',
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
    );
  }

  Widget _buildOrderSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(depositRefundProvider);
    final notifier = ref.read(depositRefundProvider.notifier);
    final selected = state.selectedDeposit;
    final deposits = state.info?.depositList ?? [];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.depositRefundOrderSection,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (selected != null)
                GestureDetector(
                  onTap: () => _selectOrder(context, deposits, notifier),
                  child: Text(
                    l10n.depositRefundReselect,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (selected != null)
            _buildSelectedOrder(selected)
          else
            GestureDetector(
              onTap: deposits.isNotEmpty
                  ? () => _selectOrder(context, deposits, notifier)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.depositRefundSelectOrder,
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

  Widget _buildSelectedOrder(Deposit deposit) {
    final l10n = context.l10n;
    final unbindTimeStr = _formatUnbindTime(deposit.unbindTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 订单号
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 16,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                deposit.orderNo ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$unbindTimeStr unbinding',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF999999),
          ),
        ),
        const Divider(height: 24, color: Color(0xFFEEEEEE)),
        // 退款金额
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.depositRefundAmount,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            Text(
              '\$ ${deposit.depositAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoucherSection(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(depositRefundProvider);
    final notifier = ref.read(depositRefundProvider.notifier);
    final voucherUrls = _splitUrls(state.selectedDeposit);

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
            l10n.depositRefundVoucher,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // 回收状态
              GestureDetector(
                onTap: () =>
                    notifier.setVoucherConfirmed(!state.voucherConfirmed),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state.voucherConfirmed
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        border: Border.all(
                          color: state.voucherConfirmed
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFCCCCCC),
                          width: 2,
                        ),
                      ),
                      child: state.voucherConfirmed
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.depositRefundRecycled,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (voucherUrls.isNotEmpty)
                GestureDetector(
                  onTap: () => _viewVoucher(voucherUrls),
                  child: Text(
                    l10n.depositRefundViewVoucher,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkSection(BuildContext context) {
    final l10n = context.l10n;

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
            l10n.depositRefundRemark,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.depositRefundRemarkHint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFCCCCCC),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(depositRefundProvider);
    final notifier = ref.read(depositRefundProvider.notifier);
    final canSubmit =
        state.selectedDeposit != null && state.info != null && !state.submitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: canSubmit ? () => _submit(notifier) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.depositRefundSubmit,
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

  String _formatUnbindTime(int? timestamp) {
    if (timestamp == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  List<String> _splitUrls(Deposit? deposit) {
    final raw = deposit?.depositImgList ?? '';
    if (raw.isEmpty) return const [];
    return raw.split(',').where((item) => item.trim().isNotEmpty).toList();
  }

  void _searchUser(DepositRefundNotifier notifier) {
    final userId = _userIdController.text.trim();
    if (userId.isNotEmpty) {
      notifier.queryUser(userId);
    }
  }

  Future<void> _scanUserId(DepositRefundNotifier notifier) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (result != null && result.isNotEmpty) {
      _userIdController.text = result;
      notifier.queryUser(result);
    }
  }

  Future<void> _selectOrder(
    BuildContext context,
    List<Deposit> deposits,
    DepositRefundNotifier notifier,
  ) async {
    if (deposits.isEmpty) return;

    final selected = await DepositOrderSheet.show(
      context,
      deposits,
      ref.read(depositRefundProvider).selectedDeposit,
    );
    if (selected != null) {
      notifier.selectDeposit(selected);
    }
  }

  void _viewVoucher(List<String> urls) {
    if (urls.isNotEmpty) {
      // TODO: 实现图片预览功能
      showToast('View voucher: ${urls.length} images');
    }
  }

  Future<void> _submit(DepositRefundNotifier notifier) async {
    final l10n = context.l10n;
    final success = await notifier.submit(
      cardNum: _userIdController.text.trim(),
      remark: _remarkController.text.trim(),
    );
    if (!mounted) return;

    if (!success) {
      showToast(l10n.depositRefundFailed);
    }
  }
}

class _SuccessPage extends ConsumerWidget {
  const _SuccessPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notifier = ref.read(depositRefundProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            notifier.reset();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          l10n.depositRefundTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 60),
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
                  color: Color(0xFF4CAF50),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.depositRefundSuccessTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 32),
              // 返回工作台按钮
              OutlinedButton(
                onPressed: () {
                  notifier.reset();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF4CAF50),
                  side: const BorderSide(color: Color(0xFF4CAF50)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  l10n.depositRefundReturnWorkbench,
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
