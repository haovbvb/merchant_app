// ignore_for_file: uri_does_not_exist, undefined_class, undefined_function, undefined_identifier

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/data/models/bind_device.dart';
import 'package:merchant_app/data/models/user_detail.dart';
import 'package:merchant_app/data/models/user_order_response.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailPage extends ConsumerStatefulWidget {
  const UserDetailPage({super.key, required this.cardNum});

  final String cardNum;

  @override
  ConsumerState<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends ConsumerState<UserDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userDetailProvider.notifier).loadDetail(widget.cardNum);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(userDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.userDetailTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User header
                _UserHeader(detail: state.detail, l10n: l10n),
                // Tabs
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: const Color(0xFF666666),
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    indicatorColor: AppColors.primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: [
                      Tab(text: l10n.userTabBasicInfo),
                      Tab(text: l10n.userTabOrderRecords),
                      Tab(text: l10n.userTabPaymentRecords),
                      Tab(text: l10n.userTabSwapRecords),
                    ],
                  ),
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _BasicInfoTab(detail: state.detail, l10n: l10n),
                      _OrderRecordsTab(orders: state.orders, l10n: l10n),
                      _PaymentRecordsTab(l10n: l10n),
                      _SwapRecordsTab(l10n: l10n),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.detail, required this.l10n});

  final UserDetail? detail;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${detail?.firstName ?? ''} ${detail?.lastName ?? ''}'.trim();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFF5F5F5),
            backgroundImage: (detail?.avatar?.isNotEmpty ?? false)
                ? NetworkImage(detail!.avatar!)
                : null,
            child: (detail?.avatar?.isEmpty ?? true)
                ? const Icon(Icons.person, color: Color(0xFF999999), size: 36)
                : null,
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName.isEmpty
                      ? (detail?.username ?? '-')
                      : displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${detail?.cardNum ?? '-'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          // Phone button
          if (detail?.phone?.isNotEmpty ?? false)
            GestureDetector(
              onTap: () => _callPhone(detail!.phone!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone, color: Colors.white, size: 16),
                    
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// =============================================================================
// Basic Info Tab
// =============================================================================

class _BasicInfoTab extends StatelessWidget {
  const _BasicInfoTab({required this.detail, required this.l10n});

  final UserDetail? detail;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vehicle & Battery section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _DeviceRow(
                label: l10n.userBasicVehicle,
                devices: detail?.vehicleList ?? const [],
                onTap: () => _showDeviceSheet(context, l10n, l10n.userBasicVehicle,
                    detail?.vehicleList ?? const []),
              ),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _DeviceRow(
                label: l10n.userBasicBattery,
                devices: detail?.batteryList ?? const [],
                onTap: () => _showDeviceSheet(context, l10n, l10n.userBasicBattery,
                    detail?.batteryList ?? const []),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Basic info card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _InfoRow(label: l10n.userBasicRegisterTime, value: detail?.createTime ?? '-'),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(label: l10n.userBasicUserType, value: _getUserType(l10n, detail?.type)),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(label: l10n.userBasicBirthday, value: detail?.birthday ?? '-'),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(label: l10n.userBasicPhone, value: detail?.phone ?? '-'),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(label: l10n.userBasicEmail, value: detail?.email ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Photos section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.userBasicPhotos,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black09Text,
                ),
              ),
              const SizedBox(height: 12),
              _PhotoGrid(photos: _parsePhotos(detail?.imgList)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Remark section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.userBasicRemark,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black09Text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detail?.remark?.isNotEmpty == true ? detail!.remark! : '-',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black06Text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getUserType(AppLocalizations l10n, int? type) {
    switch (type) {
      case 0:
        return l10n.userTypeNormal;
      case 1:
        return l10n.userTypeSenior;
      case 2:
        return l10n.userTypeVip;
      default:
        return l10n.userTypeNormal;
    }
  }

  List<String> _parsePhotos(String? imgList) {
    if (imgList == null || imgList.isEmpty) return const [];
    return imgList.split(',').where((s) => s.trim().isNotEmpty).toList();
  }

  void _showDeviceSheet(BuildContext context, AppLocalizations l10n,
      String title, List<BindDevice> devices) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DeviceSheet(title: title, devices: devices, l10n: l10n),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.label,
    required this.devices,
    required this.onTap,
  });

  final String label;
  final List<BindDevice> devices;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black09Text,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),

              child: Text(
                devices.length.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black06Text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}

class _DeviceSheet extends StatelessWidget {
  const _DeviceSheet({
    required this.title,
    required this.devices,
    required this.l10n,
  });

  final String title;
  final List<BindDevice> devices;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderColor),
          Flexible(
            child: devices.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            l10n.userDetailBindEmpty,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: devices.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _navigateToDeviceDetail(context, device);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device.deviceSn ?? '-',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      device.modelName ?? device.model ?? '-',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF999999),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF999999),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _navigateToDeviceDetail(BuildContext context, BindDevice device) {
    if (device.deviceSn == null || device.deviceSn!.isEmpty) return;
    // deviceType: 1=电池, 2=车辆, 3=电柜
    final typeParam = device.deviceType?.toString() ?? '1';
    AppRouter.router.push(
      '${AppRouter.workModulePath}/device_detail?recordNo=${device.deviceSn}&type=$typeParam',
      extra: 'Device Detail',
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black09Text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.black06Text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Text(
        '-',
        style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: photos.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 72,
              height: 72,
              color: const Color(0xFFF5F5F5),
              child: const Icon(Icons.broken_image_outlined, color: Color(0xFF999999)),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// =============================================================================
// Order Records Tab
// =============================================================================

class _OrderRecordsTab extends StatefulWidget {
  const _OrderRecordsTab({required this.orders, required this.l10n});

  final List<OrderItem> orders;
  final AppLocalizations l10n;

  @override
  State<_OrderRecordsTab> createState() => _OrderRecordsTabState();
}

class _OrderRecordsTabState extends State<_OrderRecordsTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saleOrders = widget.orders.where((o) => o.orderType == 1).toList();
    final rentOrders = widget.orders.where((o) => o.orderType == 2).toList();
    final swapOrders = widget.orders.where((o) => o.orderType == 3).toList();

    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _subTabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: const Color(0xFF666666),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: widget.l10n.userOrderTabSale),
              Tab(text: widget.l10n.userOrderTabRent),
              Tab(text: widget.l10n.userOrderTabSwap),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _OrderList(orders: saleOrders, l10n: widget.l10n, orderType: 1),
              _OrderList(orders: rentOrders, l10n: widget.l10n, orderType: 2),
              _OrderList(orders: swapOrders, l10n: widget.l10n, orderType: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.l10n,
    required this.orderType,
  });

  final List<OrderItem> orders;
  final AppLocalizations l10n;
  final int orderType;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/empty_user_orderrecord.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) => Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.userDetailOrderEmpty,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order, l10n: l10n);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.l10n});

  final OrderItem order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    switch (order.orderType) {
      case 1:
        return _SaleOrderCard(order: order, l10n: l10n);
      case 2:
        return _RentOrderCard(order: order, l10n: l10n);
      case 3:
        return _SwapOrderCard(order: order, l10n: l10n);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SaleOrderCard extends StatelessWidget {
  const _SaleOrderCard({required this.order, required this.l10n});

  final OrderItem order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final sale = order.saleOrder;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
                _statusChip(context, l10n, sale?.status),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderColor),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderImage(url: sale?.deviceImg),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _orderInfoRow(l10n.orderLabelOrderTime, _formatDate(sale?.createTime ?? order.createTime)),
                      _orderInfoRow(l10n.orderLabelDeviceSn, sale?.deviceSn ?? '-'),
                      _orderInfoRow(l10n.orderLabelModel, sale?.deviceModel ?? '-'),
                      _orderInfoRow(l10n.orderLabelAmount, _formatAmount(order.orderAmount)),
                      _orderInfoRow(l10n.orderLabelPayType, _payTypeLabel(l10n, order.payWay, sale?.payType)),
                      if (sale?.payType == 2) ...[
                        _orderInfoRow(l10n.orderLabelTerm, sale?.period?.toString() ?? '-'),
                        _orderInfoRow(l10n.orderLabelRate, _formatRate(sale?.rate)),
                        _orderInfoRow(l10n.orderLabelMonthly, _formatAmount(sale?.perAmount)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Voucher action
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: action,
            ),
        ],
      ),
    );
  }
}

