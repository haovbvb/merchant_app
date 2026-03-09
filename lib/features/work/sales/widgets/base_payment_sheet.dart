import 'package:flutter/material.dart';
import 'package:merchant_app/app/styles/colors.dart';

class BasePaymentSelection {
  const BasePaymentSelection({
    required this.paySource,
    required this.payType,
  });

  final int paySource;
  final int payType;
}

class BasePaymentResult {
  const BasePaymentResult({
    required this.paySource,
    required this.payType,
  });

  final int paySource;
  final int payType;
}

class BasePaymentSheet extends StatefulWidget {
  const BasePaymentSheet({
    super.key,
    required this.title,
    required this.paymentMethodsTitle,
    required this.payCashText,
    required this.payOnlineText,
    required this.paymentPeriodTitle,
    required this.payFullText,
    this.payInstallmentText,
    required this.confirmText,
    required this.availablePaySources,
    required this.initialPaySource,
    required this.initialPayType,
    this.availablePayTypesBySource,
    this.canConfirm,
    required this.amountSectionBuilder,
    required this.onConfirm,
    this.onSelectionChanged,
  });

  final String title;
  final String paymentMethodsTitle;
  final String payCashText;
  final String payOnlineText;
  final String paymentPeriodTitle;
  final String payFullText;
  final String? payInstallmentText;
  final String confirmText;
  final Set<int> availablePaySources;
  final int initialPaySource;
  final int initialPayType;
  final Set<int> Function(int paySource)? availablePayTypesBySource;
  final bool Function(BasePaymentSelection selection)? canConfirm;
  final Widget Function(
    BuildContext context,
    BasePaymentSelection selection,
    void Function(int payType) setPayType,
  ) amountSectionBuilder;
  final void Function(BuildContext context, BasePaymentSelection selection)
  onConfirm;
  final ValueChanged<BasePaymentSelection>? onSelectionChanged;

  @override
  State<BasePaymentSheet> createState() => _BasePaymentSheetState();
}

class _BasePaymentSheetState extends State<BasePaymentSheet> {
  late int _paySource;
  late int _payType;

  @override
  void initState() {
    super.initState();
    _paySource = widget.initialPaySource;
    _payType = widget.initialPayType;
    _normalizeSelection();
  }

  @override
  Widget build(BuildContext context) {
    final activePayTypes = _payTypesBySource(_paySource);
    final selection = BasePaymentSelection(paySource: _paySource, payType: _payType);
    final isConfirmEnabled = widget.canConfirm?.call(selection) ?? true;

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  widget.title,
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
                  _buildSectionCard(
                    title: widget.paymentMethodsTitle,
                    children: [
                      if (widget.availablePaySources.contains(1))
                        _buildRadioOption(
                          title: widget.payCashText,
                          isSelected: _paySource == 1,
                          onTap: () => setState(() {
                            _paySource = 1;
                            _normalizeSelection();
                            _notifySelectionChanged();
                          }),
                        ),
                      if (widget.availablePaySources.contains(1) &&
                          widget.availablePaySources.contains(2))
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      if (widget.availablePaySources.contains(2))
                        _buildRadioOption(
                          title: widget.payOnlineText,
                          isSelected: _paySource == 2,
                          onTap: () => setState(() {
                            _paySource = 2;
                            _normalizeSelection();
                            _notifySelectionChanged();
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (activePayTypes.isNotEmpty) ...[
                    _buildSectionCard(
                      title: widget.paymentPeriodTitle,
                      children: [
                        if (activePayTypes.contains(1))
                          _buildRadioOption(
                            title: widget.payFullText,
                            isSelected: _payType == 1,
                            onTap: () => setState(() {
                              _payType = 1;
                              _notifySelectionChanged();
                            }),
                          ),
                        if (activePayTypes.contains(1) && activePayTypes.contains(2))
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        if (activePayTypes.contains(2) &&
                            widget.payInstallmentText != null)
                          _buildRadioOption(
                            title: widget.payInstallmentText!,
                            isSelected: _payType == 2,
                            onTap: () => setState(() {
                              _payType = 2;
                              _notifySelectionChanged();
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  widget.amountSectionBuilder(
                    context,
                    selection,
                    (payType) => setState(() {
                      _payType = payType;
                      _notifySelectionChanged();
                    }),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isConfirmEnabled ? _confirm : null,
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
                  widget.confirmText,
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

  void _normalizeSelection() {
    if (!widget.availablePaySources.contains(_paySource)) {
      _paySource = widget.availablePaySources.contains(2) ? 2 : 1;
    }
    final payTypes = _payTypesBySource(_paySource);
    if (!payTypes.contains(_payType)) {
      _payType = payTypes.contains(1) ? 1 : 2;
    }
  }

  Set<int> _payTypesBySource(int source) {
    return widget.availablePayTypesBySource?.call(source) ?? const {1};
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

  void _confirm() {
    widget.onConfirm(
      context,
      BasePaymentSelection(paySource: _paySource, payType: _payType),
    );
  }

  void _notifySelectionChanged() {
    widget.onSelectionChanged?.call(
      BasePaymentSelection(paySource: _paySource, payType: _payType),
    );
  }
}
