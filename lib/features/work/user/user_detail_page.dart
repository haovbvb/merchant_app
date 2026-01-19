// ignore_for_file: uri_does_not_exist, undefined_class, undefined_function, undefined_identifier

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/bind_device.dart';
import 'package:merchant_app/data/models/user_detail.dart';
import 'package:merchant_app/data/models/user_order_response.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  const UserDetailPage({super.key, required this.cardNum});

  final String cardNum;

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userDetailProvider.notifier).loadDetail(widget.cardNum);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(userDetailProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.userDetailTitle)),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _UserHeader(detail: state.detail),
                const SizedBox(height: 16),
                _SectionTitle(title: l10n.userDetailBindDevicesTitle),
                const SizedBox(height: 8),
                _DeviceSection(
                  title: l10n.userDetailBatteryList,
                  devices: state.detail?.batteryList ?? const [],
                ),
                const SizedBox(height: 12),
                _DeviceSection(
                  title: l10n.userDetailVehicleList,
                  devices: state.detail?.vehicleList ?? const [],
                ),
                const SizedBox(height: 16),
                _SectionTitle(title: l10n.userDetailOrderList),
                const SizedBox(height: 8),
                state.orders.isEmpty
                    ? _EmptyOrderState(text: l10n.userDetailOrderEmpty)
                    : Column(
                        children: [
                          _OrderSection(
                            title: l10n.userDetailOrderSale,
                            orders: state.orders
                                .where((order) => order.orderType == 1)
                                .toList(),
                          ),
                          _OrderSection(
                            title: l10n.userDetailOrderRent,
                            orders: state.orders
                                .where((order) => order.orderType == 2)
                                .toList(),
                          ),
                          _OrderSection(
                            title: l10n.userDetailOrderSwap,
                            orders: state.orders
                                .where((order) => order.orderType == 3)
                                .toList(),
                          ),
                        ],
                      ),
              ],
            ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.detail});

  final UserDetail? detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName =
        '${detail?.firstName ?? ''} ${detail?.lastName ?? ''}'.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName.isEmpty ? (detail?.username ?? '-') : displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('${l10n.userDetailCardNum}: ${detail?.cardNum ?? '-'}'),
            Text('${l10n.userDetailPhone}: ${detail?.phone ?? '-'}'),
            Text('${l10n.userDetailIdNumber}: ${detail?.idNumber ?? '-'}'),
          ],
        ),
      ),
    );
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

class _DeviceSection extends StatelessWidget {
  const _DeviceSection({required this.title, required this.devices});

