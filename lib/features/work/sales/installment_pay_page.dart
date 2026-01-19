import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/installment_payment_response.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/features/work/sales/installment_pay_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class InstallmentPayPage extends ConsumerStatefulWidget {
  const InstallmentPayPage({super.key});

  @override
  ConsumerState<InstallmentPayPage> createState() => _InstallmentPayPageState();
}

class _InstallmentPayPageState extends ConsumerState<InstallmentPayPage> {
  final _cardController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(installmentPayProvider);
    final notifier = ref.read(installmentPayProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.installmentPayTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _cardController,
            decoration: InputDecoration(
              labelText: l10n.installmentPayCardNum,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _scanCard,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => notifier.queryUser(
                      _cardController.text.trim(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: l10n.installmentPayUserInfo,
            content: _userInfoText(l10n, state.info),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.installmentPayOrderSection),
          const SizedBox(height: 8),
          _OrderList(
            l10n: l10n,
            orders: state.orders,
            selected: state.selectedOrder,
            onSelected: notifier.selectOrder,
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.installmentPayAttachment),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...state.attachments.map(
                (url) => InputChip(
                  label: Text(url),
                  onDeleted: () => notifier.removeAttachment(url),
                ),
              ),
              ActionChip(
                label: Text(l10n.installmentPayAddAttachment),
                onPressed: state.uploading
                    ? null
                    : () => _pickAttachments(context, notifier, state),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: state.submitting
                ? null
                : () => _submit(context, notifier),
            child: state.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.installmentPaySubmit),
          ),
        ],
      ),
    );
  }

  String _userInfoText(AppLocalizations l10n, InstallmentPaymentResponse? info) {
    if (info == null) return l10n.installmentPayUserEmpty;
    final name = '${info.firstName ?? ''} ${info.lastName ?? ''}'.trim();
    return '${l10n.installmentPayUserName}: ${name.isEmpty ? '-' : name}\n'
        '${l10n.installmentPayUserPhone}: ${info.phone ?? '-'}\n'
        '${l10n.installmentPayTotalAmount}: ${info.totalAmount?.toStringAsFixed(2) ?? '-'}';
  }

  Future<void> _scanCard() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _cardController.text = result;
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
    final picks = await picker.pickMultiImage();
    if (!mounted || picks.isEmpty) return;
    var failed = 0;
    for (final item in picks.take(remaining)) {
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
    final ok = await notifier.submit(_cardController.text.trim());
    if (!context.mounted) return;
    showToast(ok ? l10n.installmentPaySuccess : l10n.installmentPayFailed);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(content),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.l10n,
    required this.orders,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<PeriodOrder> orders;
  final PeriodOrder? selected;
  final ValueChanged<PeriodOrder> onSelected;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Text(l10n.installmentPayOrderEmpty);
    }
    return Column(
      children: orders
          .map(
            (order) => RadioListTile<PeriodOrder>(
              value: order,
              groupValue: selected,
              onChanged: (value) {
                if (value != null) onSelected(value);
              },
              title: Text('${l10n.installmentPayOrderNo}: ${order.orderNo ?? '-'}'),
              subtitle: Text(
                '${l10n.installmentPayAmount}: ${order.amount?.toStringAsFixed(2) ?? '-'}\n'
                '${l10n.installmentPayPeriod}: ${order.period ?? '-'}\n'
                '${l10n.installmentPayRemainPeriod}: ${order.remainPeriod ?? '-'}\n'
                '${l10n.installmentPayRemainPay}: ${order.remainPay?.toStringAsFixed(2) ?? '-'}',
              ),
            ),
          )
          .toList(),
    );
  }
}
