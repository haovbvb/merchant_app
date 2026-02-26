import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/cabinet_cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_controller.dart';
import 'package:merchant_app/features/work/cabinet/cabinet_offline_fault_page.dart';

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
    final notifier = ref.read(cabinetOfflineProvider.notifier);
    final info = state.baseInfo;
    final canOperate = (info?.hasPermission ?? 0) == 1;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cabinetOfflineDetailTitle)),
      body: Padding(
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
                      notifier.load(sn);
                      notifier.loadLayout(sn);
                    },
              child: Text(l10n.cabinetOfflineQueryAction),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: info == null
                  ? Center(child: Text(l10n.cabinetOfflineEmpty))
                  : DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(
                            tabs: [
                              Tab(text: l10n.cabinetOfflineDeviceInfoTab),
                              Tab(text: l10n.cabinetOfflineWarehouseTab),
                              Tab(text: l10n.cabinetOfflineRealtimeTab),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _DeviceInfoTab(
                                  info: info,
                                  secretKey: state.secretKey,
                                  canOperate: canOperate,
                                  operating: state.operating,
                                  onRestart: _restartCabinet,
                                  onOpenDoor: _openBackDoor,
                                ),
                                _WarehouseTab(
                                  state: state,
                                  canOperate: canOperate,
                                  onOpenDoor: _openCabinDoor,
                                  onToggleEnable: _toggleCabinEnable,
                                ),
                                _RealtimeInfoTab(info: info),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeviceInfoTab extends StatelessWidget {
  const _DeviceInfoTab({
    required this.info,
    this.secretKey,
    required this.canOperate,
    required this.operating,
    required this.onRestart,
    required this.onOpenDoor,
  });

  final CabinetDetailBaseInfoBean info;
  final String? secretKey;
  final bool canOperate;
  final bool operating;
  final Future<void> Function() onRestart;
  final Future<void> Function() onOpenDoor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _InfoTile(label: l10n.cabinetOfflineName, value: info.stationName),
        _InfoTile(label: l10n.cabinetOfflineSnLabel, value: info.stationSn),
        _InfoTile(label: l10n.cabinetOfflinePidLabel, value: info.stationPid),
        _InfoTile(
          label: l10n.cabinetOfflineAddressLabel,
          value: info.stationAddress,
        ),
        _InfoTile(
          label: l10n.cabinetOfflineSlotModel,
          value: info.stationModelName,
        ),
        _InfoTile(label: l10n.cabinetOfflineSecretKey, value: secretKey),
        _InfoTile(
          label: l10n.cabinetOfflineSwapThreshold,
          value: info.swapThreshold?.toString(),
        ),
        _InfoTile(label: l10n.cabinetOfflineApn, value: info.apn),
        _InfoTile(
          label: l10n.cabinetOfflineVolume,
          value: info.volume?.toString(),
        ),
        _InfoTile(
          label: l10n.cabinetOfflinePlatformUrl,
          value: info.platformUrl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: !canOperate || operating
                    ? null
                    : () => _showRestartDialog(context),
                icon: const Icon(Icons.restart_alt),
                label: Text(l10n.cabinetOfflineRestart),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: !canOperate || operating
                    ? null
                    : () => _showOpenDoorDialog(context),
                icon: const Icon(Icons.door_front_door_outlined),
                label: Text(l10n.cabinetOfflineOpenDoor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: info.stationSn == null
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CabinetOfflineFaultPage(sn: info.stationSn ?? ''),
                  ),
                ),
          child: Text(l10n.cabinetOfflineFaultEntry),
        ),
      ],
    );
  }

  void _showRestartDialog(BuildContext context) {
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
              await onRestart();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showOpenDoorDialog(BuildContext context) {
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
              await onOpenDoor();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }
}

class _RealtimeInfoTab extends StatelessWidget {
  const _RealtimeInfoTab({required this.info});