  final String title;
  final List<BindDevice> devices;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            if (devices.isEmpty)
              _EmptyBindDeviceState(text: l10n.userDetailBindEmpty)
            else
              Column(
                children: devices
                    .map(
                      (device) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(device.deviceSn ?? '-'),
                        subtitle:
                            Text(device.modelName ?? device.model ?? '-'),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBindDeviceState extends StatelessWidget {
  const _EmptyBindDeviceState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/android/mipmap-xxhdpi/empty_user_binddevice.png',
          width: 140,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _EmptyOrderState extends StatelessWidget {
  const _EmptyOrderState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/android/mipmap-xxhdpi/empty_user_orderrecord.png',
          width: 140,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}

class _OrderSection extends StatelessWidget {
  const _OrderSection({required this.title, required this.orders});

  final String title;
  final List<OrderItem> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (orders.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        ...orders.map((order) => _OrderCard(order: order, l10n: l10n)),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.l10n});

  final OrderItem order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typeTag = _typeChip(context, l10n, order.orderType);
    switch (order.orderType) {
      case 1:
        return _SaleOrderCard(order: order, l10n: l10n, typeTag: typeTag);
      case 2:
        return _RentOrderCard(order: order, l10n: l10n, typeTag: typeTag);
      case 3:
        return _SwapOrderCard(order: order, l10n: l10n, typeTag: typeTag);
      default:
        return _BaseOrderCard(
          title: order.orderNo,
          typeTag: typeTag,
          subtitle: _infoRow(l10n.orderLabelAmount, _formatAmount(order.orderAmount)),
          status: _statusChip(context, l10n, order.otherOrder?.status),
        );
    }
  }
}

class _SaleOrderCard extends StatelessWidget {
  const _SaleOrderCard({
    required this.order,
    required this.l10n,
    required this.typeTag,
  });

  final OrderItem order;
  final AppLocalizations l10n;
  final Widget typeTag;

  @override
  Widget build(BuildContext context) {
    final sale = order.saleOrder;
    return _BaseOrderCard(
      title: order.orderNo,
      typeTag: typeTag,
      status: _statusChip(context, l10n, sale?.status),
      leading: _OrderImage(url: sale?.deviceImg),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            l10n.orderLabelOrderTime,
            _formatDate(sale?.createTime ?? order.createTime),
          ),
          _infoRow(l10n.orderLabelDeviceSn, sale?.deviceSn ?? '-'),
          _infoRow(l10n.orderLabelModel, sale?.deviceModel ?? '-'),
          _infoRow(l10n.orderLabelAmount, _formatAmount(order.orderAmount)),
          _infoRow(
            l10n.orderLabelPayType,
            _payTypeLabel(l10n, order.payWay, sale?.payType),
          ),
          if (_buildVoucherAction(
                context,
                l10n,
                order: order,
                status: sale?.status,
                payType: sale?.payType,
                payWay: order.payWay,
                attachment: sale?.attachment ?? order.attachment,
              )
              case final Widget action)
            action,
          if (sale?.payType == 2) ...[
            _infoRow(l10n.orderLabelTerm, sale?.period?.toString() ?? '-'),
            _infoRow(l10n.orderLabelRate, _formatRate(sale?.rate)),
            _infoRow(l10n.orderLabelMonthly, _formatAmount(sale?.perAmount)),
          ],
        ],
      ),
    );
  }
}

class _RentOrderCard extends StatelessWidget {
  const _RentOrderCard({
    required this.order,
    required this.l10n,
    required this.typeTag,
  });

  final OrderItem order;
  final AppLocalizations l10n;
  final Widget typeTag;

  @override
  Widget build(BuildContext context) {
    final rent = order.rentOrder;
    return _BaseOrderCard(
      title: order.orderNo,
      typeTag: typeTag,
      status: _statusChip(context, l10n, rent?.status),
      leading: _OrderImage(url: rent?.deviceImg),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            l10n.orderLabelOrderTime,
            _formatDate(rent?.createTime ?? order.createTime),
          ),
          _infoRow(l10n.orderLabelPackageName, rent?.infoName ?? '-'),
          _infoRow(l10n.orderLabelDeviceSn, rent?.deviceSn ?? '-'),
          _infoRow(l10n.orderLabelModel, rent?.deviceModel ?? '-'),
          _infoRow(l10n.orderLabelAmount, _formatAmount(rent?.serviceAmount)),
          _infoRow(l10n.orderLabelDeposit, _formatAmount(rent?.depositAmount)),
          _infoRow(
            l10n.orderLabelServiceDays,
            _formatUnit(rent?.duration, l10n.orderUnitDays),
          ),
          _infoRow(
            l10n.orderLabelRemainDays,
            _formatUnit(rent?.remainDuration, l10n.orderUnitDays),
          ),
          _infoRow(l10n.orderLabelExpireDate, _formatDate(rent?.expireDate)),
          _infoRow(
            l10n.orderLabelPayType,
            _payTypeLabel(l10n, order.payWay, rent?.payType),
          ),
          if (_buildVoucherAction(
                context,
                l10n,
                order: order,
                status: rent?.status,
                payType: rent?.payType,
                payWay: order.payWay,
                attachment: rent?.attachment ?? order.attachment,
              )
              case final Widget action)
            action,
        ],
      ),
    );
  }
}

