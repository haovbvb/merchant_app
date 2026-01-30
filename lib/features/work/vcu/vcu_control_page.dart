import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/storage_keys.dart';
import 'package:merchant_app/core/utils/bluetooth_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/vcu_history.dart';
import 'package:merchant_app/data/models/vcu_version.dart';
import 'package:merchant_app/features/work/vcu/vcu_ble_command.dart';
import 'package:merchant_app/features/work/vcu/vcu_controller.dart';
import 'package:merchant_app/features/work/vcu/vcu_ota_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VcuControlPage extends ConsumerStatefulWidget {
  const VcuControlPage({
    super.key,
    this.initialVin,
    this.initialCtrlId,
    this.initialSn,
  });

  final String? initialVin;
  final String? initialCtrlId;
  final String? initialSn;

  @override
  ConsumerState<VcuControlPage> createState() => _VcuControlPageState();
}

class _VcuControlPageState extends ConsumerState<VcuControlPage> {
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _ctrlIdController = TextEditingController();
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _apnController = TextEditingController();
  final TextEditingController _gpsFrequencyController = TextEditingController();
  final TextEditingController _dataFrequencyController =
      TextEditingController();
  final DateFormat _timeFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

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
    _restoreBleSwitch();
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(vcuProvider);
    final notifier = ref.read(vcuProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: AppBar(
          title: Text(l10n.vcuControlTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.vcuControlTab),
              Tab(text: l10n.vcuHistoryTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildControlTab(context, state, notifier),
            _buildHistoryTab(context, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildControlTab(
    BuildContext context,
    VcuState state,
    VcuNotifier notifier,
  ) {
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
                  title: '车辆 SN',
                  value: _snController.text.trim().isEmpty
                      ? '-'
                      : _snController.text.trim(),
                ),
                const Divider(height: 1),
                _InfoRow(
                  title: '蓝牙',
                  value: _bleConnected ? '已连接' : '未连接',
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
                  subtitle: _adapterState.name,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _bleEnabled && !_bleConnected && !_connecting
                            ? _startBleConnect
                            : null,
                        child: Text(_connecting ? '连接中...' : '连接设备'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _bleConnected
                            ? () => _disconnectBle(manual: true)
                            : null,
                        child: const Text('断开连接'),
                      ),
                    ),
                  ],
                ),
                if (_bleLogs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ..._bleLogs.take(2).map((line) => Text(line)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _CardSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _CardTitle(title: 'VCU 控制'),
                const SizedBox(height: 8),
                _CommandGrid(
                  commands: _commands,
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
                const _CardTitle(title: 'VCU 配置'),
                _ActionRow(
                  title: '平台地址',
                  value: _platformLabel ?? '请选择',
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () =>
                            _confirmPlatform(_platformOptions.first, notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: 'APN',
                  value: _apnValue ?? '未设置',
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () => _confirmApn(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: 'GPS 查询频率',
                  value: _gpsValue == null ? '未设置' : '${_gpsValue!} 秒',
                  onTap: !_bleEnabled || !_bleConnected || state.sending
                      ? null
                      : () => _confirmGpsFrequency(notifier),
                ),
                const Divider(height: 1),
                _ActionRow(
                  title: '车辆上传频率',
                  value: _dataValue == null ? '未设置' : '${_dataValue!} 秒',
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
                      '下载中 ${(100 * _otaDownloadProgress).toStringAsFixed(0)}%',
                    )
                  else if (_otaInProgress)
                    Text(
                      '升级中 $_otaCurrentSegment/$_otaTotalSegments ${_otaVersionName ?? ''}',
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.vcuHistoryFilterAll),
                selected: state.historyFilter == VcuHistoryFilter.all,
                onSelected: (_) =>
                    notifier.setHistoryFilter(VcuHistoryFilter.all),
              ),
              ChoiceChip(
                label: Text(l10n.vcuHistoryFilterRequest),
                selected: state.historyFilter == VcuHistoryFilter.request,
                onSelected: (_) =>
                    notifier.setHistoryFilter(VcuHistoryFilter.request),
              ),
              ChoiceChip(
                label: Text(l10n.vcuHistoryFilterResponse),
                selected: state.historyFilter == VcuHistoryFilter.response,
                onSelected: (_) =>
                    notifier.setHistoryFilter(VcuHistoryFilter.response),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(l10n.vcuHistoryEmpty))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.15),
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isRequest = item.type == VcuHistoryType.request;
                    final channel = _historyChannel(item.command);
                    final displayCommand = _historyCommand(item.command);
                    final statusText = item.type == VcuHistoryType.response
                        ? (item.success == true
                              ? l10n.vcuHistoryStatusSuccess
                              : l10n.vcuHistoryStatusFailed)
                        : null;
                    final info = [
                      item.vin,
                      if (item.version != null && item.version!.isNotEmpty)
                        item.version!,
                    ].join(' · ');
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              (isRequest
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.tertiary)
                                  .withOpacity(0.12),
                          child: Icon(
                            isRequest
                                ? Icons.upload_rounded
                                : Icons.download_rounded,
                            color: isRequest
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
                            size: 18,
                          ),
                        ),
                        title: Text(displayCommand),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (channel != null)
                                  _HistoryBadge(
                                    text: channel,
                                    color: channel == 'BLE'
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                  ),
                                if (statusText != null)
                                  _HistoryBadge(
                                    text: statusText,
                                    color:
                                        statusText ==
                                            l10n.vcuHistoryStatusSuccess
                                        ? AppColors.primaryColor
                                        : Colors.redAccent,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(info),
                          ],
                        ),
                        trailing: Text(
                          _timeFormatter.format(
                            DateTime.fromMillisecondsSinceEpoch(item.timestamp),
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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
      showToast('蓝牙权限未开启');
      return;
    }
    if (_adapterState != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
    }
    setState(() => _connecting = true);
    showToast('开始扫描');
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 30));
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = Timer(const Duration(seconds: 31), () {
      if (!_bleConnected && _bleEnabled) {
        showToast('扫描超时');
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
    try {
      showToast('开始连接');
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
        _bleLogs.insert(0, '已连接 BLE: ${device.remoteId}');
      });
      showToast('已连接');
      _getNewData(ref.read(vcuProvider.notifier));
    } catch (e) {
      setState(() {
        _bleConnected = false;
        _connecting = false;
      });
      showToast('BLE 连接失败');
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
      _bleLogs.insert(0, 'BLE 已断开');
    });
    showToast('已断开');
    if (_otaInProgress) {
      _resetOtaState('BLE 断开，OTA 已停止');
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
    if (data.trim().isEmpty) return;
    _bleLogs.insert(0, 'BLE 收到: $data');
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
          command: label ?? 'BLE 响应',
          type: VcuHistoryType.response,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          success: success,
          version: version,
        ),
      );
    }
    final isCommonAck = json?['result'] is num && json?['attrList'] == null;
    if (isCommonAck == true && success == true) {
      showToast('设置成功');
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
    if (txnNo != null && txnNo == _otaVerifyTxnNo) {
      final resultValue = json?['b_result'] ?? json?['result'];
      final result = resultValue is num ? resultValue.toInt() : null;
      if (result == 1) {
        setState(() {
          _otaStatus = '校验通过，开始升级';
          _otaInProgress = true;
        });
        _sendNextOtaData(notifier);
      } else {
        final msg = result == 2 ? '版本过低，拒绝升级' : '校验失败';
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
        showToast('OTA 数据发送失败');
        _resetOtaState('OTA 失败');
      }
    }
  }

