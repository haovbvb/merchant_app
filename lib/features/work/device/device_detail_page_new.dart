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
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/device_search_result.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/device/device_detail_controller.dart';
import 'package:merchant_app/features/work/device/widgets/cabinet_port_detail_section.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:url_launcher/url_launcher.dart';

class DeviceDetailPageNew extends ConsumerStatefulWidget {
  const DeviceDetailPageNew({
    super.key,
    this.initialSn,
    this.readOnly = false,
    this.popToSearchOnClear = false,
    this.showSearchBarInAppBar = true,
    this.expectedDeviceType,
    this.initialTabIndex,
  });

  final String? initialSn;
  final bool readOnly;
  final bool popToSearchOnClear;
  final bool showSearchBarInAppBar;
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

  late gmaps.BitmapDescriptor _markerIconCabinet;
  late amaps.BitmapDescriptor _markerIconCabinetApple;

  @override
  void initState() {
    super.initState();
    _loadMarker();
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
        ? _cabinetHasWarehouse(
            state.searchResult?.deviceInfo,
            state.cabinetDetail,
          )
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
          titleSpacing: widget.showSearchBarInAppBar ? 0 : null,
          title: widget.showSearchBarInAppBar
              ? _buildSearchBar(l10n, deviceType)
              : Text(
                  Localizations.localeOf(context).languageCode == 'zh'
                      ? '设备'
                      : 'Device',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          _buildCabinetBasicInfoTab(l10n, info, detail, loading: state.loading),
          _buildRepairRecordsTab(l10n, state),
        ];
      }
      return [
        _buildCabinetBasicInfoTab(l10n, info, detail, loading: state.loading),
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
        detail?.onlineStatus == 1 ||
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
    final stationName =
        info?.stationName?.trim() ?? detail?.stationName?.trim();
    final sn = info?.sn ?? detail?.stationSn ?? '-';
    final title = (stationName != null && stationName.isNotEmpty)
        ? stationName
        : 'SN: $sn';
    final showOperate =
        (info?.hasPermission ?? detail?.hasPermission) == 1 && !widget.readOnly;

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
                      color: isOnline
                          ? AppColors.primaryColor
                          : AppColors.secondaryColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi,
                        size: 14,
                        color: isOnline
                            ? AppColors.primaryColor
                            : AppColors.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? l10n.online : l10n.offline,
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? AppColors.primaryColor
                              : AppColors.secondaryColor,
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
                    if (sourceLabel != null && sourceColor != null) ...[
                      _buildStatusBadge(sourceLabel, sourceColor),
                      const SizedBox(width: 8),
                    ],
                    _buildStatusBadge(
                      isBound
                          ? l10n.deviceDetailBound
                          : l10n.deviceDetailUnbound,
                      isBound
                          ? AppColors.primaryColor
                          : const Color(0xFFFA4B51),
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
    CabinetDetailBaseInfoBean? detail, {
    required bool loading,
  }) {
    // Avoid showing onboard status before cabinet base-info callback finishes.
    final installStatus =
        detail?.installStatus ??
        ((loading && detail == null) ? null : info?.installStatus);
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
          : (detail?.installTime ??
                (detail?.putOnShelvesTime != null
                    ? detail!.putOnShelvesTime.toString()
                    : null)),
      withSeconds: true,
    );
    String? managerName;
    if (info?.managerList?.isNotEmpty == true) {
      managerName = info!.managerList!.first.showName;
    } else if (detail?.stationManagerList.isNotEmpty == true) {
      final m = detail!.stationManagerList.first;
      managerName = m['showName']?.toString();
    }
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
                _buildPhotoGrid(photos)
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
    final viewPorts = ports
        .map(
          (p) => CabinetPortViewItem(
            portNo: p.portNo ?? 0,
            status: p.status ?? 0,
            batteryStatus: p.batteryStatus ?? 0,
            batterySoc: p.batterySoc ?? 0,
            swapFlag: p.swapFlag ?? 0,
            batterySn: p.batterySn ?? '',
          ),
        )
        .toList();

    return CabinetPortDetailSection(
      l10n: l10n,
      ports: viewPorts,
      selectedFilter: _portFilter,
      onFilterChanged: (value) => setState(() => _portFilter = value),
      emptyText: l10n.deviceDetailCabinPortEmpty,
      loading: state.portsLoading,
      showSetup: showSetup,
      onRefresh: () => ref.read(deviceDetailProvider.notifier).loadCabinPorts(),
      onSetup: (item) {
        final target = ports.where((p) => (p.portNo ?? 0) == item.portNo);
        if (target.isEmpty) return;
        _setupPort(target.first);
      },
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
    bool isValidLatLng(double? lat, double? lng) {
      if (lat == null || lng == null) return false;
      if (lat == 0 && lng == 0) return false;
      if (lat < -90 || lat > 90) return false;
      if (lng < -180 || lng > 180) return false;
      return true;
    }

    final hasValidLocation = isValidLatLng(lat, lng);

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
                  Image.asset(
                    'assets/android/mipmap-xxhdpi/ic_lon_lat.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFF999999),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (address.trim().isEmpty) ? '-' : address,
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
                    ((lat == 0 && lng == 0))
                        ? '-'
                        : '${lng.toStringAsFixed(6)}    ${lat.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.black06Text,
                    ),
                  ),
                ],
              ),
              if (hasValidLocation) ...[
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
                      style: TextStyle(fontSize: 13, color: status.textColor),
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
                _buildPhotoGrid(photos)
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
                _buildPhotoGrid(photos)
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

  bool _cabinetHasWarehouse(
    DeviceInfo? info,
    CabinetDetailBaseInfoBean? detail,
  ) {
    final status = info?.installStatus ?? detail?.installStatus;
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

  Widget _buildPhotoGrid(List<String> photos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final itemSize = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: photos.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return SizedBox(
              width: itemSize,
              height: itemSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () => _openPhotoBrowser(photos, index),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
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
            icon: _markerIconCabinet, // 自定义图片
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
            icon: _markerIconCabinetApple, // 自定义图片
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
    final isStationOnly = widget.expectedDeviceType == 3;
    final sn = isStationOnly
        ? ScanUtils.parseSnByDeviceType(input, 3).trim()
        : ScanUtils.getDeviceSn(input).trim();
    if (sn.isEmpty) return;
    if (isStationOnly && !_isValidStationSnInput(input, sn)) {
      return;
    }

    if (isStationOnly) {
      final found = await ref
          .read(deviceDetailProvider.notifier)
          .searchDevice(sn: sn, deviceType: 3);
      if (!mounted) return;
      if (!found) {
        _backToSource(false);
        return;
      }
      _checkCabinetPermission();
      return;
    }

    // 默认场景下仍使用 commonSearch 自动识别设备类型
    final result = await ref
        .read(deviceDetailProvider.notifier)
        .commonSearch(sn);
    if (!mounted) return;
    if (result == null) {
      _backToSource(false);
      return;
    }
    if (result.type == 3) {
      _checkCabinetPermission();
    }
  }

  void _checkCabinetPermission() {
    if (widget.readOnly) return;
    _ensureCabinetPermission(showDialog: true, isOptDevice: true);
  }

  bool _ensureCabinetPermission({
    required bool showDialog,
    required bool isOptDevice,
  }) {
    final state = ref.read(deviceDetailProvider);
    final hasPermission = state.searchResult?.deviceInfo?.hasPermission;
    final managerList = state.searchResult?.deviceInfo?.managerList;

    if (hasPermission == null) {
      return false;
    }
    if (hasPermission == 1) {
      return true;
    }

    final shouldShowDialog =
        showDialog &&
        isOptDevice &&
        hasPermission == 0 &&
        managerList != null &&
        managerList.isNotEmpty;
    if (shouldShowDialog) {
      final (managerName, managerPhone) = _resolveManagerContact(state);
      _showNotManagerDialog(managerName, managerPhone);
    }
    return false;
  }

  (String, String) _resolveManagerContact(DeviceDetailState state) {
    String managerName = '';
    String managerPhone = '';
    final managerList = state.searchResult?.deviceInfo?.managerList;
    if (managerList != null && managerList.isNotEmpty) {
      managerName = managerList.first.showName ?? '';
      managerPhone = managerList.first.phone ?? '';
    }
    final areaCode = AuthSession.instance.current?.areaCode ?? '';
    if (areaCode.isNotEmpty && managerPhone.isNotEmpty) {
      managerPhone = '$areaCode $managerPhone';
    }
    return (managerName, managerPhone);
  }

  void _showNotManagerDialog(String managerName, String managerPhone) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            width: 310,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Text(
                    l10n.cabinetNotManagerTips,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.deviceDetailResponsibleLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          managerName,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.cabinetNotManagerPhone,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          managerPhone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0B61D9),
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0.5),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      l10n.confirm,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    // 运维角色仅允许电柜查询：先校验有效 SN，再回填输入框，避免无效值污染 UI。
    if (expectedType == 3) {
      final parsedSn = ScanUtils.parseSnByDeviceType(result, 3).trim();
      if (parsedSn.isEmpty || !_isValidStationSnInput(result, parsedSn)) {
        return;
      }
      _controller.text = parsedSn;
      _submit(parsedSn);
      return;
    }

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
    if (!_ensureCabinetPermission(showDialog: true, isOptDevice: false)) {
      return;
    }

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
                title: Center(
                  child: Text(
                    isDoorOpen
                        ? l10n.deviceDetailPortOpened
                        : l10n.deviceDetailPortOpenShort,
                    style: TextStyle(color: isDoorOpen ? Colors.grey : null),
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
                title: Center(
                  child: Text(
                    isDisabled
                        ? l10n.deviceDetailPortEnable
                        : l10n.deviceDetailPortDisableShort,
                    style: TextStyle(
                      color: isDisabled ? AppColors.primaryColor : Colors.red,
                    ),
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
    if (!_ensureCabinetPermission(showDialog: true, isOptDevice: false)) {
      return;
    }

    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context: context,
      message: l10n.deviceDetailPortOpenConfirm(port.portNo ?? 0),
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );

    if (!confirmed || !mounted) return;

    await ref
        .read(deviceDetailProvider.notifier)
        .openCabinDoor(port: port.portNo ?? 0);

    if (!mounted) return;
  }

  Future<void> _confirmOpenCabinetBackDoor() async {
    if (!_ensureCabinetPermission(showDialog: true, isOptDevice: false)) {
      return;
    }

    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context: context,
      message: l10n.cabinetOperateOpenDoorConfirmContent,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );

    if (!confirmed || !mounted) return;

    await ref.read(deviceDetailProvider.notifier).openCabinBackDoor();

    if (!mounted) return;
  }

  Future<void> _confirmTogglePort(Cabin port, bool enable) async {
    if (!_ensureCabinetPermission(showDialog: true, isOptDevice: false)) {
      return;
    }

    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context: context,
      message: enable
          ? l10n.deviceDetailPortEnableConfirm
          : l10n.deviceDetailPortDisableConfirm,
      cancelText: l10n.cancel,
      confirmText: l10n.confirm,
    );

    if (!confirmed || !mounted) return;

    final notifier = ref.read(deviceDetailProvider.notifier);
    if (enable) {
      await notifier.enableCabinPort(port: port.portNo ?? 0);
    } else {
      await notifier.disableCabinPort(port: port.portNo ?? 0);
    }

    if (!mounted) return;
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
  }

  void _openPhotoBrowser(List<String> photos, int initialIndex) {
    if (photos.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            _PhotoGalleryPage(photos: photos, initialIndex: initialIndex),
      ),
    );
  }

  Future<void> _loadMarker() async {
    _markerIconCabinet = await gmaps.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(25, 25)),
      'assets/android/mipmap-xxhdpi/icon_station_loc.png',
    );
    _markerIconCabinetApple = await amaps.BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(25, 25)),
      'assets/android/mipmap-xxhdpi/icon_station_loc.png',
    );

    if (mounted) {
      setState(() {});
    }
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
