import 'dart:typed_data';

// ignore_for_file: uri_does_not_exist, undefined_class, undefined_function, undefined_identifier

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/image_source_action_sheet.dart';
import 'package:merchant_app/data/models/bind_device.dart';
import 'package:merchant_app/data/models/power_change.dart';
import 'package:merchant_app/data/models/user_detail.dart';
import 'package:merchant_app/data/models/user_order_response.dart';
import 'package:merchant_app/data/models/user_payment_record.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/user/user_controller.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide RefreshIndicator;
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
      final notifier = ref.read(userDetailProvider.notifier);
      notifier.loadDetail(widget.cardNum);
      notifier.loadPayments(cardNum: widget.cardNum, page: 1);
      notifier.loadSwaps(cardNum: widget.cardNum, page: 1);
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
          ? const Center(child: SizedBox.shrink())
          : state.detail == null
          ? _RecordsEmptyView(
              imagePath: 'assets/android/mipmap-xxhdpi/icon_empty_search.png',
              text: l10n.userListEmpty,
            )
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
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _BasicInfoTab(detail: state.detail, l10n: l10n),
                      _OrderRecordsTab(l10n: l10n),
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
    final displayName = '${detail?.firstName ?? ''} ${detail?.lastName ?? ''}'
        .trim();

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
                  displayName.isEmpty ? (detail?.username ?? '-') : displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${(detail?.username?.isNotEmpty ?? false) ? detail!.username : '-'}',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
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
    final phoneText = _formatPhoneWithAreaCode(detail?.phone);
    final contactTextColor = Colors.blue.shade900;

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
                onTap: () => _showDeviceSheet(
                  context,
                  l10n,
                  l10n.userBasicVehicle,
                  detail?.vehicleList ?? const [],
                  deviceType: 2,
                ),
              ),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _DeviceRow(
                label: l10n.userBasicBattery,
                devices: detail?.batteryList ?? const [],
                onTap: () => _showDeviceSheet(
                  context,
                  l10n,
                  l10n.userBasicBattery,
                  detail?.batteryList ?? const [],
                  deviceType: 1,
                ),
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
              _InfoRow(
                label: l10n.userBasicRegisterTime,
                value: DateFormatUtils.formatString(detail?.createTime),
              ),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(
                label: l10n.userBasicUserType,
                value: _getUserType(l10n, detail?.type),
              ),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(
                label: l10n.userBasicBirthday,
                value: detail?.birthday ?? '-',
              ),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(
                label: l10n.userBasicPhone,
                value: phoneText,
                valueColor: contactTextColor,
              ),
              Divider(height: 1, indent: 16, color: AppColors.borderColor),
              _InfoRow(
                label: l10n.userBasicEmail,
                value: detail?.email ?? '-',
                valueColor: contactTextColor,
              ),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black09Text,
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
      case 1:
        return l10n.userFilterNormal;
      case 2:
        return l10n.userFilterOverdue;
      case 3:
        return l10n.userFilterDishonest;
      case 4:
        return l10n.userFilterEnded;
      default:
        return '-';
    }
  }

  List<String> _parsePhotos(String? imgList) {
    if (imgList == null || imgList.isEmpty) return const [];
    return imgList
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _formatPhoneWithAreaCode(String? phone) {
    final value = (phone ?? '').trim();
    if (value.isEmpty) return '-';
    final areaCode = (AuthSession.instance.current?.areaCode ?? '').trim();
    if (areaCode.isEmpty || value.startsWith(areaCode)) {
      return value;
    }
    return '$areaCode $value';
  }

  void _showDeviceSheet(
    BuildContext context,
    AppLocalizations l10n,
    String title,
    List<BindDevice> devices, {
    required int deviceType,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DeviceSheet(
        title: title,
        devices: devices,
        l10n: l10n,
        deviceType: deviceType,
      ),
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

class _DeviceSheet extends StatefulWidget {
  const _DeviceSheet({
    required this.title,
    required this.devices,
    required this.l10n,
    required this.deviceType,
  });

  final String title;
  final List<BindDevice> devices;
  final AppLocalizations l10n;
  final int deviceType;

  @override
  State<_DeviceSheet> createState() => _DeviceSheetState();
}

class _DeviceSheetState extends State<_DeviceSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<BindDevice> _saleDevices;
  late List<BindDevice> _rentalDevices;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _splitDevices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _splitDevices() {
    _saleDevices = [];
    _rentalDevices = [];
    for (final device in widget.devices) {
      if (_isRentalDevice(device)) {
        _rentalDevices.add(device);
      } else {
        _saleDevices.add(device);
      }
    }
  }

  bool _isRentalDevice(BindDevice device) {
    if (device.bindSource != null) {
      return device.bindSource == 2;
    }
    if (device.rentOrderStatus != null) {
      return device.rentOrderStatus != 0;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isBattery = widget.deviceType == 1;
    final titleStyle = const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );
    final tabTextStyle = const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      color: AppColors.bgColor,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(widget.title, style: titleStyle),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: const Color(0xFF999999),
                  labelStyle: tabTextStyle,
                  unselectedLabelStyle: tabTextStyle,
                  indicatorColor: AppColors.primaryColor,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      text:
                          '${widget.l10n.userBindSale} ${_saleDevices.length}',
                    ),
                    Tab(
                      text:
                          '${widget.l10n.userBindRental} ${_rentalDevices.length}',
                    ),
                  ],
                ),
                Divider(height: 1, color: AppColors.borderColor),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.bgColor,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DeviceListView(
                    devices: _saleDevices,
                    l10n: widget.l10n,
                    isBattery: isBattery,
                    onTap: (device) {
                      Navigator.of(context).pop();
                      _navigateToDeviceDetail(context, device);
                    },
                  ),
                  _DeviceListView(
                    devices: _rentalDevices,
                    l10n: widget.l10n,
                    isBattery: isBattery,
                    onTap: (device) {
                      Navigator.of(context).pop();
                      _navigateToDeviceDetail(context, device);
                    },
                  ),
                ],
              ),
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