class _RentOrderCard extends StatelessWidget {
  const _RentOrderCard({required this.order, required this.l10n});

  final OrderItem order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rent = order.rentOrder;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
                _statusChip(context, l10n, rent?.status),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderColor),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrderImage(url: rent?.deviceImg),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _orderInfoRow(l10n.orderLabelOrderTime, _formatDate(rent?.createTime ?? order.createTime)),
                      _orderInfoRow(l10n.orderLabelPackageName, rent?.infoName ?? '-'),
                      _orderInfoRow(l10n.orderLabelDeviceSn, rent?.deviceSn ?? '-'),
                      _orderInfoRow(l10n.orderLabelModel, rent?.deviceModel ?? '-'),
                      _orderInfoRow(l10n.orderLabelAmount, _formatAmount(rent?.serviceAmount)),
                      _orderInfoRow(l10n.orderLabelDeposit, _formatAmount(rent?.depositAmount)),
                      _orderInfoRow(l10n.orderLabelServiceDays, _formatUnit(rent?.duration, l10n.orderUnitDays)),
                      _orderInfoRow(l10n.orderLabelRemainDays, _formatUnit(rent?.remainDuration, l10n.orderUnitDays)),
                      _orderInfoRow(l10n.orderLabelExpireDate, _formatDate(rent?.expireDate)),
                      _orderInfoRow(l10n.orderLabelPayType, _payTypeLabel(l10n, order.payWay, rent?.payType)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Voucher action
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: action,
            ),
        ],
      ),
    );
  }
}