class _SwapOrderCard extends StatelessWidget {
  const _SwapOrderCard({
    required this.order,
    required this.l10n,
    required this.typeTag,
  });

  final OrderItem order;
  final AppLocalizations l10n;
  final Widget typeTag;

  @override
  Widget build(BuildContext context) {
    final swap = order.otherOrder;
    final batteryInfo = swap == null
        ? '-'
        : '${swap.batteryType ?? '-'} • ${swap.batteryNum ?? '-'}';
    return _BaseOrderCard(
      title: order.orderNo,
      typeTag: typeTag,
      status: _statusChip(context, l10n, swap?.status),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            l10n.orderLabelOrderTime,
            _formatDate(swap?.createTime ?? order.createTime),
          ),
          _infoRow(l10n.orderLabelPackageName, swap?.infoName ?? '-'),
          _infoRow(l10n.orderLabelVehicle, swap?.carType ?? '-'),
          _infoRow(l10n.orderLabelBattery, batteryInfo),
          _infoRow(l10n.orderLabelAmount, _formatAmount(order.orderAmount)),
          _infoRow(
            l10n.orderLabelServiceDays,
            _formatUnit(swap?.duration, l10n.orderUnitDays),
          ),
          _infoRow(
            l10n.orderLabelSwapTimes,
            _formatUnit(swap?.times, l10n.orderUnitTimes),
          ),
          _infoRow(
            l10n.orderLabelRemainDays,
            _formatUnit(swap?.remainDuration, l10n.orderUnitDays),
          ),
          _infoRow(
            l10n.orderLabelRemainTimes,
            _formatUnit(swap?.remainTime, l10n.orderUnitTimes),
          ),
          _infoRow(l10n.orderLabelExpireDate, _formatDate(swap?.expireDate)),
          _infoRow(
            l10n.orderLabelPayType,
            _payTypeLabel(l10n, order.payWay, swap?.payType),
          ),
          if (_buildVoucherAction(
                context,
                l10n,
                order: order,
                status: swap?.status,
                payType: swap?.payType,
                payWay: order.payWay,
                attachment: swap?.attachment ?? order.attachment,
              )
              case final Widget action)
            action,
        ],
      ),
    );
  }
}

class _BaseOrderCard extends StatelessWidget {
  const _BaseOrderCard({
    required this.title,
    required this.subtitle,
    this.typeTag,
    this.leading,
    this.status,
  });

  final String? title;
  final Widget subtitle;
  final Widget? typeTag;
  final Widget? leading;
  final Widget? status;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (typeTag != null) ...[
                        typeTag!,
                        const SizedBox(height: 6),
                      ],
                      Text(
                        title ?? '-',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                if (status != null) status!,
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(child: subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: url == null || url!.isEmpty
          ? Container(
              width: 52,
              height: 52,
              color: Colors.black12,
              child: const Icon(Icons.image_outlined, size: 28),
            )
          : Image.network(
              url!,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                color: Colors.black12,
                child: const Icon(Icons.broken_image_outlined, size: 28),
              ),
            ),
    );
  }
}

class _VoucherButton extends StatelessWidget {
  const _VoucherButton({
    required this.iconPath,
    required this.label,
    required this.onPressed,
  });

  final String iconPath;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Image.asset(iconPath, width: 18, height: 18),
        label: Text(label),
      ),
    );
  }
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

String _formatDate(int? timestamp) {
  if (timestamp == null || timestamp == 0) return '-';
  final value = timestamp > 1000000000000 ? timestamp : timestamp * 1000;
  return DateFormat('yyyy-MM-dd HH:mm').format(
    DateTime.fromMillisecondsSinceEpoch(value),
  );
}

String _formatAmount(double? amount) {
  final value = amount ?? 0;
  return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
}

String _formatRate(double? rate) {
  if (rate == null) return '-';
  return '${(rate * 100).toStringAsFixed(0)}%';
}

String _formatUnit(int? value, String unit) {
  if (value == null) return '-$unit';
  return '$value$unit';
}

