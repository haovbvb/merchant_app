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

  static final Guid _serviceUuidAndroid = Guid(
    '00001802-0000-1000-8000-00805F9B34FB',
  );
  static final Guid _readUuidAndroid = Guid('00002a06-0000-1000-8000-00805F9B34FB');
  static final Guid _writeUuidAndroid = Guid('00002a06-0000-1000-8000-00805F9B34FB');

  static final Guid _serviceUuidIos = Guid('1802');
  static final Guid _readUuidIos = Guid('2a06');
  static final Guid _writeUuidIos = Guid('2a06');

  Guid get _serviceUuid => Platform.isIOS ? _serviceUuidIos : _serviceUuidAndroid;
  Guid get _readUuid => Platform.isIOS ? _readUuidIos : _readUuidAndroid;
  Guid get _writeUuid => Platform.isIOS ? _writeUuidIos : _writeUuidAndroid;

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
        appBar: AppBar(title: Text(l10n.vcuControlTitle), centerTitle: true),
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
                            icon: _isOnline4g ? Icons.wifi : Icons.wifi_off,
                            selected: _isOnline4g,
                          ),
                          const SizedBox(width: 6),
                          _buildStatusTag(
                            text: 'BT',
                            icon: Icons.bluetooth,
                            iconAsset: _bleConnected
                                ? 'assets/images/icon_vcu_ble_online.png'
                                : 'assets/images/icon_vcu_ble_offline.png',
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
    String? iconAsset,
    required bool selected,
  }) {
    final foreground = selected
        ? const Color(0xFF08983B)
        : AppColors.secondaryColor;
    final border = selected
        ? const Color(0xFF08983B)
        : AppColors.secondaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null)
            Image.asset(
              iconAsset,
              width: 12,
              height: 12,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, size: 12, color: foreground),
            )
          else
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
                  value: _bluetoothStatusText(l10n),
                  trailing: Switch.adaptive(
                    value: _bleEnabled,
                    onChanged: (value) async {
                      setState(() => _bleEnabled = value);
                      await _persistBleSwitch(value);
                      if (!value) {
                        await _disconnectBle(manual: true);
                        await _stopBleScan();
                      } else if (_ctrlIdController.text.trim().isNotEmpty) {
                        await _startBleConnect();
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
                  value: _platformLabel ?? '',
                  onTap: state.sending
                      ? null
                      : () => _confirmPlatform(platformOptions.first, notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: 'APN',
                  value: _apnValue ?? '',
                  onTap: state.sending ? null : () => _confirmApn(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: l10n.vcuGpsFrequencyLabel,
                  value: _gpsValue == null
                      ? ''
                      : '${_gpsValue!} ${l10n.vcuSecondUnit}',
                  onTap: state.sending
                      ? null
                      : () => _confirmGpsFrequency(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: l10n.vcuVehicleUploadFrequencyLabel,
                  value: _dataValue == null
                      ? ''
                      : '${_dataValue!} ${l10n.vcuSecondUnit}',
                  onTap: state.sending
                      ? null
                      : () => _confirmDataFrequency(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: 'OTA',
                  value: _mcuVersion ?? '',
                  onTap: _otaDownloading || _otaInProgress
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
          color: const Color(0xFFF5F6F7),
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Row(
            children: [
              _buildHistoryFilterButton(
                label: l10n.vcuHistoryFilterAll,
                selected: state.historyFilter == VcuHistoryFilter.all,
                onTap: () => notifier.setHistoryFilter(VcuHistoryFilter.all),
              ),
              const SizedBox(width: 8),
              _buildHistoryFilterButton(
                label: l10n.vcuHistoryFilterResponse,
                selected: state.historyFilter == VcuHistoryFilter.response,
                onTap: () =>
                    notifier.setHistoryFilter(VcuHistoryFilter.response),
              ),
              const SizedBox(width: 8),
              _buildHistoryFilterButton(
                label: l10n.vcuHistoryFilterRequest,
                selected: state.historyFilter == VcuHistoryFilter.request,
                onTap: () =>
                    notifier.setHistoryFilter(VcuHistoryFilter.request),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF5F6F7),
            child: filtered.isEmpty
                ? Center(child: Text(l10n.vcuHistoryEmpty))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildHistoryItemCard(context, filtered[index]),
                  ),
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
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? const Color(0xFF08983B) : Colors.transparent,
          ),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: selected ? const Color(0xFF08983B) : const Color(0x99000000),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
                Image.asset(
                  isRequest
                      ? 'assets/android/mipmap-xxhdpi/icon_request.png'
                      : 'assets/android/mipmap-xxhdpi/icon_response.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => Icon(
                    isRequest
                        ? Icons.call_made_rounded
                        : Icons.call_received_rounded,
                    size: 20,
                    color: isRequest
                        ? const Color(0xFF08983B)
                        : const Color(0xFFFA4332),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isRequest
                      ? l10n.vcuHistoryFilterRequest
                      : l10n.vcuHistoryFilterResponse,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xE60C0C0D),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormatUtils.formatTimestamp(
                    item.timestamp,
                    pattern: 'M\u6708 dd,yyyy HH:mm:ss',
                  ),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0x66000000),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, thickness: 0.5, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset(
                isBle
                    ? 'assets/android/mipmap-xxhdpi/icon_ble.png'
                    : 'assets/android/mipmap-xxhdpi/icon_wifi.png',
                width: 16,
                height: 16,
                errorBuilder: (_, __, ___) => Icon(
                  isBle ? Icons.bluetooth : Icons.wifi,
                  size: 16,
                  color: const Color(0x99000000),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _historyCommand(item.command),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xE60C0C0D),
                  ),
                ),
              ),
            ],
          ),
          if (payload.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              payload,
              style: const TextStyle(fontSize: 14, color: Color(0x99000000)),
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
    final channel = await _showCtrlDialog(
      title: command.label,
      iconAsset: command.iconAsset,
    );
    if (channel == null || !context.mounted) return;
    if (channel == _CtrlChannel.ble && command.bleId != null) {
      final cmdData = VcuBleCommandBuilder.build(
        params: [VcuBleCommandParam(command.bleId!, command.bleValue ?? 1)],
      );
      final ok = _sendBle(cmdData, notifier);
      if (!context.mounted) return;
      if (!ok) {
        showToast(l10n.vcuSendFailed);
      }
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
    final bluetoothEnabled = await _isBluetoothEnabled();
    if (!bluetoothEnabled) {
      showToast(l10n.vcuBleConnectFailed);
      _scheduleReconnect();
      return;
    }
    if (_adapterState != BluetoothAdapterState.on && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        showToast(l10n.vcuBleConnectFailed);
        _scheduleReconnect();
        return;
      }
    }
    setState(() => _connecting = true);
    showToast(l10n.vcuBleScanStarted);
    try {
      await _stopBleScan();
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 30),
        androidUsesFineLocation: true,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _connecting = false);
      showToast(l10n.vcuBleConnectFailed);
      _scheduleReconnect();
      return;
    }
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = Timer(const Duration(seconds: 31), () {
      if (!_bleConnected && _bleEnabled) {
        showToast(l10n.vcuBleScanTimeout);
        _scheduleReconnect();
      }
    });
  }

  Future<void> _handleScanResults(List<ScanResult> results) async {
    if (!_bleEnabled || _bleConnected) return;
    final ctrlId = _ctrlIdController.text.trim();
    if (ctrlId.isEmpty) return;
    for (final result in results) {
      final platformName = result.device.platformName.trim();
      final advName = result.advertisementData.advName.trim();
      final deviceName = platformName.isNotEmpty ? platformName : advName;
      final remoteId = result.device.remoteId.str.trim();
      if (_isTargetBleDevice(
        targetCtrlId: ctrlId,
        platformName: deviceName,
        advName: advName,
        remoteId: remoteId,
      )) {
        await _stopBleScan();
        await _connectDevice(result.device);
        break;
      }
    }
  }

  Future<bool> _isBluetoothEnabled() async {
    try {
      final state = await FlutterBluePlus.adapterState
          .firstWhere((s) => s != BluetoothAdapterState.unknown)
          .timeout(const Duration(seconds: 2));
      return state == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  bool _isTargetBleDevice({
    required String targetCtrlId,
    required String platformName,
    required String advName,
    required String remoteId,
  }) {
    final expected = targetCtrlId.trim().toLowerCase();
    if (expected.isEmpty) return false;
    return platformName.trim().toLowerCase() == expected ||
        advName.trim().toLowerCase() == expected ||
        remoteId.trim().toLowerCase() == expected;
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    final l10n = context.l10n;
    try {
      showToast(l10n.vcuBleConnecting);
      await device.connect(timeout: const Duration(seconds: 30));
      _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleBleDisconnected();
        }
      });
      _scanTimeoutTimer?.cancel();

      try {
        await device.requestMtu(512).timeout(const Duration(seconds: 5));
      } catch (_) {}

      final services = await device.discoverServices();
      BluetoothCharacteristic? writeChar;
      BluetoothCharacteristic? notifyChar;
      for (final service in services) {
        if (service.uuid != _serviceUuid) continue;
        for (final char in service.characteristics) {
          if (char.uuid == _writeUuid) {
            writeChar ??= char;
          }
          if (char.uuid == _readUuid) {
            notifyChar ??= char;
          }
        }
      }
      if (writeChar == null || notifyChar == null) {
        throw StateError('BLE characteristics not found');
      }
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

  Future<void> _stopBleScan() async {
    _scanTimeoutTimer?.cancel();
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
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

  String _bluetoothStatusText(AppLocalizations l10n) {
    if (!_bleEnabled) return '-';
    if (_bleConnected) return l10n.vcuBleConnected;
    if (_connecting) return l10n.vcuBleConnecting;
    return l10n.vcuBleDisconnected;
  }

  bool _sendBle(VcuBleCommand command, VcuNotifier notifier) {
    if (!_bleConnected || _writeChar == null) {
      return false;
    }
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
    return true;
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
    final cmd = VcuBleCommandBuilder.build(
      params: [VcuBleCommandParam(VcuBleCommandIds.editApn, input)],
    );
    if (_sendBle(cmd, notifier)) {
      setState(() => _apnValue = input);
    }
  }

  void _sendGpsFrequency(VcuNotifier notifier) {
    final input = int.tryParse(_gpsFrequencyController.text.trim());
    if (input == null) return;
    final frequency = input * 100;
    final cmd = VcuBleCommandBuilder.build(
      params: [
        VcuBleCommandParam(VcuBleCommandIds.editFrequencyGps, frequency),
      ],
    );
    if (_sendBle(cmd, notifier)) {
      setState(() => _gpsValue = input.toString());
    }
  }

  void _sendDataFrequency(VcuNotifier notifier) {
    final input = int.tryParse(_dataFrequencyController.text.trim());
    if (input == null) return;
    final frequency = input * 100;
    final cmd = VcuBleCommandBuilder.build(
      params: [
        VcuBleCommandParam(VcuBleCommandIds.editFrequencyVehicle, frequency),
        VcuBleCommandParam(VcuBleCommandIds.editFrequencyVehicle1, frequency),
      ],
    );
    if (_sendBle(cmd, notifier)) {
      setState(() => _dataValue = input.toString());
    }
  }

  void _sendPlatform(_VcuPlatformOption option, VcuNotifier notifier) {
    final cmd = VcuBleCommandBuilder.build(
      params: [
        VcuBleCommandParam(VcuBleCommandIds.editUrl, option.host),
        VcuBleCommandParam(VcuBleCommandIds.editPort, option.port),
      ],
    );
    if (_sendBle(cmd, notifier)) {
      setState(() => _platformLabel = option.label);
    }
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
    required String iconAsset,
  }) async {
    final l10n = context.l10n;
    return showModalBottomSheet<_CtrlChannel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        var selected = _CtrlChannel.ble;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: EdgeInsets.fromLTRB(
                12,
                24,
                12,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    child: Image.asset(
                      iconAsset,
                      width: 54,
                      height: 54,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xE60C0C0D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.vcuChooseSendMethod,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0x66000000),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildChannelOption(
                          text: '4G',
                          selected: selected == _CtrlChannel.network,
                          onTap: () {
                            setSheetState(() {
                              selected = _CtrlChannel.network;
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 12, endIndent: 12),
                        _buildChannelOption(
                          text: l10n.vcuBluetoothLabel,
                          selected: selected == _CtrlChannel.ble,
                          onTap: () {
                            setSheetState(() {
                              selected = _CtrlChannel.ble;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide.none,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xE60C0C0D),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF12B34B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, selected),
                            child: Text(
                              l10n.vcuSendButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
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

  Widget _buildChannelOption({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 24,
              color: selected
                  ? const Color(0xFF12B34B)
                  : const Color(0xFFCCCCCC),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 15, color: Color(0xE6000000)),
            ),
          ],
        ),
      ),
    );
  }

  Future<T?> _showListSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T item) titleBuilder,
    String? Function(T item)? subtitleBuilder,
    int initialIndex = 0,
  }) async {
    final l10n = context.l10n;
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        var selectedIndex = initialIndex;
        if (items.isEmpty) {
          selectedIndex = -1;
        } else if (selectedIndex < 0 || selectedIndex >= items.length) {
          selectedIndex = 0;
        }
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: EdgeInsets.fromLTRB(
                12,
                0,
                12,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xE60C0C0D),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: items.isEmpty
                        ? const SizedBox(height: 50)
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 12,
                              endIndent: 12,
                            ),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final subtitle = subtitleBuilder == null
                                  ? null
                                  : subtitleBuilder(item);
                              final selected = selectedIndex == index;
                              return InkWell(
                                onTap: () => setSheetState(() {
                                  selectedIndex = index;
                                }),
                                child: SizedBox(
                                  height: subtitle == null ? 50 : 60,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Icon(
                                        selected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        size: 24,
                                        color: selected
                                            ? const Color(0xFF12B34B)
                                            : const Color(0xFFCCCCCC),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              titleBuilder(item),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Color(0xE6000000),
                                              ),
                                            ),
                                            if (subtitle != null)
                                              Text(
                                                subtitle,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0x800C0C0D),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide.none,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xE60C0C0D),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF12B34B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: items.isEmpty
                                ? null
                                : () => Navigator.pop(
                                    context,
                                    items[selectedIndex],
                                  ),
                            child: Text(
                              l10n.vcuSendButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
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
    required String hint,
    String? unit,
    bool numeric = false,
  }) async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F6F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: EdgeInsets.fromLTRB(
                12,
                0,
                12,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xE60C0C0D),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            keyboardType: numeric
                                ? TextInputType.number
                                : TextInputType.text,
                            decoration: InputDecoration(
                              hintText: hint,
                              hintStyle: const TextStyle(
                                color: Color(0x4D0C0C0D),
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xE60C0C0D),
                            ),
                            onChanged: (_) => setSheetState(() {}),
                          ),
                        ),
                        if (controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.cancel,
                              size: 20,
                              color: Color(0xFFBFBFBF),
                            ),
                            onPressed: () {
                              controller.clear();
                              setSheetState(() {});
                            },
                          ),
                        if (unit != null && unit.isNotEmpty)
                          Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xE60C0C0D),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide.none,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xE60C0C0D),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF12B34B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
                            child: Text(
                              l10n.vcuSendButton,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
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
    return result;
  }

  Future<void> _confirmPlatform(
    _VcuPlatformOption option,
    VcuNotifier notifier,
  ) async {
    final l10n = context.l10n;
    final platformOptions = _buildPlatformOptions(l10n);
    final selectedIndex = platformOptions.indexOf(option);
    final selected = await _showListSheet<_VcuPlatformOption>(
      title: l10n.vcuSetPlatformTitle,
      items: platformOptions,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      titleBuilder: (item) => item.label,
    );
    if (selected == null) return;
    _sendPlatform(selected, notifier);
  }

  Future<void> _confirmApn(VcuNotifier notifier) async {
    final l10n = context.l10n;
    final value = await _showInputSheet(
      title: l10n.vcuSetApnTitle,
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
      hint: l10n.vcuInputVehicleUploadFrequencyHint,
      unit: l10n.vcuSecondUnit,
      numeric: true,
    );
    if (value == null) return;
    _dataFrequencyController.text = value;
    _sendDataFrequency(notifier);
  }

  Future<void> _confirmBleOta(VcuVersion version, VcuNotifier notifier) async {
    final versions = ref.read(vcuProvider).versions;
    final selectedIndex = versions.indexOf(version);
    final selected = await _showListSheet<VcuVersion>(
      title: 'OTA',
      items: versions,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      titleBuilder: (item) => item.version ?? item.name ?? '-',
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
      case VcuBleCommandIds.reset:
        return l10n.vcuCmdReset;
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
              if (value.trim().isNotEmpty)
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
          if (value.trim().isNotEmpty)
            Text(
              value,
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
                        Image.asset(
                          item.iconAsset,
                          width: 58,
                          height: 58,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            item.icon,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
  final String iconAsset;
  final String? bleId;
  final Object? bleValue;
  final IconData icon;

  const _VcuCommand(
    this.cmd,
    this.label, {
    required this.iconAsset,
    this.bleId,
    this.bleValue,
    required this.icon,
  });
}

List<_VcuCommand> _buildVcuCommands(AppLocalizations l10n) => [
  _VcuCommand(
    2,
    l10n.vcuCmdLaunch,
    iconAsset: 'assets/images/icon_vcu_start.png',
    bleId: VcuBleCommandIds.launch,
    bleValue: 1,
    icon: Icons.flash_on,
  ),
  _VcuCommand(
    1,
    l10n.vcuCmdLock,
    iconAsset: 'assets/images/icon_vcu_lock.png',
    bleId: VcuBleCommandIds.lock,
    bleValue: 1,
    icon: Icons.lock,
  ),
  _VcuCommand(
    3,
    l10n.vcuCmdAntiTheft,
    iconAsset: 'assets/images/icon_vcu_anti.png',
    bleId: VcuBleCommandIds.antiTheft,
    bleValue: 1,
    icon: Icons.security,
  ),
  _VcuCommand(
    4,
    l10n.vcuCmdFind,
    iconAsset: 'assets/images/icon_vcu_findcar.png',
    bleId: VcuBleCommandIds.find,
    bleValue: 1,
    icon: Icons.search,
  ),
  _VcuCommand(
    5,
    l10n.vcuCmdRemoteLock,
    iconAsset: 'assets/images/icon_vcu_remotelock.png',
    bleId: VcuBleCommandIds.remoteLock,
    bleValue: 1,
    icon: Icons.lock_clock,
  ),
  _VcuCommand(
    7,
    l10n.vcuCmdRemoteUnlock,
    iconAsset: 'assets/images/icon_vcu_remoteunlock.png',
    bleId: VcuBleCommandIds.remoteUnlock,
    bleValue: 1,
    icon: Icons.lock_open,
  ),
  _VcuCommand(
    16,
    l10n.vcuCmdReset,
    iconAsset: 'assets/android/mipmap-xxhdpi/icon_flash.png',
    bleId: VcuBleCommandIds.reset,
    bleValue: 1,
    icon: Icons.restart_alt,
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
