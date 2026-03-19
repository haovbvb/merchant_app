import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merchant_app/app/styles/colors.dart';
import 'package:merchant_app/core/utils/bluetooth_permission.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';
import 'package:merchant_app/core/widgets/confirm_dialog.dart';
import 'package:merchant_app/data/models/sn_bean.dart';
import 'package:merchant_app/features/work/bluetooth/ble_command.dart';
import 'package:merchant_app/features/work/bluetooth/bluetooth_operate_controller.dart';
import 'package:merchant_app/features/work/qrcode/qr_scan_page.dart';
import 'package:merchant_app/l10n/app_localizations.dart';
import 'package:merchant_app/network/api_path.dart';
import 'package:merchant_app/network/api_service.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothOperatePage extends ConsumerStatefulWidget {
  const BluetoothOperatePage({super.key});

  @override
  ConsumerState<BluetoothOperatePage> createState() =>
      _BluetoothOperatePageState();
}

class _BluetoothOperatePageState extends ConsumerState<BluetoothOperatePage> {
  static final Guid _serviceUuid = Guid(BleCommandBuilder.serviceId);
  static final Guid _readUuid = Guid(BleCommandBuilder.readUuid);
  static final Guid _writeUuid = Guid(BleCommandBuilder.writeUuid);
  static const int _bleChunkSize = 20;
  static const int _authTypeNone = 0;
  static const int _authTypeNormal = 1;
  static const int _authTypeFactory = 2;

  final List<ScanResult> _scanResults = [];
  final List<String> _logs = [];
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _snController = TextEditingController();
  final TextEditingController _lockDevIdController = TextEditingController();
  final TextEditingController _lockIcIdController = TextEditingController();
  final TextEditingController _keyIdController = TextEditingController();
  final TextEditingController _userNumController = TextEditingController(
    text: '00000001',
  );
  final TextEditingController _authDaysController = TextEditingController(
    text: '1',
  );
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final ApiService _api = ApiService();

  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<bool>? _isScanningSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<List<int>>? _notifySub;

  bool _isScanning = false;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeChar;
  String _pendingSignal = '';
  String _notifyBuffer = '';
  String _lastSetKeyTime = '';
  int _lastAuthBegin = 0;
  int _lastAuthEnd = 0;
  int _authType = _authTypeNone;

