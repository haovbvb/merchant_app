import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/cabinet_cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_fault_page.dart';
import 'package:merchant_app/features/work/device/widgets/cabinet_port_detail_section.dart';

class CabinetOfflineDetailPage extends ConsumerStatefulWidget {
  const CabinetOfflineDetailPage({super.key, this.initialSn});

  /// Optional initial SN to load on page open.
  final String? initialSn;

  @override
  ConsumerState<CabinetOfflineDetailPage> createState() =>
      _CabinetOfflineDetailPageState();
}

class _CabinetOfflineDetailPageState
    extends ConsumerState<CabinetOfflineDetailPage> {
  final TextEditingController _snController = TextEditingController();
  bool _noPermissionHandled = false;
  String _warehousePortFilter = 'all';

  @override
  void initState() {
    super.initState();
    if (widget.initialSn != null && widget.initialSn!.isNotEmpty) {
      _snController.text = widget.initialSn!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queryWithSn(widget.initialSn!);
      });
    }
  }

  void _queryWithSn(String sn) {
    final notifier = ref.read(cabinetOfflineProvider.notifier);
    notifier.load(sn);
    notifier.loadLayout(sn);
  }

  Future<void> _restartCabinet() async {
    final l10n = context.l10n;
    final info = ref.read(cabinetOfflineProvider).baseInfo;
    final pId = info?.stationPid?.trim() ?? '';
    if (pId.isEmpty) return;
    final ok = await ref
        .read(cabinetOfflineProvider.notifier)
        .restartCabinet(pId: pId);
    if (!mounted) return;
    showToast(
      ok ? l10n.deviceDetailToggleSuccess : l10n.deviceDetailToggleFailed,
    );
  }

  Future<void> _openBackDoor() async {
    final l10n = context.l10n;
    final info = ref.read(cabinetOfflineProvider).baseInfo;
    final sn = info?.stationSn?.trim() ?? '';
    if (sn.isEmpty) return;
    final ok = await ref
        .read(cabinetOfflineProvider.notifier)
        .openBackDoor(sn: sn);
    if (!mounted) return;
    showToast(
      ok
          ? l10n.cabinetOperateOpenDoorSuccess
          : l10n.cabinetOperateOpenDoorFailed,
    );
  }

  Future<void> _openCabinDoor(CabinetCabin cabin) async {
    final l10n = context.l10n;
    final info = ref.read(cabinetOfflineProvider).baseInfo;
    final sn = info?.stationSn?.trim() ?? '';
    if (sn.isEmpty) return;
    final ok = await ref
        .read(cabinetOfflineProvider.notifier)
        .controlCabinPort(sn: sn, port: cabin.portNo, type: 1);
    if (!mounted) return;
    showToast(
      ok
          ? l10n.deviceDetailCabinOpenDoorSuccess
          : l10n.deviceDetailCabinOpenDoorFailed,
    );
  }

  Future<void> _toggleCabinEnable(CabinetCabin cabin) async {
    final l10n = context.l10n;
    final info = ref.read(cabinetOfflineProvider).baseInfo;
    final sn = info?.stationSn?.trim() ?? '';
    if (sn.isEmpty) return;
    final type = cabin.isEnabled ? 2 : 3;
    final ok = await ref
        .read(cabinetOfflineProvider.notifier)
        .controlCabinPort(sn: sn, port: cabin.portNo, type: type);
    if (!mounted) return;
    showToast(
      ok ? l10n.deviceDetailToggleSuccess : l10n.deviceDetailToggleFailed,
    );
  }

  @override
  void dispose() {
    _snController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    final info = state.baseInfo;
    final canOperate = (info?.hasPermission ?? 0) == 1;

    if (info != null && !canOperate && !_noPermissionHandled) {
      _noPermissionHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showToast(l10n.cabinetOfflineNoPermission);
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else {
          AppRouter.goHome();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(l10n.cabinetOfflineDetailTitle),
        actions: [
          if (info != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                final sn = _snController.text.trim();
                if (sn.isNotEmpty) _queryWithSn(sn);
              },
            ),
        ],
      ),
      body: info == null
          ? _buildInputView(state)
          : _buildDetailView(state, info, canOperate),
    );
  }

  Widget _buildInputView(CabinetOfflineState state) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: l10n.cabinetOfflineSnLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.loading
                ? null
                : () {
                    final sn = _snController.text.trim();
                    final notifier =
                        ref.read(cabinetOfflineProvider.notifier);
                    notifier.load(sn);
                    notifier.loadLayout(sn);
                  },
            child: Text(l10n.cabinetOfflineQueryAction),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailView(
    CabinetOfflineState state,
    CabinetDetailBaseInfoBean info,
    bool canOperate,
  ) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildHeader(info, state, canOperate),
          Material(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: AppColors.black05Text,
              indicatorColor: AppColors.primaryColor,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: l10n.cabinetOfflineDeviceInfoTab),
                Tab(text: l10n.cabinetOfflineWarehouseTab),
                Tab(text: l10n.cabinetOfflineRealtimeTab),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DeviceInfoTab(
                  info: info,
                  state: state,
                  onEditSwapThreshold: () =>
                      _showEditSwapThreshold(info),
                  onEditApn: () => _showEditApn(info),
                  onEditVolume: () => _showEditVolume(info),
                  onEditPlatformUrl: () =>
                      _showEditPlatformUrl(info),
                ),
                _WarehouseTab(
                  state: state,
                  canOperate: canOperate,
                  selectedFilter: _warehousePortFilter,
                  onFilterChanged: (value) {
                    setState(() => _warehousePortFilter = value);
                  },
                  onOpenDoor: _openCabinDoor,
                  onToggleEnable: _toggleCabinEnable,
                ),
                _RealtimeInfoTab(info: info),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    CabinetDetailBaseInfoBean info,
    CabinetOfflineState state,
    bool canOperate,
  ) {
    final l10n = context.l10n;
    final isOnline = info.online == '1';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF2F2F2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: info.standardImg != null &&
                        info.standardImg!.isNotEmpty
                    ? Image.network(
                        info.standardImg!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.battery_charging_full,
                          size: 32,
                          color: AppColors.primaryColor,
                        ),
                      )
                    : const Icon(
                        Icons.battery_charging_full,
                        size: 32,
                        color: AppColors.primaryColor,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.stationName ??
                          info.stationModelName ??
                          '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isOnline
                                  ? AppColors.primaryColor
                                  : const Color(0xFFFA4B51),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isOnline
                                    ? Icons.wifi
                                    : Icons.wifi_off,
                                size: 14,
                                color: isOnline
                                    ? AppColors.primaryColor
                                    : const Color(0xFFFA4B51),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isOnline
                                      ? AppColors.primaryColor
                                      : const Color(0xFFFA4B51),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD9D9D9),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            state.bleConnected
                                ? l10n.cabinetOfflineBleConnected
                                : l10n.cabinetOfflineBleDisconnected,
                            style: TextStyle(
                              fontSize: 12,
                              color: state.bleConnected
                                  ? const Color(0xFF0B61D9)
                                  : const Color(0xFF6C7180),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !canOperate || state.operating
                      ? null
                      : () => _showRestartDialog(),
                  icon: const Icon(Icons.restart_alt, size: 18),
                  label: Text(l10n.cabinetOfflineRestart),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: const Color(0xFFF6F8FC),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !canOperate || state.operating
                      ? null
                      : () => _showOpenDoorDialog(),
                  icon: const Icon(
                    Icons.door_front_door_outlined,
                    size: 18,
                  ),
                  label: Text(l10n.cabinetOfflineOpenDoor),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: const Color(0xFFF6F8FC),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRestartDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cabinetOfflineRestartTitle),
        content: Text(l10n.cabinetOfflineRestartConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _restartCabinet();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showOpenDoorDialog() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cabinetOfflineOpenDoorTitle),
        content: Text(l10n.cabinetOfflineOpenDoorConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _openBackDoor();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showEditSwapThreshold(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.swapThreshold?.toString() ?? '';
    final maxChargeSoc = info.maxChargeSoc ?? 100;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditTextSheet(
        title: l10n.cabinetOfflineSwapThreshold,
        currentValue: currentValue,
        keyboardType: TextInputType.number,
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterSwapThreshold);
            return;
          }
          final intVal = int.tryParse(value);
          if (intVal == null || intVal > maxChargeSoc) {
            showToast(
              l10n.cabinetOfflineSwapThresholdExceed(maxChargeSoc),
            );
            return;
          }
          Navigator.of(ctx).pop();
          showToast(l10n.cabinetOfflinePleaseConnectBle);
        },
      ),
    );
  }

  void _showEditApn(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.apn ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditTextSheet(
        title: l10n.cabinetOfflineApn,
        currentValue: currentValue,
        keyboardType: TextInputType.text,
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterApn);
            return;
          }
          if (value.length > 200) {
            showToast(l10n.cabinetOfflineMaxLenError(200));
            return;
          }
          Navigator.of(ctx).pop();
          showToast(l10n.cabinetOfflinePleaseConnectBle);
        },
      ),
    );
  }

  void _showEditVolume(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.volume ?? 0;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditVolumeSheet(
        title: l10n.cabinetOfflineVolume,
        currentValue: currentValue,
        onSave: (value) {
          Navigator.of(ctx).pop();
          showToast(l10n.cabinetOfflinePleaseConnectBle);
        },
      ),
    );
  }

  void _showEditPlatformUrl(CabinetDetailBaseInfoBean info) {
    final l10n = context.l10n;
    final currentValue = info.platformUrl ?? '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EditTextSheet(
        title: l10n.cabinetOfflinePlatformUrl,
        currentValue: currentValue,
        keyboardType: TextInputType.url,
        onSave: (value) {
          if (value.isEmpty) {
            showToast(l10n.cabinetOfflineEnterPlatformUrl);
            return;
          }
          if (value.length > 200) {
            showToast(l10n.cabinetOfflineMaxLenError(200));
            return;
          }
          Navigator.of(ctx).pop();
          showToast(l10n.cabinetOfflinePleaseConnectBle);
        },
      ),
    );
  }
}

