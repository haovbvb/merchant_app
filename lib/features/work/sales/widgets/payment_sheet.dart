import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/payment_plan.dart';
import 'package:merchant_app/data/models/shop_payment_method.dart';
import 'package:merchant_app/features/work/sales/sell_bind_controller.dart';
import 'package:merchant_app/features/work/sales/widgets/base_payment_sheet.dart';

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

class SwapPaymentResult {
  final int paySource;

  const SwapPaymentResult({required this.paySource});
}

class PaymentSheet extends ConsumerStatefulWidget {
  const PaymentSheet({
    super.key,
    required this.notifier,
    required this.packageAmount,
    required this.shopPaymentMethod,
  });

  final SellBindNotifier notifier;
  final double packageAmount;
  final ShopPaymentMethod? shopPaymentMethod;

  static Future<PaymentResult?> show(
    BuildContext context,
    SellBindNotifier notifier,
    double packageAmount,
    ShopPaymentMethod? shopPaymentMethod,
  ) {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentSheet(
        notifier: notifier,
        packageAmount: packageAmount,
        shopPaymentMethod: shopPaymentMethod,
      ),
    );
  }

  static Future<SwapPaymentResult?> showForSwap(
    BuildContext context,
    double totalAmount, {
    int initialPaySource = 2,
  }) {
    return showModalBottomSheet<SwapPaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SwapPaymentSheet(
        totalAmount: totalAmount,
        initialPaySource: initialPaySource,
      ),
    );
  }

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _SwapPaymentSheet extends StatefulWidget {
  const _SwapPaymentSheet({
    required this.totalAmount,
    required this.initialPaySource,
  });

  final double totalAmount;
  final int initialPaySource;

  @override
  State<_SwapPaymentSheet> createState() => _SwapPaymentSheetState();
}

class _SwapPaymentSheetState extends State<_SwapPaymentSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BasePaymentSheet(
      title: l10n.swapBindSelectPayment,
      paymentMethodsTitle: l10n.swapBindPaymentMethods,
      payCashText: l10n.swapBindPayCash,
      payOnlineText: l10n.swapBindPayOnline,
      paymentPeriodTitle: l10n.swapBindPaymentPeriod,
      payFullText: l10n.orderStatusFullPayment,
      confirmText: l10n.confirm,
      availablePaySources: const {1, 2},
      initialPaySource: widget.initialPaySource,
      initialPayType: 1,
      availablePayTypesBySource: (_) => const {1},
      amountSectionBuilder: (context, _, __) {
        return _buildSwapAmountCard(l10n);
      },
      onConfirm: (context, selection) {
        Navigator.of(context).pop(
          SwapPaymentResult(paySource: selection.paySource),
        );
      },
    );
  }

  Widget _buildSwapAmountCard(dynamic l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              l10n.swapBindTotal,
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const Spacer(),
            Text(
              '\$ ${widget.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  int _paySource = 2; // 1=Cash, 2=Online
  int _payType = 1; // 1=Full Payment, 2=Installment
  PaymentPlan? _selectedPlan;
  late Set<int> _availablePaySources;
  late Set<int> _onlinePayTypes;
  late Set<int> _cashPayTypes;

  @override
  void initState() {
    super.initState();
    final state = ref.read(sellBindProvider);
    _availablePaySources = _parseOptions(
      widget.shopPaymentMethod?.salePayWay,
      defaultValues: const {1, 2},
    );
    _onlinePayTypes = _parseOptions(
      widget.shopPaymentMethod?.saleOnlineOption,
      defaultValues: const {1, 2},
    );
    _cashPayTypes = _parseOptions(
      widget.shopPaymentMethod?.saleCashOption,
      defaultValues: const {1, 2},
    );
    _paySource = state.paySource;
    _payType = state.payType;
    _selectedPlan = state.selectedPaymentPlan;
    _normalizeSelection(state);

    // Load payment plans if selecting installment
    if (_payType == 2 && state.paymentPlans.isEmpty) {
      widget.notifier.queryPaymentPlans(widget.packageAmount);
    }
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

  Set<int> _payTypesBySource(int source) {
    return source == 1 ? _cashPayTypes : _onlinePayTypes;
  }

  int _pickPaySource(Set<int> sources) {
    if (sources.contains(2)) return 2;
    if (sources.contains(1)) return 1;
    return 2;
  }

  int _pickPayType(Set<int> types) {
    if (types.contains(1)) return 1;
    if (types.contains(2)) return 2;
    return 1;
  }

  void _normalizeSelection(SellBindState state) {
    if (!_availablePaySources.contains(_paySource)) {
      _paySource = _pickPaySource(_availablePaySources);
    }
    final payTypes = _payTypesBySource(_paySource);
    if (!payTypes.contains(_payType)) {
      _payType = _pickPayType(payTypes);
    }
    if (_payType != 2) {
      _selectedPlan = null;
      return;
    }
    if (_selectedPlan == null && state.selectedPaymentPlan != null) {
      _selectedPlan = state.selectedPaymentPlan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(sellBindProvider);
    return BasePaymentSheet(
      title: l10n.sellBindSelectPayment,
      paymentMethodsTitle: l10n.sellBindPaymentMethods,
      payCashText: l10n.sellBindPayCash,
      payOnlineText: l10n.sellBindPayOnline,
      paymentPeriodTitle: l10n.sellBindPaymentPeriod,
      payFullText: l10n.sellBindPayFull,
      payInstallmentText: l10n.sellBindPayInstallment,
      confirmText: l10n.sellBindNext,
      availablePaySources: _availablePaySources,
      initialPaySource: _paySource,
      initialPayType: _payType,
      availablePayTypesBySource: _payTypesBySource,
      canConfirm: (selection) =>
          selection.payType == 1 || _selectedPlan != null,
      onSelectionChanged: (selection) {
        if (selection.payType == 2 && state.paymentPlans.isEmpty) {
          widget.notifier.queryPaymentPlans(widget.packageAmount);
        }
      },
      amountSectionBuilder: (context, selection, _) {
        if (selection.payType == 2) {
          return _buildSectionCard(
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
                              '${_formatRatePercent(_selectedPlan!.rate)} ${l10n.sellBindAnnualRate}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Color(0xFF999999)),
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
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderColor,
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
          );
        }

        return _buildSectionCard(
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
        );
      },
      onConfirm: (context, selection) {
        widget.notifier.updatePaySource(selection.paySource);
        widget.notifier.updatePayType(selection.payType);
        if (selection.payType == 2 && _selectedPlan != null) {
          widget.notifier.selectPaymentPlan(_selectedPlan!);
        } else {
          widget.notifier.clearPaymentPlan();
        }
        Navigator.of(context).pop(
          PaymentResult(
            paySource: selection.paySource,
            payType: selection.payType,
            paymentPlan: _selectedPlan,
          ),
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

  Widget _buildFinancialRow({required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  double _calculateInterest() {
    if (_selectedPlan == null) return 0;
    return _selectedPlan!.fee ?? 0;
  }

  double _calculateTotal() {
    return widget.packageAmount + (_selectedPlan?.fee ?? 0);
  }

  String _formatRatePercent(double? rawRate) {
    final value = (rawRate ?? 0) * 100;
    return value.toStringAsFixed(1);
  }

  Future<void> _showPeriodSheet(
    BuildContext context,
    SellBindState state,
  ) async {
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
                        '${_formatRatePercent(plan.rate)} ${l10n.sellBindAnnualRate}',
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
