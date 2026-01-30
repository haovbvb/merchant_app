import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/installment_payment_response.dart';

class InstallmentOrderSheet extends StatefulWidget {
  const InstallmentOrderSheet({
    super.key,
    required this.orders,
    required this.selected,
  });

  final List<PeriodOrder> orders;
  final PeriodOrder? selected;

  static Future<PeriodOrder?> show(
    BuildContext context,
    List<PeriodOrder> orders,
    PeriodOrder? selected,
  ) {
    return showModalBottomSheet<PeriodOrder>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InstallmentOrderSheet(
        orders: orders,
        selected: selected,
      ),
    );
  }

  @override
  State<InstallmentOrderSheet> createState() => _InstallmentOrderSheetState();
}

class _InstallmentOrderSheetState extends State<InstallmentOrderSheet> {
  PeriodOrder? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              l10n.installmentPaySelectOrderTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black06Text,
              ),
            ),
          ),
          // 订单列表
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: widget.orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = widget.orders[index];
                final isSelected = _selected?.orderNo == order.orderNo;
                return _buildOrderCard(context, order, isSelected);
              },
            ),
          ),
          // 取消按钮
          Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black06Text,
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
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, PeriodOrder order, bool isSelected) {
    final l10n = context.l10n;
    // 设备类型: 1=Vehicle, 2=Battery
    final deviceType = order.type == 1 ? 'Vehicle' : 'Battery';
    final deviceInfo = '$deviceType | ${order.sn ?? '-'}';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = order;
        });
        Navigator.of(context).pop(order);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryColor, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order NO + 选中图标
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: Color(0xFF999999),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order NO: ${order.orderNo ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor,
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
            // Device
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.installmentPayDevice,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
                Text(
                  deviceInfo,
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
    );
  }
}