  void _handleAttrAck(Map<String, dynamic>? json) {
    final attrList = json?['attrList'];
    if (attrList is! List) return;
    for (final item in attrList) {
      if (item is! Map) continue;
      final id = item['id']?.toString();
      final value = item['value'];
      if (id == VcuBleUpDataIds.otaResult) {
        final ok = value is num ? value.toInt() == 1 : false;
        showToast(ok ? 'OTA 升级完成' : 'OTA 升级失败');
        if (ok) {
          _finishOta('OTA 升级完成');
        } else {
          _resetOtaState('OTA 升级失败');
        }
      }
      if (id == VcuBleUpDataIds.verifyResult) {
        final ok = value is num ? value.toInt() == 1 : false;
        if (!ok) {
          showToast('OTA 校验失败');
          _resetOtaState('OTA 校验失败');
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
    if (!_bleConnected) {
      showToast('请先连接 BLE');
      return;
    }
    final versionName = version.name ?? version.version ?? version.url ?? 'OTA';
    final file = await _downloadOtaFile(versionName, version.url);
    if (file == null) return;

    final segments = await VcuOtaUtil.buildOtaSegments(file);
    if (segments.isEmpty) {
      showToast('OTA 文件为空');
      return;
    }
    setState(() {
      _otaSegments = segments;
      _otaTotalSegments = segments.length;
      _otaCurrentSegment = 0;
      _otaInProgress = true;
      _otaVersionName = versionName;
      _otaStatus = '版本校验中';
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
    if (url == null || url.isEmpty) {
      showToast('OTA 地址为空');
      return null;
    }
    final dir = await getTemporaryDirectory();
    final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File('${dir.path}/$safeName.bin');
    if (await file.exists()) {
      setState(() => _otaStatus = '已使用缓存包');
      return file;
    }
    setState(() {
      _otaDownloading = true;
      _otaDownloadProgress = 0;
      _otaStatus = '开始下载 OTA';
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
        setState(() => _otaStatus = '下载完成');
      }
      return file;
    } catch (_) {
      showToast('OTA 下载失败');
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
    if (!_bleConnected) {
      _resetOtaState('BLE 断开，OTA 已停止');
      return;
    }
    if (_otaSegments.isEmpty) return;
    if (_otaCurrentSegment >= _otaSegments.length) {
      setState(() {
        _otaStatus = 'OTA 数据发送完成，等待结果';
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
      _otaStatus = '发送 OTA 数据中';
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
                  _DialogTitle(icon: icon, title: title, subtitle: '请选择下发方式'),
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
                        label: const Text('4G/网络'),
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
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, selected),
                          child: const Text('发送'),
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
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.pop(context, items[selectedIndex]),
                          child: const Text('发送'),
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
                          child: const Text('取消'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final value = controller.text.trim();
                            if (value.isEmpty) {
                              showToast('请输入有效数据');
                              return;
                            }
                            if (numeric) {
                              final numValue = int.tryParse(value);
                              if (numValue == null ||
                                  numValue <= 0 ||
                                  numValue > 65535) {
                                showToast('请输入 1-65535');
                                return;
                              }
                            }
                            Navigator.pop(context, value);
                          },
                          child: const Text('发送'),
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
    if (!(_bleEnabled && _bleConnected)) return;
    final selectedIndex = _platformOptions.indexOf(option);
    final selected = await _showListSheet<_VcuPlatformOption>(
      title: '设置平台',
      icon: Icons.cloud_done_outlined,
      items: _platformOptions,
      initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      titleBuilder: (item) => item.label,
      subtitleBuilder: (item) => '${item.host}:${item.port}',
    );
    if (selected == null) return;
    _sendPlatform(selected, notifier);
  }

  Future<void> _confirmApn(VcuNotifier notifier) async {
    final value = await _showInputSheet(
      title: '设置 APN',
      icon: Icons.settings_input_antenna,
      hint: '请输入 APN',
    );
    if (value == null) return;
    _apnController.text = value;
    _sendApn(notifier);
  }

  Future<void> _confirmGpsFrequency(VcuNotifier notifier) async {
    final value = await _showInputSheet(
      title: '设置 GPS 频率',
      icon: Icons.gps_fixed,
      hint: '请输入 GPS 频率',
      unit: '秒',
      numeric: true,
    );
    if (value == null) return;
    _gpsFrequencyController.text = value;
    _sendGpsFrequency(notifier);
  }

  Future<void> _confirmDataFrequency(VcuNotifier notifier) async {
    final value = await _showInputSheet(
      title: '设置车辆上传频率',
      icon: Icons.cloud_upload_outlined,
      hint: '请输入车辆上传频率',
      unit: '秒',
      numeric: true,
    );
    if (value == null) return;
    _dataFrequencyController.text = value;
    _sendDataFrequency(notifier);
  }

  Future<void> _confirmBleOta(VcuVersion version, VcuNotifier notifier) async {
    final versions = ref.read(vcuProvider).versions;
    if (versions.isEmpty) {
      showToast('请先获取版本列表');
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
    if (command.params.isNotEmpty) {
      final base = vcuBleIdToLabel[command.params.first.id];
      if (base != null && base.isNotEmpty) {
        return 'BLE $base';
      }
    }
    return 'BLE 指令';
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
    if (command.startsWith('BLE ')) return 'BLE';
    if (command.startsWith('NET ')) return '网络';
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
  const _InfoRow({
    required this.title,
    required this.value,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String value;
  final String? subtitle;
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
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
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

class _HistoryBadge extends StatelessWidget {
  const _HistoryBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
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

const List<_VcuCommand> _commands = [
  _VcuCommand(
    2,
    '一键启动',
    bleId: VcuBleCommandIds.launch,
    bleValue: 1,
    icon: Icons.flash_on,
  ),
  _VcuCommand(
    1,
    '一键锁车',
    bleId: VcuBleCommandIds.lock,
    bleValue: 1,
    icon: Icons.lock,
  ),
  _VcuCommand(
    3,
    '防盗模式',
    bleId: VcuBleCommandIds.antiTheft,
    bleValue: 1,
    icon: Icons.security,
  ),
  _VcuCommand(
    4,
    '一键找车',
    bleId: VcuBleCommandIds.find,
    bleValue: 1,
    icon: Icons.search,
  ),
  _VcuCommand(
    5,
    '远程锁车',
    bleId: VcuBleCommandIds.remoteLock,
    bleValue: 1,
    icon: Icons.lock_clock,
  ),
  _VcuCommand(
    7,
    '远程解锁',
    bleId: VcuBleCommandIds.remoteUnlock,
    bleValue: 1,
    icon: Icons.lock_open,
  ),
  _VcuCommand(
    109,
    '查询车辆状态',
    bleId: VcuBleCommandIds.queryStatus,
    bleValue: 1,
    icon: Icons.directions_car,
  ),
  _VcuCommand(
    101,
    '查询 MCU 版本',
    bleId: VcuBleCommandIds.queryMcuVersion,
    bleValue: 1,
    icon: Icons.memory,
  ),
  _VcuCommand(
    104,
    '查询 ICCID',
    bleId: VcuBleCommandIds.queryIccid,
    bleValue: 1,
    icon: Icons.sim_card,
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

const List<_VcuPlatformOption> _platformOptions = [
  _VcuPlatformOption(
    label: '生产环境',
    host: 'okla-irontower-controller-netty.esquare-global.com',
    port: 9401,
  ),
  _VcuPlatformOption(
    label: '测试环境',
    host: 't-ov-irontower-controller-netty2.esquare-global.com',
    port: 9001,
  ),
];
