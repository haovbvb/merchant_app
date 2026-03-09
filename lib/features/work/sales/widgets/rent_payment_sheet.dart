import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/features/work/sales/rent_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/base_payment_sheet.dart';

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
  late Set<int> _availablePaySources;

  @override
  void initState() {
    super.initState();
    final state = ref.read(rentBindProvider);
    _availablePaySources = _parseOptions(
      state.shopPaymentMethod?.otherPayWay,
      defaultValues: const {1, 2},
    );
    _paySource = state.paySource;
    if (!_availablePaySources.contains(_paySource)) {
      _paySource = _availablePaySources.contains(2) ? 2 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = widget.leaseAmount + widget.deposit;
    return BasePaymentSheet(
      title: l10n.rentBindSelectPayment,
      paymentMethodsTitle: l10n.rentBindPaymentMethods,
      payCashText: l10n.rentBindPayCash,
      payOnlineText: l10n.rentBindPayOnline,
      paymentPeriodTitle: l10n.rentBindPaymentPeriod,
      payFullText: l10n.rentBindPayFull,
      confirmText: l10n.rentBindConfirm,
      availablePaySources: _availablePaySources,
      initialPaySource: _paySource,
      initialPayType: 1,
      availablePayTypesBySource: (_) => const {1},
      amountSectionBuilder: (context, selection, _) {
        return _buildSectionCard(
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
        );
      },
      onConfirm: (context, selection) {
        widget.notifier.updatePaySource(selection.paySource);
        Navigator.of(context).pop(
          RentPaymentResult(paySource: selection.paySource),
        );
      },
    );
  }

  Widget _buildSectionCard({String? title, required List<Widget> children}) {
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
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ),
          ...children,
        ],
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
              color: isTotal ? const Color(0xFFFF9800) : AppColors.black06Text,
            ),
          ),
        ],
      ),
    );
  }

  Set<int> _parseOptions(String? raw, {required Set<int> defaultValues}) {
    if (raw == null || raw.trim().isEmpty) return defaultValues;
    final values = raw
        .split(RegExp(r'[^0-9]+'))
        .where((item) => item.isNotEmpty)
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    return values.isEmpty ? defaultValues : values;
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
