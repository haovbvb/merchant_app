import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/constants/app_icons.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/hud.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/data/models/sn_bean.dart';
import 'package:merchant_app/features/login/models/auth_session.dart';
import 'package:merchant_app/features/work/bluetooth/ble_command.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_operate_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// 蓝牙授权入口页面 - Find Bluetooth key
class BluetoothAuthPage extends ConsumerStatefulWidget {
  const BluetoothAuthPage({super.key});

  @override
  ConsumerState<BluetoothAuthPage> createState() => _BluetoothAuthPageState();
}

class _BluetoothAuthPageState extends ConsumerState<BluetoothAuthPage> {
  static const int _scanTimeoutSeconds = 10;

  final List<ScanResult> _devices = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  Timer? _switchOnDelayTimer;
  BluetoothDevice? _connectingDevice;
  BluetoothDevice? _connectedDevice;
  bool _bluetoothOn = false;
  bool _systemBluetoothOn = false;
  bool _deviceConnected = false;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _initPageData();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _adapterSubscription?.cancel();
    _connectionSubscription?.cancel();
    _switchOnDelayTimer?.cancel();
    FlutterBluePlus.stopScan();
    _disconnectCurrentDevice();
    super.dispose();
  }

  Future<void> _initPageData() async {
    _adapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      if (!mounted) return;
      final isSystemOn = state == BluetoothAdapterState.on;
      setState(() {
        _systemBluetoothOn = isSystemOn;
        _bluetoothOn = isSystemOn;
        if (!isSystemOn) {
          _clearDevicesAndResetScanState();
        }
      });
      if (!isSystemOn) {
        FlutterBluePlus.stopScan();
      }
    });

    final state = await FlutterBluePlus.adapterState.first;
    if (!mounted) return;
    setState(() {
      _systemBluetoothOn = state == BluetoothAdapterState.on;
      _bluetoothOn = _systemBluetoothOn;
    });
    _onRefresh();
    await _checkPermissions();
  }

  Future<void> _toggleBluetooth(bool value) async {
    if (value) {
      setState(() => _bluetoothOn = true);
      if (Platform.isAndroid) {
        if (_androidSdkInt() >= 31) {
          final status = await Permission.bluetoothConnect.status;
          if (status.isGranted) {
            await FlutterBluePlus.turnOn();
          }
        } else {
          await FlutterBluePlus.turnOn();
        }
      }
      _switchOnDelayTimer?.cancel();
      _switchOnDelayTimer = Timer(const Duration(seconds: 2), () async {
        if (!mounted) return;
        _onRefresh();
        await _checkPermissions();
      });
    } else {
      await FlutterBluePlus.stopScan();
      await _disconnectCurrentDevice();
      setState(() {
        _bluetoothOn = false;
        _clearDevicesAndResetScanState();
      });
    }
  }

  int _androidSdkInt() {
    if (!Platform.isAndroid) return 0;
    final version = Platform.operatingSystemVersion;
    final sdkMatch = RegExp(r'SDK\s*(\d+)').firstMatch(version);
    if (sdkMatch != null) {
      return int.tryParse(sdkMatch.group(1) ?? '') ?? 0;
    }
    final apiMatch = RegExp(r'API\s*(\d+)').firstMatch(version);
    if (apiMatch != null) {
      return int.tryParse(apiMatch.group(1) ?? '') ?? 0;
    }
    return 0;
  }

  Future<void> _checkPermissions() async {
    final l10n = context.l10n;
    if (!_systemBluetoothOn) {
      showToast(l10n.bluetoothAuthPleaseOpenBluetooth);
      return;
    }

    if (!Platform.isAndroid) {
      await _onPermissionGranted();
      return;
    }

    if (_androidSdkInt() >= 31) {
      await _checkBluetoothPermission();
      return;
    }

    await _checkLocationPermission();
  }

  Future<void> _checkBluetoothPermission() async {
    final permissions = <Permission>[
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ];
    final deniedPermissions = <Permission>[];
    for (final permission in permissions) {
      final status = await permission.status;
      if (status.isGranted) {
        await _onPermissionGranted();
      } else {
        deniedPermissions.add(permission);
      }
    }

    if (deniedPermissions.isEmpty) {
      return;
    }

    final results = await deniedPermissions.request();
    var hasReject = false;
    for (final permission in deniedPermissions) {
      final status = results[permission] ?? PermissionStatus.denied;
      if (status.isGranted) {
        await _onPermissionGranted();
      } else {
        hasReject = true;
      }
    }

    if (deniedPermissions.length > 1 && hasReject && mounted) {
      await _showNearbyPermissionDialog();
    }
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      await _onPermissionGranted();
      return;
    }

    final result = await Permission.locationWhenInUse.request();
    if (result.isGranted) {
      await _onPermissionGranted();
    }
  }

  Future<void> _onPermissionGranted() async {
    final sdkInt = _androidSdkInt();
    final mustCheckGps = !Platform.isAndroid || sdkInt >= 23;
    if (mustCheckGps && !await _checkGpsIsOpen()) {
      if (!mounted) return;
      await _showGpsDialog();
      return;
    }
    _setScanRule();
    await _startScan();
  }

  Future<bool> _checkGpsIsOpen() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  Future<void> _showNearbyPermissionDialog() async {
    final l10n = context.l10n;
    final action = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.bluetoothPermissionTitle),
          content: Text(l10n.bluetoothPermissionDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.bluetoothOpenSettings),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (action == true) {
      await openAppSettings();
      if (!mounted) return;
      await _checkPermissions();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _showGpsDialog() async {
    final l10n = context.l10n;
    final action = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.bluetoothPermissionTitle),
          content: const Text('定位服务未开启，请先在系统设置中打开定位服务。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.bluetoothOpenSettings),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    if (action == true) {
      await Geolocator.openLocationSettings();
      if (!mounted) return;
      if (await _checkGpsIsOpen()) {
        _setScanRule();
        await _startScan();
      }
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _setScanRule() {
    // FlutterBluePlus does not expose a mutable scan rule object; timeout is set in startScan.
  }

  void _onRefresh() {
    if (!_bluetoothOn) return;
    _clearDevicesAndResetScanState();
  }

  void _clearDevicesAndResetScanState() {
    _devices.clear();
    _scanning = false;
  }

  Future<void> _startScan() async {
    if (_scanning || !_bluetoothOn || !_systemBluetoothOn) return;
    setState(() {
      _scanning = true;
      _devices.clear();
    });

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (!mounted) return;
      var changed = false;
      for (final item in results) {
        final name = item.device.platformName;
        if (name.isEmpty || (!name.contains('HWK') && !name.contains('HNT'))) {
          continue;
        }
        final exists = _devices.any(
          (d) => d.device.remoteId == item.device.remoteId,
        );
        if (!exists) {
          _devices.add(item);
          changed = true;
        }
      }
      if (changed) {
        setState(() {});
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: _scanTimeoutSeconds),
        androidUsesFineLocation: true,
      );
    } catch (_) {}

    if (mounted) {
      setState(() => _scanning = false);
    }
  }

  Future<void> _connectOrEnter(BluetoothDevice device) async {
    if (_deviceConnected && _connectedDevice?.remoteId == device.remoteId) {
      await _openAuthorizationPage(device);
      return;
    }
    await _connectDevice(device);
  }

  Future<void> _connectDevice(BluetoothDevice device) async {
    final l10n = context.l10n;
    setState(() => _connectingDevice = device);
    Hud.show();

    try {
      await FlutterBluePlus.stopScan();
      await device.connect(timeout: const Duration(seconds: 20));
      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDeviceDisconnected();
        }
      });
      if (!mounted) return;
      setState(() {
        _connectedDevice = device;
        _deviceConnected = true;
      });
      await _openAuthorizationPage(device);
    } catch (_) {
      if (mounted) {
        showToast(l10n.bluetoothAuthFailed);
      }
    } finally {
      Hud.dismiss();
      if (!mounted) return;
      setState(() => _connectingDevice = null);
    }
  }

  Future<void> _openAuthorizationPage(BluetoothDevice device) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BluetoothAuthorizationPage(device: device),
      ),
    );
  }

  void _handleDeviceDisconnected() {
    if (!mounted) return;
    setState(() {
      _connectedDevice = null;
      _deviceConnected = false;
      _clearDevicesAndResetScanState();
    });
  }

  Future<void> _disconnectCurrentDevice() async {
    final device = _connectedDevice;
    if (device == null) return;
    try {
      await device.disconnect();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothAuthFindTitle)),
      backgroundColor: AppColors.bgColor,
      body: Column(
        children: [
          // Bluetooth 开关
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bluetoothAuthBluetoothLabel,
                  style: const TextStyle(fontSize: 16),
                ),
                CupertinoSwitch(
                  value: _bluetoothOn,
                  activeTrackColor: AppColors.primaryColor,
                  onChanged: _toggleBluetooth,
                ),
              ],
            ),
          ),

          // 设备列表
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _devices.isEmpty
                              ? l10n.bluetoothAuthNoDevices
                              : l10n.bluetoothAuthAvailableDevices,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                        if (_scanning)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _devices.isEmpty
                        ? Center(
                            child: Text(
                              _scanning
                                  ? l10n.bluetoothAuthScanning
                                  : l10n.bluetoothAuthNoDevices,
                              style: const TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _devices.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 56),
                            itemBuilder: (context, index) {
                              final device = _devices[index].device;
                              final isConnecting =
                                  _connectingDevice?.remoteId ==
                                  device.remoteId;

                              return ListTile(
                                leading: Image.asset(
                                  'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
                                  width: 32,
                                  height: 32,
                                ),
                                title: Text(device.platformName),
                                trailing: isConnecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: SizedBox.shrink(),
                                      )
                                    : null,
                                onTap: isConnecting
                                    ? null
                                    : () => _connectOrEnter(device),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 蓝牙授权操作页面 - Authorization
class _BluetoothAuthorizationPage extends ConsumerStatefulWidget {
  const _BluetoothAuthorizationPage({required this.device});

  final BluetoothDevice device;

  @override
  ConsumerState<_BluetoothAuthorizationPage> createState() =>
      _BluetoothAuthorizationPageState();
}

class _BluetoothAuthorizationPageState
    extends ConsumerState<_BluetoothAuthorizationPage> {
  static final Guid _serviceUuid = Guid(BleCommandBuilder.serviceId);
  static final Guid _readUuid = Guid(BleCommandBuilder.readUuid);
  static final Guid _writeUuid = Guid(BleCommandBuilder.writeUuid);

  final _snController = TextEditingController();
  final ApiService _api = ApiService();
  BluetoothCharacteristic? _writeChar;
  StreamSubscription<List<int>>? _notifySub;
  String _pendingSignal = '';
  String _notifyBuffer = '';
  Completer<String>? _pendingResponse;
  String _lastKeyId = '';
  bool _authorizing = false;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _prepareGatt();
  }

  @override
  void dispose() {
    _notifySub?.cancel();
    _snController.dispose();
    super.dispose();
  }

  Future<void> _prepareGatt() async {
    try {
      final services = await widget.device.discoverServices();
      // 查找目标服务 serviceId=0000FFE0
      BluetoothService? targetService;
      for (final s in services) {
        if (s.uuid == _serviceUuid) {
          targetService = s;
          break;
        }
      }
      if (targetService == null) {
        // 回退：遍历所有服务找含有 readUuid / writeUuid 特征的服务
        for (final s in services) {
          final hasRead = s.characteristics.any((c) => c.uuid == _readUuid);
          final hasWrite = s.characteristics.any((c) => c.uuid == _writeUuid);
          if (hasRead || hasWrite) {
            targetService = s;
            break;
          }
        }
      }
      if (targetService == null) {
        if (mounted) showToast(context.l10n.bluetoothAuthFailed);
        return;
      }
      BluetoothCharacteristic? writeChar;
      BluetoothCharacteristic? notifyChar;
      for (final c in targetService.characteristics) {
        if (c.uuid == _writeUuid) writeChar = c;
        if (c.uuid == _readUuid) notifyChar = c;
      }
      if (writeChar == null || notifyChar == null) {
        if (mounted) showToast(context.l10n.bluetoothAuthFailed);
        return;
      }
      await notifyChar.setNotifyValue(true);
      _notifySub?.cancel();
      _notifySub = notifyChar.onValueReceived.listen((data) {
        _handleNotify(_bytesToHex(data));
      });
      _writeChar = writeChar;
      // 对齐安卓：GATT 准备好后立即读取钥匙 ID
      _readKeyId();
    } catch (e) {
      if (!mounted) return;
      showToast(context.l10n.bluetoothAuthFailed);
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            const QrScanPage(allowManualInput: false, parseDeviceSn: true),
      ),
    );
    if (result != null && result.isNotEmpty) {
      _snController.text = result;
    }
  }

  Future<void> _openAuthorization() async {
    final l10n = context.l10n;
    final sn = _snController.text.trim();
    if (sn.isEmpty) {
      showToast(l10n.bluetoothAuthSnRequired);
      return;
    }

    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        message: l10n.bluetoothAuthConfirmOpen,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    setState(() => _authorizing = true);

    try {
      final sn = _snController.text.trim();
      // 对齐安卓新版：先查询锁信息
      final lockInfo = await _queryLockInfo(sn);
      if (lockInfo == null) {
        throw Exception('lock info missing');
      }
      // 对齐安卓新版：检查 lockDevId 不能为空
      if (lockInfo.lockDevId.isEmpty) {
        if (mounted) showToast(l10n.bluetoothAuthNoMatchLockId);
        return;
      }
      final phone = AuthSession.instance.current?.phone ?? '';
      // 对齐安卓新版（BluetoothOperateActivityNew）：userNum 硬编码为 "00000001"
      const userNum = '00000001';
      final keyId = await _readKeyId();
      if (keyId == null || keyId.isEmpty) {
        throw Exception('key id missing');
      }
      final days = 1;
      final now = DateTime.now();
      final authBegTime = now
          .subtract(const Duration(hours: 1))
          .millisecondsSinceEpoch;
      final authEndTime = now.add(Duration(days: days)).millisecondsSinceEpoch;
      final payload = BleCommandBuilder.buildAddAuthorizationData(
        keyId: keyId,
        lockId: lockInfo.lockDevId,
        userNum: userNum,
        days: days,
      );
      final ack = await _sendEncryptedCommand(signal: '000D', payload: payload);
      if (!_isValidAckForKeyId(ack, keyId)) {
        throw Exception('authorize ack invalid');
      }
      final uploaded = await ref
          .read(bluetoothOperateProvider.notifier)
          .authAdd(
            phone: phone,
            keyId: keyId,
            lockIcId: lockInfo.lockIcId,
            lockDevId: lockInfo.lockDevId,
            sn: sn,
            authBegTime: authBegTime,
            authEndTime: authEndTime,
          );
      if (!uploaded) {
        throw Exception('upload failed');
      }
      if (mounted) {
        showToast(l10n.bluetoothAuthSuccess);
      }
    } catch (e) {
      if (mounted) {
        showToast(l10n.bluetoothAuthFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _authorizing = false);
      }
    }
  }

  Future<void> _clearAuthorization() async {
    final l10n = context.l10n;

    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _ConfirmDialog(
        message: l10n.bluetoothAuthConfirmClear,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed != true) return;

    setState(() => _clearing = true);

    try {
      final keyId = await _readKeyId();
      if (keyId == null || keyId.isEmpty) {
        throw Exception('key id missing');
      }
      final payload = BleCommandBuilder.buildClearAuthorizationData(keyId);
      final ack = await _sendEncryptedCommand(signal: '000c', payload: payload);
      if (!_isValidAckForKeyId(ack, keyId)) {
        throw Exception('clear ack invalid');
      }
      if (mounted) {
        showToast(l10n.bluetoothAuthClearSuccess);
      }
    } catch (e) {
      if (mounted) {
        showToast(l10n.bluetoothAuthClearFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _clearing = false);
      }
    }
  }

  Future<SNBean?> _queryLockInfo(String sn) async {
    final response = await _api.get<SNBean>(
      ApiPath.bluetoothGetLockIdBySn,
      queryParameters: {'sn': sn},
      parser: (json) => SNBean.fromJson(Map<String, dynamic>.from(json as Map)),
      showHud: false,
    );
    if (!response.isSuccess) return null;
    return response.result;
  }

  Future<String?> _readKeyId() async {
    if (_lastKeyId.length == 8) return _lastKeyId;
    final response = await _sendEncryptedCommand(
      signal: '0031',
      payload: BleCommandBuilder.buildReadKeyIdData(),
    );
    if (response == null || response.length < 8) return null;
    _lastKeyId = response.substring(0, 8).toLowerCase();
    return _lastKeyId;
  }

  bool _isValidAckForKeyId(String? ack, String keyId) {
    if (ack == null || ack.length < 8) return false;
    final ackPrefix = ack.substring(0, 8).toLowerCase();
    final key = keyId.trim().toLowerCase();
    if (key.isEmpty) return false;
    return ackPrefix == key;
  }

  Future<String?> _sendEncryptedCommand({
    required String signal,
    required String payload,
  }) async {
    final writeChar = _writeChar;
    if (writeChar == null) {
      await _prepareGatt();
    }
    final activeWrite = _writeChar;
    if (activeWrite == null) return null;
    final encrypted = await ref
        .read(bluetoothOperateProvider.notifier)
        .enOrDecrypt(payload: payload, isEncrypt: true);
    if (encrypted == null || encrypted.isEmpty) return null;
    final command = BleCommandBuilder.buildCommand(
      signal: signal,
      plainHex: payload,
      encryptedHex: encrypted,
    );
    final bytes = _hexToBytes(command);
    if (bytes == null) return null;
    _pendingSignal = signal.toLowerCase();
    _pendingResponse = Completer<String>();
    await activeWrite.write(bytes, withoutResponse: false);
    try {
      return await _pendingResponse!.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      return null;
    } finally {
      _pendingResponse = null;
    }
  }

  void _handleNotify(String hex) {
    _notifyBuffer += hex.toLowerCase();
    final endFlag = BleCommandBuilder.commandEnd.toLowerCase();
    while (_notifyBuffer.contains(endFlag)) {
      final index = _notifyBuffer.indexOf(endFlag);
      final raw = _notifyBuffer.substring(0, index + endFlag.length);
      _notifyBuffer = _notifyBuffer.substring(index + endFlag.length);
      final unescaped = BleCommandBuilder.unescapeResponse(raw);
      final signal = BleCommandBuilder.extractSignal(unescaped).toLowerCase();
      final expectedSignal = _pendingSignal;
      final matched =
          expectedSignal.isEmpty ||
          signal == expectedSignal ||
          signal == _toResponseSignal(expectedSignal);
      if (!matched) {
        // 对齐安卓：如果收到 010d 表示重复授权
        if (signal == '010d' && mounted) {
          showToast(context.l10n.bluetoothAuthRepeatAuthorization);
        }
        continue;
      }
      final decryptStr = BleCommandBuilder.extractDecryptStr(unescaped);
      ref
          .read(bluetoothOperateProvider.notifier)
          .enOrDecrypt(payload: decryptStr, isEncrypt: false)
          .then((value) {
            if (value == null || value.isEmpty) return;
            final completer = _pendingResponse;
            if (completer != null && !completer.isCompleted) {
              completer.complete(value);
            }
          });
    }
  }

  List<int>? _hexToBytes(String input) {
    final clean = input
        .replaceAll('0x', '')
        .replaceAll('0X', '')
        .replaceAll(RegExp(r'\s+'), '')
        .toUpperCase();
    if (clean.isEmpty || clean.length.isOdd) return null;
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i += 2) {
      final part = clean.substring(i, i + 2);
      final value = int.tryParse(part, radix: 16);
      if (value == null) return null;
      bytes.add(value);
    }
    return bytes;
  }

  String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0').toUpperCase());
    }
    return buffer.toString();
  }

  String _toResponseSignal(String requestSignal) {
    if (requestSignal.length != 4) return requestSignal;
    final value = int.tryParse(requestSignal, radix: 16);
    if (value == null) return requestSignal;
    return (value + 0x0100).toRadixString(16).padLeft(4, '0');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothAuthTitle)),
      backgroundColor: AppColors.bgColor,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 已连接设备卡片
          _ConnectedDeviceCard(device: widget.device),
          const SizedBox(height: 16),

          // 授权柜机输入区域
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.bluetoothAuthAuthorizedStation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _snController,
                  decoration: InputDecoration(
                    hintText: l10n.bluetoothAuthSnHint,
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _scanQRCode,
                      icon: AppIcons.scanIcon(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Opening Authorization 按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _authorizing ? null : _openAuthorization,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _authorizing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: SizedBox.shrink(),
                          )
                        : Text(
                            l10n.bluetoothAuthOpenButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Clear Authorization 按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _clearing ? null : _clearAuthorization,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.black26),
                    ),
                    child: _clearing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: SizedBox.shrink(),
                          )
                        : Text(
                            l10n.bluetoothAuthClearButton,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tips 区域
          _TipsSection(),
        ],
      ),
    );
  }
}

/// 已连接设备卡片
class _ConnectedDeviceCard extends StatelessWidget {
  const _ConnectedDeviceCard({required this.device});

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B9FE8), Color(0xFF5BB8F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/android/mipmap-xxhdpi/icon_blue_key_autho.png',
            width: 32,
            height: 32,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.platformName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.bluetoothAuthConnected,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(
            Icons.bluetooth,
            color: Colors.white.withValues(alpha: 0.3),
            size: 48,
          ),
        ],
      ),
    );
  }
}

/// Tips 区域
class _TipsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tips = [
      l10n.bluetoothAuthTip1,
      l10n.bluetoothAuthTip2,
      l10n.bluetoothAuthTip3,
      l10n.bluetoothAuthTip4,
      l10n.bluetoothAuthTip5,
      l10n.bluetoothAuthTip6,
    ];

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.bluetoothAuthTipsTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 12),
        ...tips.map(
          (tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('· ', style: TextStyle(color: Colors.black54)),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 确认对话框
class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.message,
    required this.onCancel,
    required this.onConfirm,
  });

  final String message;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.black26),
                      ),
                      child: Text(
                        l10n.bluetoothAuthCancel,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      onPressed: onConfirm,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.bluetoothAuthConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