class _DeviceInfoTab extends StatelessWidget {
  const _DeviceInfoTab({
    required this.info,
    required this.state,
    required this.onEditSwapThreshold,
    required this.onEditApn,
    required this.onEditVolume,
    required this.onEditPlatformUrl,
  });

  final CabinetDetailBaseInfoBean info;
  final CabinetOfflineState state;
  final VoidCallback onEditSwapThreshold;
  final VoidCallback onEditApn;
  final VoidCallback onEditVolume;
  final VoidCallback onEditPlatformUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SizedBox(height: 4),
        // First card: read-only info
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSoftwareVersion,
                value: state.softwareVersion,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineBackupPowerStatus,
                value: state.backupPowerStatus,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineSlotCount,
                value: info.storeNum?.toString(),
              ),
              _InfoTile(
                label: l10n.cabinetOfflineBatteryInSlot,
                value: state.batteryInSlot?.toString(),
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Second card: editable items with right arrow
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSwapThreshold,
                value: info.swapThreshold?.toString(),
                showArrow: true,
                onTap: onEditSwapThreshold,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineApn,
                value: info.apn,
                showArrow: true,
                onTap: onEditApn,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineVolume,
                value: info.volume?.toString(),
                showArrow: true,
                onTap: onEditVolume,
              ),
              _InfoTile(
                label: l10n.cabinetOfflinePlatformUrl,
                value: info.platformUrl,
                showArrow: true,
                showDivider: false,
                onTap: onEditPlatformUrl,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RealtimeInfoTab extends ConsumerWidget {
  const _RealtimeInfoTab({required this.info});

  final CabinetDetailBaseInfoBean info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(cabinetOfflineProvider);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const SizedBox(height: 4),
        // Card 1: 通讯相关
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineGsmSignal,
                value: state.gsmSignal,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineCharger,
                value: state.chargerStatus ?? l10n.cabinetOfflineYes,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineCtrlSystem,
                value: state.ctrlSystemStatus ?? l10n.cabinetOfflineYes,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 2: 电气数据
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineOMDoor,
                value: state.omDoorStatus,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTotalVoltage,
                value: state.totalVoltage,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTotalCurrent,
                value: state.totalCurrent,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineTemperature,
                value: state.temperature,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineElectricityMeter,
                value: state.electricityMeter,
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Card 3: 报警状态
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              _InfoTile(
                label: l10n.cabinetOfflineSmokeAlarm,
                value: state.smokeAlarmStatus ?? l10n.cabinetOfflineNoAlarm,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineWaterAlarm,
                value: state.waterAlarmStatus ?? l10n.cabinetOfflineNoAlarm,
              ),
              _InfoTile(
                label: l10n.cabinetOfflineFanStatus,
                value: state.fanStatus,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab({
    required this.state,
    required this.canOperate,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onOpenDoor,
    required this.onToggleEnable,
  });

  final CabinetOfflineState state;
  final bool canOperate;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Future<void> Function(CabinetCabin cabin) onOpenDoor;
  final Future<void> Function(CabinetCabin cabin) onToggleEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // 优先显示蓝牙获取的仓位数据
    if (state.cabins.isNotEmpty) {
      final viewPorts = state.cabins
          .map(
            (c) => CabinetPortViewItem(
              portNo: c.portNo,
              status: c.status,
              batteryStatus: c.batteryStatus,
              batterySoc: c.batterySoc,
              swapFlag: c.swapFlag,
              batterySn: c.batterySn,
            ),
          )
          .toList();
      return CabinetPortDetailSection(
        l10n: l10n,
        ports: viewPorts,
        selectedFilter: selectedFilter,
        onFilterChanged: onFilterChanged,
        emptyText: l10n.cabinetOfflineCabinEmpty,
        loading: false,
        showSetup: canOperate,
        onSetup: (item) {
          final target = state.cabins.where((c) => c.portNo == item.portNo);
          if (target.isEmpty) return;
          _showCabinOperateSheet(context, target.first);
        },
      );
    }

    // 否则显示布局历史信息
    if (state.layoutLoading) {
      return const Center(child: SizedBox.shrink());
    }
    final items = state.layoutInfo?.list ?? const [];
    if (items.isEmpty) {
      return Center(child: Text(l10n.cabinetOfflineWarehouseEmpty));
    }
    return ListView(
      children: [
        _InfoTile(
          label: l10n.cabinetOfflineWarehouseTotal,
          value: state.layoutInfo?.total.toString(),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoTile(label: l10n.cabinetOfflineSnLabel, value: item.sn),
                  _InfoTile(
                    label: l10n.cabinetOfflinePidLabel,
                    value: item.pid,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineStatusLabel,
                    value: item.status,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseCityCodeLabel,
                    value: item.cityCode?.toString(),
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseLatLabel,
                    value: item.latitude,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseLngLabel,
                    value: item.longitude,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseOpPhoneLabel,
                    value: item.opPhone,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseOpNameLabel,
                    value: item.opName,
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineWarehouseCreateTimeLabel,
                    value: item.createTime?.toString(),
                  ),
                  _InfoTile(
                    label: l10n.cabinetOfflineAddressLabel,
                    value: item.address,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  void _showCabinOperateSheet(BuildContext context, CabinetCabin cabin) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.cabinetOfflineCabinSlot(cabin.portNo),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.door_front_door),
              title: Text(l10n.cabinetOfflineCabinOpenDoor),
              onTap: !canOperate || state.operating
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await onOpenDoor(cabin);
                    },
            ),
            ListTile(
              leading: const Icon(Icons.power_settings_new),
              title: Text(
                cabin.isEnabled
                    ? l10n.cabinetOfflineCabinDisable
                    : l10n.cabinetOfflineCabinEnable,
              ),
              onTap: !canOperate || state.operating
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await onToggleEnable(cabin);
                    },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber),
              title: Text(l10n.cabinetOfflineCabinCheckFault),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CabinetOfflineFaultPage(
                      sn: state.baseInfo?.stationSn ?? '',
                      port: cabin.portNo,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    this.value,
    this.showArrow = false,
    this.showDivider = true,
    this.onTap,
  });

  final String label;
  final String? value;
  final bool showArrow;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
              ),
            ),
          ),
          Text(
            value?.isNotEmpty == true ? value! : '-',
            style: TextStyle(
              fontSize: 14,
              color: showArrow
                  ? const Color(0xFF666666)
                  : const Color(0xFF999999),
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF999999),
            ),
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        onTap != null
            ? InkWell(onTap: onTap, child: content)
            : content,
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFF0F0F0),
          ),
      ],
    );
  }
}

