import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/device_search_result.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/device/device_detail_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceDetailPageNew extends ConsumerStatefulWidget {
  const DeviceDetailPageNew({
    super.key,
    this.initialSn,
    this.readOnly = false,
    this.popToSearchOnClear = false,
    this.expectedDeviceType,
    this.initialTabIndex,
  });

  final String? initialSn;
  final bool readOnly;
  final bool popToSearchOnClear;
  final int? expectedDeviceType;
  final int? initialTabIndex;

  @override
  ConsumerState<DeviceDetailPageNew> createState() =>
      _DeviceDetailPageNewState();
}

class _DeviceDetailPageNewState extends ConsumerState<DeviceDetailPageNew>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  TabController? _tabController;
  bool _autoSearched = false;
  bool _appliedInitialTab = false;
  String _portFilter = 'all';
  int _currentDeviceType = 0;
  bool _disposed = false;

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
        _submit(value);
        _autoSearched = true;
      });
    }
  }

  void _updateTabController(
    int deviceType, {
    required bool cabinetHasWarehouse,
  }) {
    if (_currentDeviceType == deviceType &&
        _tabController != null &&
        _tabController!.length ==
            (deviceType == 3 ? (cabinetHasWarehouse ? 4 : 2) : 3)) {
      return;
    }
    _currentDeviceType = deviceType;
    // 电池: 3 tabs, 车辆: 3 tabs, 电柜: 2/4 tabs
    final tabCount = deviceType == 3 ? (cabinetHasWarehouse ? 4 : 2) : 3;
    final previous = _tabController;
    _tabController = TabController(length: tabCount, vsync: this);
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_disposed) return;
        previous.dispose();
      });
    }
  }

  void _applyInitialTabIfNeeded() {
    if (_appliedInitialTab) return;
    final controller = _tabController;
    final requested = widget.initialTabIndex;
    if (controller == null || requested == null) return;
    _appliedInitialTab = true;
    if (requested >= 0 && requested < controller.length) {
      controller.index = requested;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(deviceDetailProvider);
    final deviceType = state.deviceType;
    final hasData =
        state.cabinetDetail != null ||
        state.batteryDetail != null ||
        state.vehicleDetail != null ||
        (state.deviceType == 3 && state.searchResult?.deviceInfo != null);
    final cabinetHasWarehouse = deviceType == 3
      ? _cabinetHasWarehouse(state.searchResult?.deviceInfo)
      : true;

    // 根据设备类型更新 TabController
    if (hasData) {
      _updateTabController(
        deviceType,
        cabinetHasWarehouse: cabinetHasWarehouse,
      );
      _applyInitialTabIfNeeded();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _backToSource(hasData);
      },
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => _backToSource(hasData),
          ),
          titleSpacing: 0,
          title: _buildSearchBar(l10n, deviceType),
        ),
        body: Column(
          children: [
            // 设备信息头部
            if (hasData) _buildDeviceHeaderByType(state, l10n),

            // Tab 切换
            if (hasData && _tabController != null)
              _buildTabBarByType(
                l10n,
                deviceType,
                cabinetHasWarehouse: cabinetHasWarehouse,
              ),

            // Tab 内容
            Expanded(
              child: !hasData
                  ? _buildEmptyState(l10n, state.loading)
                  : _tabController == null
                  ? const SizedBox.shrink()
                  : TabBarView(
                      controller: _tabController,
                      children: _buildTabViewsByType(
                        l10n,
                        state,
                        deviceType,
                        cabinetHasWarehouse: cabinetHasWarehouse,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _backToSource(bool hasData) {
    final navigator = Navigator.of(context);
    if (!navigator.canPop()) {
      AppRouter.goHome();
      return;
    }

    navigator.pop(hasData);

    if (widget.popToSearchOnClear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!navigator.mounted) return;
        if (navigator.canPop()) {
          navigator.pop();
        }
      });
    }
  }

  /// 根据设备类型构建头部
  Widget _buildDeviceHeaderByType(DeviceDetailState state, dynamic l10n) {
    if (state.deviceType == 3 &&
        (state.cabinetDetail != null ||
            state.searchResult?.deviceInfo != null)) {
      return _buildCabinetHeader(
        state.searchResult?.deviceInfo,
        state.cabinetDetail,
        l10n,
      );
    } else if (state.deviceType == 2 && state.vehicleDetail != null) {
      return _buildVehicleHeader(state.vehicleDetail!, l10n);
    } else if (state.deviceType == 1 && state.batteryDetail != null) {
      return _buildBatteryHeader(state.batteryDetail!, l10n);
    }
    return const SizedBox.shrink();
  }

  /// 根据设备类型构建 Tab Bar
  Widget _buildTabBarByType(
    dynamic l10n,
    int deviceType, {
    required bool cabinetHasWarehouse,
  }) {
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
      // 电柜: 基础信息、仓位信息、位置信息、维修记录（未上架仅基础信息+维修记录）
      tabs = cabinetHasWarehouse
          ? [
              Tab(text: l10n.deviceDetailTabBasicInfo),
              Tab(text: l10n.deviceDetailTabPortDetail),
              Tab(text: l10n.deviceDetailTabAddress),
              Tab(text: l10n.deviceDetailTabRepairRecords),
            ]
          : [
              Tab(text: l10n.deviceDetailTabBasicInfo),
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
    int deviceType, {
    required bool cabinetHasWarehouse,
  }) {
    if (deviceType == 1 && state.batteryDetail != null) {
      // 电池: 基础信息、位置信息、维修记录
      return [
        _buildBatteryBasicInfoTab(l10n, state),
        _buildBatteryLocationTab(l10n, state.batteryDetail!),
        _buildRepairRecordsTab(l10n, state),
      ];
    } else if (deviceType == 2 && state.vehicleDetail != null) {
      // 车辆: 基础信息、维修记录、保养记录
      return [
        _buildVehicleBasicInfoTab(l10n, state),
        _buildRepairRecordsTab(l10n, state),
        _buildMaintenanceRecordsTab(l10n, state),
      ];
    } else if (state.cabinetDetail != null ||
        state.searchResult?.deviceInfo != null) {
      // 电柜: 基础信息、仓位信息、位置信息、维修记录（未上架仅基础信息+维修记录）
      final info = state.searchResult?.deviceInfo;
      final detail = state.cabinetDetail;
      if (!cabinetHasWarehouse) {
        return [
          _buildCabinetBasicInfoTab(l10n, info, detail),
          _buildRepairRecordsTab(l10n, state),
        ];
      }
      return [
        _buildCabinetBasicInfoTab(l10n, info, detail),
        _buildPortDetailTab(l10n, state),
        _buildCabinetAddressTab(l10n, info, detail),
        _buildRepairRecordsTab(l10n, state),
      ];
    }
    return [];
  }

  Widget _buildSearchBar(dynamic l10n, int deviceType) {
    final hintText = deviceType == 3
        ? l10n.deviceSearchStationHint
        : l10n.deviceSearchHint;
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
                hintText: hintText,
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
                if (widget.popToSearchOnClear) {
                  _backToSource(false);
                  return;
                }
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
            child: AppIcons.scanIcon(size: 24, color: AppColors.black06Text),
          ),
        ],
      ),
    );
  }

  Widget _buildCabinetHeader(
    DeviceInfo? info,
    CabinetDetailBaseInfoBean? detail,
    dynamic l10n,
  ) {
    final isOnline =
        info?.onlineStatus == 1 ||
        info?.showOnlineStatus == 'Online' ||
        detail?.online == '1' ||
        detail?.showOnlineStatus == 'Online';
    final headerImg = (info?.img?.trim().isNotEmpty == true)
        ? info!.img!.trim()
        : info == null
        ? (detail?.standardImg?.trim().isNotEmpty == true)
              ? detail!.standardImg!.trim()
              : (detail?.installImgSet.isNotEmpty == true
                    ? detail!.installImgSet.first
                    : null)
        : null;
    final stationName = info?.stationName?.trim();
    final sn = info?.sn ?? detail?.stationSn ?? '-';
    final title = (stationName != null && stationName.isNotEmpty)
        ? stationName
        : 'SN: $sn';
    final showOperate = info?.hasPermission == 1 && !widget.readOnly;

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
            child: headerImg != null
                ? Image.network(
                    headerImg,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.ev_station,
                      size: 40,
                      color: Color(0xFF999999),
                    ),
                  )
                : const Icon(
                    Icons.ev_station,
                    size: 40,
                    color: Color(0xFF999999),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black06Text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
                        isOnline ? l10n.online : l10n.offline,
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
          if (showOperate)
            GestureDetector(
              onTap: _confirmOpenCabinetBackDoor,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x330C0C0D)),
                ),
                child: const Icon(
                  Icons.door_front_door_outlined,
                  size: 20,
                  color: AppColors.black06Text,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 电池头部
  Widget _buildBatteryHeader(BatteryDetail detail, dynamic l10n) {
    final deviceInfo = ref.read(deviceDetailProvider).searchResult?.deviceInfo;
    final bindStatus = deviceInfo?.deviceBindStatus;
    final isBound = bindStatus != null && bindStatus != 0;
    final bindSource = deviceInfo?.bindSource;
    String? sourceLabel;
    Color? sourceColor;
    if (bindSource == 1) {
      sourceLabel = l10n.deviceDetailSale;
      sourceColor = AppColors.primaryColor;
    } else if (bindSource == 2) {
      sourceLabel = l10n.deviceDetailLease;
      sourceColor = const Color(0xFFF49300);
    }

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
                      isBound
                          ? l10n.deviceDetailBound
                          : l10n.deviceDetailUnbound,
                      isBound
                          ? AppColors.primaryColor
                          : const Color(0xFFFA4B51),
                    ),
                    if (sourceLabel != null && sourceColor != null) ...[
                      const SizedBox(width: 8),
                      _buildStatusBadge(sourceLabel, sourceColor),
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

  /// 车辆头部
  Widget _buildVehicleHeader(VehicleDetail detail, dynamic l10n) {
    final deviceInfo = ref.read(deviceDetailProvider).searchResult?.deviceInfo;
    final bindStatus = deviceInfo?.deviceBindStatus;
    final showBindStatus = bindStatus != null;
    final isBound = bindStatus != null && bindStatus != 0;
    final bindSource = deviceInfo?.bindSource;
    String? sourceLabel;
    Color? sourceColor;
    if (bindSource == 1) {
      sourceLabel = l10n.deviceDetailSale;
      sourceColor = AppColors.primaryColor;
    } else if (bindSource == 2) {
      sourceLabel = l10n.deviceDetailLease;
      sourceColor = const Color(0xFFF49300);
    }

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
                    if (sourceLabel != null && sourceColor != null) ...[
                      _buildStatusBadge(sourceLabel, sourceColor),
                    ],
                    if (showBindStatus) ...[
                      if (sourceLabel != null && sourceColor != null)
                        const SizedBox(width: 8),
                      _buildStatusBadge(
                        isBound
                            ? l10n.deviceDetailBound
                            : l10n.deviceDetailUnbound,
                        isBound
                            ? AppColors.primaryColor
                            : const Color(0xFFFA4B51),
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
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }

  Widget _buildEmptyState(dynamic l10n, bool loading) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/android/mipmap-xxhdpi/icon_empty_search.png'),
          const SizedBox(height: 16),
          Text(
            l10n.deviceDetailEmpty,
            style: const TextStyle(color: Color(0xFF999999)),
          ),
        ],
      ),
    );
  }

  Widget _buildCabinetBasicInfoTab(
    dynamic l10n,
    DeviceInfo? info,
    CabinetDetailBaseInfoBean? detail,
  ) {
    final installStatus = info?.installStatus;
    final isOnboarded = installStatus != null && installStatus != 0;
    final spec = info != null ? info.showDeviceModel : detail?.stationSpec;
    final model = info != null ? info.deviceModel : detail?.stationModel;
    final inputTime = _formatTimeString(
      info != null ? info.createTime : detail?.createTime,
      withSeconds: true,
    );
    final onboardTime = _formatTimeString(
      info != null
          ? info.installTime
          : (detail?.putOnShelvesTime != null
                ? detail!.putOnShelvesTime.toString()
                : null),
      withSeconds: true,
    );
    final managerName = info?.managerList?.isNotEmpty == true
        ? info!.managerList!.first.showName
        : null;
    final photos = <String>[
      if (info != null) ..._collectDevicePhotos(info),
      if (info == null && detail != null) ...detail.installImgSet,
    ].where((item) => item.isNotEmpty).toSet().toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 基本信息卡片
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailSpecLabel,
                value: spec?.isNotEmpty == true ? spec : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailModelLabel,
                value: model?.isNotEmpty == true ? model : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailInputTimeLabel,
                value: inputTime,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 状态信息卡片
        _CardSection(
          child: Column(
            children: [
              if (installStatus == null)
                _InfoRow(label: l10n.deviceDetailBindingStateLabel, value: '-')
              else
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
              _InfoRow(
                label: l10n.deviceDetailOnboardedTimeLabel,
                value: onboardTime,
              ),
              _InfoRow(
                label: l10n.deviceDetailResponsibleLabel,
                value: (managerName ?? '-').isNotEmpty
                    ? managerName ?? '-'
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
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              if (photos.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: photos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () => _openPhotoBrowser(photos, index),
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
    final info = state.searchResult?.deviceInfo;
    final hasPermission =
        info?.hasPermission ??
        (info == null ? state.cabinetDetail?.hasPermission : null);
    final showSetup = hasPermission == 1 && !widget.readOnly;

    // 统计各状态数量
    final freeCount = ports.where((p) => (p.batteryStatus ?? 0) == 0).length;
    final disabledCount = ports.where((p) => p.status == 0).length;
    final occupiedCount = ports
        .where((p) => (p.batteryStatus ?? 0) == 1)
        .length;

    // 过滤端口
    List<Cabin> filteredPorts;
    switch (_portFilter) {
      case 'available':
        filteredPorts = ports
            .where((p) => (p.batteryStatus ?? 0) == 0)
            .toList();
        break;
      case 'disabled':
        filteredPorts = ports.where((p) => p.status == 0).toList();
        break;
      case 'inuse':
        filteredPorts = ports
            .where((p) => (p.batteryStatus ?? 0) == 1)
            .toList();
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
                label: '${l10n.deviceDetailPortFilterAvailable}  $freeCount',
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
                label: '${l10n.deviceDetailPortFilterInUse}  $occupiedCount',
                isSelected: _portFilter == 'inuse',
                onTap: () => setState(() => _portFilter = 'inuse'),
              ),
            ],
          ),
        ),

        // 端口网格
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.read(deviceDetailProvider.notifier).loadCabinPorts(),
            child: filteredPorts.isEmpty && !state.portsLoading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    children: [
                      Center(
                        child: Text(
                          l10n.deviceDetailCabinPortEmpty,
                          style: const TextStyle(color: Color(0xFF999999)),
                        ),
                      ),
                    ],
                  )
                : GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        showSetup: showSetup,
                        onSetup: () => _setupPort(filteredPorts[index]),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCabinetAddressTab(
    dynamic l10n,
    DeviceInfo? info,
    CabinetDetailBaseInfoBean? detail,
  ) {
    final lat = info?.latitude ?? detail?.latitude ?? 0.0;
    final lng = info?.longitude ?? detail?.longitude ?? 0.0;
    final address =
        info?.address ?? detail?.stationAddress ?? detail?.address ?? '-';

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
                      address,
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
        final status = _resolveRepairStatus(l10n, record.result);

        return _CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部：头像、姓名、状态（安卓 item_device_fix_record）
              Row(
                children: [
                  _RecordAvatar(
                    imageUrl: record.fixManAvatar,
                    showFixBadge: true,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.fixMan ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: status.textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              const SizedBox(height: 12),

              // 问题标题
              Text(
                record.itemName ?? '-',
                style: const TextStyle(
                  fontSize: 16,
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
                _formatRecordTime(record.createTime),
                style: const TextStyle(fontSize: 12, color: Color(0x4D0C0C0D)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 电池基础信息 Tab
  Widget _buildBatteryBasicInfoTab(dynamic l10n, DeviceDetailState state) {
    final detail = state.batteryDetail;
    if (detail == null) {
      return const SizedBox.shrink();
    }

    final deviceInfo = state.searchResult?.deviceInfo;
    final isOnline = deviceInfo?.onlineStatus == 1;
    final spec = deviceInfo?.showDeviceModel;
    final model = deviceInfo?.deviceModel;
    final inputTime = _formatTimeString(
      deviceInfo?.createTime,
      withSeconds: true,
    );
    final bindUserId = deviceInfo?.bindUserId;
    final bindUserName = deviceInfo?.bindUserName;
    final bindUserPhone = _formatBindUserPhone(deviceInfo?.bindUserPhone);
    final bindTime = _formatTimeString(deviceInfo?.bindTime, withSeconds: true);
    final photos = _collectDevicePhotos(deviceInfo);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailStatus,
                valueWidget: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      isOnline
                          ? 'assets/android/mipmap-xxhdpi/icon_signal_online.png'
                          : 'assets/android/mipmap-xxhdpi/icon_signal_offline.webp',
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? l10n.online : l10n.offline,
                      style: TextStyle(
                        fontSize: 15,
                        color: isOnline
                            ? AppColors.primaryColor
                            : const Color(0xFFFA4B51),
                      ),
                    ),
                  ],
                ),
              ),
              _InfoRow(
                label: l10n.deviceDetailSpecLabel,
                value: spec?.isNotEmpty == true ? spec : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailModelLabel,
                value: model?.isNotEmpty == true ? model : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailInputTimeLabel,
                value: inputTime,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.vehicleDetailBindingId,
                value: bindUserId ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailOwner,
                valueWidget: Text(
                  bindUserName ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0B61D9),
                  ),
                ),
              ),
              _InfoRow(
                label: l10n.vehicleDetailUserPhone,
                valueWidget: Text(
                  bindUserPhone,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0B61D9),
                  ),
                ),
              ),
              _InfoRow(
                label: l10n.deviceDetailBindingTimeLabel,
                value: bindTime,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deviceDetailPhotoLabel,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              if (photos.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: photos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () => _openPhotoBrowser(photos, index),
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
  Widget _buildVehicleBasicInfoTab(dynamic l10n, DeviceDetailState state) {
    final detail = state.vehicleDetail;
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final deviceInfo = state.searchResult?.deviceInfo;
    final spec = deviceInfo?.showDeviceModel ?? detail.spec ?? detail.carSpec;
    final model = deviceInfo?.deviceModel ?? detail.model ?? detail.carModel;
    final inputTime = _formatTimeString(
      deviceInfo?.createTime ?? detail.createTime,
      withSeconds: true,
    );
    final bindUserId = deviceInfo?.bindUserId;
    final bindUserName = deviceInfo?.bindUserName ?? detail.ownerName;
    final bindUserPhone = _formatBindUserPhone(
      deviceInfo?.bindUserPhone ?? detail.phone,
    );
    final bindTime = _formatTimeString(deviceInfo?.bindTime, withSeconds: true);
    final insuranceNumber = deviceInfo?.insuranceNumber;
    final photos = _collectDevicePhotos(deviceInfo);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.deviceDetailSpecLabel,
                value: spec?.isNotEmpty == true ? spec : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailModelLabel,
                value: model?.isNotEmpty == true ? model : '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailInputTimeLabel,
                value: inputTime,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _CardSection(
          child: Column(
            children: [
              _InfoRow(label: l10n.vehicleDetailVin, value: detail.vin ?? '-'),
              _InfoRow(
                label: l10n.vehicleDetailPlateNumber,
                value: detail.carNumber ?? '-',
              ),
              _InfoRow(
                label: l10n.deviceDetailInsuranceNumberLabel,
                value: insuranceNumber ?? '-',
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _CardSection(
          child: Column(
            children: [
              _InfoRow(
                label: l10n.vehicleDetailBindingId,
                value: bindUserId ?? '-',
              ),
              _InfoRow(
                label: l10n.vehicleDetailOwner,
                valueWidget: Text(
                  bindUserName ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0B61D9),
                  ),
                ),
              ),
              _InfoRow(
                label: l10n.vehicleDetailUserPhone,
                valueWidget: Text(
                  bindUserPhone,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0B61D9),
                  ),
                ),
              ),
              _InfoRow(
                label: l10n.deviceDetailBindingTimeLabel,
                value: bindTime,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _CardSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deviceDetailPhotoLabel,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.black06Text,
                ),
              ),
              const SizedBox(height: 12),
              if (photos.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: photos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () => _openPhotoBrowser(photos, index),
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
              Row(
                children: [
                  _RecordAvatar(imageUrl: record.img, showFixBadge: false),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record.username ?? '-',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.black06Text,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE6E6E6)),
              const SizedBox(height: 12),
              Text(
                l10n.maintenanceNoteLabel,
                style: const TextStyle(
                  fontSize: 16,
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
                record.date ?? _formatRecordTime(record.createTime),
                style: const TextStyle(fontSize: 12, color: Color(0x4D0C0C0D)),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatRecordTime(int? timestamp) {
    return DateFormatUtils.formatTimestamp(
      timestamp,
      pattern: 'yyyy-MM-dd HH:mm:ss',
    );
  }

  _RepairStatusDisplay _resolveRepairStatus(dynamic l10n, String? result) {
    final value = (result ?? '').trim();
    if (value == '2') {
      return _RepairStatusDisplay(
        label: l10n.deviceDetailRepairMissingParts,
        textColor: const Color(0xFFED942F),
        backgroundColor: const Color(0xFFFDF5EB),
      );
    }
    if (value == '3') {
      return _RepairStatusDisplay(
        label: l10n.repairRecordStatusDiscard,
        textColor: const Color(0xFFFA4B51),
        backgroundColor: const Color(0xFFFFF0F0),
      );
    }
    if (value == '1') {
      return _RepairStatusDisplay(
        label: l10n.deviceDetailRepairCompleted,
        textColor: AppColors.primaryColor,
        backgroundColor: const Color(0xFFE9F7F2),
      );
    }
    return _RepairStatusDisplay(
      label: value.isEmpty ? '-' : value,
      textColor: AppColors.primaryColor,
      backgroundColor: const Color(0xFFE9F7F2),
    );
  }

  String _formatTimeString(String? value, {bool withSeconds = false}) {
    if (value == null || value.trim().isEmpty) return '-';
    final trimmed = value.trim();
    final pattern = withSeconds ? 'yyyy/MM/dd HH:mm:ss' : 'yyyy/MM/dd HH:mm';
    final parsed = DateFormatUtils.parse(trimmed);
    if (parsed != null) {
      return DateFormatUtils.format(parsed, pattern: pattern);
    }
    return trimmed;
  }

  String _formatBindUserPhone(String? phone) {
    final value = (phone ?? '').trim();
    if (value.isEmpty) return '-';
    final areaCode = (AuthSession.instance.current?.areaCode ?? '').trim();
    if (areaCode.isEmpty || value.startsWith(areaCode)) {
      return value;
    }
    return '$areaCode $value';
  }

  bool _cabinetHasWarehouse(DeviceInfo? info) {
    final status = info?.installStatus;
    // 搜索接口部分场景不返回 installStatus，按有仓位处理，避免误隐藏“仓位详情”Tab
    if (status == null) return true;
    return status != 0;
  }

  List<String> _collectDevicePhotos(DeviceInfo? info) {
    final photos = <String>[];
    if (info != null) {
      photos.addAll(info.installImgSet);
    }
    return photos.toSet().toList();
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
    final l10n = context.l10n;
    final input = value.trim();
    if (input.isEmpty) return;
    final isStationOnly = widget.expectedDeviceType == 3;
    final sn = isStationOnly
        ? ScanUtils.parseSnByDeviceType(input, 3).trim()
        : ScanUtils.getDeviceSn(input).trim();
    if (sn.isEmpty) return;
    if (isStationOnly && !_isValidStationSnInput(input, sn)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.deviceSearchInvalidStationSn)));
      return;
    }

    if (isStationOnly) {
      final found = await ref
          .read(deviceDetailProvider.notifier)
          .searchDevice(sn: sn, deviceType: 3);
      if (!mounted) return;
      if (!found) {
        _backToSource(false);
      }
      return;
    }

    // 默认场景下仍使用 commonSearch 自动识别设备类型
    final result = await ref.read(deviceDetailProvider.notifier).commonSearch(sn);
    if (!mounted) return;
    if (result == null) {
      _backToSource(false);
    }
  }

  Future<void> _scanSn() async {
    final expectedType = widget.expectedDeviceType;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          allowManualInput: true,
          parseDeviceSn: true,
          deviceType: expectedType,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
    _submit(result);
  }

  bool _isValidStationSnInput(String rawInput, String parsedSn) {
    if (parsedSn.isEmpty) return false;
    final input = rawInput.trim().toLowerCase();
    if (input.isEmpty) return false;

    final containsNonStationKey =
        input.contains('vin=') ||
        input.contains('vin:') ||
        input.contains('imei=') ||
        input.contains('imei:') ||
        input.contains('iccid=') ||
        input.contains('iccid:') ||
        input.contains('vcu=') ||
        input.contains('vcu:');
    if (containsNonStationKey) return false;

    if (input.startsWith('b:')) return false;

    return true;
  }

  void _setupPort(Cabin port) {
    final l10n = context.l10n;
    final isDisabled = port.status == 0;
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
                  style: TextStyle(color: isDoorOpen ? Colors.grey : null),
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

  Future<void> _confirmOpenCabinetBackDoor() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cabinetOperateOpenDoorConfirmTitle),
        content: Text(l10n.cabinetOperateOpenDoorConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.cabinetOfflineCabinOpenDoor),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ref
        .read(deviceDetailProvider.notifier)
        .openCabinBackDoor();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.cabinetOperateOpenDoorSuccess
              : l10n.cabinetOperateOpenDoorFailed,
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

  Future<void> _openNavigation(double lat, double lng) async {
    Uri uri;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      uri = Uri.parse('http://maps.apple.com/?daddr=$lat,$lng');
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('请用手机安装地图App 进行导航'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openPhotoBrowser(List<String> photos, int initialIndex) {
    if (photos.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoGalleryPage(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _PhotoGalleryPage extends StatefulWidget {
  const _PhotoGalleryPage({required this.photos, required this.initialIndex});

  final List<String> photos;
  final int initialIndex;

  @override
  State<_PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<_PhotoGalleryPage> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.photos.length;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('${_currentIndex + 1}/$total'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: total,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final url = widget.photos[index];
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RepairStatusDisplay {
  const _RepairStatusDisplay({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
}

class _RecordAvatar extends StatelessWidget {
  const _RecordAvatar({required this.imageUrl, required this.showFixBadge});

  final String? imageUrl;
  final bool showFixBadge;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: hasImage
                ? Image.network(
                    imageUrl!,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_def_avatar.webp',
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/android/mipmap-xxhdpi/icon_def_avatar.webp',
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                  ),
          ),
          if (showFixBadge)
            Positioned(
              right: -1,
              bottom: -1,
              child: Image.asset(
                'assets/android/mipmap-xxhdpi/icon_fix.png',
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
        ],
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
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.black06Text,
              ),
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
    required this.showSetup,
    required this.onSetup,
  });

  final Cabin port;
  final dynamic l10n;
  final bool showSetup;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final isDisabled = port.status == 0;
    final batteryStatus = port.batteryStatus ?? 0;
    final hasBattery = batteryStatus == 1;
    final soc = port.batterySoc ?? 0;
    final swapFlag = port.swapFlag ?? 0;

    // 电量颜色（与 Android 逻辑一致：禁用灰，低于阈值红，否则绿）
    final socColor = isDisabled
        ? const Color(0x330C0C0D)
        : (swapFlag == 0 ? const Color(0xFFFA4B51) : const Color(0xFF0ABF83));

    final portBadgeColor = isDisabled
        ? const Color(0x330C0C0D)
        : hasBattery
        ? const Color(0xE60C0C0D)
        : const Color(0x330C0C0D);

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
                  color: portBadgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${port.portNo ?? 0}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              if (!isDisabled && hasBattery && swapFlag == 1)
                Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_cabin_enable.webp',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortReplaceable,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0ABF83),
                      ),
                    ),
                  ],
                ),
              if (isDisabled)
                Row(
                  children: [
                    Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_cabin_unable.webp',
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortDisabled,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xE60C0C0D),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BatteryCapacityView(
                  soc: soc,
                  swapFlag: swapFlag,
                  isDisabled: isDisabled,
                ),
                const SizedBox(width: 4),
                Text(
                  '$soc%',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: socColor,
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                l10n.deviceDetailPortAvailable,
                style: TextStyle(fontSize: 17, color: const Color(0x800C0C0D)),
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
                    ? const Color(0x330C0C0D)
                    : const Color(0x800C0C0D),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),

          // 设置按钮
          if (showSetup)
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
                    fontSize: 15,
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

/// 电池电量视图，模拟 Android BatteryCapacityView
class _BatteryCapacityView extends StatelessWidget {
  const _BatteryCapacityView({
    required this.soc,
    required this.swapFlag,
    required this.isDisabled,
  });

  final int soc;
  final int swapFlag;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bgImage = isDisabled
        ? 'assets/android/mipmap-xxhdpi/bg_battery_capacity_disable.webp'
        : 'assets/android/mipmap-xxhdpi/bg_battery_capacity.webp';

    final fillColor = isDisabled
        ? const Color(0x330C0C0D)
        : (swapFlag == 0
            ? const Color(0xFFFA4B51)
            : const Color(0xFF0ABF83));

    final progress = (soc / 100.0).clamp(0.0, 1.0);

    return SizedBox(
      width: 22,
      height: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          // 与 Android BatteryCapacityView 保持一致的填充区域比例
          final left = w * 0.08;
          final top = h * 0.18;
          final maxFillWidth = w * 0.72;
          final fillHeight = h * 0.64;

          return Stack(
            children: [
              Image.asset(bgImage, width: w, height: h, fit: BoxFit.fill),
              Positioned(
                left: left,
                top: top,
                child: Container(
                  width: progress * maxFillWidth,
                  height: fillHeight,
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
