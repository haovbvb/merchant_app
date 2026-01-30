import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/payment_plan.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';

class PaymentResult {
  final int paySource;
  final int payType;
  final PaymentPlan? paymentPlan;

  const PaymentResult({
    required this.paySource,
    required this.payType,
    this.paymentPlan,
  });
}

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({
    super.key,
    required this.notifier,
    required this.packageAmount,
  });

  final SellBindNotifier notifier;
  final double packageAmount;

  static Future<PaymentResult?> show(
    BuildContext context,
    SellBindNotifier notifier,
    double packageAmount,
  ) {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentSheet(
        notifier: notifier,
        packageAmount: packageAmount,
      ),
    );
  }

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  int _paySource = 2; // 1=Cash, 2=Online
  int _payType = 1; // 1=Full Payment, 2=Installment
  PaymentPlan? _selectedPlan;

  @override
  void initState() {
    super.initState();
    final state = ref.read(sellBindProvider);
    _paySource = state.paySource;
    _payType = state.payType;
    _selectedPlan = state.selectedPaymentPlan;

    // Load payment plans if selecting installment
    if (_payType == 2 && state.paymentPlans.isEmpty) {
      widget.notifier.queryPaymentPlans(widget.packageAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(sellBindProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
                  l10n.sellBindSelectPayment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
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

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Methods
                  _buildSectionCard(
                    title: l10n.sellBindPaymentMethods,
                    children: [
                      _buildRadioOption(
                        title: l10n.sellBindPayCash,
                        isSelected: _paySource == 1,
                        onTap: () => setState(() => _paySource = 1),
                      ),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      _buildRadioOption(
                        title: l10n.sellBindPayOnline,
                        isSelected: _paySource == 2,
                        onTap: () => setState(() => _paySource = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Period (only for Online)
                  if (_paySource == 2) ...[
                    _buildSectionCard(
                      title: l10n.sellBindPaymentPeriod,
                      children: [
                        _buildRadioOption(
                          title: l10n.sellBindPayFull,
                          isSelected: _payType == 1,
                          onTap: () => setState(() => _payType = 1),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildRadioOption(
                          title: l10n.sellBindPayInstallment,
                          isSelected: _payType == 2,
                          onTap: () {
                            setState(() => _payType = 2);
                            if (state.paymentPlans.isEmpty) {
                              widget.notifier
                                  .queryPaymentPlans(widget.packageAmount);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Installment options
                  if (_paySource == 2 && _payType == 2) ...[
                    _buildSectionCard(
                      children: [
                        _buildFinancialRow(
                          label: l10n.sellBindFinancial,
                          trailing: GestureDetector(
                            onTap: () => _showPeriodSheet(context, state),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _selectedPlan != null
                                          ? '${_selectedPlan!.period} Periods'
                                          : l10n.sellBindSelectPeriod,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.black06Text,
                                      ),
                                    ),
                                    if (_selectedPlan != null)
                                      Text(
                                        '${_selectedPlan!.rate ?? 0}% annual interest rate',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF999999),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildFinancialRow(
                          label: l10n.sellBindPrincipal,
                          trailing: Text(
                            '\$ ${widget.packageAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black06Text,
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        _buildFinancialRow(
                          label: l10n.sellBindTotalInterest,
                          trailing: Text(
                            '\$ ${_calculateInterest().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.black06Text,
                            ),
                          ),
                        ),
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFEEEEEE),
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                        _buildFinancialRow(
                          label: l10n.sellBindTotal,
                          trailing: Text(
                            '\$ ${_calculateTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Total for Full Payment
                  if (_paySource == 2 && _payType == 1) ...[
                    _buildSectionCard(
                      children: [
                        _buildFinancialRow(
                          label: l10n.sellBindTotal,
                          trailing: Text(
                            '\$ ${widget.packageAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // Next button
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _canProceed() ? _proceed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  disabledBackgroundColor: const Color(0xFFE8F5E9),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.sellBindNext,
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
                color: AppColors.black06Text,
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
                      ? AppColors.primaryColor
                      : const Color(0xFFDDDDDD),
                  width: 2,
                ),
                color: isSelected ? AppColors.primaryColor : Colors.white,
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
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  double _calculateInterest() {
    if (_selectedPlan == null) return 0;
    final rate = (_selectedPlan!.rate ?? 0) / 100;
    final periods = _selectedPlan!.period ?? 12;
    return widget.packageAmount * rate * (periods / 12);
  }

  double _calculateTotal() {
    return widget.packageAmount + _calculateInterest();
  }

  bool _canProceed() {
    if (_paySource == 1) return true; // Cash always ok
    if (_payType == 1) return true; // Full payment ok
    return _selectedPlan != null; // Installment needs plan selected
  }

  void _proceed() {
    widget.notifier.updatePaySource(_paySource);
    widget.notifier.updatePayType(_payType);
    if (_selectedPlan != null) {
      widget.notifier.selectPaymentPlan(_selectedPlan!);
    }

    Navigator.of(context).pop(
      PaymentResult(
        paySource: _paySource,
        payType: _payType,
        paymentPlan: _selectedPlan,
      ),
    );
  }

  Future<void> _showPeriodSheet(BuildContext context, SellBindState state) async {
    final l10n = context.l10n;
    final selected = await showModalBottomSheet<PaymentPlan>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...state.paymentPlans.map((plan) {
                final isSelected = _selectedPlan?.planNo == plan.planNo;
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        '${plan.period} Periods',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.black06Text,
                        ),
                      ),
                      subtitle: Text(
                        '${plan.rate ?? 0}% annual interest rate',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      onTap: () => Navigator.of(context).pop(plan),
                    ),
                    const Divider(height: 1),
                  ],
                );
              }),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.black06Text,
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() => _selectedPlan = selected);
    }
  }
}
