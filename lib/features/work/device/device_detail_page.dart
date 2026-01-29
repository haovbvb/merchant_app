import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/scan_utils.dart';
import 'package:merchant_app/data/models/battery_detail.dart';
import 'package:merchant_app/data/models/cabin.dart';
import 'package:merchant_app/data/models/cabinet_detail_base_info_bean.dart';
import 'package:merchant_app/data/models/vehicle_detail.dart';
import 'package:merchant_app/features/work/device/device_detail_controller.dart';
import 'package:merchant_app/features/work/map/battery_location_page.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';

class DeviceDetailPage extends ConsumerStatefulWidget {
  const DeviceDetailPage({super.key, this.initialSn, this.initialDeviceType});

  final String? initialSn;
  final int? initialDeviceType;

  @override
  ConsumerState<DeviceDetailPage> createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends ConsumerState<DeviceDetailPage> {
  final TextEditingController _controller = TextEditingController();
  bool _autoSearched = false;
  int _selectedDeviceType = 1;

  @override
  void initState() {
    super.initState();
    _selectedDeviceType = widget.initialDeviceType ?? 1;
    final initial = widget.initialSn?.trim() ?? '';
    if (initial.isNotEmpty) {
      _controller.text = initial;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _autoSearched) return;
        final value = _controller.text.trim();
        if (value.isEmpty) return;
        ref
            .read(deviceDetailProvider.notifier)
            .searchDevice(sn: value, deviceType: _selectedDeviceType);
        _autoSearched = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(deviceDetailProvider);
    final notifier = ref.read(deviceDetailProvider.notifier);

    return DefaultTabController(
      length: 3,
      initialIndex: _selectedDeviceType - 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.deviceDetailTitle),
          bottom: TabBar(
            onTap: (index) => _changeDeviceType(index, notifier),
            tabs: [
              Tab(text: l10n.deviceDetailTabBattery),
              Tab(text: l10n.deviceDetailTabVehicle),
              Tab(text: l10n.deviceDetailTabCabinet),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.deviceDetailSearchHint,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/android/mipmap-xxhdpi/icon_search.webp',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: AppIcons.scanIcon(),
                    onPressed: _scanSn,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.loading
                      ? null
                      : () => _submit(notifier),
                  child: state.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.warehouseSearchAction),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _DeviceDetailPanel(
                      deviceType: 1,
                      state: state,
                      notifier: notifier,
                    ),
                    _DeviceDetailPanel(
                      deviceType: 2,
                      state: state,
                      notifier: notifier,
                    ),
                    _DeviceDetailPanel(
                      deviceType: 3,
                      state: state,
                      notifier: notifier,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QrScanPage(
          parseDeviceSn: true,
          deviceType: _selectedDeviceType,
        ),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    _controller.text = result;
  }

  void _submit(DeviceDetailNotifier notifier) {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final sn = ScanUtils.parseSnByDeviceType(value, _selectedDeviceType).trim();
    if (sn.isEmpty) return;
    notifier.searchDevice(sn: sn, deviceType: _selectedDeviceType);
  }

  void _changeDeviceType(int index, DeviceDetailNotifier notifier) {
    setState(() => _selectedDeviceType = index + 1);
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    final sn =
        ScanUtils.parseSnByDeviceType(value, _selectedDeviceType).trim();
    if (sn.isEmpty) return;
    notifier.searchDevice(sn: sn, deviceType: _selectedDeviceType);
  }
}

class _DeviceDetailPanel extends StatelessWidget {
  const _DeviceDetailPanel({
    required this.deviceType,
    required this.state,
    required this.notifier,
  });

  final int deviceType;
  final DeviceDetailState state;
  final DeviceDetailNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matchesType = state.deviceType == deviceType;
    final detail = _resolveDetail();

    if (!matchesType) {
      return _DeviceDetailEmpty(text: l10n.deviceDetailEmpty);
    }
    if (state.loading && detail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (detail == null) {
      return _DeviceDetailEmpty(text: l10n.deviceDetailEmpty);
    }

    return ListView(
      children: [
        if (deviceType == 1)
          _buildBatteryDetail(context, detail as BatteryDetail)
        else if (deviceType == 2)
          _buildVehicleDetail(context, detail as VehicleDetail)
        else
          _buildCabinetDetail(context, detail as CabinetDetailBaseInfoBean),
        if (deviceType == 1) ...[
          const SizedBox(height: 16),
          _buildChargeHistory(context),
        ],
        if (deviceType == 2) ...[
          const SizedBox(height: 16),
          _buildMaintenanceRecords(context),
        ],
        if (deviceType == 3) ...[
          const SizedBox(height: 16),
          _buildCabinPorts(context),
        ],
        const SizedBox(height: 16),
        _buildFixRecords(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Object? _resolveDetail() {
    if (deviceType == 1) return state.batteryDetail;
    if (deviceType == 2) return state.vehicleDetail;
    return state.cabinetDetail;
  }

  Widget _buildBatteryDetail(BuildContext context, BatteryDetail detail) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deviceDetailBatteryBaseInfoTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    detail.deviceSn ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _statusChip(
                  label: _onlineLabel(l10n, detail.online),
                  color: detail.online == 1
                      ? const Color(0xFF00B88A)
                      : const Color(0xFFBDBDBD),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(l10n.deviceDetailSoc, _formatValue(detail.soc)),
            _infoRow(l10n.deviceDetailCycle, _formatValue(detail.cycle)),
            _infoRow(l10n.deviceDetailMile, _formatValue(detail.mile)),
            _infoRow(
              l10n.deviceDetailTodayMile,
              _formatValue(detail.todayMile),
            ),
            _infoRow(l10n.deviceDetailAvgSpeed, _formatValue(detail.avgSpeed)),
            _infoRow(l10n.deviceDetailSignalTime, _formatValue(detail.signalTime)),
            _infoRow(
              l10n.deviceDetailStatus,
              _dischargeLabel(l10n, detail.status),
            ),
            _infoRow(
              l10n.deviceDetailLocation,
              _formatLocation(detail.latitude, detail.longitude),
            ),
            const SizedBox(height: 12),
            if (detail.deviceSn != null &&
                detail.deviceSn!.isNotEmpty &&
                detail.latitude != null &&
                detail.longitude != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _openLocation(context, detail),
                  child: Text(l10n.deviceDetailViewMap),
                ),
              ),
            if (detail.deviceSn != null &&
                detail.deviceSn!.isNotEmpty &&
                detail.latitude != null &&
                detail.longitude != null)
              const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _toggleDischarge(context),
                child: Text(l10n.deviceDetailToggleDischarge),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetail(BuildContext context, VehicleDetail detail) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deviceDetailVehicleBaseInfoTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _infoRow(l10n.deviceDetailSnLabel, _formatValue(detail.sn)),
            _infoRow(l10n.deviceDetailVinLabel, _formatValue(detail.vin)),
            _infoRow(
              l10n.deviceDetailCarNumberLabel,
              _formatValue(detail.carNumber),
            ),
            _infoRow(
              l10n.deviceDetailModelLabel,
              _formatValue(detail.model ?? detail.carModel),
            ),
            _infoRow(
              l10n.deviceDetailSpecLabel,
              _formatValue(detail.spec ?? detail.carSpec),
            ),
            _infoRow(
              l10n.deviceDetailLocation,
              _formatLocation(detail.latitude, detail.longitude),
            ),
            _infoRow(l10n.deviceDetailMile, _formatValue(detail.mile)),
            _infoRow(
              l10n.deviceDetailBatterySnLabel,
              _formatValue(detail.batterySn),
            ),
            _infoRow(
              l10n.deviceDetailMotorNumberLabel,
              _formatValue(detail.motorNumber),
            ),
            _infoRow(
              l10n.deviceDetailControllerSnLabel,
              _formatValue(detail.controllerSn),
            ),
            _infoRow(
              l10n.deviceDetailOwnerLabel,
              _formatValue(detail.ownerName),
            ),
            _infoRow(l10n.deviceDetailPhoneLabel, _formatValue(detail.phone)),
          ],
        ),
      ),
    );
  }

  Widget _buildCabinetDetail(
    BuildContext context,
    CabinetDetailBaseInfoBean detail,
  ) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deviceDetailCabinetBaseInfoTitle,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _infoRow(
              l10n.deviceDetailStationNameLabel,
              _formatValue(detail.stationName),
            ),
            _infoRow(
              l10n.deviceDetailSnLabel,
              _formatValue(detail.stationSn),
            ),
            _infoRow(
              l10n.deviceDetailModelLabel,
              _formatValue(detail.stationModel),
            ),
            _infoRow(
              l10n.deviceDetailSpecLabel,
              _formatValue(detail.stationSpec),
            ),
            _infoRow(
              l10n.deviceDetailStationAddressLabel,
              _formatValue(detail.stationAddress ?? detail.address),
            ),
            _infoRow(
              l10n.deviceDetailStationStatusLabel,
              _formatValue(detail.stationStatus),
            ),
            _infoRow(
              l10n.deviceDetailStationOnlineLabel,
              _formatValue(detail.online ?? detail.showOnlineStatus),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openBackDoor(context),
                child: Text(l10n.deviceDetailCabinOpenBackDoor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeHistory(BuildContext context) {
    final l10n = context.l10n;
    final histories = state.histories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceDetailChargeHistoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (state.historyLoading)
          const Center(child: CircularProgressIndicator())
        else if (histories.isEmpty)
          _DeviceDetailEmpty(text: l10n.deviceDetailChargeHistoryEmpty)
        else
          ...histories.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.date ?? '-'),
                subtitle: Text(
                  '${l10n.deviceDetailChargeValue}: '
                  '${item.chargeValue ?? '-'}\n'
                  '${l10n.deviceDetailChargeTime}: '
                  '${item.chargeTime ?? '-'}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFixRecords(BuildContext context) {
    final l10n = context.l10n;
    final records = state.fixRecords;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceDetailFixRecordsTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (state.fixLoading)
          const Center(child: CircularProgressIndicator())
        else if (records.isEmpty)
          _DeviceDetailEmpty(text: l10n.deviceDetailFixRecordsEmpty)
        else
          ...records.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.itemName ?? '-'),
                subtitle: Text(
                  '${l10n.deviceDetailFixResultLabel}: '
                  '${item.result ?? '-'}\n'
                  '${l10n.deviceDetailFixManLabel}: '
                  '${item.fixMan ?? '-'}\n'
                  '${l10n.deviceDetailFixRemarkLabel}: '
                  '${item.remark ?? '-'}\n'
                  '${l10n.deviceDetailFixTimeLabel}: '
                  '${_formatValue(item.createTime)}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMaintenanceRecords(BuildContext context) {
    final l10n = context.l10n;
    final records = state.maintenanceRecords;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceDetailMaintenanceTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (state.maintenanceLoading)
          const Center(child: CircularProgressIndicator())
        else if (records.isEmpty)
          _DeviceDetailEmpty(text: l10n.deviceDetailMaintenanceEmpty)
        else
          ...records.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.itemName ?? '-'),
                subtitle: Text(
                  '${l10n.deviceDetailMaintenanceUserLabel}: '
                  '${item.username ?? '-'}\n'
                  '${l10n.deviceDetailMaintenanceLogLabel}: '
                  '${item.log ?? '-'}\n'
                  '${l10n.deviceDetailMaintenanceTimeLabel}: '
                  '${_formatValue(item.createTime)}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCabinPorts(BuildContext context) {
    final l10n = context.l10n;
    final ports = state.cabinPorts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.deviceDetailCabinPortTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (state.portsLoading)
          const Center(child: CircularProgressIndicator())
        else if (ports.isEmpty)
          _DeviceDetailEmpty(text: l10n.deviceDetailCabinPortEmpty)
        else
          ...ports.map((port) => _buildCabinPortCard(context, port)),
      ],
    );
  }

  Widget _buildCabinPortCard(BuildContext context, Cabin port) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        title: Text(
          '${l10n.deviceDetailPortNoLabel}: ${_formatValue(port.portNo)}',
        ),
        subtitle: Text(
          '${l10n.deviceDetailPortNameLabel}: ${_formatValue(port.portName)}\n'
          '${l10n.deviceDetailCabinBatterySn}: ${_formatValue(port.batterySn)}\n'
          '${l10n.deviceDetailCabinSoc}: ${_formatValue(port.batterySoc)}\n'
          '${l10n.deviceDetailCabinPortStatus}: ${_formatValue(port.status)}\n'
          '${l10n.deviceDetailDoorStatusLabel}: ${_formatValue(port.doorStatus)}\n'
          '${l10n.deviceDetailLockStatusLabel}: ${_formatValue(port.lockStatus)}\n'
          '${l10n.deviceDetailChargeStatusLabel}: ${_formatValue(port.chargeStatus)}\n'
          '${l10n.deviceDetailVoltageLabel}: ${_formatValue(port.voltage)}\n'
          '${l10n.deviceDetailTemperatureLabel}: ${_formatValue(port.temperature)}',
        ),
        trailing: OutlinedButton(
          onPressed: () => _openCabinDoor(context, port.portNo),
          child: Text(l10n.deviceDetailCabinOpenDoor),
        ),
      ),
    );
  }

  Future<void> _toggleDischarge(BuildContext context) async {
    final l10n = context.l10n;
    final success = await notifier.toggleDischargeStatus();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.deviceDetailToggleSuccess : l10n.deviceDetailToggleFailed,
        ),
      ),
    );
  }

  Future<void> _openCabinDoor(BuildContext context, int? port) async {
    final l10n = context.l10n;
    if (port == null) return;
    final success = await notifier.openCabinDoor(port: port);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.deviceDetailCabinOpenDoorSuccess
              : l10n.deviceDetailCabinOpenDoorFailed,
        ),
      ),
    );
  }

  Future<void> _openBackDoor(BuildContext context) async {
    final l10n = context.l10n;
    final success = await notifier.openCabinBackDoor();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? l10n.deviceDetailCabinOpenBackDoorSuccess
              : l10n.deviceDetailCabinOpenBackDoorFailed,
        ),
      ),
    );
  }

  void _openLocation(BuildContext context, BatteryDetail detail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BatteryLocationPage(
          initialSn: detail.deviceSn ?? '',
        ),
      ),
    );
  }

  String _formatValue(Object? value) {
    if (value == null) return '-';
    final result = value.toString();
    return result.isEmpty ? '-' : result;
  }

  String _formatLocation(double? lat, double? lng) {
    if (lat == null || lng == null) return '-';
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  String _onlineLabel(AppLocalizations l10n, int? online) {
    return online == 1 ? l10n.deviceDetailOnline : l10n.deviceDetailOffline;
  }

  String _dischargeLabel(AppLocalizations l10n, int? status) {
    return status == 1
        ? l10n.deviceDetailDischargeOn
        : l10n.deviceDetailDischargeOff;
  }
}

class _DeviceDetailEmpty extends StatelessWidget {
  const _DeviceDetailEmpty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_empty_record.png',
            width: 160,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

Widget _statusChip({required String label, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, color: color),
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
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
