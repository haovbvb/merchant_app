import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/deposit_refund_info_bean.dart';

class DepositOrderSheet extends StatefulWidget {
  const DepositOrderSheet({
    super.key,
    required this.deposits,
    required this.selected,
  });

  final List<Deposit> deposits;
  final Deposit? selected;

  static Future<Deposit?> show(
    BuildContext context,
    List<Deposit> deposits,
    Deposit? selected,
  ) {
    return showModalBottomSheet<Deposit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DepositOrderSheet(
        deposits: deposits,
        selected: selected,
      ),
    );
  }

  @override
  State<DepositOrderSheet> createState() => _DepositOrderSheetState();
}

class _DepositOrderSheetState extends State<DepositOrderSheet> {
  Deposit? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.depositRefundSelectOrderTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          // 订单列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.deposits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final deposit = widget.deposits[index];
                final isSelected = _selected?.orderNo == deposit.orderNo;
                return _buildOrderCard(deposit, isSelected);
              },
            ),
          ),
          // 取消按钮
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF333333),
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    l10n.cancel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Deposit deposit, bool isSelected) {
    final l10n = context.l10n;
    final unbindTimeStr = _formatUnbindTime(deposit.unbindTime);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = deposit;
        });
        Navigator.of(context).pop(deposit);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF4CAF50), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单号 + 选中图标
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    'Order NO: ${deposit.orderNo ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF4CAF50),
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            // 解绑时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.depositRefundUnbindingTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
                Text(
                  unbindTimeStr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 押金金额
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.depositRefundDeposit,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
                Text(
                  '\$ ${deposit.depositAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatUnbindTime(int? timestamp) {
    if (timestamp == null) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
