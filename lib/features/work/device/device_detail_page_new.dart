import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';
import 'package:merchant_app/features/work/device/device_detail_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';

class DeviceDetailPageNew extends ConsumerStatefulWidget {
  const DeviceDetailPageNew({super.key, this.initialSn});

  final String? initialSn;

  @override
  ConsumerState<DeviceDetailPageNew> createState() =>
      _DeviceDetailPageNewState();
}

class _DeviceDetailPageNewState extends ConsumerState<DeviceDetailPageNew>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  TabController? _tabController;
  bool _autoSearched = false;
  String _portFilter = 'all';
  int _currentDeviceType = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialSn?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _autoSearched) return;
        final value = _controller.text.trim();
        if (value.isEmpty) return;
        // 使用 commonSearch 自动识别设备类型
        ref.read(deviceDetailProvider.notifier).commonSearch(value);
        _autoSearched = true;
      });
    }
  }

  void _updateTabController(int deviceType) {
    if (_currentDeviceType == deviceType && _tabController != null) return;
    _currentDeviceType = deviceType;
    _tabController?.dispose();
    // 电池: 3 tabs, 车辆: 3 tabs, 电柜: 4 tabs
    final tabCount = deviceType == 3 ? 4 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(deviceDetailProvider);
    final deviceType = state.deviceType;
    final hasData = state.cabinetDetail != null ||
        state.batteryDetail != null ||
        state.vehicleDetail != null;

    // 根据设备类型更新 TabController
    if (hasData) {
      _updateTabController(deviceType);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(hasData);
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(hasData),
          ),
          titleSpacing: 0,
          title: _buildSearchBar(l10n),
        ),
        body: Column(
          children: [
            // 设备信息头部
            if (hasData) _buildDeviceHeaderByType(state, l10n),

            // Tab 切换
            if (hasData && _tabController != null) _buildTabBarByType(l10n, deviceType),

            // Tab 内容
            Expanded(
              child: !hasData
                  ? _buildEmptyState(l10n, state.loading)
                  : _tabController == null
                      ? const SizedBox.shrink()
                      : TabBarView(
                          controller: _tabController,
                          children: _buildTabViewsByType(l10n, state, deviceType),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据设备类型构建头部
  Widget _buildDeviceHeaderByType(DeviceDetailState state, dynamic l10n) {
    if (state.deviceType == 3 && state.cabinetDetail != null) {
      return _buildDeviceHeader(state.cabinetDetail!);
    } else if (state.deviceType == 2 && state.vehicleDetail != null) {
      return _buildVehicleHeader(state.vehicleDetail!, l10n);
    } else if (state.deviceType == 1 && state.batteryDetail != null) {
      return _buildBatteryHeader(state.batteryDetail!, l10n);
    }
    return const SizedBox.shrink();
  }

  /// 根据设备类型构建 Tab Bar
  Widget _buildTabBarByType(dynamic l10n, int deviceType) {
    List<Tab> tabs;
    if (deviceType == 1) {
      // 电池: 基础信息、位置信息、维修记录
      tabs = [
        Tab(text: l10n.deviceDetailTabBasicInfo),
        Tab(text: l10n.deviceDetailTabAddress),
        Tab(text: l10n.deviceDetailTabRepairRecords),
      ];
    } else if (deviceType == 2) {
      // 车辆: 基础信息、维修记录、保养记录
      tabs = [
        Tab(text: l10n.deviceDetailTabBasicInfo),
        Tab(text: l10n.deviceDetailTabRepairRecords),
        Tab(text: l10n.deviceDetailTabMaintenance),
      ];
    } else {
      // 电柜: 基础信息、仓位信息、位置信息、维修记录
      tabs = [
        Tab(text: l10n.deviceDetailTabBasicInfo),
        Tab(text: l10n.deviceDetailTabPortDetail),
        Tab(text: l10n.deviceDetailTabAddress),
        Tab(text: l10n.deviceDetailTabRepairRecords),
      ];
    }

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.black06Text,
        unselectedLabelColor: const Color(0xFF999999),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        indicatorColor: AppColors.primaryColor,
        indicatorWeight: 3,
        tabs: tabs,
      ),
    );
  }

  /// 根据设备类型构建 Tab 内容
  List<Widget> _buildTabViewsByType(
    dynamic l10n,
    DeviceDetailState state,
    int deviceType,
  ) {
    if (deviceType == 1 && state.batteryDetail != null) {
      // 电池: 基础信息、位置信息、维修记录
      return [
        _buildBatteryBasicInfoTab(l10n, state.batteryDetail!),
        _buildBatteryLocationTab(l10n, state.batteryDetail!),
        _buildRepairRecordsTab(l10n, state),
      ];
    } else if (deviceType == 2 && state.vehicleDetail != null) {
      // 车辆: 基础信息、维修记录、保养记录
      return [
        _buildVehicleBasicInfoTab(l10n, state.vehicleDetail!),
        _buildRepairRecordsTab(l10n, state),
        _buildMaintenanceRecordsTab(l10n, state),
      ];
    } else if (state.cabinetDetail != null) {
      // 电柜: 基础信息、仓位信息、位置信息、维修记录
      return [
        _buildBasicInfoTab(l10n, state.cabinetDetail!),
        _buildPortDetailTab(l10n, state),
        _buildAddressTab(l10n, state.cabinetDetail!),
        _buildRepairRecordsTab(l10n, state),
      ];
    }
    return [];
  }

  Widget _buildSearchBar(dynamic l10n) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF999999), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.deviceSearchHint,
                hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15),
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                setState(() {});
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFCCCCCC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 14),
              ),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _scanSn,
            child: AppIcons.scanIcon(
              size: 24,
              color: AppColors.black06Text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceHeader(CabinetDetailBaseInfoBean detail) {
    final isOnline = detail.online == '1' || detail.showOnlineStatus == 'Online';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 设备图片
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/android/mipmap-xxhdpi/icon_cabinet.png',
              width: 72,
              height: 72,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.ev_station,
                size: 40,
                color: Color(0xFF999999),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.stationName ?? '-',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isOnline ? AppColors.primaryColor : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi,
                        size: 14,
                        color: isOnline ? AppColors.primaryColor : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? AppColors.primaryColor
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 电池头部
  Widget _buildBatteryHeader(BatteryDetail detail, dynamic l10n) {
    final isOnline = detail.online == 1;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: detail.img != null && detail.img!.isNotEmpty
                ? Image.network(
                    detail.img!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.battery_charging_full,
                      size: 40,
                      color: Color(0xFF999999),
                    ),
                  )
                : const Icon(
                    Icons.battery_charging_full,
                    size: 40,
                    color: Color(0xFF999999),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SN: ${detail.deviceSn ?? '-'}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(
                      isOnline ? l10n.online : l10n.offline,
                      isOnline ? AppColors.primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    if (detail.soc != null)
                      Text(
                        'SOC: ${detail.soc}%',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 车辆头部
  Widget _buildVehicleHeader(VehicleDetail detail, dynamic l10n) {
    final hasOwner = detail.ownerName != null && detail.ownerName!.isNotEmpty;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: detail.img != null && detail.img!.isNotEmpty
                ? Image.network(
                    detail.img!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.electric_moped,
                      size: 40,
                      color: Color(0xFF999999),
                    ),
                  )
                : const Icon(
                    Icons.electric_moped,
                    size: 40,
                    color: Color(0xFF999999),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SN: ${detail.sn ?? '-'}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black06Text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(
                      hasOwner ? l10n.deviceDetailBound : l10n.deviceDetailUnbound,
                      hasOwner ? AppColors.primaryColor : Colors.grey,
                    ),
                    if (detail.carNumber != null && detail.carNumber!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        detail.carNumber!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Widget _buildEmptyState(dynamic l10n, bool loading) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_search.png',
          ),
          const SizedBox(height: 16),
          Text(
            l10n.deviceDetailEmpty,
            style: const TextStyle(color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab(dynamic l10n, CabinetDetailBaseInfoBean detail) {
    final isOnboarded = detail.stationStatus == 1;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 基本信息卡片
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailSpecLabel,
                value: detail.stationSpec ?? '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailModelLabel,
                value: detail.stationModel ?? '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailInputTimeLabel,
                value: detail.createTime ?? '-',
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 状态信息卡片
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailBindingStateLabel,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnboarded
                            ? AppColors.primaryColor
                            : const Color(0xFFE57373),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnboarded
                          ? l10n.deviceDetailOnboarded
                          : l10n.deviceDetailNotBoarded,
                      style: TextStyle(
                        fontSize: 15,
                        color: isOnboarded
                            ? AppColors.primaryColor
                            : const Color(0xFFE57373),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOnboarded)
                _InfoRow(
                  label: l10n.deviceDetailOnboardedTimeLabel,
                  value: detail.createTime ?? '-',
                ),
              _InfoRow(
                label: l10n.deviceDetailResponsibleLabel,
                value: detail.stationManagerList.isNotEmpty
                    ? detail.stationManagerList.first['trueName']?.toString() ??
                          '-'
                    : '-',
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 照片卡片
        _CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deviceDetailPhotoLabel,
                style: const TextStyle(fontSize: 15, color: AppColors.black06Text),
              ),
              const SizedBox(height: 12),
              if (detail.installImgSet.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: detail.installImgSet.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: const Color(0xFFEEEEEE),
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const Text(
                  '-',
                  style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortDetailTab(dynamic l10n, DeviceDetailState state) {
    final ports = state.cabinPorts;

    // 统计各状态数量
    final availableCount = ports.where((p) => p.status == 0).length;
    final disabledCount = ports.where((p) => p.status == 2).length;
    final inUseCount = ports.where((p) => p.status == 1).length;

    // 过滤端口
    List<Cabin> filteredPorts;
    switch (_portFilter) {
      case 'available':
        filteredPorts = ports.where((p) => p.status == 0).toList();
        break;
      case 'disabled':
        filteredPorts = ports.where((p) => p.status == 2).toList();
        break;
      case 'inuse':
        filteredPorts = ports.where((p) => p.status == 1).toList();
        break;
      default:
        filteredPorts = ports;
    }

    return Column(
      children: [
        // 过滤标签
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _FilterChip(
                label: l10n.deviceDetailPortFilterAll,
                isSelected: _portFilter == 'all',
                onTap: () => setState(() => _portFilter = 'all'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label:
                    '${l10n.deviceDetailPortFilterAvailable}  $availableCount',
                isSelected: _portFilter == 'available',
                onTap: () => setState(() => _portFilter = 'available'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '${l10n.deviceDetailPortFilterDisabled}  $disabledCount',
                isSelected: _portFilter == 'disabled',
                onTap: () => setState(() => _portFilter = 'disabled'),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '${l10n.deviceDetailPortFilterInUse}  $inUseCount',
                isSelected: _portFilter == 'inuse',
                onTap: () => setState(() => _portFilter = 'inuse'),
              ),
            ],
          ),
        ),

        // 端口网格
        Expanded(
          child: filteredPorts.isEmpty && !state.portsLoading
              ? Center(
                  child: Text(
                    l10n.deviceDetailCabinPortEmpty,
                    style: const TextStyle(color: Color(0xFF999999)),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredPorts.length,
                  itemBuilder: (context, index) {
                    return _PortCard(
                      port: filteredPorts[index],
                      l10n: l10n,
                      onSetup: () => _setupPort(filteredPorts[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddressTab(dynamic l10n, CabinetDetailBaseInfoBean detail) {
    final lat = detail.latitude ?? 0.0;
    final lng = detail.longitude ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CardSection(
          child: Column(
            children: [
              // 地图
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(height: 200, child: _buildMap(lat, lng)),
              ),
              const SizedBox(height: 16),

              // 地址信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      detail.stationAddress ?? detail.address ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 坐标
              Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lng.toStringAsFixed(6)}    ${lat.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 导航按钮
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _openNavigation(lat, lng),
                  icon: const Icon(Icons.navigation),
                  label: Text(l10n.deviceDetailNavigation),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black06Text,
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepairRecordsTab(dynamic l10n, DeviceDetailState state) {
    final records = state.fixRecords;

    if (records.isEmpty && !state.fixLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_record.png',
              width: 120,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deviceDetailFixRecordsEmpty,
              style: const TextStyle(color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        final isCompleted =
            record.result == 'completed' || record.result == '1';

        return _CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：头像、姓名、状态
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFEEEEEE),
                    child: Text(
                      (record.fixMan ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      record.fixMan ?? '-',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black06Text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      isCompleted
                          ? l10n.deviceDetailRepairCompleted
                          : l10n.deviceDetailRepairMissingParts,
                      style: TextStyle(
                        fontSize: 13,
                        color: isCompleted
                            ? AppColors.primaryColor
                            : const Color(0xFFE57373),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 问题标题
              Text(
                record.itemName ?? '-',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 8),

              // 问题描述
              Text(
                record.remark ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),

              // 时间
              Text(
                _formatTimestamp(record.createTime),
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 电池基础信息 Tab
  Widget _buildBatteryBasicInfoTab(dynamic l10n, BatteryDetail detail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailSnLabel,
                value: detail.deviceSn ?? '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailBatterySocLabel,
                value: detail.soc != null ? '${detail.soc}%' : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailBatteryCycleLabel,
                value: detail.cycle?.toString() ?? '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailBatteryMileLabel,
                value: detail.mile != null ? '${detail.mile} km' : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailBatteryTodayMileLabel,
                value: detail.todayMile != null ? '${detail.todayMile} km' : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailBatteryAvgSpeedLabel,
                value: detail.avgSpeed != null
                    ? '${detail.avgSpeed} km/h'
                    : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailBatteryColorLabel,
                value: detail.color?.toString() ?? '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailSignalTimeLabel,
                value: detail.signalTime != null
                    ? _formatTimestamp(detail.signalTime)
                    : '-',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 电池位置 Tab
  Widget _buildBatteryLocationTab(dynamic l10n, BatteryDetail detail) {
    final lat = detail.latitude ?? 0.0;
    final lng = detail.longitude ?? 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CardSection(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(height: 200, child: _buildMap(lat, lng)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lng.toStringAsFixed(6)}    ${lat.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _openNavigation(lat, lng),
                  icon: const Icon(Icons.navigation),
                  label: Text(l10n.deviceDetailNavigation),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black06Text,
                    side: const BorderSide(color: Color(0xFFEEEEEE)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 车辆基础信息 Tab
  Widget _buildVehicleBasicInfoTab(dynamic l10n, VehicleDetail detail) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailSnLabel,
                value: detail.sn ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailPlateNumber,
                value: detail.carNumber ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailVin,
                value: detail.vin ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailOwner,
                value: detail.ownerName ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailUserPhone,
                value: detail.phone ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailMileage,
                value: detail.mile != null ? '${detail.mile} km' : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailInputTimeLabel,
                value: detail.createTime ?? '-',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 保养记录 Tab
  Widget _buildMaintenanceRecordsTab(dynamic l10n, DeviceDetailState state) {
    final records = state.maintenanceRecords;

    if (records.isEmpty && !state.maintenanceLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/android/mipmap-xxhdpi/icon_empty_record.png',
              width: 120,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.deviceDetailMaintenanceEmpty,
              style: const TextStyle(color: Color(0xFF999999)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];

        return _CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.itemName ?? '-',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                record.log ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                record.date ?? (record.createTime != null
                    ? _formatTimestamp(record.createTime)
                    : '-'),
                style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '-';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  Widget _buildMap(double lat, double lng) {
    if (kIsWeb || (lat == 0 && lng == 0)) {
      return Container(
        color: const Color(0xFFE3F2FD),
        child: Center(
          child: Icon(Icons.map, size: 48, color: Colors.blue.shade200),
        ),
      );
    }

    final platform = defaultTargetPlatform;
    if (platform == TargetPlatform.android) {
      return gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target: gmaps.LatLng(lat, lng),
          zoom: 15,
        ),
        markers: {
          gmaps.Marker(
            markerId: const gmaps.MarkerId('device'),
            position: gmaps.LatLng(lat, lng),
          ),
        },
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomGesturesEnabled: false,
      );
    }
    if (platform == TargetPlatform.iOS) {
      return amaps.AppleMap(
        initialCameraPosition: amaps.CameraPosition(
          target: amaps.LatLng(lat, lng),
          zoom: 15,
        ),
        annotations: {
          amaps.Annotation(
            annotationId: amaps.AnnotationId('device'),
            position: amaps.LatLng(lat, lng),
          ),
        },
        myLocationButtonEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        pitchGesturesEnabled: false,
        zoomGesturesEnabled: false,
      );
    }
    return const Center(child: Text('Map not supported'));
  }

  Future<void> _submit(String value) async {
    final input = value.trim();
    if (input.isEmpty) return;
    final sn = ScanUtils.getDeviceSn(input).trim();
    if (sn.isEmpty) return;
    // 使用 commonSearch 自动识别设备类型
    ref.read(deviceDetailProvider.notifier).commonSearch(sn);
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanPage(parseDeviceSn: true, deviceType: 3),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
    _submit(result);
  }

  void _setupPort(Cabin port) {
    final l10n = context.l10n;
    final isDisabled = port.status == 2 || port.status == 0;
    final isDoorOpen = port.doorStatus == 1;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${l10n.deviceDetailPortLabel} ${port.portNo ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 开仓门按钮
              ListTile(
                leading: const Icon(Icons.door_front_door_outlined),
                title: Text(
                  isDoorOpen
                      ? l10n.deviceDetailPortOpened
                      : l10n.deviceDetailPortOpen,
                  style: TextStyle(
                    color: isDoorOpen ? Colors.grey : null,
                  ),
                ),
                onTap: isDoorOpen
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _confirmOpenDoor(port);
                      },
              ),

              // 启用/禁用按钮
              ListTile(
                leading: Icon(
                  isDisabled ? Icons.check_circle_outline : Icons.block,
                  color: isDisabled ? AppColors.primaryColor : Colors.red,
                ),
                title: Text(
                  isDisabled
                      ? l10n.deviceDetailPortEnable
                      : l10n.deviceDetailPortDisable,
                  style: TextStyle(
                    color: isDisabled ? AppColors.primaryColor : Colors.red,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmTogglePort(port, isDisabled);
                },
              ),

              const SizedBox(height: 8),

              // 取消按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
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
  }

  Future<void> _confirmOpenDoor(Cabin port) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirm),
        content: Text(l10n.deviceDetailPortOpenConfirm(port.portNo ?? 0)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(deviceDetailProvider.notifier)
        .openCabinDoor(port: port.portNo ?? 0);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.deviceDetailPortOpenSuccess
              : l10n.deviceDetailPortOpenFailed,
        ),
      ),
    );
  }

  Future<void> _confirmTogglePort(Cabin port, bool enable) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirm),
        content: Text(
          enable
              ? l10n.deviceDetailPortEnableConfirm
              : l10n.deviceDetailPortDisableConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final notifier = ref.read(deviceDetailProvider.notifier);
    final success = enable
        ? await notifier.enableCabinPort(port: port.portNo ?? 0)
        : await notifier.disableCabinPort(port: port.portNo ?? 0);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (enable
                  ? l10n.deviceDetailPortEnableSuccess
                  : l10n.deviceDetailPortDisableSuccess)
              : l10n.deviceDetailToggleFailed,
        ),
      ),
    );
  }

  void _openNavigation(double lat, double lng) {
    // 导航功能需要 url_launcher 包支持
    // 这里暂时不做实现，可以后续添加
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation to: $lat, $lng'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// 卡片容器
class _CardSection extends StatelessWidget {
  const _CardSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

/// 信息行
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.valueWidget});

  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: AppColors.black06Text),
            ),
          ),
          valueWidget ??
              Text(
                value ?? '-',
                style: const TextStyle(fontSize: 15, color: Color(0xFF999999)),
              ),
        ],
      ),
    );
  }
}

/// 过滤标签
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

/// 端口卡片
class _PortCard extends StatelessWidget {
  const _PortCard({
    required this.port,
    required this.l10n,
    required this.onSetup,
  });

  final Cabin port;
  final dynamic l10n;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final isAvailable = port.status == 0;
    final isDisabled = port.status == 2;
    final hasBattery = port.batterySn != null && port.batterySn!.isNotEmpty;
    final soc = port.batterySoc ?? 0;

    // 电量颜色
    Color socColor;
    if (soc >= 80) {
      socColor = AppColors.primaryColor;
    } else if (soc >= 40) {
      socColor = const Color(0xFFFFA000);
    } else {
      socColor = const Color(0xFFE57373);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDisabled ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 端口号和状态
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDisabled
                      ? const Color(0xFFEEEEEE)
                      : AppColors.black06Text,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${port.portNo ?? 0}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? const Color(0xFF999999) : Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (!isAvailable && !isDisabled && hasBattery)
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortReplaceable,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              if (isDisabled)
                Row(
                  children: [
                    const Icon(Icons.block, size: 14, color: Color(0xFF999999)),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortDisabled,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Spacer(),

          // 电量或可用状态
          if (hasBattery)
            Row(
              children: [
                Icon(Icons.battery_std, size: 18, color: socColor),
                const SizedBox(width: 4),
                Text(
                  '$soc%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? const Color(0xFF999999) : socColor,
                  ),
                ),
              ],
            )
          else
            Text(
              l10n.deviceDetailPortAvailable,
              style: TextStyle(
                fontSize: 14,
                color: isDisabled
                    ? const Color(0xFF999999)
                    : const Color(0xFF666666),
              ),
            ),
          const SizedBox(height: 4),

          // 电池SN
          if (hasBattery)
            Text(
              'SN: ${port.batterySn}',
              style: TextStyle(
                fontSize: 12,
                color: isDisabled
                    ? const Color(0xFFCCCCCC)
                    : const Color(0xFF999999),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),

          // 设置按钮
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton.icon(
              onPressed: onSetup,
              icon: Icon(
                Icons.settings_outlined,
                size: 16,
                color: isDisabled
                    ? const Color(0xFFCCCCCC)
                    : const Color(0xFF666666),
              ),
              label: Text(
                l10n.deviceDetailPortSetup,
                style: TextStyle(
                  fontSize: 13,
                  color: isDisabled
                      ? const Color(0xFFCCCCCC)
                      : const Color(0xFF666666),
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: isDisabled
                      ? const Color(0xFFEEEEEE)
                      : const Color(0xFFDDDDDD),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