  @override
  void initState() {
    super.initState();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) {
        final name = r.device.platformName;
        return name.isNotEmpty &&
            (name.contains('HWK') || name.contains('HNT'));
      }).toList();
      setState(() {
        _scanResults
          ..clear()
          ..addAll(filtered);
      });
    });
    _isScanningSub = FlutterBluePlus.isScanning.listen((value) {
      if (mounted) {
        setState(() => _isScanning = value);
      }
    });
    _adapterSub = FlutterBluePlus.adapterState.listen((state) {
      if (mounted) {
        setState(() => _adapterState = state);
      }
    });
  }

  @override
  void dispose() {
    _commandController.dispose();
    _snController.dispose();
    _lockDevIdController.dispose();
    _lockIcIdController.dispose();
    _keyIdController.dispose();
    _userNumController.dispose();
    _authDaysController.dispose();
    _phoneController.dispose();
    _uidController.dispose();
    _scanSub?.cancel();
    _isScanningSub?.cancel();
    _adapterSub?.cancel();
    _notifySub?.cancel();
    _disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final device = _device;
    final operateState = ref.watch(bluetoothOperateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothOperateTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(adapterState: _adapterState, isScanning: _isScanning),
          const SizedBox(height: 12),
          _SectionTitle(title: '授权参数'),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '手机号',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _uidController,
                  decoration: const InputDecoration(
                    labelText: 'UID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(onPressed: _queryUid, child: const Text('查询UID')),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _snController,
            decoration: InputDecoration(
              labelText: '柜机SN',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: _scanSn,
                icon: const Icon(Icons.qr_code_scanner),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lockDevIdController,
                  decoration: const InputDecoration(
                    labelText: 'lockDevId',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _queryLockId,
                child: const Text('查询锁ID'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _lockIcIdController,
            decoration: const InputDecoration(
              labelText: 'lockIcId',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keyIdController,
            decoration: const InputDecoration(
              labelText: '钥匙ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userNumController,
                  decoration: const InputDecoration(
                    labelText: '用户编号(8位)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _authDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '授权天数',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: device == null || operateState.processing
                      ? null
                      : _readKeyId,
                  child: const Text('读取钥匙ID'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: device == null || operateState.processing
                      ? null
                      : _clearAuthorization,
                  child: const Text('清空授权'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: device == null || operateState.processing
                      ? null
                      : _resetAuthorizationTime,
                  child: const Text('设置有效期'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: device == null || operateState.processing
                      ? null
                      : _addAuthorization,
                  child: const Text('新增授权'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: device == null || operateState.processing
                ? null
                : _addFactoryAuthorization,
            child: const Text('工厂授权'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _isScanning ? null : _startScan,
                  child: Text(_isScanning ? '扫描中...' : '开始扫描'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isScanning ? _stopScan : null,
                  child: const Text('停止扫描'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionTitle(title: '可用设备'),
          const SizedBox(height: 8),
          if (_scanResults.isEmpty)
            const Text('-')
          else
            ..._scanResults.map(
              (result) => _DeviceTile(
                result: result,
                isConnected: device?.remoteId == result.device.remoteId,
                onConnect: () => _connect(result.device),
              ),
            ),
          const SizedBox(height: 16),
          _SectionTitle(title: '指令操作'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.bluetoothOperateTip),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commandController,
                    decoration: const InputDecoration(
                      labelText: 'HEX 指令（可含空格）',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: device == null ? null : _sendCommand,
                          child: const Text('发送'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: device == null ? null : _disconnect,
                          child: const Text('断开连接'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '日志'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_logs.isEmpty) const Text('-'),
                  ..._logs.map((line) => Text(line)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _logs.isEmpty
                          ? null
                          : () => setState(_logs.clear),
                      child: const Text('清空日志'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Future<void> _scanSn() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            const QrScanPage(allowManualInput: false, parseDeviceSn: true),
      ),
    );
    if (!mounted || result == null || result.isEmpty) return;
    setState(() {
      _snController.text = result;
    });
  }

  Future<void> _startScan() async {
    final result = await _ensurePermissions();
    if (!result.granted) {
      if (!mounted) return;
      await _handlePermissionDenied(context.l10n, result.status);
      return;
    }
    if (Platform.isAndroid && _adapterState != BluetoothAdapterState.on) {
      await FlutterBluePlus.turnOn();
    }
    _scanResults.clear();
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  Future<void> _stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      await _stopScan();
      await _disconnect();
      await device.connect(timeout: const Duration(seconds: 30));
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
        final hex = _bytesToHex(data);
        _handleNotify(hex);
      });
      setState(() {
        _device = device;
        _writeChar = writeChar;
        _logs.add('已连接：${device.remoteId}');
      });
      // Native flow triggers reading key id after notify is ready.
      await _readKeyId();
    } catch (e) {
      showToast('连接失败');
    }
  }

  Future<void> _disconnect() async {
    final device = _device;
    if (device == null) return;
    try {
      await device.disconnect();
    } catch (_) {}
    setState(() {
      _device = null;
      _writeChar = null;
    });
  }

  Future<void> _sendCommand() async {
    final writeChar = _writeChar;
    if (writeChar == null) {
      showToast('未找到写入通道');
      return;
    }
    final raw = _commandController.text.trim();
    final bytes = _hexToBytes(raw);
    if (bytes == null) {
      showToast('请输入有效的HEX指令');
      return;
    }
    _pendingSignal = '';
    await _writeWithNativeLikeFallback(writeChar, bytes);
    setState(() => _logs.add('→ ${_bytesToHex(bytes)}'));
  }

  Future<void> _readKeyId() async {
    final payload = BleCommandBuilder.buildReadKeyIdData();
    await _sendEncryptedCommand(signal: '0031', payload: payload);
  }

  Future<void> _clearAuthorization() async {
    final keyId = _keyIdController.text.trim();
    if (keyId.length < 8) {
      showToast('请先读取钥匙ID');
      return;
    }
    final payload = BleCommandBuilder.buildClearAuthorizationData(keyId);
    await _sendEncryptedCommand(signal: '000c', payload: payload);
  }

  Future<void> _resetAuthorizationTime() async {
    final now = DateTime.now();
    _lastSetKeyTime = _getSetKeyTime(now);
    final payload =
        BleCommandBuilder.userPwd +
        _lastSetKeyTime +
        BleCommandBuilder.bleKeyBlock;
    await _sendEncryptedCommand(signal: '0087', payload: payload);
  }

  Future<void> _addAuthorization() async {
    final keyId = _keyIdController.text.trim();
    final lockId = _lockDevIdController.text.trim();
    final userNum = _userNumController.text.trim();
    final days = int.tryParse(_authDaysController.text.trim()) ?? 1;
    if (keyId.length < 8 || lockId.isEmpty || userNum.isEmpty) {
      showToast('请补充钥匙ID/lockDevId/用户编号');
      return;
    }
    final confirmed = await ConfirmDialog.show(
      context: context,
      message: '确认执行开柜授权？',
    );
    if (!confirmed) return;
    _authType = _authTypeNormal;
    _setAuthTime(days);
    final payload = BleCommandBuilder.buildAddAuthorizationData(
      keyId: keyId,
      lockId: lockId,
      userNum: userNum,
      days: days,
    );
    await _sendEncryptedCommand(signal: '000D', payload: payload);
  }

  Future<void> _addFactoryAuthorization() async {
    final keyId = _keyIdController.text.trim();
    final days = int.tryParse(_authDaysController.text.trim()) ?? 1;
    if (keyId.length < 8) {
      showToast('请先读取钥匙ID');
      return;
    }
    _authType = _authTypeFactory;
    _setAuthTime(days);
    final payload = BleCommandBuilder.buildFactoryAuthorizationData(
      keyId: keyId,
      days: days,
    );
    await _sendEncryptedCommand(signal: '000D', payload: payload);
  }

  Future<void> _sendEncryptedCommand({
    required String signal,
    required String payload,
  }) async {
    final notifier = ref.read(bluetoothOperateProvider.notifier);
    final encrypted = await notifier.enOrDecrypt(
      payload: payload,
      isEncrypt: true,
    );
    if (encrypted == null || encrypted.isEmpty) {
      showToast('加密失败');
      return;
    }
    final command = BleCommandBuilder.buildCommand(
      signal: signal,
      plainHex: payload,
      encryptedHex: encrypted,
    );
    final bytes = _hexToBytes(command);
    if (bytes == null) {
      showToast('指令格式错误');
      return;
    }
    _pendingSignal = signal.toLowerCase();
    _notifyBuffer = '';
    final writeChar = _writeChar;
    if (writeChar == null) {
      showToast('未找到写入通道');
      return;
    }
    await _writeWithNativeLikeFallback(writeChar, bytes);
    setState(() => _logs.add('→ ${_bytesToHex(bytes)}'));
  }

  Future<void> _writeWithNativeLikeFallback(
    BluetoothCharacteristic writeChar,
    List<int> bytes,
  ) async {
    try {
      // Match native FastBle behavior for larger frames.
      await writeChar.write(
        bytes,
        withoutResponse: false,
        allowLongWrite: true,
      );
      return;
    } catch (_) {}

    try {
      await _writeInChunks(writeChar, bytes, withoutResponse: false);
      return;
    } catch (_) {}

    try {
      await writeChar.write(bytes, withoutResponse: true);
      return;
    } catch (_) {}

    await _writeInChunks(writeChar, bytes, withoutResponse: true);
  }

  Future<void> _writeInChunks(
    BluetoothCharacteristic writeChar,
    List<int> bytes, {
    required bool withoutResponse,
  }) async {
    var offset = 0;
    while (offset < bytes.length) {
      final end = (offset + _bleChunkSize < bytes.length)
          ? offset + _bleChunkSize
          : bytes.length;
      final chunk = bytes.sublist(offset, end);
      await writeChar.write(chunk, withoutResponse: withoutResponse);
      offset = end;
      if (offset < bytes.length) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    }
  }

  Future<void> _queryLockId() async {
    final sn = _snController.text.trim();
    if (sn.isEmpty) {
      showToast('请输入SN');
      return;
    }
    final response = await _api.get<SNBean>(
      ApiPath.bluetoothGetLockIdBySn,
      queryParameters: {'sn': sn},
      parser: (json) => SNBean.fromJson(Map<String, dynamic>.from(json as Map)),
    );
    if (!mounted) return;
    if (response.isSuccess && response.result != null) {
      setState(() {
        _lockDevIdController.text = response.result!.lockDevId;
        _lockIcIdController.text = response.result!.lockIcId;
      });
    } else {
      showToast('未查询到锁信息');
    }
  }

  Future<void> _queryUid() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showToast('请输入手机号');
      return;
    }
    final response = await _api.get<String>(
      ApiPath.bluetoothGetUidByPhone,
      queryParameters: {'phone': phone},
      parser: (json) => json?.toString() ?? '',
    );
    if (!mounted) return;
    if (response.isSuccess && response.result != null) {
      final uid = response.result ?? '';
      final padded = uid.padLeft(8, '0');
      setState(() {
        _uidController.text = uid;
        _userNumController.text = padded;
      });
    } else {
      showToast('UID查询失败');
    }
  }

  void _handleNotify(String hex) {
    _notifyBuffer += hex.toLowerCase();
    final endFlag = BleCommandBuilder.commandEnd.toLowerCase();
    while (_notifyBuffer.contains(endFlag)) {
      final index = _notifyBuffer.indexOf(endFlag);
      final raw = _notifyBuffer.substring(0, index + endFlag.length);
      _notifyBuffer = _notifyBuffer.substring(index + endFlag.length);

      final signal = BleCommandBuilder.extractSignal(raw).toLowerCase();
      final unescaped = BleCommandBuilder.unescapeResponse(raw);
      if (_pendingSignal.isNotEmpty && signal != _pendingSignal) {
        _handleSignalMismatch(signal);
        continue;
      }
      final decryptStr = BleCommandBuilder.extractDecryptStr(unescaped);
      final notifier = ref.read(bluetoothOperateProvider.notifier);
      notifier.enOrDecrypt(payload: decryptStr, isEncrypt: false).then((value) {
        if (value == null || value.isEmpty) {
          setState(() => _logs.add('← 解密失败'));
          return;
        }
        _pendingSignal = '';
        setState(() => _logs.add('← $value'));
        _handleDecryptedResponse(signal: signal, data: value);
      });
    }
  }

  void _handleSignalMismatch(String signal) {
    if (signal == '010d') {
      showToast('重复授权');
    }
    _pendingSignal = '';
    _notifyBuffer = '';
    setState(() => _logs.add('← 异常指令:$signal'));
  }

  void _handleDecryptedResponse({
    required String signal,
    required String data,
  }) {
    if (signal == '0031' && data.length >= 8) {
      _keyIdController.text = data.substring(0, 8);
      return;
    }
    if (signal == '000c' && data.length >= 8) {
      final backKeyId = data.substring(0, 8);
      if (backKeyId == _keyIdController.text.trim()) {
        showToast('清空授权成功');
      } else {
        showToast('清空授权失败：钥匙ID不匹配');
      }
      return;
    }
    if (signal == '0087' && data.length >= 10) {
      final backKeyTime = data.substring(0, 10);
      if (backKeyTime.toLowerCase() == _lastSetKeyTime.toLowerCase()) {
        showToast('设置有效期成功');
      } else {
        showToast('设置有效期失败：回执时间不一致');
      }
      return;
    }
    if (signal == '000d' && data.length >= 8) {
      final backKeyId = data.substring(0, 8);
      final keyId = _keyIdController.text.trim();
      if (backKeyId == keyId) {
        _uploadAuthorization(
          isFactoryAuthorization: _authType == _authTypeFactory,
        );
      } else {
        showToast('授权失败：钥匙ID不匹配');
        _authType = _authTypeNone;
      }
    }
  }

  void _setAuthTime(int days) {
    final now = DateTime.now();
    final begin = now.subtract(const Duration(hours: 1));
    final end = now.add(Duration(days: days));
    _lastAuthBegin = begin.millisecondsSinceEpoch;
    _lastAuthEnd = end.millisecondsSinceEpoch;
  }

  String _getSetKeyTime(DateTime now) {
    final dt = DateTime(
      now.year + 10,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    return _getBcd(dt);
  }

  String _getBcd(DateTime dateTime) {
    var year = dateTime.year - 2000;
    if (year < 0) year = 0;
    return year.toString().padLeft(2, '0') +
        dateTime.month.toString().padLeft(2, '0') +
        dateTime.day.toString().padLeft(2, '0') +
        dateTime.hour.toString().padLeft(2, '0') +
        dateTime.minute.toString().padLeft(2, '0');
  }

  Future<void> _uploadAuthorization({
    required bool isFactoryAuthorization,
  }) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      showToast('请填写手机号');
      _authType = _authTypeNone;
      return;
    }
    final notifier = ref.read(bluetoothOperateProvider.notifier);
    final lockDevId = isFactoryAuthorization
        ? '0'
        : _lockDevIdController.text.trim();
    final sn = isFactoryAuthorization ? '0' : _snController.text.trim();
    final ok = await notifier.authAdd(
      phone: phone,
      keyId: _keyIdController.text.trim(),
      // Native flow always uploads 0 for lockIcId in this page.
      lockIcId: '0',
      lockDevId: lockDevId,
      sn: sn.isEmpty ? '0' : sn,
      authBegTime: _lastAuthBegin,
      authEndTime: _lastAuthEnd,
    );
    _authType = _authTypeNone;
    if (!mounted) return;
    showToast(ok ? '授权记录已上传' : '授权记录上传失败');
  }

  Future<BluetoothPermissionResult> _ensurePermissions() async {
    return ensureBluetoothPermission();
  }

  Future<void> _handlePermissionDenied(
    AppLocalizations l10n,
    BluetoothPermissionStatus status,
  ) async {
    final needsSettings =
        status == BluetoothPermissionStatus.deniedForever ||
        status == BluetoothPermissionStatus.restricted;
    final action = await ConfirmDialog.show(
      context: context,
      message: l10n.bluetoothPermissionDesc,
      confirmText: needsSettings
          ? l10n.bluetoothOpenSettings
          : l10n.bluetoothPermissionRetry,
    );

    if (!action || !mounted) return;
    if (needsSettings) {
      await openAppSettings();
    } else {
      await _startScan();
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w600));
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.adapterState, required this.isScanning});

  final BluetoothAdapterState adapterState;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    final stateText = adapterState.name;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('蓝牙状态：$stateText'),
            const SizedBox(height: 4),
            Text('扫描状态：${isScanning ? '进行中' : '未扫描'}'),
          ],
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.result,
    required this.isConnected,
    required this.onConnect,
  });

  final ScanResult result;
  final bool isConnected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final name = result.device.platformName.isNotEmpty
        ? result.device.platformName
        : 'Unknown';
    return ListTile(
      title: Text(name),
      subtitle: Text(result.device.remoteId.str),
      trailing: isConnected
          ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
          : TextButton(onPressed: onConnect, child: const Text('连接')),
    );
  }
}
