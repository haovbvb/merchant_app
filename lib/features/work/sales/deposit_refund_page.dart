import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/deposit_refund_info_bean.dart';
import 'package:merchant_app/features/work/sales/deposit_refund_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class DepositRefundPage extends ConsumerStatefulWidget {
  const DepositRefundPage({super.key});

  @override
  ConsumerState<DepositRefundPage> createState() => _DepositRefundPageState();
}

class _DepositRefundPageState extends ConsumerState<DepositRefundPage> {
  final _cardController = TextEditingController();
  final _remarkController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(depositRefundProvider);
    final notifier = ref.read(depositRefundProvider.notifier);
    final info = state.info;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.depositRefundTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _cardController,
            decoration: InputDecoration(
              labelText: l10n.depositRefundCardNum,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => notifier.queryUser(
                  _cardController.text.trim(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: l10n.depositRefundUserInfo,
            content: _userInfoText(l10n, info),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: l10n.depositRefundOrderSection),
          const SizedBox(height: 8),
          _DepositList(
            l10n: l10n,
            deposits: info?.depositList ?? const [],
            selected: state.selectedDeposit,
            onSelected: notifier.selectDeposit,
          ),
          const SizedBox(height: 12),
          _SectionTitle(title: l10n.depositRefundVoucher),
          const SizedBox(height: 6),
          _VoucherChips(urls: _splitUrls(state.selectedDeposit)),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: state.voucherConfirmed,
            onChanged: (value) =>
                notifier.setVoucherConfirmed(value ?? true),
            title: Text(l10n.depositRefundVoucherConfirmed),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _remarkController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.depositRefundRemark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
                : Text(l10n.depositRefundSubmit),
          ),
        ],
      ),
    );
  }

  String _userInfoText(AppLocalizations l10n, DepositRefundInfoBean? info) {
    if (info == null) return l10n.depositRefundUserEmpty;
    final name = '${info.firstName} ${info.lastName}'.trim();
    return '${l10n.depositRefundUserName}: ${name.isEmpty ? '-' : name}\n'
        '${l10n.depositRefundUserPhone}: ${info.phone}\n'
        '${l10n.depositRefundUserCardNum}: ${info.cardNum}';
  }

  List<String> _splitUrls(Deposit? deposit) {
    final raw = deposit?.depositImgList ?? '';
    if (raw.isEmpty) return const [];
    return raw.split(',').where((item) => item.trim().isNotEmpty).toList();
  }

  Future<void> _submit(
    BuildContext context,
    DepositRefundNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final ok = await notifier.submit(
      cardNum: _cardController.text.trim(),
      remark: _remarkController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.depositRefundSuccess : l10n.depositRefundFailed);
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

class _DepositList extends StatelessWidget {
  const _DepositList({
    required this.l10n,
    required this.deposits,
    required this.selected,
    required this.onSelected,
  });

  final AppLocalizations l10n;
  final List<Deposit> deposits;
  final Deposit? selected;
  final ValueChanged<Deposit?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (deposits.isEmpty) {
      return Text(l10n.depositRefundOrderEmpty);
    }
    return Column(
      children: deposits
          .map(
            (deposit) => RadioListTile<Deposit>(
              value: deposit,
              groupValue: selected,
              onChanged: onSelected,
              title: Text(deposit.orderNo ?? '-'),
              subtitle: Text(
                '${l10n.depositRefundAmount}: ${deposit.depositAmount.toStringAsFixed(2)}',
              ),
            ),
          )
          .toList(),
    );
  }
}

class _VoucherChips extends StatelessWidget {
  const _VoucherChips({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) {
      return const Text('-');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: urls.map((url) => Chip(label: Text(url))).toList(),
    );
  }
}