class _DeviceListView extends StatelessWidget {
  const _DeviceListView({
    required this.devices,
    required this.l10n,
    required this.isBattery,
    required this.onTap,
  });

  final List<BindDevice> devices;
  final AppLocalizations l10n;
  final bool isBattery;
  final ValueChanged<BindDevice> onTap;

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/empty_user_binddevice.png',
              width: 120,
              height: 120,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.link_off, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.userDetailBindEmpty,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: devices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final device = devices[index];
        return _BoundDeviceCard(
          device: device,
          l10n: l10n,
          isBattery: isBattery,
          onTap: () => onTap(device),
        );
      },
    );
  }
}

class _BoundDeviceCard extends StatelessWidget {
  const _BoundDeviceCard({
    required this.device,
    required this.l10n,
    required this.isBattery,
    required this.onTap,
  });

  final BindDevice device;
  final AppLocalizations l10n;
  final bool isBattery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bindTimeText = _bindTimeText(l10n, device.bindDate);
    final showMaintenance =
        device.needMaintenance == true || (device.status == 1);
    final isOnline = device.onlineFlag == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeviceThumb(url: device.img),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceSn ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black09Text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (!isBattery && showMaintenance)
                            _TagChip(
                              text: l10n.homeFilterNeedMaintenance,
                              borderColor: const Color(0xFFF56C6C),
                              textColor: const Color(0xFFF56C6C),
                            ),
                          if (isBattery)
                            _TagChip(
                              text: isOnline
                                  ? l10n.deviceDetailOnline
                                  : l10n.deviceDetailOffline,
                              borderColor: isOnline
                                  ? const Color(0xFF67C23A)
                                  : const Color(0xFFF56C6C),
                              textColor: isOnline
                                  ? const Color(0xFF67C23A)
                                  : const Color(0xFFF56C6C),
                            ),
                          if (bindTimeText != '-')
                            _TagChip(
                              text: bindTimeText,
                              borderColor: const Color(0xFFDDDDDD),
                              textColor: const Color(0xFF666666),
                              backgroundColor: Colors.white,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isBattery)
              _BatteryInfoGrid(
                l10n: l10n,
                soc: device.soc,
                specification: device.modelName,
                model: device.model,
              )
            else
              _VehicleInfoGrid(
                l10n: l10n,
                model: device.model,
                plate: device.carNumber,
                specification: device.modelName,
              ),
          ],
        ),
      ),
    );
  }
}

