import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/after_sale_can_bind_order_bean.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_controller.dart';
import 'package:merchant_app/features/work/after_sale/after_sale_bind_success_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class AfterSaleBindPage extends ConsumerStatefulWidget {
  const AfterSaleBindPage({super.key});

  @override
  ConsumerState<AfterSaleBindPage> createState() =>
      _AfterSaleBindPageState();
}

class _AfterSaleBindPageState extends ConsumerState<AfterSaleBindPage> {
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(afterSaleBindProvider);
    final notifier = ref.read(afterSaleBindProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.afterSaleBindTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SectionTitle(title: l10n.afterSaleBindUserSectionTitle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cardController,
                    decoration: InputDecoration(
                      labelText: l10n.afterSaleBindCardNumLabel,
                      hintText: l10n.afterSaleBindCardNumHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: _scanCardNum,
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: state.loading
                                ? null
                                : () => notifier.fetchUserDetail(),
                          ),
                        ],
                      ),
                    ),
                    onChanged: notifier.updateCardNum,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: l10n.afterSaleBindUserInfoTitle,
                    content: state.userDetail == null
                        ? null
                        : _buildUserInfo(l10n, state),
                    emptyText: l10n.afterSaleBindUserInfoEmpty,
                    emptyIcon: 'assets/android/mipmap-xxhdpi/empty_user_binddevice.png',
                  ),
                  const SizedBox(height: 16),
                  _OrderSelector(
                    title: l10n.afterSaleBindSelectableOrders,
                    emptyText: l10n.afterSaleBindNoOrders,
                    orders: state.orders,
                    selectedOrder: state.selectedOrder,
                    onSelected: notifier.selectOrder,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),
                  _SectionTitle(title: l10n.afterSaleBindDeviceSectionTitle),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _deviceController,
                    decoration: InputDecoration(
                      labelText: l10n.afterSaleBindDeviceSnLabel,
                      hintText: l10n.afterSaleBindDeviceSnHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            onPressed: _scanDeviceSn,
                          ),
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: state.selectedOrder == null
                                ? null
                                : () => notifier.fetchDeviceInfo(),
                          ),
                        ],
                      ),
                    ),
                    onChanged: notifier.updateDeviceSn,
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    title: l10n.afterSaleBindDeviceInfoTitle,
                    content: state.deviceInfo == null
                        ? null
                        : _buildDeviceInfo(l10n, state),
                    emptyText: l10n.afterSaleBindDeviceInfoEmpty,
                    emptyIcon: 'assets/android/mipmap-xxhdpi/empty_user_binddevice.png',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.binding ||
                          state.cardNum.trim().isEmpty ||
                          state.deviceSn.trim().isEmpty ||
                          state.selectedOrder == null
                      ? null
                      : () async {
                          final success = await notifier.bindOrder();
                          if (!context.mounted || !success) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AfterSaleBindSuccessPage(),
                            ),
                          );
                        },
                  child: state.binding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.afterSaleBindConfirm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildUserInfo(AppLocalizations l10n, AfterSaleBindState state) {
    final detail = state.userDetail;
    if (detail == null) {
      return '-';
    }
    final name =
        [detail.firstName, detail.lastName].where((e) => e?.isNotEmpty == true);
    final displayName = name.isEmpty ? '-' : name.join(' ');
    return '${l10n.afterSaleBindUserIdLabel}: ${detail.cardNum ?? '-'}\n'
        '${l10n.afterSaleBindUserNameLabel}: $displayName\n'
        '${l10n.afterSaleBindUserPhoneLabel}: ${detail.phone ?? '-'}';
  }

  String _buildDeviceInfo(AppLocalizations l10n, AfterSaleBindState state) {
    final device = state.deviceInfo;
    if (device == null) {
      return '-';
    }
    if (device.deviceType == 1) {
      final battery = device.batteryVo;
        return '${l10n.afterSaleBindBatteryLabel} SN: ${battery?.sn ?? '-'}\n'
          '${l10n.afterSaleBindModelLabel}: ${battery?.model ?? '-'}\n'
          '${l10n.afterSaleBindSpecLabel}: ${battery?.spec ?? '-'}';
    }
    final car = device.carVo;
    return '${l10n.afterSaleBindVehicleLabel} SN: ${car?.sn ?? '-'}\n'
      '${l10n.afterSaleBindModelLabel}: ${car?.model ?? '-'}\n'
      '${l10n.afterSaleBindSpecLabel}: ${car?.spec ?? '-'}';
  }

  Future<void> _scanCardNum() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _cardController.text = result;
    ref.read(afterSaleBindProvider.notifier).updateCardNum(result);
  }

  Future<void> _scanDeviceSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _deviceController.text = result;
    ref.read(afterSaleBindProvider.notifier).updateDeviceSn(result);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.emptyText,
    required this.emptyIcon,
  });

  final String title;
  final String? content;
  final String emptyText;
  final String emptyIcon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (content == null)
              Column(
                children: [
                  Image.asset(emptyIcon, width: 120),
                  const SizedBox(height: 8),
                  Text(emptyText),
                ],
              )
            else
              Text(content!),
          ],
        ),
      ),
    );
  }
}