class _SwapOrderCard extends StatelessWidget {
  const _SwapOrderCard({required this.order, required this.l10n});

  final OrderItem order;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final swap = order.otherOrder;
    final batteryInfo = swap == null
        ? '-'
        : '${swap.batteryType ?? '-'} • ${swap.batteryNum ?? '-'}';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderNo,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black06Text,
                    ),
                  ),
                ),
                _statusChip(context, l10n, swap?.status),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.borderColor),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _orderInfoRow(l10n.orderLabelOrderTime, _formatDate(swap?.createTime ?? order.createTime)),
                _orderInfoRow(l10n.orderLabelPackageName, swap?.infoName ?? '-'),
                _orderInfoRow(l10n.orderLabelVehicle, swap?.carType ?? '-'),
                _orderInfoRow(l10n.orderLabelBattery, batteryInfo),
                _orderInfoRow(l10n.orderLabelAmount, _formatAmount(order.orderAmount)),
                _orderInfoRow(l10n.orderLabelServiceDays, _formatUnit(swap?.duration, l10n.orderUnitDays)),
                _orderInfoRow(l10n.orderLabelSwapTimes, _formatUnit(swap?.times, l10n.orderUnitTimes)),
                _orderInfoRow(l10n.orderLabelRemainDays, _formatUnit(swap?.remainDuration, l10n.orderUnitDays)),
                _orderInfoRow(l10n.orderLabelRemainTimes, _formatUnit(swap?.remainTime, l10n.orderUnitTimes)),
                _orderInfoRow(l10n.orderLabelExpireDate, _formatDate(swap?.expireDate)),
                _orderInfoRow(l10n.orderLabelPayType, _payTypeLabel(l10n, order.payWay, swap?.payType)),
              ],
            ),
          ),
          // Voucher action
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: action,
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Payment Records Tab
// =============================================================================

class _PaymentRecordsTab extends StatelessWidget {
  const _PaymentRecordsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement payment records API
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.userDetailOrderEmpty,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Swap Records Tab
// =============================================================================

class _SwapRecordsTab extends StatelessWidget {
  const _SwapRecordsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // TODO: Implement swap records API
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            l10n.userDetailOrderEmpty,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null || url!.isEmpty
          ? Container(
              width: 60,
              height: 60,
              color: const Color(0xFFF5F5F5),
              child: const Icon(Icons.image_outlined, size: 28, color: Color(0xFF999999)),
            )
          : Image.network(
              url!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.broken_image_outlined, size: 28, color: Color(0xFF999999)),
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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 16,
              height: 16,
              errorBuilder: (_, __, ___) => Icon(
                Icons.upload_file,
                size: 16,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Helper Functions
// =============================================================================

Widget _orderInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.black09Text),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.black06Text),
          ),
        ),
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
            Divider(height: 1, color: AppColors.borderColor),
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