class _DeviceThumb extends StatelessWidget {
  const _DeviceThumb({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null || url!.isEmpty
          ? Container(
              width: 56,
              height: 56,
              color: const Color(0xFFF2F3F5),
              child: const Icon(
                Icons.image_outlined,
                size: 28,
                color: Color(0xFFB0B0B0),
              ),
            )
          : Image.network(
              url!,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: const Color(0xFFF2F3F5),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 28,
                  color: Color(0xFFB0B0B0),
                ),
              ),
            ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.text,
    required this.borderColor,
    required this.textColor,
    this.backgroundColor = Colors.white,
  });

  final String text;
  final Color borderColor;
  final Color textColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VehicleInfoGrid extends StatelessWidget {
  const _VehicleInfoGrid({
    required this.l10n,
    required this.model,
    required this.plate,
    required this.specification,
  });

  final AppLocalizations l10n;
  final String? model;
  final String? plate;
  final String? specification;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InfoGridBox(
          children: [
            _InfoCell(label: l10n.orderLabelModel, value: model ?? '-'),
            _InfoDivider(),
            _InfoCell(
              label: l10n.repairRecordDevicePlateNumber,
              value: plate ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 8),
        _InfoGridBox(
          children: [
            _InfoCell(
              label: l10n.repairRecordDeviceSpecLabel,
              value: specification ?? '-',
              alignStart: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _BatteryInfoGrid extends StatelessWidget {
  const _BatteryInfoGrid({
    required this.l10n,
    required this.soc,
    required this.specification,
    required this.model,
  });

  final AppLocalizations l10n;
  final int? soc;
  final String? specification;
  final String? model;

  @override
  Widget build(BuildContext context) {
    final socText = soc == null ? '-' : '${soc!}%';
    return _InfoGridBox(
      children: [
        _InfoCell(label: l10n.deviceDetailSoc, value: socText),
        _InfoDivider(),
        _InfoCell(
          label: l10n.repairRecordDeviceSpecLabel,
          value: specification ?? '-',
        ),
        _InfoDivider(),
        _InfoCell(label: l10n.orderLabelModel, value: model ?? '-'),
      ],
    );
  }
}

class _InfoGridBox extends StatelessWidget {
  const _InfoGridBox({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: children),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell({
    required this.label,
    required this.value,
    this.alignStart = false,
  });

  final String label;
  final String value;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: alignStart
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9B9B9B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.black09Text,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: const Color(0xFFE4E6EB),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: valueColor ?? AppColors.black06Text,
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
      children: photos.asMap().entries.map((entry) {
        final index = entry.key;
        final url = entry.value;
        return GestureDetector(
          onTap: () => _showPhotoViewer(context, index),
          child: ClipRRect(
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
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF999999),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPhotoViewer(BuildContext context, int initialIndex) {
    final controller = PageController(initialPage: initialIndex);
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: photos.length,
              pageController: controller,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(photos[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.5,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Order Records Tab
// =============================================================================

class _OrderRecordsTab extends ConsumerStatefulWidget {
  const _OrderRecordsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_OrderRecordsTab> createState() => _OrderRecordsTabState();
}

class _OrderRecordsTabState extends ConsumerState<_OrderRecordsTab> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(userDetailProvider);
      if (state.cardNum.trim().isEmpty) return;
      if (state.saleOrders.isEmpty) {
        await ref
            .read(userDetailProvider.notifier)
            .loadOrders(orderType: _currentOrderType, page: 1);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  int get _currentOrderType {
    switch (_selectedIndex) {
      case 1:
        return 2;
      case 2:
        return 3;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      widget.l10n.userOrderTabSale,
      widget.l10n.userOrderTabRent,
      widget.l10n.userOrderTabSwap,
    ];

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < tabs.length - 1 ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryColor
                              : const Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: _OrderTypeRecordsTab(
            key: ValueKey(_currentOrderType),
            orderType: _currentOrderType,
            l10n: widget.l10n,
          ),
        ),
      ],
    );
  }
}

class _OrderTypeRecordsTab extends ConsumerStatefulWidget {
  const _OrderTypeRecordsTab({
    super.key,
    required this.orderType,
    required this.l10n,
  });

  final int orderType;
  final AppLocalizations l10n;

  @override
  ConsumerState<_OrderTypeRecordsTab> createState() =>
      _OrderTypeRecordsTabState();
}

class _OrderTypeRecordsTabState extends ConsumerState<_OrderTypeRecordsTab> {
  static const Duration _loadMoreMinDuration = Duration(milliseconds: 380);

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = ref.read(userDetailProvider);
      if (state.cardNum.trim().isEmpty) return;
      if (_ordersByType(state).isEmpty) {
        await ref
            .read(userDetailProvider.notifier)
            .loadOrders(orderType: widget.orderType, page: 1);
      }
      if (!mounted) return;
      final refreshed = ref.read(userDetailProvider);
      if (_hasMoreByType(refreshed)) {
        _refreshController.resetNoData();
      } else {
        _refreshController.loadNoData();
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  List<OrderItem> _ordersByType(UserDetailState state) {
    switch (widget.orderType) {
      case 1:
        return state.saleOrders;
      case 2:
        return state.rentOrders;
      case 3:
        return state.swapOrders;
      default:
        return const <OrderItem>[];
    }
  }

  int _currentPageByType(UserDetailState state) {
    switch (widget.orderType) {
      case 1:
        return state.saleOrdersPage;
      case 2:
        return state.rentOrdersPage;
      case 3:
        return state.swapOrdersPage;
      default:
        return 1;
    }
  }

  bool _hasMoreByType(UserDetailState state) {
    switch (widget.orderType) {
      case 1:
        return state.saleOrdersHasMore;
      case 2:
        return state.rentOrdersHasMore;
      case 3:
        return state.swapOrdersHasMore;
      default:
        return false;
    }
  }

  Future<void> _onRefresh() async {
    try {
      await ref
          .read(userDetailProvider.notifier)
          .loadOrders(orderType: widget.orderType, page: 1);
      if (!mounted) return;
      final refreshed = ref.read(userDetailProvider);
      if (_hasMoreByType(refreshed)) {
        _refreshController.resetNoData();
      } else {
        _refreshController.loadNoData();
      }
    } catch (_) {
      _refreshController.refreshFailed();
    }
  }

  Future<void> _loadMore() async {
    final current = ref.read(userDetailProvider);
    if (!_hasMoreByType(current)) {
      _refreshController.loadNoData();
      return;
    }

    final start = DateTime.now();
    final before = _ordersByType(current).length;
    final currentPage = _currentPageByType(current);
    try {
      await ref
          .read(userDetailProvider.notifier)
          .loadOrders(orderType: widget.orderType, page: currentPage + 1);
      final refreshed = ref.read(userDetailProvider);
      final after = _ordersByType(refreshed).length;
      final elapsed = DateTime.now().difference(start);
      if (elapsed < _loadMoreMinDuration) {
        await Future.delayed(_loadMoreMinDuration - elapsed);
      }

      if (!_hasMoreByType(refreshed) || after <= before) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    } catch (_) {
      _refreshController.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailProvider);
    final items = _ordersByType(state);

    return SmartRefresher(
      controller: _refreshController,
      header: _buildRefreshHeader(context),
      footer: _buildRefreshFooter(context),
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () async {
        await _onRefresh();
        if (!mounted) return;
        _refreshController.refreshCompleted();
      },
      onLoading: _loadMore,
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Center(
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
                          widget.l10n.userDetailOrderEmpty,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = items[index];
                return _OrderCard(
                  order: order,
                  l10n: widget.l10n,
                  orderType: widget.orderType,
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.l10n,
    required this.orderType,
  });

  final OrderItem order;
  final AppLocalizations l10n;
  final int orderType;

  @override
  Widget build(BuildContext context) {
    switch (orderType) {
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
    final orderNo = order.orderNo.isNotEmpty ? order.orderNo : '-';
    final timeText = _formatOrderTime(
      order.createTime ?? sale?.createTime ?? 0,
    );
    final payTypeLabel = _payTypeLabel(
      l10n,
      sale?.payWay ?? order.payWay,
      sale?.payType,
    );
    final statusChip = sale?.status != null
        ? _statusChip(context, l10n, sale?.status)
        : null;
    final voucherAction = _buildVoucherAction(
      context,
      l10n,
      order: order,
      status: sale?.status,
      payType: sale?.payType,
      payWay: sale?.payWay ?? order.payWay,
      attachment: _resolveAttachment(sale?.attachment, order.attachment),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _OrderHeaderRow(orderNo: orderNo, timeText: timeText),
          Divider(height: 1, color: AppColors.borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderImage(url: sale?.deviceImg, size: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale?.deviceSn ?? '-',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black09Text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (statusChip != null) statusChip,
                              if (payTypeLabel != '-')
                                _OrderTag(text: payTypeLabel),
                              if ((sale?.deviceModel ?? '').isNotEmpty)
                                _OrderTag(text: sale?.deviceModel ?? '-'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OrderInfoPanel(
                  children: [
                    _InfoLine(
                      label: l10n.sellBindPlanPrice,
                      value: _formatAmount(order.orderAmount),
                    ),
                    if (sale?.payType == 2) ...[
                      _InfoLine(
                        label: l10n.orderLabelTerm,
                        value: sale?.period?.toString() ?? '-',
                      ),
                      _InfoLine(
                        label: l10n.orderLabelRate,
                        value: _formatRate(sale?.rate),
                      ),
                      const _InfoDashedDivider(),
                      _InfoLine(
                        label: l10n.orderLabelMonthly,
                        value: _formatAmount(sale?.perAmount),
                        boldValue: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (voucherAction case final Widget action)
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
    final orderNo = order.orderNo.isNotEmpty ? order.orderNo : '-';
    final timeText = _formatOrderTime(
      order.createTime ?? rent?.createTime ?? 0,
    );
    final payTypeLabel = _payTypeLabel(
      l10n,
      rent?.payWay ?? order.payWay,
      rent?.payType,
    );
    final statusChip = rent?.status != null
        ? _statusChip(context, l10n, rent?.status)
        : null;
    final voucherAction = _buildVoucherAction(
      context,
      l10n,
      order: order,
      status: rent?.status,
      payType: rent?.payType,
      payWay: rent?.payWay ?? order.payWay,
      attachment: _resolveAttachment(rent?.attachment, order.attachment),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _OrderHeaderRow(orderNo: orderNo, timeText: timeText),
          Divider(height: 1, color: AppColors.borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderImage(url: rent?.deviceImg, size: 50),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rent?.deviceSn ?? '-',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black09Text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (statusChip != null) statusChip,
                              if (payTypeLabel != '-')
                                _OrderTag(text: payTypeLabel),
                              if ((rent?.deviceModel ?? '').isNotEmpty)
                                _OrderTag(text: rent?.deviceModel ?? '-'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OrderPackageHeader(
                  title: rent?.infoName ?? '-',
                  amount: _formatAmount(
                    rent?.serviceAmount ?? order.orderAmount,
                  ),
                ),
                _OrderInfoPanel(
                  children: [
                    _InfoLine(
                      label: l10n.orderLabelDeposit,
                      value: _formatAmount(rent?.depositAmount),
                    ),
                    _InfoLine(
                      label: l10n.orderLabelServiceDays,
                      value: _formatUnit(rent?.duration, l10n.orderUnitDays),
                    ),
                    _InfoLine(
                      label: l10n.orderLabelRemainDays,
                      value: _formatUnit(
                        rent?.remainDuration,
                        l10n.orderUnitDays,
                      ),
                    ),
                    _InfoLine(
                      label: l10n.orderLabelExpireDate,
                      value: DateFormatUtils.formatTimestamp(
                        rent?.expireDate,
                        pattern: 'yyyy-MM-dd',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (voucherAction case final Widget action)
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
    final orderNo = order.orderNo.isNotEmpty ? order.orderNo : '-';
    final timeText = _formatOrderTime(
      order.createTime ?? swap?.createTime ?? 0,
    );
    final payTypeLabel = _payTypeLabel(
      l10n,
      swap?.payWay ?? order.payWay,
      swap?.payType,
    );
    final statusChip = swap?.status != null
        ? _statusChip(context, l10n, swap?.status)
        : null;
    final voucherAction = _buildVoucherAction(
      context,
      l10n,
      order: order,
      status: swap?.status,
      payType: swap?.payType,
      payWay: swap?.payWay ?? order.payWay,
      attachment: _resolveAttachment(swap?.attachment, order.attachment),
    );
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
          _OrderHeaderRow(orderNo: orderNo, timeText: timeText),
          Divider(height: 1, color: AppColors.borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderImage(
                      url: null,
                      size: 50,
                      placeholder:
                          'assets/android/mipmap-xxhdpi/icon_swap_bind.webp',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  swap?.infoName ?? '-',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black09Text,
                                  ),
                                ),
                              ),
                              Text(
                                _formatAmount(order.orderAmount),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black09Text,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (statusChip != null) statusChip,
                              if (payTypeLabel != '-')
                                _OrderTag(text: payTypeLabel),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _OrderInfoPanel(
                  children: [
                    _InfoLine(
                      label: l10n.orderLabelVehicle,
                      value: swap?.carType ?? '-',
                    ),
                    _InfoLine(
                      label: l10n.orderLabelBattery,
                      value: batteryInfo,
                    ),
                    _InfoLine(
                      label: l10n.orderLabelServiceDays,
                      value: _formatUnit(swap?.duration, l10n.orderUnitDays),
                    ),
                    _InfoLine(
                      label: l10n.orderLabelSwapTimes,
                      value: _formatUnit(swap?.times, l10n.orderUnitTimes),
                    ),
                    const _InfoDashedDivider(),
                    _InfoLine(
                      label: l10n.orderLabelRemainDays,
                      value: _formatUnit(
                        swap?.remainDuration,
                        l10n.orderUnitDays,
                      ),
                    ),
                    _InfoLine(
                      label: l10n.orderLabelRemainTimes,
                      value: swap?.status == 0
                          ? _formatUnit(null, l10n.orderUnitTimes)
                          : _formatUnit(swap?.remainTime, l10n.orderUnitTimes),
                    ),
                    _InfoLine(
                      label: l10n.orderLabelExpireDate,
                      value: _formatDate(swap?.expireDate),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (voucherAction case final Widget action)
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

class _PaymentRecordsTab extends ConsumerStatefulWidget {
  const _PaymentRecordsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_PaymentRecordsTab> createState() => _PaymentRecordsTabState();
}

class _PaymentRecordsTabState extends ConsumerState<_PaymentRecordsTab> {
  static const Duration _loadMoreMinDuration = Duration(milliseconds: 380);

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(userDetailProvider);
      if (state.cardNum.isNotEmpty && state.payments.isEmpty) {
        ref.read(userDetailProvider.notifier).loadPayments(page: 1);
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailProvider);
    final notifier = ref.read(userDetailProvider.notifier);
    final items = state.payments;

    return SmartRefresher(
      controller: _refreshController,
      header: _buildRefreshHeader(context),
      footer: _buildRefreshFooter(context),
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () async {
        try {
          await notifier.loadPayments(page: 1);
          _refreshController.refreshCompleted();
          _refreshController.resetNoData();
        } catch (_) {
          _refreshController.refreshFailed();
        }
      },
      onLoading: () async {
        try {
          final start = DateTime.now();
          final before = ref.read(userDetailProvider).payments.length;
          final currentPage = ref.read(userDetailProvider).paymentsPage;
          await notifier.loadPayments(page: currentPage + 1);
          final refreshed = ref.read(userDetailProvider);
          final elapsed = DateTime.now().difference(start);
          if (elapsed < _loadMoreMinDuration) {
            await Future.delayed(_loadMoreMinDuration - elapsed);
          }

          if (!refreshed.paymentsHasMore ||
              refreshed.payments.length <= before) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
        } catch (_) {
          _refreshController.loadFailed();
        }
      },
      child: items.isEmpty && !state.loadingPayments
          ? _RecordsEmptyView(
              imagePath:
                  'assets/android/mipmap-xxhdpi/icon_empty_payrecord.png',
              text: widget.l10n.userPaymentEmpty,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _PaymentRecordCard(
                  record: items[index],
                  l10n: widget.l10n,
                );
              },
            ),
    );
  }
}

// =============================================================================
// Swap Records Tab
// =============================================================================

class _SwapRecordsTab extends ConsumerStatefulWidget {
  const _SwapRecordsTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  ConsumerState<_SwapRecordsTab> createState() => _SwapRecordsTabState();
}

class _SwapRecordsTabState extends ConsumerState<_SwapRecordsTab> {
  static const Duration _loadMoreMinDuration = Duration(milliseconds: 380);

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(userDetailProvider);
      if (state.cardNum.isNotEmpty && state.swaps.isEmpty) {
        ref.read(userDetailProvider.notifier).loadSwaps(page: 1);
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userDetailProvider);
    final notifier = ref.read(userDetailProvider.notifier);
    final items = state.swaps;

    return SmartRefresher(
      controller: _refreshController,
      header: _buildRefreshHeader(context),
      footer: _buildRefreshFooter(context),
      enablePullDown: true,
      enablePullUp: true,
      onRefresh: () async {
        try {
          await notifier.loadSwaps(page: 1);
          _refreshController.refreshCompleted();
          _refreshController.resetNoData();
        } catch (_) {
          _refreshController.refreshFailed();
        }
      },
      onLoading: () async {
        try {
          final start = DateTime.now();
          final before = ref.read(userDetailProvider).swaps.length;
          final currentPage = ref.read(userDetailProvider).swapsPage;
          await notifier.loadSwaps(page: currentPage + 1);
          final refreshed = ref.read(userDetailProvider);
          final elapsed = DateTime.now().difference(start);
          if (elapsed < _loadMoreMinDuration) {
            await Future.delayed(_loadMoreMinDuration - elapsed);
          }

          if (!refreshed.swapsHasMore || refreshed.swaps.length <= before) {
            _refreshController.loadNoData();
          } else {
            _refreshController.loadComplete();
          }
        } catch (_) {
          _refreshController.loadFailed();
        }
      },
      child: items.isEmpty && !state.loadingSwaps
          ? _RecordsEmptyView(
              imagePath:
                  'assets/android/mipmap-xxhdpi/icon_empty_swaprecord.png',
              text: widget.l10n.userSwapEmpty,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _SwapRecordCard(record: items[index], l10n: widget.l10n);
              },
            ),
    );
  }
}

// =============================================================================
// Helper Widgets
// =============================================================================

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.url, this.size = 60, this.placeholder});

  final String? url;
  final double size;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: url == null || url!.isEmpty
          ? _OrderPlaceholder(size: size, asset: placeholder)
          : Image.network(
              url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                color: const Color(0xFFF5F5F5),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 28,
                  color: Color(0xFF999999),
                ),
              ),
            ),
    );
  }
}

class _OrderPlaceholder extends StatelessWidget {
  const _OrderPlaceholder({required this.size, this.asset});

  final double size;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    if (asset != null && asset!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xFFF5F5F5),
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          asset!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.image_outlined,
            size: 28,
            color: Color(0xFF999999),
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFF5F5F5),
      child: const Icon(
        Icons.image_outlined,
        size: 28,
        color: Color(0xFF999999),
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 18,
              height: 18,
              errorBuilder: (_, __, ___) => Icon(
                Icons.upload_file,
                size: 18,
                color: AppColors.black06Text,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: AppColors.black06Text),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHeaderRow extends StatelessWidget {
  const _OrderHeaderRow({required this.orderNo, required this.timeText});

  final String orderNo;
  final String timeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_userdetail_saleorder.png',
            width: 18,
            height: 18,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.event_note_outlined,
              size: 18,
              color: Color(0xFF999999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              orderNo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black09Text,
              ),
            ),
          ),
          Text(
            timeText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }
}

class _OrderTag extends StatelessWidget {
  const _OrderTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D4DA)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
      ),
    );
  }
}

class _OrderPackageHeader extends StatelessWidget {
  const _OrderPackageHeader({required this.title, required this.amount});

  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3A4D9C), Color(0xFF2A3F83)],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderInfoPanel extends StatelessWidget {
  const _OrderInfoPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.boldValue = false,
  });

  final String label;
  final String value;
  final bool boldValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A8A)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.black09Text,
              fontWeight: boldValue ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDashedDivider extends StatelessWidget {
  const _InfoDashedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 1,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
    );
  }
}

class _RecordsEmptyView extends StatelessWidget {
  const _RecordsEmptyView({required this.imagePath, required this.text});

  final String imagePath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 120,
            height: 120,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }
}

class _PickedXFileThumb extends StatelessWidget {
  const _PickedXFileThumb({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          );
        }
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Icon(Icons.image_outlined, color: Color(0xFF999999)),
        );
      },
    );
  }
}

class _PaymentRecordCard extends StatelessWidget {
  const _PaymentRecordCard({required this.record, required this.l10n});

  final UserPaymentRecord record;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final payWayLabel = _paymentWayLabel(l10n, record.payWay);
    final payTypeLabel = _paymentTypeLabel(l10n, record.payType);
    final title = [
      payWayLabel,
      payTypeLabel,
    ].where((item) => item.trim().isNotEmpty && item != '-').join('');
    final amountText = _formatAmountOptional(record.amount);
    final timeText = DateFormatUtils.formatString(record.payTime);
    final attachment = _resolveAttachment(record.attachment, null);
    final hasVoucher = _parseAttachmentUrls(attachment).isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                _paymentIconPath(record.payWay),
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.payment_outlined,
                  size: 28,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? '-' : title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black09Text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.userPaymentOrderNo} ${record.orderNo ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.black06Text,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amountText,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black09Text,
                    ),
                  ),
                  if (record.payType == 2) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.userPaymentPeriod} ${record.period?.toString() ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.black06Text,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Row(
              children: [
                Text(
                  timeText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF999999),
                  ),
                ),
                const Spacer(),
                if (hasVoucher)
                  GestureDetector(
                    onTap: () => _showVoucherDialog(context, l10n, attachment),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD0D4DA)),
                      ),
                      child: Text(
                        l10n.orderVoucherView,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapRecordCard extends StatelessWidget {
  const _SwapRecordCard({required this.record, required this.l10n});

  final PowerChangeItem record;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typeInfo = _swapTypeInfo(l10n, record);
    final statusLabel = _swapStatusLabel(l10n, record);
    final statusColor = _swapStatusColor(record.status);
    final timeText = DateFormatUtils.formatString(record.createTime);
    final operator = record.handlerName ?? '-';
    final detailRows = <MapEntry<String, String>>[];
    if (operator.isNotEmpty) {
      detailRows.add(MapEntry(l10n.userSwapOperator, operator));
    }
    if (record.stationSn?.isNotEmpty ?? false) {
      detailRows.add(MapEntry(l10n.userSwapStationSn, record.stationSn ?? '-'));
    }
    if (record.outBattery?.isNotEmpty ?? false) {
      detailRows.add(
        MapEntry(l10n.userSwapOutBattery, record.outBattery ?? '-'),
      );
    }
    if (record.inBattery?.isNotEmpty ?? false) {
      detailRows.add(MapEntry(l10n.userSwapInBattery, record.inBattery ?? '-'));
    }
    if (record.error?.isNotEmpty ?? false) {
      detailRows.add(MapEntry(l10n.userSwapError, record.error ?? '-'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                typeInfo.iconPath,
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.swap_horiz_outlined,
                  size: 22,
                  color: Color(0xFF999999),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  typeInfo.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black09Text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: record.status == 1 ? 14 : 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            timeText,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6E7681)),
          ),
          if (detailRows.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: const Color(0xFFEFF2F5)),
            const SizedBox(height: 12),
            ...detailRows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _swapRecordInfoRow(row.key, row.value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SwapTypeInfo {
  const _SwapTypeInfo(this.label, this.iconPath);

  final String label;
  final String iconPath;
}

Widget _buildRefreshHeader(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode == 'zh';
  return CustomHeader(
    height: 56,
    builder: (context, mode) {
      final status = mode ?? RefreshStatus.idle;
      String text;
      Widget icon;
      switch (status) {
        case RefreshStatus.canRefresh:
          text = isZh ? '松开刷新' : 'Release to refresh';
          icon = const Icon(
            Icons.arrow_downward,
            size: 16,
            color: AppColors.black06Text,
          );
          break;
        case RefreshStatus.refreshing:
          text = isZh ? '正在刷新...' : 'Refreshing...';
          icon = const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
          break;
        case RefreshStatus.completed:
          text = isZh ? '刷新成功' : 'Refresh completed';
          icon = const Icon(Icons.check_circle, size: 16, color: Colors.green);
          break;
        case RefreshStatus.failed:
          text = isZh ? '刷新失败' : 'Refresh failed';
          icon = const Icon(Icons.error, size: 16, color: Colors.redAccent);
          break;
        default:
          text = isZh ? '下拉刷新' : 'Pull down to refresh';
          icon = const Icon(
            Icons.arrow_downward,
            size: 16,
            color: AppColors.black06Text,
          );
      }

      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.black06Text,
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildRefreshFooter(BuildContext context) {
  final isZh = Localizations.localeOf(context).languageCode == 'zh';
  return CustomFooter(
    height: 56,
    builder: (context, mode) {
      final status = mode ?? LoadStatus.idle;
      String text;
      Widget icon;
      switch (status) {
        case LoadStatus.canLoading:
          text = isZh ? '松开加载' : 'Release to load';
          icon = const Icon(
            Icons.arrow_upward,
            size: 16,
            color: AppColors.black06Text,
          );
          break;
        case LoadStatus.loading:
          text = isZh ? '正在加载...' : 'Loading...';
          icon = const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          );
          break;
        case LoadStatus.noMore:
          text = isZh ? '没有更多数据' : 'No more data';
          icon = const Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.black05Text,
          );
          break;
        case LoadStatus.failed:
          text = isZh ? '加载失败，点击重试' : 'Load failed, tap to retry';
          icon = const Icon(Icons.error, size: 16, color: Colors.redAccent);
          break;
        default:
          text = isZh ? '上拉加载更多' : 'Pull up to load more';
          icon = const Icon(
            Icons.arrow_upward,
            size: 16,
            color: AppColors.black06Text,
          );
      }

      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.black06Text,
              ),
            ),
          ],
        ),
      );
    },
  );
}

// =============================================================================
// Helper Functions
// =============================================================================

Widget _swapRecordInfoRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 92,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6E7681),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.black09Text,
          ),
        ),
      ),
    ],
  );
}

