import 'package:flutter/material.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';

class SwapPaymentSheet extends StatefulWidget {
  const SwapPaymentSheet({
    super.key,
    required this.totalAmount,
    this.initialPaymentMethod,
    this.initialPaymentPeriod,
  });

  final double totalAmount;
  final String? initialPaymentMethod;
  final String? initialPaymentPeriod;

  static Future<Map<String, String>?> show(
    BuildContext context,
    double totalAmount, {
    String? initialPaymentMethod,
    String? initialPaymentPeriod,
  }) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SwapPaymentSheet(
        totalAmount: totalAmount,
        initialPaymentMethod: initialPaymentMethod,
        initialPaymentPeriod: initialPaymentPeriod,
      ),
    );
  }

  @override
  State<SwapPaymentSheet> createState() => _SwapPaymentSheetState();
}

class _SwapPaymentSheetState extends State<SwapPaymentSheet> {
  String? _selectedPaymentMethod;
  String? _selectedPaymentPeriod;

  final List<String> _paymentMethods = ['Cash', 'Online'];
  final List<String> _paymentPeriods = ['Full Payment'];

  @override
  void initState() {
    super.initState();
    _selectedPaymentMethod = widget.initialPaymentMethod ?? 'Cash';
    _selectedPaymentPeriod = widget.initialPaymentPeriod ?? 'Full Payment';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.swapBindSelectPayment,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Payment Methods
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.swapBindPaymentMethods,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _paymentMethods.map((method) {
                  final isSelected = _selectedPaymentMethod == method;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          right: method != _paymentMethods.last ? 12 : 0,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: const Color(0xFF4CAF50))
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              Container(
                                width: 18,
                                height: 18,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4CAF50),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            Text(
                              method,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF333333),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Period
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                l10n.swapBindPaymentPeriod,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _paymentPeriods.map((period) {
                  final isSelected = _selectedPaymentPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPaymentPeriod = period;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: const Color(0xFF4CAF50))
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              Container(
                                width: 18,
                                height: 18,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4CAF50),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            Text(
                              period,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF333333),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Confirm 按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _selectedPaymentMethod != null &&
                          _selectedPaymentPeriod != null
                      ? () {
                          Navigator.of(context).pop({
                            'paymentMethod': _selectedPaymentMethod!,
                            'paymentPeriod': _selectedPaymentPeriod!,
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
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
            ),
          ],
        ),
      ),
    );
  }
}
