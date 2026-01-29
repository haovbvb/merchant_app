import 'dart:async';

import 'package:apple_maps_flutter/apple_maps_flutter.dart' as amaps;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:intl/intl.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
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
  late TabController _tabController;
  bool _autoSearched = false;
  String _portFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    final initial = widget.initialSn?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _autoSearched) return;
        final value = _controller.text.trim();
        if (value.isEmpty) return;
        ref
            .read(deviceDetailProvider.notifier)
            .searchDevice(sn: value, deviceType: 3);
        _autoSearched = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(deviceDetailProvider);
    final detail = state.cabinetDetail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: _buildSearchBar(l10n),
      ),
      body: Column(
        children: [
          // 设备信息头部
          if (detail != null) _buildDeviceHeader(detail),

          // Tab 切换
          if (detail != null) _buildTabBar(l10n),

          // Tab 内容
          Expanded(
            child: detail == null
                ? _buildEmptyState(l10n, state.loading)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBasicInfoTab(l10n, detail),
                      _buildPortDetailTab(l10n, state),
                      _buildAddressTab(l10n, detail),
                      _buildRepairRecordsTab(l10n, state),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(dynamic l10n) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
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
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceHeader(CabinetDetailBaseInfoBean detail) {
    final isOnline = detail.online == 1 || detail.showOnlineStatus == 'Online';

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
                    color: Color(0xFF333333),
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
                      color: isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi,
                        size: 14,
                        color: isOnline ? const Color(0xFF4CAF50) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline
                              ? const Color(0xFF4CAF50)
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

  Widget _buildTabBar(dynamic l10n) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF333333),
        unselectedLabelColor: const Color(0xFF999999),
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        indicatorColor: const Color(0xFF4CAF50),
        indicatorWeight: 3,
        tabs: [
          Tab(text: l10n.deviceDetailTabBasicInfo),
          Tab(text: l10n.deviceDetailTabPortDetail),
          Tab(text: l10n.deviceDetailTabAddress),
          Tab(text: l10n.deviceDetailTabRepairRecords),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic l10n, bool loading) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
                            ? const Color(0xFF4CAF50)
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
                            ? const Color(0xFF4CAF50)
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
                style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
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
          child: state.portsLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredPorts.isEmpty
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
                        color: Color(0xFF333333),
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
                      color: Color(0xFF333333),
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
                    foregroundColor: const Color(0xFF333333),
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

    if (state.fixLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (records.isEmpty) {
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
                        color: Color(0xFF333333),
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
                            ? const Color(0xFF4CAF50)
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
                  color: Color(0xFF333333),
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
    ref.read(deviceDetailProvider.notifier).searchDevice(sn: sn, deviceType: 3);
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
    // TODO: 实现端口设置功能
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
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
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
                ? const Color(0xFF4CAF50)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected
                ? const Color(0xFF4CAF50)
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
      socColor = const Color(0xFF4CAF50);
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
                      : const Color(0xFF333333),
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
                    const Icon(Icons.bolt, size: 14, color: Color(0xFF4CAF50)),
                    const SizedBox(width: 2),
                    Text(
                      l10n.deviceDetailPortReplaceable,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4CAF50),
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