String _formatDate(int? timestamp) {
  return DateFormatUtils.formatTimestamp(
    timestamp,
    pattern: 'yyyy-MM-dd HH:mm',
  );
}

String _formatOrderTime(int? timestamp) {
  return DateFormatUtils.formatTimestamp(timestamp);
}

String _formatAmount(double? amount) {
  final value = amount ?? 0;
  return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(value);
}

String _formatAmountOptional(double? amount) {
  if (amount == null) return '-';
  return _formatAmount(amount);
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
  return '$wayLabel$typeLabel'.trim();
}

String _resolveAttachment(String? primary, String? fallback) {
  String normalize(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '';
    if (text == 'null' || text == '[]') return '';
    return text;
  }

  final first = normalize(primary);
  if (first.isNotEmpty) return first;
  return normalize(fallback);
}

List<String> _parseAttachmentUrls(String attachment) {
  var text = attachment.trim();
  if (text.isEmpty || text == 'null' || text == '[]') return const [];
  if (text.startsWith('[') && text.endsWith(']')) {
    text = text.substring(1, text.length - 1);
  }
  text = text.replaceAll('"', '');
  return text
      .split(RegExp(r'[,;|]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

String _bindTimeText(AppLocalizations l10n, int? timestamp) {
  final time = DateFormatUtils.formatTimestamp(timestamp);
  if (time == '-') return '-';
  return '$time ${l10n.userBindTimeSuffix}';
}

String _paymentWayLabel(AppLocalizations l10n, int? payWay) {
  switch (payWay) {
    case 1:
      return l10n.orderPayCash;
    case 2:
      return l10n.orderPayOnline;
    default:
      return '-';
  }
}

String _paymentTypeLabel(AppLocalizations l10n, int? payType) {
  switch (payType) {
    case 1:
      return l10n.orderPayFull;
    case 2:
      return l10n.orderPayInstallment;
    default:
      return '-';
  }
}

String _paymentIconPath(int? payWay) {
  switch (payWay) {
    case 1:
      return 'assets/android/mipmap-xxhdpi/icon_payrecord_cash.png';
    case 2:
      return 'assets/android/mipmap-xxhdpi/icon_payrecord_online.png';
    default:
      return 'assets/android/mipmap-xxhdpi/icon_payrecord_cash.png';
  }
}

_SwapTypeInfo _swapTypeInfo(AppLocalizations l10n, PowerChangeItem record) {
  final title = record.swapTypeName?.isNotEmpty == true
      ? record.swapTypeName!
      : null;
  switch (record.type) {
    case 5:
      return _SwapTypeInfo(
        title ?? l10n.userSwapManual,
        'assets/android/mipmap-xxhdpi/icon_manual_change.webp',
      );
    case 6:
      return _SwapTypeInfo(
        title ?? l10n.userSwapRemote,
        'assets/android/mipmap-xxhdpi/icon_remote_change.png',
      );
    case 7:
      return _SwapTypeInfo(
        title ?? l10n.userSwapBluetooth,
        'assets/android/mipmap-xxhdpi/icon_bluetooth_change.png',
      );
    default:
      return _SwapTypeInfo(
        title ?? l10n.userSwapScan,
        'assets/android/mipmap-xxhdpi/icon_scan_change.webp',
      );
  }
}

String _swapStatusLabel(AppLocalizations l10n, PowerChangeItem record) {
  // if (record.showStatusName?.isNotEmpty == true) {
  //   return record.showStatusName!;
  // }
  switch (record.status) {
    case 1:
      return l10n.userSwapStatusSuccess;
    case 2:
      return l10n.userSwapStatusFail;
    case 3:
      return l10n.userSwapStatusPartSuccess;
    case 4:
      return l10n.userSwapStatusSystemReject;
    default:
      return '-';
  }
}

Color _swapStatusColor(int? status) {
  switch (status) {
    case 1:
      return const Color(0xFF19BE6B);
    case 2:
      return const Color(0xFFF56C6C);
    case 3:
      return const Color(0xFFE6A23C);
    case 4:
      return const Color(0xFFF56C6C);
    default:
      return const Color(0xFF909399);
  }
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
  if (hasAttachment) {
    return _VoucherButton(
      iconPath: 'assets/android/mipmap-xxhdpi/icon_view_voucher.png',
      label: l10n.orderVoucherView,
      onPressed: () => _showVoucherDialog(context, l10n, attachment),
    );
  }
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
  return null;
}

Future<void> _uploadVoucherImages(
  BuildContext context,
  AppLocalizations l10n, {
  required OrderItem order,
  required int? payType,
  required String? existingAttachment,
}) async {
  final files = await _showUploadVoucherDialog(context, l10n);
  if (files == null) {
    return;
  }
  if (files.isEmpty) {
    _showSnack(context, l10n.orderVoucherSelectEmpty);
    return;
  }
  final limited = files.length > 5 ? files.take(5).toList() : files;

  final progress = ValueNotifier<double>(0);
  _showUploadProgressDialog(context, l10n, progress);

  final notifier = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(userDetailProvider.notifier);
  final paths = limited
      .map((file) => file.path)
      .where((path) => path.trim().isNotEmpty)
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

Future<List<XFile>?> _showUploadVoucherDialog(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final picker = ImagePicker();
  final selected = <XFile>[];

  return showModalBottomSheet<List<XFile>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          void appendPickedFiles(List<XFile> files) {
            if (files.isEmpty) {
              return;
            }
            final remain = 5 - selected.length;
            if (remain <= 0) {
              showToast(l10n.orderVoucherMaxCount);
              return;
            }
            final toAppend = <XFile>[];
            for (final file in files) {
              if (file.path.trim().isEmpty) {
                continue;
              }
              toAppend.add(file);
              if (toAppend.length >= remain) {
                break;
              }
            }

            if (toAppend.isNotEmpty) {
              selected.addAll(toAppend);
              setState(() {});
            }
          }

          Future<void> pickFromSource(ImageSource source) async {
            final remain = 5 - selected.length;
            if (remain <= 0) {
              showToast(l10n.orderVoucherMaxCount);
              return;
            }
            if (source == ImageSource.camera) {
              final file = await picker.pickImage(source: ImageSource.camera);
              if (file != null) {
                appendPickedFiles(<XFile>[file]);
              }
            } else {
              // Cap album selection by remaining slots to match native behavior.
              if (remain == 1) {
                final file = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (file != null) {
                  appendPickedFiles(<XFile>[file]);
                }
              } else {
                // Prefer the platform media picker path for better limit support.
                final files = await picker.pickMultipleMedia(limit: remain);
                appendPickedFiles(files);
              }
            }
          }

          Future<void> addImages() async {
            if (selected.length >= 5) {
              showToast(l10n.orderVoucherMaxCount);
              return;
            }
            final source = await ImageSourceActionSheet.show(
              context,
              maxGallerySelection: 5 - selected.length,
            );
            if (source != null) {
              await pickFromSource(source);
            }
          }

          const crossAxisCount = 3;
          const thumbSpacing = 10.0;
          final gridItems = <Widget>[
            ...selected.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox.expand(
                      child: _PickedXFileThumb(file: file),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () {
                        selected.removeAt(index);
                        setState(() {});
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ];
          if (selected.length < 5) {
            gridItems.add(
              GestureDetector(
                onTap: addImages,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E2E6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 28,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      l10n.orderVoucherUpload,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  // Image grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF0F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.orderVoucherUpload}(${selected.length}/5)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: gridItems.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: thumbSpacing,
                                  mainAxisSpacing: thumbSpacing,
                                ),
                            itemBuilder: (_, index) => gridItems[index],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                l10n.orderVoucherPickCancel,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: selected.isEmpty
                                  ? null
                                  : () => Navigator.of(
                                      sheetContext,
                                    ).pop(List<XFile>.from(selected)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                disabledBackgroundColor: AppColors.primaryColor
                                    .withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.orderVoucherConfirm,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

void _showVoucherDialog(
  BuildContext context,
  AppLocalizations l10n,
  String attachment,
) {
  final urls = _parseAttachmentUrls(attachment);
  if (urls.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.orderVoucherEmpty)));
    return;
  }
  final controller = PageController();
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.9),
    builder: (context) => Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: urls.length,
            pageController: controller,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(urls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.white70,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _statusChip(BuildContext context, AppLocalizations l10n, int? status) {
  final label = _statusLabel(l10n, status);
  final colors = _statusColors(status);
  return Container(
    height: 24,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: colors.border),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, color: colors.text)),
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