  final CabinetDetailBaseInfoBean info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _InfoTile(
          label: l10n.cabinetOfflineStatusLabel,
          value: info.showOnlineStatus ?? info.online,
        ),
        _InfoTile(
          label: l10n.cabinetOfflineLastHbLabel,
          value: info.lastHbTime,
        ),
        _InfoTile(label: l10n.cabinetOfflineLockDevId, value: info.lockDevId),
        _InfoTile(label: l10n.cabinetOfflineLockIcId, value: info.lockIcId),
        // 实时报警状态 (需要蓝牙连接获取)
        _InfoTile(
          label: l10n.cabinetOfflineSmokeAlarm,
          value: l10n.cabinetOfflineNoAlarm,
        ),
        _InfoTile(
          label: l10n.cabinetOfflineWaterAlarm,
          value: l10n.cabinetOfflineNoAlarm,
        ),
        _InfoTile(
          label: l10n.cabinetOfflineChargerStatus,
          value: l10n.cabinetOfflineNormal,
        ),
      ],
    );
  }
}

class _WarehouseTab extends StatelessWidget {
  const _WarehouseTab({
    required this.state,
    required this.canOperate,
    required this.onOpenDoor,
    required this.onToggleEnable,
  });

  final CabinetOfflineState state;
  final bool canOperate;
  final Future<void> Function(CabinetCabin cabin) onOpenDoor;
  final Future<void> Function(CabinetCabin cabin) onToggleEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // 优先显示蓝牙获取的仓位数据
    if (state.cabins.isNotEmpty) {
      return _CabinGridView(
        state: state,
        canOperate: canOperate,
        onOpenDoor: onOpenDoor,
        onToggleEnable: onToggleEnable,
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
}

/// 仓位网格视图 (对标 Android CabinetOfflineWarehouseFragment)
class _CabinGridView extends StatelessWidget {
  const _CabinGridView({
    required this.state,
    required this.canOperate,
    required this.onOpenDoor,
    required this.onToggleEnable,
  });

  final CabinetOfflineState state;
  final bool canOperate;
  final Future<void> Function(CabinetCabin cabin) onOpenDoor;
  final Future<void> Function(CabinetCabin cabin) onToggleEnable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cabins = state.cabins;

    if (cabins.isEmpty) {
      return Center(child: Text(l10n.cabinetOfflineCabinEmpty));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cabins.length,
      itemBuilder: (context, index) {
        final cabin = cabins[index];
        return _CabinCard(
          cabin: cabin,
          onTap: () => _showCabinOperateSheet(context, cabin),
        );
      },
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

/// 仓位卡片
class _CabinCard extends StatelessWidget {
  const _CabinCard({required this.cabin, required this.onTap});

  final CabinetCabin cabin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusText = cabin.isEnabled && cabin.canSwap
        ? l10n.cabinetOfflineCabinCanUse
        : cabin.isEnabled
        ? (cabin.hasBattery ? '' : l10n.cabinetOfflineCabinNoBattery)
        : l10n.cabinetOfflineCabinNoUse;
    final statusColor = cabin.canSwap
        ? Colors.green
        : cabin.isEnabled
        ? Colors.orange
        : Colors.grey;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${cabin.portNo}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(fontSize: 11, color: statusColor),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 电量指示器
              _BatteryIndicator(
                soc: cabin.batterySoc,
                isEnabled: cabin.isEnabled,
                canSwap: cabin.canSwap,
              ),
              const SizedBox(height: 8),
              Text(
                '${cabin.batterySoc}%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'SN: ${cabin.batterySn.isNotEmpty ? cabin.batterySn : '-'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.settings,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 电量指示器 (对标 Android BatteryCapacityView)
class _BatteryIndicator extends StatelessWidget {
  const _BatteryIndicator({
    required this.soc,
    required this.isEnabled,
    required this.canSwap,
  });

  final int soc;
  final bool isEnabled;
  final bool canSwap;

  @override
  Widget build(BuildContext context) {
    final color = !isEnabled
        ? Colors.grey
        : canSwap
        ? Colors.green
        : soc > 20
        ? Colors.orange
        : Colors.red;

    return Container(
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: soc / 100.0,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Container(
            width: 4,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label)),
          Expanded(child: Text(value?.isNotEmpty == true ? value! : '-')),
        ],
      ),
    );
  }
}
