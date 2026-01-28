import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';

class RentPaymentResult {
  final int paySource;

  const RentPaymentResult({required this.paySource});
}

class RentPaymentSheet extends ConsumerStatefulWidget {
  const RentPaymentSheet({
    super.key,
    required this.notifier,
    required this.leaseAmount,
    required this.deposit,
  });

  final RentBindNotifier notifier;
  final double leaseAmount;
  final double deposit;

  static Future<RentPaymentResult?> show(
    BuildContext context,
    RentBindNotifier notifier,
    double leaseAmount,
    double deposit,
  ) {
    return showModalBottomSheet<RentPaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RentPaymentSheet(
        notifier: notifier,
        leaseAmount: leaseAmount,
        deposit: deposit,
      ),
    );
  }

  @override
  ConsumerState<RentPaymentSheet> createState() => _RentPaymentSheetState();
}

class _RentPaymentSheetState extends ConsumerState<RentPaymentSheet> {
  int _paySource = 2; // 1=Cash, 2=Online

  @override
  void initState() {
    super.initState();
    final state = ref.read(rentBindProvider);
    _paySource = state.paySource;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = widget.leaseAmount + widget.deposit;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  l10n.rentBindSelectPayment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Color(0xFF999999)),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Methods
                _buildSectionCard(
                  title: l10n.rentBindPaymentMethods,
                  children: [
                    _buildRadioOption(
                      title: l10n.rentBindPayCash,
                      isSelected: _paySource == 1,
                      onTap: () => setState(() => _paySource = 1),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildRadioOption(
                      title: l10n.rentBindPayOnline,
                      isSelected: _paySource == 2,
                      onTap: () => setState(() => _paySource = 2),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Period (Full Payment only for rent)
                _buildSectionCard(
                  title: l10n.rentBindPaymentPeriod,
                  children: [
                    _buildRadioOption(
                      title: l10n.rentBindPayFull,
                      isSelected: true,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Financial summary
                _buildSectionCard(
                  children: [
                    _buildFinancialRow(
                      label: l10n.rentBindLeaseAmount,
                      value: '\$ ${widget.leaseAmount.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    _buildFinancialRow(
                      label: l10n.rentBindDeposit,
                      value: '\$ ${widget.deposit.toStringAsFixed(2)}',
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: const DottedLine(),
                    ),
                    _buildFinancialRow(
                      label: l10n.rentBindTotal,
                      value: '\$ ${total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Confirm button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.rentBindConfirm,
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

  Widget _buildSectionCard({
    String? title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
            ),
            const Spacer(),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFDDDDDD),
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: const Color(0xFF666666),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFFFF9800) : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  void _confirm() {
    widget.notifier.updatePaySource(_paySource);
    Navigator.of(context).pop(
      RentPaymentResult(paySource: _paySource),
    );
  }
}

class DottedLine extends StatelessWidget {
  const DottedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: const Color(0xFFDDDDDD),
            );
          }),
        );
      },
    );
  }
}