String _payTypeLabel(AppLocalizations l10n, int? payWay, int? payType) {
  final wayLabel = payWay == 1
      ? l10n.orderPayCash
      : payWay == 2
          ? l10n.orderPayOnline
          : '-';
  final typeLabel = payType == 1
      ? l10n.orderPayFull
      : payType == 2
          ? l10n.orderPayInstallment
          : '-';
  if (wayLabel == '-' || typeLabel == '-') return '-';
  return '$wayLabel $typeLabel'.trim();
}

Widget? _buildVoucherAction(
  BuildContext context,
  AppLocalizations l10n, {
  required OrderItem order,
  required int? status,
  required int? payType,
  required int? payWay,
  required String? attachment,
}) {
  final hasAttachment = attachment != null && attachment.trim().isNotEmpty;
  if (status == 0 && payWay == 1) {
    return _VoucherButton(
      iconPath: 'assets/android/mipmap-xxhdpi/icon_upload_voucher.png',
      label: l10n.orderVoucherUpload,
      onPressed: () => _uploadVoucherImages(
        context,
        l10n,
        order: order,
        payType: payType,
        existingAttachment: attachment,
      ),
    );
  }
  if (hasAttachment) {
    return _VoucherButton(
      iconPath: 'assets/android/mipmap-xxhdpi/icon_view_voucher.png',
      label: l10n.orderVoucherView,
      onPressed: () => _showVoucherDialog(context, l10n, attachment),
    );
  }
  return null;
}

Future<void> _uploadVoucherImages(
  BuildContext context,
  AppLocalizations l10n, {
  required OrderItem order,
  required int? payType,
  required String? existingAttachment,
}) async {
  final picker = ImagePicker();
  final files = await _pickVoucherImages(context, l10n, picker);
  if (files.isEmpty) {
    _showSnack(context, l10n.orderVoucherSelectEmpty);
    return;
  }
  final limited = files.length > 5 ? files.take(5).toList() : files;
  if (files.length > 5) {
    _showSnack(context, l10n.orderVoucherMaxCount);
  }

  final progress = ValueNotifier<double>(0);
  _showUploadProgressDialog(context, l10n, progress);

  final notifier = ProviderScope.containerOf(context, listen: false)
      .read(userDetailProvider.notifier);
  final paths = limited
      .map((file) => (file as dynamic).path)
      .whereType<String>()
      .toList();
  final result = await notifier.uploadOrderVouchers(
    paths,
    onProgress: (value) => progress.value = value,
  );
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  if (result.urls.isEmpty) {
    _showSnack(context, l10n.orderVoucherUploadFailed);
    return;
  }
  if (result.failed.isNotEmpty) {
    _showSnack(context, l10n.orderVoucherUploadPartialFailed);
  }

  final attachment = _mergeAttachments(existingAttachment, result.urls);
  final confirmed = await notifier.confirmPayOrder(
    orderNo: order.orderNo,
    attachment: attachment,
  );
  if (!confirmed) {
    _showSnack(context, l10n.orderVoucherConfirmFailed);
    return;
  }
  final newStatus = _statusAfterUpload(order.orderType, payType);
  notifier.updateOrderAttachment(
    orderNo: order.orderNo,
    orderType: order.orderType,
    attachment: attachment,
    newStatus: newStatus,
  );
  _showSnack(context, l10n.orderVoucherConfirmSuccess);
}

String _mergeAttachments(String? existing, List<String> next) {
  final items = <String>{};
  if (existing != null && existing.trim().isNotEmpty) {
    items.addAll(
      existing
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }
  items.addAll(next.where((item) => item.trim().isNotEmpty));
  return items.join(',');
}

int? _statusAfterUpload(int orderType, int? payType) {
  if (orderType == 1) {
    if (payType == 1) return 1;
    if (payType == 2) return 3;
    return null;
  }
  if (orderType == 2 || orderType == 3) {
    return 7;
  }
  return null;
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void _showUploadProgressDialog(
  BuildContext context,
  AppLocalizations l10n,
  ValueNotifier<double> progress,
) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(l10n.orderVoucherUploading),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, value, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: value == 0 ? null : value),
            const SizedBox(height: 12),
            Text('${(value * 100).toStringAsFixed(0)}%'),
          ],
        ),
      ),
    ),
  );
}

