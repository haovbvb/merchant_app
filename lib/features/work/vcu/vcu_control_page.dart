import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/bluetooth_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/date_format_utils.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/vcu_history.dart';
import 'package:merchant_app/data/models/vcu_version.dart';
import 'package:merchant_app/features/work/vcu/vcu_ble_command.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';
import 'package:merchant_app/features/work/vcu/vcu_ota_util.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VcuControlPage extends ConsumerStatefulWidget {
  const VcuControlPage({
    super.key,
    this.initialVin,
    this.initialCtrlId,
    this.initialSn,
    this.initialOnline = false,
  });

  final String? initialVin;
  final String? initialCtrlId;
  final String? initialSn;
  final bool initialOnline;

  @override
  ConsumerState<VcuControlPage> createState() => _VcuControlPageState();
}

class _VcuControlPageState extends ConsumerState<VcuControlPage>
    with WidgetsBindingObserver {
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _ctrlIdController = TextEditingController();
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _apnController = TextEditingController();
  final TextEditingController _gpsFrequencyController = TextEditingController();
  final TextEditingController _dataFrequencyController =
      TextEditingController();

  static final Guid _serviceUuid = Guid('00001802-0000-1000-8000-00805F9B34FB');
  static final Guid _readUuid = Guid('00002a06-0000-1000-8000-00805F9B34FB');
  static final Guid _writeUuid = Guid('00002a06-0000-1000-8000-00805F9B34FB');

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  BluetoothDevice? _bleDevice;
  BluetoothCharacteristic? _writeChar;
  bool _bleEnabled = true;
  bool _connecting = false;
  bool _bleConnected = false;
  bool _manualDisconnect = false;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  final Queue<String> _bleQueue = Queue<String>();
  bool _bleSending = false;
  final Map<int, String> _pendingTxnLabels = {};
  final Map<int, String?> _pendingTxnVersions = {};
  final List<String> _bleLogs = [];
  Timer? _scanTimeoutTimer;
  Timer? _reconnectTimer;
  bool _otaDownloading = false;
  double _otaDownloadProgress = 0;
  bool _otaInProgress = false;
  String? _otaStatus;
  String? _otaVersionName;
  String? _mcuVersion;
  String? _platformLabel;
  late bool _isOnline4g;
  String? _apnValue;
  String? _gpsValue;
  String? _dataValue;
  int _otaTotalSegments = 0;
  int _otaCurrentSegment = 0;
  int? _otaVerifyTxnNo;
  int? _otaDataTxnNo;
  List<String> _otaSegments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isOnline4g = widget.initialOnline;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(vcuProvider.notifier).loadVersions();
    });
    if (widget.initialVin != null && widget.initialVin!.isNotEmpty) {
      _vinController.text = widget.initialVin!;
    }
    if (widget.initialCtrlId != null && widget.initialCtrlId!.isNotEmpty) {
      _ctrlIdController.text = widget.initialCtrlId!;
    }
    if (widget.initialSn != null && widget.initialSn!.isNotEmpty) {
      _snController.text = widget.initialSn!;
    }
    _restoreBleSwitch();
    _scanSub = FlutterBluePlus.scanResults.listen(_handleScanResults);
    _isScanningSub = FlutterBluePlus.isScanning.listen((value) {
      if (!mounted) return;
      setState(() => _connecting = value);
    });
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      setState(() => _adapterState = state);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vinController.dispose();
    _ctrlIdController.dispose();
    _snController.dispose();
    _apnController.dispose();
    _gpsFrequencyController.dispose();
    _dataFrequencyController.dispose();
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _adapterSub?.cancel();
    _notifySub?.cancel();
    _connectionSub?.cancel();
    _scanTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _disconnectBle(manual: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restoreBleSwitch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(vcuProvider);
    final notifier = ref.read(vcuProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(title: Text(l10n.vcuControlTitle)),
        body: Column(
          children: [
            _buildTopHeader(),
            Container(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: TabBar(
                indicatorColor: AppColors.primaryColor,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: const Color(0xE6000000),
                unselectedLabelColor: const Color(0x66000000),
                tabs: [
                  Tab(text: l10n.vcuControlTab),
                  Tab(text: l10n.vcuHistoryTab),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildControlTab(context, state, notifier),
                  _buildHistoryTab(context, state, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    final ctrlId = _ctrlIdController.text.trim();
    final deviceInfo = ctrlId.isEmpty ? '-' : 'SN:$ctrlId';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/android/mipmap-xxhdpi/icon_devicedetail_topbg.webp',
                ),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Image.asset(
                    'assets/android/mipmap-xxhdpi/img_vcu.png',
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.memory,
                      color: Color(0xFF999999),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deviceInfo,
                        style: const TextStyle(
                          fontSize: 19,
                          color: Color(0xE60C0C0D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStatusTag(
                            text: '4G',
                            icon: Icons.wifi,
                            selected: _isOnline4g,
                          ),
                          const SizedBox(width: 6),
                          _buildStatusTag(
                            text: 'BT',
                            icon: Icons.bluetooth,
                            selected: _bleConnected,
                          ),
                        ],
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

  Widget _buildStatusTag({
    required String text,
    required IconData icon,
    required bool selected,
  }) {
    final foreground = selected
        ? const Color(0xFF08983B)
        : const Color(0x80FA4332);
    final border = selected ? const Color(0xFF08983B) : const Color(0xFFFA4332);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 2),
          Text(text, style: TextStyle(fontSize: 13, color: foreground)),
        ],
      ),
    );
  }

  Widget _buildControlTab(
    BuildContext context,
    VcuState state,
    VcuNotifier notifier,
  ) {
    final l10n = context.l10n;
    final commands = _buildVcuCommands(l10n);
    final platformOptions = _buildPlatformOptions(l10n);
    return RefreshIndicator(
      onRefresh: () async {
        await notifier.loadVersions();
        _getNewData(notifier);
      },
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _CardSection(
            child: Column(
              children: [
                _InfoRow(
                  title: l10n.vcuDeviceSnLabel,
                  value: _snController.text.trim().isEmpty
                      ? '-'
                      : _snController.text.trim(),
                ),
                const Divider(height: 1),
                _InfoRow(
                  title: l10n.vcuBluetoothLabel,
                  value: _connecting
                      ? l10n.vcuBleConnecting
                      : _bleConnected
                      ? l10n.vcuBleConnected
                      : l10n.vcuBleDisconnected,
                  trailing: Switch.adaptive(
                    value: _bleEnabled,
                    onChanged: (value) async {
                      setState(() => _bleEnabled = value);
                      await _persistBleSwitch(value);
                      if (!value) {
                        await _disconnectBle(manual: true);
                        _stopBleScan();
                      } else if (_ctrlIdController.text.trim().isNotEmpty) {
                        _startBleConnect();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CardSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CardTitle(title: l10n.vcuControlSectionTitle),
                const SizedBox(height: 8),
                _CommandGrid(
                  commands: commands,
                  onTap: (command) => _sendQuick(context, notifier, command),
                  disabled: state.sending,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CardSection(
            child: Column(
              children: [
                _CardTitle(title: l10n.vcuConfigSectionTitle),
                _ActionRow(
                  title: l10n.vcuPlatformAddressLabel,
                  value: _platformLabel ?? l10n.vcuPleaseSelect,
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () => _confirmPlatform(platformOptions.first, notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: 'APN',
                  value: _apnValue ?? l10n.vcuNotSet,
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () => _confirmApn(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: l10n.vcuGpsFrequencyLabel,
                  value: _gpsValue == null
                      ? l10n.vcuNotSet
                      : '${_gpsValue!} ${l10n.vcuSecondUnit}',
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () => _confirmGpsFrequency(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: l10n.vcuVehicleUploadFrequencyLabel,
                  value: _dataValue == null
                      ? l10n.vcuNotSet
                      : '${_dataValue!} ${l10n.vcuSecondUnit}',
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () => _confirmDataFrequency(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: 'OTA',
                  value: _mcuVersion ?? '-',
                  onTap: !_bleConnected || _otaDownloading || _otaInProgress
                      ? null
                      : () => _confirmBleOta(
                          state.versions.isNotEmpty
                              ? state.versions.first
                              : const VcuVersion(),
                          notifier,
                        ),
                ),
                if (_otaDownloading ||
                    _otaInProgress ||
                    _otaStatus != null) ...[
                  const SizedBox(height: 8),
                  if (_otaDownloading)
                    LinearProgressIndicator(value: _otaDownloadProgress)
                  else if (_otaInProgress)
                    LinearProgressIndicator(
                      value: _otaTotalSegments == 0
                          ? null
                          : _otaCurrentSegment / _otaTotalSegments,
                    ),
                  const SizedBox(height: 6),
                  if (_otaDownloading)
                    Text(
                      l10n.vcuOtaDownloadingProgress(
                        (100 * _otaDownloadProgress).toStringAsFixed(0),
                      ),
                    )
                  else if (_otaInProgress)
                    Text(
                      l10n.vcuOtaUpgradingProgress(
                        _otaCurrentSegment,
                        _otaTotalSegments,
                        _otaVersionName ?? '',
                      ),
                    )
                  else if (_otaStatus != null)
                    Text(_otaStatus!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    VcuState state,
    VcuNotifier notifier,
  ) {
    final l10n = context.l10n;
    final filtered = _filterHistory(state);
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
          child: Row(
            children: [
              Expanded(
                child: _buildHistoryFilterButton(
                  label: l10n.vcuHistoryFilterAll,
                  selected: state.historyFilter == VcuHistoryFilter.all,
                  onTap: () => notifier.setHistoryFilter(VcuHistoryFilter.all),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHistoryFilterButton(
                  label: l10n.vcuHistoryFilterRequest,
                  selected: state.historyFilter == VcuHistoryFilter.request,
                  onTap: () =>
                      notifier.setHistoryFilter(VcuHistoryFilter.request),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildHistoryFilterButton(
                  label: l10n.vcuHistoryFilterResponse,
                  selected: state.historyFilter == VcuHistoryFilter.response,
                  onTap: () =>
                      notifier.setHistoryFilter(VcuHistoryFilter.response),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l10n.vcuHistoryEmpty))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildHistoryItemCard(context, filtered[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppColors.primaryColor : const Color(0xFFE6E6E6),
          ),
          color: selected ? AppColors.primaryColor : Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : const Color(0xCC000000),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItemCard(BuildContext context, VcuHistoryItem item) {
    final l10n = context.l10n;
    final isRequest = item.type == VcuHistoryType.request;
    final channel = _historyChannel(item.command);
    final isBle = channel == 'BLE';
    final payload = (item.data ?? '').trim();
    final statusText = item.type == VcuHistoryType.response
        ? (item.success == true
              ? l10n.vcuHistoryStatusSuccess
              : l10n.vcuHistoryStatusFailed)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                isRequest
                    ? 'assets/android/mipmap-xxhdpi/icon_request.png'
                    : 'assets/android/mipmap-xxhdpi/icon_response.png',
                width: 14,
                height: 14,
                errorBuilder: (_, __, ___) => Icon(
                  isRequest
                      ? Icons.call_made_rounded
                      : Icons.call_received_rounded,
                  size: 16,
                  color: isRequest
                      ? AppColors.primaryColor
                      : const Color(0xFFFA4332),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isRequest
                    ? l10n.vcuHistoryFilterRequest
                    : l10n.vcuHistoryFilterResponse,
                style: TextStyle(
                  fontSize: 12,
                  color: isRequest
                      ? AppColors.primaryColor
                      : const Color(0xFFFA4332),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                isBle
                    ? 'assets/android/mipmap-xxhdpi/icon_ble.png'
                    : 'assets/android/mipmap-xxhdpi/icon_wifi.png',
                width: 14,
                height: 14,
                errorBuilder: (_, __, ___) => Icon(
                  isBle ? Icons.bluetooth : Icons.wifi,
                  size: 14,
                  color: const Color(0x99000000),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                channel ?? 'NET',
                style: const TextStyle(fontSize: 12, color: Color(0x99000000)),
              ),
              const Spacer(),
              Text(
                DateFormatUtils.formatTimestamp(
                  item.timestamp,
                  pattern: 'yyyy-MM-dd HH:mm:ss',
                ),
                style: const TextStyle(fontSize: 11, color: Color(0x66000000)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _historyCommand(item.command),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xE6000000),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.vin,
            style: const TextStyle(fontSize: 12, color: Color(0x99000000)),
          ),
          if (statusText != null) ...[
            const SizedBox(height: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusText == l10n.vcuHistoryStatusSuccess
                    ? AppColors.primaryColor
                    : const Color(0xFFFA4332),
              ),
            ),
          ],
          if (payload.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              payload,
              style: const TextStyle(fontSize: 12, color: Color(0xCC000000)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  List<VcuHistoryItem> _filterHistory(VcuState state) {
    switch (state.historyFilter) {
      case VcuHistoryFilter.request:
        return state.history
            .where((item) => item.type == VcuHistoryType.request)
            .toList();
      case VcuHistoryFilter.response:
        return state.history
            .where((item) => item.type == VcuHistoryType.response)
            .toList();
      case VcuHistoryFilter.all:
        return state.history;
    }
  }

  Future<void> _sendQuick(
    BuildContext context,
    VcuNotifier notifier,
    _VcuCommand command,
  ) async {
    final l10n = context.l10n;
    final devId = _snController.text.trim();
    if (devId.isEmpty) {
      showToast(l10n.vcuSendFailed);
      return;
    }
    final canBle = _bleEnabled && _bleConnected && command.bleId != null;
    final channel = await _showCtrlDialog(
      title: command.label,
      icon: command.icon,
      canBle: canBle,
      canNet: true,
    );
    if (channel == null || !context.mounted) return;
    if (channel == _CtrlChannel.ble && command.bleId != null) {
      final cmdData = VcuBleCommandBuilder.build(
        params: [VcuBleCommandParam(command.bleId!, command.bleValue ?? 1)],
      );
      _sendBle(cmdData, notifier);
      if (!context.mounted) return;
      showToast(l10n.vcuSendSuccess);
      return;
    }
    final ok = await notifier.sendCommand(
      devId: devId,
      cmd: command.cmd,
      label: 'NET ${command.label}',
      deviceSn: _snController.text.trim(),
    );
    if (!context.mounted) return;
    showToast(ok ? l10n.vcuSendSuccess : l10n.vcuSendFailed);
  }

  Future<void> _startBleConnect() async {
    final l10n = context.l10n;
    final ctrlId = _ctrlIdController.text.trim();
    if (ctrlId.isEmpty) {
      showToast(l10n.vcuSendFailed);
      return;
    }
    _manualDisconnect = false;
    final permission = await ensureBluetoothPermission();
    if (!permission.granted) {
      showToast(l10n.vcuBlePermissionNotGranted);
      return;
    }
    if (_adapterState != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
    }
    setState(() => _connecting = true);
    showToast(l10n.vcuBleScanStarted);
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = Timer(const Duration(seconds: 31), () {
      if (!_bleConnected && _bleEnabled) {
        showToast(l10n.vcuBleScanTimeout);
        _scheduleReconnect();
      }
    });
  }

  void _handleScanResults(List<ScanResult> results) {
    if (!_bleEnabled || _bleConnected) return;
    final ctrlId = _ctrlIdController.text.trim();
    if (ctrlId.isEmpty) return;
    for (final result in results) {
      final name = result.device.name;
      if (name == ctrlId) {
        FlutterBluePlus.stopScan();
        _connectDevice(result.device);
        break;
      }
    }
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    final l10n = context.l10n;
    try {
      showToast(l10n.vcuBleConnecting);
      await device.connect(timeout: const Duration(seconds: 12));
      _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleBleDisconnected();
        }
      });
      _scanTimeoutTimer?.cancel();
      final services = await device.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => services.first,
      );
      final writeChar = service.characteristics.firstWhere(
        (c) => c.uuid == _writeUuid,
        orElse: () => service.characteristics.first,
      );
      final notifyChar = service.characteristics.firstWhere(
        (c) => c.uuid == _readUuid,
        orElse: () => service.characteristics.first,
      );
      await notifyChar.setNotifyValue(true);
      _notifySub?.cancel();
      _notifySub = notifyChar.onValueReceived.listen((data) {
        final text = utf8.decode(data, allowMalformed: true);
        _handleBleNotify(text, ref.read(vcuProvider.notifier));
      });
      setState(() {
        _bleDevice = device;
        _writeChar = writeChar;
        _bleConnected = true;
        _connecting = false;
        _bleLogs.insert(0, l10n.vcuBleConnectedWithId(device.remoteId.str));
      });
      showToast(l10n.vcuBleConnected);
      _getNewData(ref.read(vcuProvider.notifier));
    } catch (e) {
      setState(() {
        _bleConnected = false;
        _connecting = false;
      });
      showToast(l10n.vcuBleConnectFailed);
      _scheduleReconnect();
    }
  }

  Future<void> _disconnectBle({bool manual = false}) async {
    _manualDisconnect = manual;
    _reconnectTimer?.cancel();
    try {
      await _bleDevice?.disconnect();
    } catch (_) {}
    setState(() {
      _bleDevice = null;
      _writeChar = null;
      _bleConnected = false;
      _bleSending = false;
      _bleQueue.clear();
      _connecting = false;
    });
  }

  void _stopBleScan() {
    _scanTimeoutTimer?.cancel();
    FlutterBluePlus.stopScan();
  }

  void _handleBleDisconnected() {
    final l10n = context.l10n;
    if (!mounted) return;
    _notifySub?.cancel();
    _connectionSub?.cancel();
    setState(() {
      _bleDevice = null;
      _writeChar = null;
      _bleConnected = false;
      _bleSending = false;
      _bleQueue.clear();
      _connecting = false;
      _bleLogs.insert(0, l10n.vcuBleDisconnectedLog);
    });
    showToast(l10n.vcuBleDisconnected);
    if (_otaInProgress) {
      _resetOtaState(l10n.vcuOtaStoppedByBleDisconnect);
    }
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_manualDisconnect || !_bleEnabled) return;
    final ctrlId = _ctrlIdController.text.trim();
    if (ctrlId.isEmpty) return;
    _reconnectTimer = Timer(const Duration(seconds: 10), () {
      if (!_bleConnected && _bleEnabled && mounted) {
        _startBleConnect();
      }
    });
  }

  Future<void> _restoreBleSwitch() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(StorageKeys.vcuBleEnabled) ?? true;
    if (!mounted) return;
    setState(() => _bleEnabled = enabled);
    if (enabled && _ctrlIdController.text.trim().isNotEmpty) {
      _startBleConnect();
    }
  }

  Future<void> _persistBleSwitch(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.vcuBleEnabled, enabled);
  }

  void _sendBle(VcuBleCommand command, VcuNotifier notifier) {
    final label = _buildBleLabel(command);
    final version = _extractBleVersion(command);
    _pendingTxnLabels[command.txnNo] = label;
    _pendingTxnVersions[command.txnNo] = version;
    notifier.addHistory(
      VcuHistoryItem(
        vin: _bleHistoryVin(),
        command: label,
        data: command.payload,
        type: VcuHistoryType.request,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        version: version,
      ),
    );
    _enqueueBle(command.payload);
  }

  void _enqueueBle(String payload) {
    if (_bleSending) {
      _bleQueue.add(payload);
      return;
    }
    _writeBle(payload);
  }

  Future<void> _writeBle(String payload) async {
    final char = _writeChar;
    if (char == null) return;
    _bleSending = true;
    try {
      await char.write(utf8.encode(payload), withoutResponse: false);
    } catch (_) {
      _bleSending = false;
    }
    if (_bleQueue.isNotEmpty) {
      final next = _bleQueue.removeFirst();
      await _writeBle(next);
    } else {
      _bleSending = false;
    }
  }

  void _handleBleNotify(String data, VcuNotifier notifier) {
    final l10n = context.l10n;
    if (data.trim().isEmpty) return;
    _bleLogs.insert(0, l10n.vcuBleReceivedData(data));
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {}
    final txnNo = json?['txnNo'] is num
        ? (json?['txnNo'] as num).toInt()
        : null;
    final label = txnNo != null ? _pendingTxnLabels.remove(txnNo) : null;
    final version = txnNo != null ? _pendingTxnVersions.remove(txnNo) : null;
    bool? success;
    final resultValue = json?['result'] ?? json?['b_result'];
    if (resultValue is num) {
      success = resultValue.toInt() == 1;
    }
    if (label != null || success != null) {
      notifier.addHistory(
        VcuHistoryItem(
          vin: _bleHistoryVin(),
          command:
              label ?? '${l10n.vcuBleChannel} ${l10n.vcuHistoryFilterResponse}',
          data: data,
          type: VcuHistoryType.response,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: success,
          version: version,
        ),
      );
    }
    final isCommonAck = json?['result'] is num && json?['attrList'] == null;
    if (isCommonAck == true && success == true) {
      showToast(l10n.vcuSettingSuccess);
    }
    _handleOtaAck(json, txnNo, notifier);
    _handleAttrAck(json);
    if (mounted) {
      setState(() {});
    }
  }

  void _handleOtaAck(
    Map<String, dynamic>? json,
    int? txnNo,
    VcuNotifier notifier,
  ) {
    final l10n = context.l10n;
    if (txnNo != null && txnNo == _otaVerifyTxnNo) {
      final resultValue = json?['b_result'] ?? json?['result'];
      final result = resultValue is num ? resultValue.toInt() : null;
      if (result == 1) {
        setState(() {
          _otaStatus = l10n.vcuOtaVerifyPassAndStart;
          _otaInProgress = true;
        });
        _sendNextOtaData(notifier);
      } else {
        final msg = result == 2
            ? l10n.vcuOtaRejectVersionTooLow
            : l10n.vcuOtaVerifyFailed;
        showToast(msg);
        _resetOtaState(msg);
      }
      return;
    }
    if (txnNo != null && txnNo == _otaDataTxnNo) {
      final resultValue = json?['b_result'] ?? json?['result'];
      final result = resultValue is num ? resultValue.toInt() : null;
      if (result == 1) {
        _sendNextOtaData(notifier);
      } else {
        showToast(l10n.vcuOtaDataSendFailed);
        _resetOtaState(l10n.vcuOtaFailed);
      }
    }
  }

  void _handleAttrAck(Map<String, dynamic>? json) {
    final l10n = context.l10n;
    final attrList = json?['attrList'];
    if (attrList is! List) return;
    for (final item in attrList) {
      if (item is! Map) continue;
      final id = item['id']?.toString();
      final value = item['value'];
      if (id == VcuBleUpDataIds.otaResult) {
        final ok = value is num ? value.toInt() == 1 : false;
        showToast(ok ? l10n.vcuOtaUpgradeSuccess : l10n.vcuOtaUpgradeFailed);
        if (ok) {
          _finishOta(l10n.vcuOtaUpgradeSuccess);
        } else {
          _resetOtaState(l10n.vcuOtaUpgradeFailed);
        }
      }
      if (id == VcuBleUpDataIds.verifyResult) {
        final ok = value is num ? value.toInt() == 1 : false;
        if (!ok) {
          showToast(l10n.vcuOtaVerifyFailed);
          _resetOtaState(l10n.vcuOtaVerifyFailed);
        }
      }
      if (id == VcuBleUpDataIds.mcuVersion) {
        setState(() => _mcuVersion = value?.toString() ?? '-');
      }
    }
  }

  void _sendApn(VcuNotifier notifier) {
    final input = _apnController.text.trim();
    if (input.isEmpty) return;
    setState(() => _apnValue = input);
    final cmd = VcuBleCommandBuilder.build(
      params: [VcuBleCommandParam(VcuBleCommandIds.editApn, input)],
    );
    _sendBle(cmd, notifier);
  }

  void _sendGpsFrequency(VcuNotifier notifier) {
    final input = int.tryParse(_gpsFrequencyController.text.trim());
    if (input == null) return;
    setState(() => _gpsValue = input.toString());
    final frequency = input * 100;
    final cmd = VcuBleCommandBuilder.build(
      params: [
        VcuBleCommandParam(VcuBleCommandIds.editFrequencyGps, frequency),
      ],
    );
    _sendBle(cmd, notifier);
  }

  void _sendDataFrequency(VcuNotifier notifier) {
    final input = int.tryParse(_dataFrequencyController.text.trim());
    if (input == null) return;
    setState(() => _dataValue = input.toString());
    final frequency = input * 100;
    final cmd = VcuBleCommandBuilder.build(
      params: [
        VcuBleCommandParam(VcuBleCommandIds.editFrequencyVehicle, frequency),
        VcuBleCommandParam(VcuBleCommandIds.editFrequencyVehicle1, frequency),
      ],
    );
    _sendBle(cmd, notifier);
  }

  void _sendPlatform(_VcuPlatformOption option, VcuNotifier notifier) {
    setState(() => _platformLabel = option.label);
    final cmd = VcuBleCommandBuilder.build(
      params: [
        VcuBleCommandParam(VcuBleCommandIds.editUrl, option.host),
        VcuBleCommandParam(VcuBleCommandIds.editPort, option.port),
      ],
    );
    _sendBle(cmd, notifier);
  }

  void _getNewData(VcuNotifier notifier) {
    if (!_bleConnected) return;
    final queryVer = VcuBleCommandBuilder.build(
      params: [VcuBleCommandParam(VcuBleCommandIds.queryMcuVersion, 1)],
    );
    _sendBle(queryVer, notifier);
    final queryIccid = VcuBleCommandBuilder.build(
      params: [VcuBleCommandParam(VcuBleCommandIds.queryIccid, 0)],
    );
    _sendBle(queryIccid, notifier);
  }

  Future<void> _startBleOta(VcuVersion version, VcuNotifier notifier) async {
    final l10n = context.l10n;
    if (!_bleConnected) {
      showToast(l10n.vcuPleaseConnectBleFirst);
      return;
    }
    final versionName = version.name ?? version.version ?? version.url ?? 'OTA';
    final file = await _downloadOtaFile(versionName, version.url);
    if (file == null) return;

    final segments = await VcuOtaUtil.buildOtaSegments(file);
    if (segments.isEmpty) {
      showToast(l10n.vcuOtaFileEmpty);
      return;
    }
    setState(() {
      _otaSegments = segments;
      _otaTotalSegments = segments.length;
      _otaCurrentSegment = 0;
      _otaInProgress = true;
      _otaVersionName = versionName;
      _otaStatus = l10n.vcuOtaVerifying;
    });
    final txnNo = DateTime.now().millisecondsSinceEpoch;
    _otaVerifyTxnNo = txnNo;
    final cmd = VcuBleCommandBuilder.build(
      txnNo: txnNo,
      params: [
        VcuBleCommandParam(VcuBleCommandIds.otaVerifyVersion, versionName),
        VcuBleCommandParam(VcuBleCommandIds.otaUpgrade, 1),
      ],
    );
    _sendBle(cmd, notifier);
  }

  Future<File?> _downloadOtaFile(String name, String? url) async {
    final l10n = context.l10n;
    if (url == null || url.isEmpty) {
      showToast(l10n.vcuOtaUrlEmpty);
      return null;
    }
    final dir = await getTemporaryDirectory();
    final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${dir.path}/$safeName.bin');
    if (await file.exists()) {
      setState(() => _otaStatus = l10n.vcuOtaUsingCachedPackage);
      return file;
    }
    setState(() {
      _otaDownloading = true;
      _otaDownloadProgress = 0;
      _otaStatus = l10n.vcuOtaStartDownload;
    });
    try {
      final dio = Dio();
      await dio.download(
        url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _otaDownloadProgress = received / total;
            });
          }
        },
      );
      if (mounted) {
        setState(() => _otaStatus = l10n.vcuOtaDownloadCompleted);
      }
      return file;
    } catch (_) {
      showToast(l10n.vcuOtaDownloadFailed);
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _otaDownloading = false;
        });
      }
    }
  }

  void _sendNextOtaData(VcuNotifier notifier) {
    final l10n = context.l10n;
    if (!_bleConnected) {
      _resetOtaState(l10n.vcuOtaStoppedByBleDisconnect);
      return;
    }
    if (_otaSegments.isEmpty) return;
    if (_otaCurrentSegment >= _otaSegments.length) {
      setState(() {
        _otaStatus = l10n.vcuOtaDataSentWaitingResult;
      });
      return;
    }
    final data = _otaSegments[_otaCurrentSegment];
    _otaCurrentSegment += 1;
    final txnNo = DateTime.now().millisecondsSinceEpoch;
    _otaDataTxnNo = txnNo;
    final cmd = VcuBleCommandBuilder.build(
      txnNo: txnNo,
      params: [VcuBleCommandParam(VcuBleCommandIds.otaData, data)],
    );
    _sendBle(cmd, notifier);
    setState(() {
      _otaStatus = l10n.vcuOtaSendingData;
    });
  }

  void _resetOtaState(String message) {
    if (!mounted) return;
    setState(() {
      _otaInProgress = false;
      _otaStatus = message;
      _otaVerifyTxnNo = null;
      _otaDataTxnNo = null;
      _otaCurrentSegment = 0;
      _otaTotalSegments = 0;
      _otaSegments = [];
    });
  }

  void _finishOta(String message) {
    if (!mounted) return;
    setState(() {
      _otaInProgress = false;
      _otaStatus = message;
      _otaVerifyTxnNo = null;
      _otaDataTxnNo = null;
    });
  }

  Future<_CtrlChannel?> _showCtrlDialog({
    required String title,
    required IconData icon,
    required bool canBle,
    required bool canNet,
  }) async {
    final l10n = context.l10n;
    return showModalBottomSheet<_CtrlChannel>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        var selected = canBle ? _CtrlChannel.ble : _CtrlChannel.network;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogTitle(
                    icon: icon,
                    title: title,
                    subtitle: l10n.vcuChooseSendMethod,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('BLE'),
                        selected: selected == _CtrlChannel.ble,
                        onSelected: canBle
                            ? (value) {
                                if (!value) return;
                                setSheetState(() {
                                  selected = _CtrlChannel.ble;
                                });
                              }
                            : null,
                      ),
                      ChoiceChip(
                        label: Text(l10n.vcuChannel4gNetwork),
                        selected: selected == _CtrlChannel.network,
                        onSelected: canNet
                            ? (value) {
                                if (!value) return;
                                setSheetState(() {
                                  selected = _CtrlChannel.network;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, selected),
                          child: Text(l10n.vcuSendButton),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<T?> _showListSheet<T>({
    required String title,
    required IconData icon,
    required List<T> items,
    required String Function(T item) titleBuilder,
    String? Function(T item)? subtitleBuilder,
    int initialIndex = 0,
  }) async {
    final l10n = context.l10n;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        var selectedIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogTitle(icon: icon, title: title),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final subtitle = subtitleBuilder == null
                            ? null
                            : subtitleBuilder(item);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(titleBuilder(item)),
                          subtitle: subtitle == null ? null : Text(subtitle),
                          selected: selectedIndex == index,
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.06),
                          trailing: Icon(
                            selectedIndex == index
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                          ),
                          onTap: () => setSheetState(() {
                            selectedIndex = index;
                          }),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, items[selectedIndex]),
                          child: Text(l10n.vcuSendButton),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _showInputSheet({
    required String title,
    required IconData icon,
    required String hint,
    String? unit,
    bool numeric = false,
  }) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogTitle(icon: icon, title: title),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: numeric
                        ? TextInputType.number
                        : TextInputType.text,
                    decoration: InputDecoration(
                      hintText: hint,
                      suffixText: unit,
                      suffixIcon: controller.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.clear();
                                setSheetState(() {});
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (_) => setSheetState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final value = controller.text.trim();
                            if (value.isEmpty) {
                              showToast(l10n.vcuPleaseEnterValidValue);
                              return;
                            }
                            if (numeric) {
                              final numValue = int.tryParse(value);
                              if (numValue == null ||
                                  numValue <= 0 ||
                                  numValue > 65535) {
                                showToast(l10n.vcuPleaseEnterRange1To65535);
                                return;
                              }
                            }
                            Navigator.pop(context, value);
                          },
                          child: Text(l10n.vcuSendButton),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _confirmPlatform(
    _VcuPlatformOption option,
    VcuNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final platformOptions = _buildPlatformOptions(l10n);
    if (!(_bleEnabled && _bleConnected)) return;
    final selectedIndex = platformOptions.indexOf(option);
    final selected = await _showListSheet<_VcuPlatformOption>(
      title: l10n.vcuSetPlatformTitle,
      icon: Icons.cloud_done_outlined,
      items: platformOptions,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      titleBuilder: (item) => item.label,
      subtitleBuilder: (item) => '${item.host}:${item.port}',
    );
    if (selected == null) return;
    _sendPlatform(selected, notifier);
  }

  Future<void> _confirmApn(VcuNotifier notifier) async {
    final l10n = context.l10n;
    final value = await _showInputSheet(
      title: l10n.vcuSetApnTitle,
      icon: Icons.settings_input_antenna,
      hint: l10n.vcuInputApnHint,
    );
    if (value == null) return;
    _apnController.text = value;
    _sendApn(notifier);
  }

  Future<void> _confirmGpsFrequency(VcuNotifier notifier) async {
    final l10n = context.l10n;
    final value = await _showInputSheet(
      title: l10n.vcuSetGpsFrequencyTitle,
      icon: Icons.gps_fixed,
      hint: l10n.vcuInputGpsFrequencyHint,
      unit: l10n.vcuSecondUnit,
      numeric: true,
    );
    if (value == null) return;
    _gpsFrequencyController.text = value;
    _sendGpsFrequency(notifier);
  }

  Future<void> _confirmDataFrequency(VcuNotifier notifier) async {
    final l10n = context.l10n;
    final value = await _showInputSheet(
      title: l10n.vcuSetVehicleUploadFrequencyTitle,
      icon: Icons.cloud_upload_outlined,
      hint: l10n.vcuInputVehicleUploadFrequencyHint,
      unit: l10n.vcuSecondUnit,
      numeric: true,
    );
    if (value == null) return;
    _dataFrequencyController.text = value;
    _sendDataFrequency(notifier);
  }

  Future<void> _confirmBleOta(VcuVersion version, VcuNotifier notifier) async {
    final l10n = context.l10n;
    final versions = ref.read(vcuProvider).versions;
    if (versions.isEmpty) {
      showToast(l10n.vcuPleaseLoadVersionsFirst);
      return;
    }
    final selectedIndex = versions.indexOf(version);
    final selected = await _showListSheet<VcuVersion>(
      title: 'OTA',
      icon: Icons.system_update_alt,
      items: versions,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      titleBuilder: (item) => item.version ?? item.name ?? '-',
      subtitleBuilder: (item) => item.url,
    );
    if (selected == null) return;
    await _startBleOta(selected, notifier);
  }

  String _bleHistoryVin() {
    final ctrlId = _ctrlIdController.text.trim();
    if (ctrlId.isNotEmpty) return ctrlId;
    return _snController.text.trim();
  }

  String _buildBleLabel(VcuBleCommand command) {
    final l10n = context.l10n;
    if (command.params.isNotEmpty) {
      final base = _bleCommandNameById(command.params.first.id);
      if (base != null && base.isNotEmpty) {
        return '${l10n.vcuBleChannel} $base';
      }
    }
    return '${l10n.vcuBleChannel} ${l10n.vcuBleCommandGeneric}';
  }

  String? _bleCommandNameById(String id) {
    final l10n = context.l10n;
    switch (id) {
      case VcuBleCommandIds.lock:
        return l10n.vcuCmdLock;
      case VcuBleCommandIds.launch:
        return l10n.vcuCmdLaunch;
      case VcuBleCommandIds.antiTheft:
        return l10n.vcuCmdAntiTheft;
      case VcuBleCommandIds.find:
        return l10n.vcuCmdFind;
      case VcuBleCommandIds.remoteLock:
        return l10n.vcuCmdRemoteLock;
      case VcuBleCommandIds.remoteUnlock:
        return l10n.vcuCmdRemoteUnlock;
      case VcuBleCommandIds.queryStatus:
        return l10n.vcuCmdQueryVehicleStatus;
      case VcuBleCommandIds.queryMcuVersion:
        return l10n.vcuCmdQueryMcuVersion;
      case VcuBleCommandIds.otaVerifyVersion:
        return l10n.vcuCmdOtaVerifyVersion;
      case VcuBleCommandIds.otaUpgrade:
        return l10n.vcuCmdOtaUpgrade;
      case VcuBleCommandIds.otaData:
        return l10n.vcuCmdOtaDataPacket;
      case VcuBleCommandIds.queryIccid:
        return l10n.vcuCmdQueryIccid;
      case VcuBleCommandIds.editUrl:
        return l10n.vcuCmdSetPlatformUrl;
      case VcuBleCommandIds.editPort:
        return l10n.vcuCmdSetPlatformPort;
      case VcuBleCommandIds.editApn:
        return l10n.vcuCmdSetApn;
      case VcuBleCommandIds.editFrequencyVehicle:
      case VcuBleCommandIds.editFrequencyVehicle1:
        return l10n.vcuCmdSetVehicleUploadFrequency;
      case VcuBleCommandIds.editFrequencyGps:
        return l10n.vcuCmdSetGpsFrequency;
      default:
        return null;
    }
  }

  String? _extractBleVersion(VcuBleCommand command) {
    for (final param in command.params) {
      if (param.id == VcuBleCommandIds.otaVerifyVersion) {
        return param.value.toString();
      }
    }
    return null;
  }

  String? _historyChannel(String command) {
    final l10n = context.l10n;
    if (command.startsWith('BLE ')) return l10n.vcuBleChannel;
    if (command.startsWith('NET ')) return l10n.vcuNetworkChannel;
    return null;
  }

  String _historyCommand(String command) {
    if (command.startsWith('BLE ')) return command.substring(4);
    if (command.startsWith('NET ')) return command.substring(4);
    return command;
  }
}

enum _CtrlChannel { network, ble }

class _CardSection extends StatelessWidget {
  const _CardSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.08),
        ),
      ),
      child: child,
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xE60C0C0D),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value, this.trailing});

  final String title;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 54),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 17,
                    color: const Color(0xE60C0C0D),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0x800C0C0D),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.title, required this.value, this.onTap});

  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 10,
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xE60C0C0D)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.isEmpty ? '-' : value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0x800C0C0D)),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right),
        ],
      ),
      enabled: onTap != null,
      onTap: onTap,
    );
  }
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CommandGrid extends StatelessWidget {
  const _CommandGrid({
    required this.commands,
    required this.onTap,
    required this.disabled,
  });

  final List<_VcuCommand> commands;
  final ValueChanged<_VcuCommand> onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: 24,
          children: commands
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: disabled ? null : () => onTap(item),
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: const Color(0x800C0C0D),
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _VcuCommand {
  final int cmd;
  final String label;
  final String? bleId;
  final Object? bleValue;
  final IconData icon;

  const _VcuCommand(
    this.cmd,
    this.label, {
    this.bleId,
    this.bleValue,
    required this.icon,
  });
}

List<_VcuCommand> _buildVcuCommands(AppLocalizations l10n) => [
  _VcuCommand(
    2,
    l10n.vcuCmdLaunch,
    bleId: VcuBleCommandIds.launch,
    bleValue: 1,
    icon: Icons.flash_on,
  ),
  _VcuCommand(
    1,
    l10n.vcuCmdLock,
    bleId: VcuBleCommandIds.lock,
    bleValue: 1,
    icon: Icons.lock,
  ),
  _VcuCommand(
    3,
    l10n.vcuCmdAntiTheft,
    bleId: VcuBleCommandIds.antiTheft,
    bleValue: 1,
    icon: Icons.security,
  ),
  _VcuCommand(
    4,
    l10n.vcuCmdFind,
    bleId: VcuBleCommandIds.find,
    bleValue: 1,
    icon: Icons.search,
  ),
  _VcuCommand(
    5,
    l10n.vcuCmdRemoteLock,
    bleId: VcuBleCommandIds.remoteLock,
    bleValue: 1,
    icon: Icons.lock_clock,
  ),
  _VcuCommand(
    7,
    l10n.vcuCmdRemoteUnlock,
    bleId: VcuBleCommandIds.remoteUnlock,
    bleValue: 1,
    icon: Icons.lock_open,
  ),
];

class _VcuPlatformOption {
  final String label;
  final String host;
  final int port;

  const _VcuPlatformOption({
    required this.label,
    required this.host,
    required this.port,
  });
}

List<_VcuPlatformOption> _buildPlatformOptions(AppLocalizations l10n) => [
  _VcuPlatformOption(
    label: l10n.vcuPlatformProduction,
    host: 'okla-irontower-controller-netty.esquare-global.com',
    port: 9401,
  ),
  _VcuPlatformOption(
    label: l10n.vcuPlatformTesting,
    host: 't-ov-irontower-controller-netty2.esquare-global.com',
    port: 9001,
  ),
];