/// 文本编辑底部弹窗 (对标 Android dialog_edit_text1.xml)
class _EditTextSheet extends StatefulWidget {
  const _EditTextSheet({
    required this.title,
    required this.currentValue,
    this.keyboardType,
    required this.onSave,
  });

  final String title;
  final String currentValue;
  final TextInputType? keyboardType;
  final void Function(String) onSave;

  @override
  State<_EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<_EditTextSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Color(0xE60C0C0D),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () => _controller.clear(),
                ),
              ),
            ),
          ),
          _buildButtons(l10n),
        ],
      ),
    );
  }

  Widget _buildButtons(dynamic l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F8FB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(
                    color: Color(0xB30C0C0D),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextButton(
                onPressed: () =>
                    widget.onSave(_controller.text),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 音量编辑底部弹窗 (对标 Android dialog_edit_volume.xml)
class _EditVolumeSheet extends StatefulWidget {
  const _EditVolumeSheet({
    required this.title,
    required this.currentValue,
    required this.onSave,
  });

  final String title;
  final int currentValue;
  final void Function(int) onSave;

  @override
  State<_EditVolumeSheet> createState() => _EditVolumeSheetState();
}

class _EditVolumeSheetState extends State<_EditVolumeSheet> {
  late int _volume;

  @override
  void initState() {
    super.initState();
    _volume = widget.currentValue.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 50,
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Color(0xE60C0C0D),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primaryColor,
                    inactiveTrackColor: const Color(0xFFE0E0E0),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 2,
                    ),
                    overlayColor:
                        AppColors.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: Slider(
                    value: _volume.toDouble(),
                    min: 0,
                    max: 100,
                    onChanged: (v) =>
                        setState(() => _volume = v.round()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD9D9D9),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_volume',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xE60C0C0D),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF5F8FB),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(
                        color: Color(0xB30C0C0D),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: TextButton(
                    onPressed: () =>
                        widget.onSave(_volume),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.save,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
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
}