Future<List<dynamic>> _pickVoucherImages(
  BuildContext context,
  AppLocalizations l10n,
  ImagePicker picker,
) async {
  final source = await showModalBottomSheet(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: Text(l10n.orderVoucherPickCamera),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_outlined),
            title: Text(l10n.orderVoucherPickGallery),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            title: Text(l10n.orderVoucherPickCancel),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );

  if (source == ImageSource.camera) {
    final file = await picker.pickImage(source: ImageSource.camera);
    return file == null ? [] : [file];
  }
  if (source == ImageSource.gallery) {
    return picker.pickMultiImage();
  }
  return [];
}

void _showVoucherDialog(
  BuildContext context,
  AppLocalizations l10n,
  String attachment,
) {
  final urls = attachment
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
  if (urls.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.orderVoucherEmpty)),
    );
    return;
  }
  showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                l10n.orderVoucherView,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: PageView.builder(
                itemCount: urls.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(
                    urls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.orderVoucherClose),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _statusChip(
  BuildContext context,
  AppLocalizations l10n,
  int? status,
) {
  final label = _statusLabel(l10n, status);
  final colors = _statusColors(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: colors.border),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, color: colors.text),
    ),
  );
}

Widget _typeChip(BuildContext context, AppLocalizations l10n, int orderType) {
  final label = _orderTypeLabel(l10n, orderType);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, color: Color(0xFF5E6A7A)),
    ),
  );
}

String _orderTypeLabel(AppLocalizations l10n, int orderType) {
  switch (orderType) {
    case 1:
      return l10n.userDetailOrderSale;
    case 2:
      return l10n.userDetailOrderRent;
    case 3:
      return l10n.userDetailOrderSwap;
    default:
      return '-';
  }
}

String _statusLabel(AppLocalizations l10n, int? status) {
  switch (status) {
    case -1:
      return l10n.orderStatusClosed;
    case 0:
      return l10n.orderStatusPending;
    case 1:
      return l10n.orderStatusFullPayment;
    case 2:
      return l10n.orderStatusPaidUp;
    case 3:
      return l10n.orderStatusInstallments;
    case 4:
      return l10n.orderStatusOverdue;
    case 5:
      return l10n.orderStatusDishonest;
    case 7:
      return l10n.orderStatusInUse;
    case 8:
      return l10n.orderStatusEnded;
    default:
      return '-';
  }
}

_StatusColors _statusColors(int? status) {
  switch (status) {
    case 0:
      return const _StatusColors(
        text: Color(0xFFF49300),
        background: Color(0xFFFFF2E0),
        border: Color(0xFFF49300),
      );
    case 1:
    case 2:
    case 8:
      return const _StatusColors(
        text: Color(0xFF00B88A),
        background: Color(0xFFE9F7F2),
        border: Color(0xFF00B88A),
      );
    case 3:
    case 7:
      return const _StatusColors(
        text: Color(0xFF1184F7),
        background: Color(0xFFE8F2FF),
        border: Color(0xFF1184F7),
      );
    case 4:
    case 5:
      return const _StatusColors(
        text: Color(0xFFFA4332),
        background: Color(0xFFFFF3F2),
        border: Color(0xFFFA4332),
      );
    case -1:
    default:
      return const _StatusColors(
        text: Color(0x99000000),
        background: Color(0xFFF2F2F2),
        border: Color(0xFFBDBDBD),
      );
  }
}

class _StatusColors {
  const _StatusColors({
    required this.text,
    required this.background,
    required this.border,
  });

  final Color text;
  final Color background;
  final Color border;
}