class _OrderSelector extends StatelessWidget {
  const _OrderSelector({
    required this.title,
    required this.emptyText,
    required this.orders,
    required this.selectedOrder,
    required this.onSelected,
    required this.l10n,
  });

  final String title;
  final String emptyText;
  final List<AfterSaleCanBindOrderBean> orders;
  final AfterSaleCanBindOrderBean? selectedOrder;
  final ValueChanged<AfterSaleCanBindOrderBean?> onSelected;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (orders.isEmpty)
              Text(emptyText)
            else
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(selectedOrder?.orderNo ?? emptyText),
                subtitle: Text(_subtitleForOrder(selectedOrder)),
                trailing: const Icon(Icons.keyboard_arrow_down),
                onTap: () async {
                  final result = await showModalBottomSheet<
                      AfterSaleCanBindOrderBean>(
                    context: context,
                    builder: (_) => _OrderSheet(orders: orders),
                  );
                  if (result != null) {
                    onSelected(result);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _subtitleForOrder(AfterSaleCanBindOrderBean? order) {
    if (order == null) {
      return '-';
    }
    final device = order.deviceType == 1
        ? '${l10n.afterSaleBindBatteryLabel} | ${order.batteryType ?? '-'}'
        : '${l10n.afterSaleBindVehicleLabel} | ${order.carType ?? '-'}';
    final orderType = _orderTypeLabel(order.type);
    final orderStatus = _orderStatusLabel(order.status);
    return '$device\n$orderType | $orderStatus';
  }

  String _orderTypeLabel(int? type) {
    if (type == 1) {
      return l10n.afterSaleBindOrderTypeSale;
    }
    if (type == 2) {
      return l10n.afterSaleBindOrderTypeLease;
    }
    return '-';
  }

  String _orderStatusLabel(int? status) {
    if (status == 1) {
      return l10n.afterSaleBindOrderStatusPaid;
    }
    if (status == 2) {
      return l10n.afterSaleBindOrderStatusInstallment;
    }
    if (status == 3) {
      return l10n.afterSaleBindOrderStatusLease;
    }
    return '-';
  }
}

class _OrderSheet extends StatelessWidget {
  const _OrderSheet({required this.orders});

  final List<AfterSaleCanBindOrderBean> orders;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order.orderNo ?? '-'),
            subtitle: Text(
              '${order.deviceType == 1 ? context.l10n.afterSaleBindBatteryLabel : context.l10n.afterSaleBindVehicleLabel} | '
              '${order.deviceType == 1 ? order.batteryType ?? '-' : order.carType ?? '-'}\n'
              '${_orderTypeLabel(context, order.type)} | ${_orderStatusLabel(context, order.status)}',
            ),
            onTap: () => Navigator.of(context).pop(order),
          );
        },
      ),
    );
  }

  String _orderTypeLabel(BuildContext context, int? type) {
    if (type == 1) {
      return context.l10n.afterSaleBindOrderTypeSale;
    }
    if (type == 2) {
      return context.l10n.afterSaleBindOrderTypeLease;
    }
    return '-';
  }

  String _orderStatusLabel(BuildContext context, int? status) {
    if (status == 1) {
      return context.l10n.afterSaleBindOrderStatusPaid;
    }
    if (status == 2) {
      return context.l10n.afterSaleBindOrderStatusInstallment;
    }
    if (status == 3) {
      return context.l10n.afterSaleBindOrderStatusLease;
    }
    return '-';
  }
}
