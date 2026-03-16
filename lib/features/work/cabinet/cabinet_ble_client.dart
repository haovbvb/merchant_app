import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:merchant_app/core/utils/bluetooth_permission.dart';

class CabinetBleSignal {
  static const String gsm = '02105001';
  static const String cabinetVoltage = '02107001';
  static const String cabinetCurrent = '02108001';
  static const String cabinetTemperature = '02113001';
  static const String batterySoc = '02109001';
  static const String electricMeter = '02120001';
  static const String backupBatteryStatus = '02019001';
  static const String alarmSmoke = '02017001';
  static const String alarmWater = '02018001';
  static const String allData = '02309009';
  static const String ctrlChargerPrefix = '020030';
  static const String ctrlSystem = '02020001';
  static const String cabinetMaintenanceDoor = '02020002';
  static const String cabinetFanStatus = '02020003';
  static const String cabinetDoorStatus = '02118001';
  static const String batterySn = '02106001';
  static const String cabinetSwapStatus = '18002010';
  static const String cabinetBatterySwapStatus = '02104001';
}

class CabinetDataType {
  static const int queryRequest = 210;
  static const int queryResponse = 211;
  static const int attributeRequest = 310;
  static const int alarmRequest = 410;
  static const int controlRequest = 500;
  static const int controlResponse = 501;
}

class CabinetParamName {
  static const String reset = 'swCabReset';
  static const String switchControl = 'switchControl';
  static const String cabVolume = 'swCabVolControl';
  static const String cabSoc = 'swCabSocControl';
  static const String softVersion = 'softVersion';
  static const String cabTcpPort = 'swCabTcpPort';
  static const String apn = 'APN';
  static const String control = '02301001';
}

enum CabinetBleConnectionPhase {
  idle,
  scanning,
  connecting,
  connected,
  reconnecting,
}

class CabinetBleClient {
  CabinetBleClient({
    required this.onConnectionChanged,
    required this.onPhaseChanged,
    required this.onAuthorized,
    required this.onJsonData,
    required this.onError,
  });

  final void Function(bool connected) onConnectionChanged;
  final void Function(CabinetBleConnectionPhase phase) onPhaseChanged;
  final VoidCallback onAuthorized;
  final void Function(String jsonText) onJsonData;
  final void Function(String message) onError;

  static final Guid _serviceUuid = Guid('00008910-0000-1000-8000-00805f9b34fb');
  static final Guid _notifyUuid = Guid('0000ffe4-0000-1000-8000-00805f9b34fb');
  static final Guid _writeUuid = Guid('0000ffe9-0000-1000-8000-00805f9b34fb');
  static const String _notifyShortUuid = 'ffe4';
  static const String _writeShortUuid = 'ffe9';
  static const int _iosWriteChunkSize = 180;
  static const Duration _packetSendInterval = Duration(seconds: 5);
  static const String _authorizationFixedKey =
      'E9?t>MM21G7K2HWVM6FNgr81HI90XK=s==';
  static const String _dataFixedKey = 'AG;B:;I`Mu3yNv3DIdB|C@4?D75>4Y9A==';

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeChar;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  bool _scanning = false;
  bool _connecting = false;
  bool _authorized = false;
  bool _reconnectPending = false;
  Timer? _reconnectTimer;
  String _deviceSn = '';
  String _secretKey = '';
  final List<int> _rxBuffer = <int>[];
  final List<String> _sendQueue = <String>[];
  bool _sending = false;

  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[CabinetBLE] $message');
  }

  bool get isConnected => _device != null && _writeChar != null;

  Future<void> start({
    required String deviceSn,
    required String secretKey,
  }) async {
    _log('start, deviceSn=$deviceSn');
    if (deviceSn.isEmpty || secretKey.isEmpty) return;
    final sameTarget = _deviceSn == deviceSn && _secretKey == secretKey;
    if (sameTarget && isConnected) {
      _log('already connected to same target');
      onPhaseChanged(CabinetBleConnectionPhase.connected);
      return;
    }
    await stop(clearTarget: false);
    _deviceSn = deviceSn;
    _secretKey = secretKey;

    final permission = await ensureBluetoothPermission();
    if (!permission.granted) {
      onConnectionChanged(false);
      onPhaseChanged(CabinetBleConnectionPhase.idle);
      onError('permission-denied');
      return;
    }

    if (Platform.isAndroid) {
      final adapterState = await FlutterBluePlus.adapterState.first;
      _log('android adapterState=$adapterState');
      if (adapterState != BluetoothAdapterState.on) {
        try {
          await FlutterBluePlus.turnOn();
        } catch (_) {
          onPhaseChanged(CabinetBleConnectionPhase.idle);
          onError('bluetooth-off');
          _scheduleReconnect();
          return;
        }
      }
    }

    await _scanAndConnect();
  }

  Future<void> stop({bool clearTarget = true}) async {
    _authorized = false;
    _rxBuffer.clear();
    _sendQueue.clear();
    _sending = false;
    _scanning = false;
    _connecting = false;
    _reconnectPending = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _log('stop called: disconnect + stop scan + clear reconnect state');
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
    await _scanSub?.cancel();
    _scanSub = null;
    await _notifySub?.cancel();
    _notifySub = null;
    await _connectionSub?.cancel();
    _connectionSub = null;
    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
    }
    _device = null;
    _writeChar = null;
    if (clearTarget) {
      _deviceSn = '';
      _secretKey = '';
    }
    onConnectionChanged(false);
    onPhaseChanged(CabinetBleConnectionPhase.idle);
  }

  Future<void> queryAllData() async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.queryRequest,
      params: [
        {'id': CabinetBleSignal.allData, 'value': '0', 'doorId': null},
      ],
    );
  }

  Future<void> queryDeviceInfo() async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.queryRequest,
      params: [
        {'id': CabinetParamName.softVersion, 'value': null, 'doorId': null},
        {'id': CabinetParamName.cabVolume, 'value': null, 'doorId': null},
        {'id': CabinetParamName.cabSoc, 'value': null, 'doorId': null},
        {'id': CabinetParamName.cabTcpPort, 'value': null, 'doorId': null},
        {'id': CabinetParamName.apn, 'value': null, 'doorId': null},
      ],
    );
  }

  Future<void> sendRestart() async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.reset, 'value': null, 'doorId': null},
      ],
    );
  }

  Future<void> sendOpenBackDoor() async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.control, 'value': '14', 'doorId': null},
      ],
    );
  }

  Future<void> sendPortControl({required int port, required int type}) async {
    String op;
    if (type == 1) {
      op = '04';
    } else if (type == 2) {
      op = '06';
    } else {
      op = '07';
    }
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.switchControl, 'value': op, 'doorId': '$port'},
      ],
    );
  }

  Future<void> sendSwapThreshold(int threshold) async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.cabSoc, 'value': '$threshold', 'doorId': null},
      ],
    );
  }

  Future<void> sendApn(String apn) async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.apn, 'value': apn, 'doorId': null},
      ],
    );
  }

  Future<void> sendVolume(int volume) async {
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.cabVolume, 'value': '$volume', 'doorId': null},
      ],
    );
  }

  Future<void> sendPlatformUrl(String url) async {
    final payload = url.replaceAll(':', ',');
    await _sendCabinetFormat(
      msgType: CabinetDataType.controlRequest,
      params: [
        {'id': CabinetParamName.cabTcpPort, 'value': payload, 'doorId': null},
      ],
    );
  }

  Future<void> _scanAndConnect() async {
    _scanning = true;
    _log(
      'scan start, expected serviceId=${_serviceUuid.str128}, '
      'readUuid=${_notifyUuid.str128}, writeUuid=${_writeUuid.str128}',
    );
    onPhaseChanged(CabinetBleConnectionPhase.scanning);
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (!_scanning) return;
      for (final result in results) {
        final platformName = result.device.platformName.trim();
        final advName = result.advertisementData.advName.trim();
        if (_isTargetName(platformName) || _isTargetName(advName)) {
          _log(
            'scan hit target, platformName=$platformName, advName=$advName, '
            'remoteId=${result.device.remoteId.str}',
          );
          _scanning = false;
          FlutterBluePlus.stopScan();
          _connect(result.device);
          break;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        withNames: <String>[_deviceSn],
        timeout: const Duration(seconds: 60),
        androidUsesFineLocation: true,
      );
      _log('scan completed, stillScanning=$_scanning, target=$_deviceSn');
      if (_scanning) {
        _scanning = false;
        onError('scan-timeout');
        _scheduleReconnect();
      }
    } catch (_) {
      _log('scan failed with exception');
      _scanning = false;
      onError('scan-failed');
      _scheduleReconnect();
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    if (_connecting) return;
    _connecting = true;
    _log(
      'connect start, remoteId=${device.remoteId.str}, name=${device.platformName}',
    );
    onPhaseChanged(CabinetBleConnectionPhase.connecting);
    try {
      await device.connect(timeout: const Duration(seconds: 12));
      final services = await device.discoverServices();
      _log('discoverServices count=${services.length}');
      BluetoothService? service;
      for (final s in services) {
        final uuid = s.uuid.toString().toLowerCase();
        if (uuid == _serviceUuid.toString().toLowerCase() ||
            uuid.contains('8910')) {
          service = s;
          break;
        }
      }
      if (service == null) {
        throw StateError('ble-service-not-found');
      }

      _log('serviceId=${service.uuid.str128}');

      BluetoothCharacteristic? write;
      BluetoothCharacteristic? notify;
      for (final c in service.characteristics) {
        final u = c.uuid.toString().toLowerCase();
        if (u == _writeUuid.toString().toLowerCase() ||
            u.contains(_writeShortUuid)) {
          write = c;
        }
        if (u == _notifyUuid.toString().toLowerCase() ||
            u.contains(_notifyShortUuid)) {
          notify = c;
        }
        _log(
          'characteristic uuid=${c.uuid.str128}, properties=${c.properties}',
        );
      }
      if (write == null || notify == null) {
        throw StateError('ble-characteristic-not-found');
      }

      _log('readUuid=${notify.uuid.str128}, writeUuid=${write.uuid.str128}');

      await notify.setNotifyValue(true);
      await _notifySub?.cancel();
      _notifySub = notify.onValueReceived.listen(_onNotifyData);

      await _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        final connected = state == BluetoothConnectionState.connected;
        _log('connectionState=$state, connected=$connected');
        onConnectionChanged(connected);
        onPhaseChanged(
          connected
              ? CabinetBleConnectionPhase.connected
              : CabinetBleConnectionPhase.reconnecting,
        );
        if (!connected) {
          _log('connection dropped, schedule reconnect');
          _authorized = false;
          _writeChar = null;
          _device = null;
          _scheduleReconnect();
        }
      });

      _device = device;
      _writeChar = write;
      _log('connect success, waiting authorization');
      onConnectionChanged(true);
      onPhaseChanged(CabinetBleConnectionPhase.connected);
      await _sendAuthorization();
    } catch (e) {
      _log('connect failed: $e');
      onConnectionChanged(false);
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectPending || _deviceSn.isEmpty || _secretKey.isEmpty) return;
    _reconnectPending = true;
    _log('schedule reconnect in 10s');
    onPhaseChanged(CabinetBleConnectionPhase.reconnecting);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 10), () async {
      _reconnectPending = false;
      if (isConnected || _connecting || _scanning) return;
      _log('reconnect timer fired, restart scan/connect');
      await _scanAndConnect();
    });
  }

  Future<void> _sendAuthorization() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signSource = '$_deviceSn$_authorizationFixedKey$timestamp';
    final sign = md5.convert(utf8.encode(signSource)).toString().toUpperCase();
    final payload = '$timestamp$sign';
    final packet = _buildPacket(cmd: 0x01, payload: utf8.encode(payload));
    _log('send authorization cmd=0x01, payloadLen=${payload.length}');
    await _write(packet);
  }

  Future<void> _sendCabinetFormat({
    required int msgType,
    required List<Map<String, Object?>> params,
  }) async {
    if (!isConnected) {
      onError('not-connected');
      return;
    }
    if (!_authorized) {
      onError('not-authorized');
      return;
    }
    final data = <String, Object?>{
      'msgType': msgType,
      'devId': _deviceSn,
      'paramList': params,
      'txnNo': '${DateTime.now().millisecondsSinceEpoch}',
    };
    final jsonText = jsonEncode(data);
    final signSource = '$jsonText$_dataFixedKey$_secretKey';
    final sign = md5.convert(utf8.encode(signSource)).toString().toUpperCase();
    final body = '$jsonText$sign';
    final packet = _buildPacket(cmd: 0x03, payload: utf8.encode(body));
    _log(
      'send business cmd=0x03, msgType=$msgType, paramCount=${params.length}',
    );
    await _write(packet);
  }

  Future<void> _write(List<int> packet) async {
    final hex = _bytesToHex(packet);
    _sendQueue.add(hex);
    if (_sending) return;
    _sending = true;
    try {
      while (_sendQueue.isNotEmpty && _writeChar != null) {
        final item = _sendQueue.removeAt(0);
        final data = _hexToBytes(item);
        _log('write packet len=${data.length}, hex=${_shortHex(item)}');
        if (Platform.isIOS) {
          // iOS 使用分片写入，避免长包写入失败或丢包。
          var offset = 0;
          while (offset < data.length) {
            final end = (offset + _iosWriteChunkSize < data.length)
                ? offset + _iosWriteChunkSize
                : data.length;
            final chunk = data.sublist(offset, end);
            _log('write chunk offset=$offset, len=${chunk.length}');
            await _writeChar!.write(chunk, withoutResponse: false);
            offset = end;
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }
        } else {
          await _writeChar!.write(data, withoutResponse: false);
        }
        await Future<void>.delayed(_packetSendInterval);
      }
    } catch (_) {
      _sendQueue.clear();
      onError('write-failed');
      _scheduleReconnect();
    } finally {
      _sending = false;
    }
  }

  List<int> _buildPacket({required int cmd, required List<int> payload}) {
    final dataLen = payload.length;
    final lenHigh = (dataLen >> 8) & 0xFF;
    final lenLow = dataLen & 0xFF;
    final crc = _crc16(<int>[0xBB, 0x66, cmd, lenHigh, lenLow, ...payload]);
    return <int>[
      0xBB,
      0x66,
      cmd,
      lenHigh,
      lenLow,
      ...payload,
      (crc >> 8) & 0xFF,
      crc & 0xFF,
    ];
  }

  void _onNotifyData(List<int> data) {
    _log('notify len=${data.length}, hex=${_shortHex(_bytesToHex(data))}');
    _rxBuffer.addAll(data);
    _decodeBuffer();
  }

  void _decodeBuffer() {
    while (_rxBuffer.length >= 7) {
      var head = -1;
      for (var i = 0; i < _rxBuffer.length - 1; i++) {
        if (_rxBuffer[i] == 0xBB && _rxBuffer[i + 1] == 0x66) {
          head = i;
          break;
        }
      }
      if (head < 0) {
        _rxBuffer.clear();
        return;
      }
      if (head > 0) {
        _rxBuffer.removeRange(0, head);
      }
      if (_rxBuffer.length < 5) {
        return;
      }

      final cmd = _rxBuffer[2] & 0xFF;
      final len = ((_rxBuffer[3] & 0xFF) << 8) | (_rxBuffer[4] & 0xFF);
      final total = 7 + len;
      if (_rxBuffer.length < total) {
        return;
      }
      final payload = _rxBuffer.sublist(5, 5 + len);
      _rxBuffer.removeRange(0, total);

      if (cmd == 0x02) {
        if (payload.isNotEmpty && payload.first == 1) {
          _log('authorization success');
          _authorized = true;
          onAuthorized();
        } else {
          _log('authorization failed');
          _authorized = false;
          onError('auth-failed');
          // Native Android flow reconnects after auth failure via disconnect callback.
          _device?.disconnect();
        }
        continue;
      }

      if (cmd == 0x03) {
        final raw = utf8.decode(payload, allowMalformed: true);
        final jsonText = raw.length > 32
            ? raw.substring(0, raw.length - 32)
            : raw;
        _log('recv business cmd=0x03, jsonLen=${jsonText.length}');
        if (jsonText.trim().isNotEmpty) {
          onJsonData(jsonText);
        }
      }
    }
  }

  String _shortHex(String hex) {
    const keep = 96;
    if (hex.length <= keep) return hex;
    return '${hex.substring(0, keep)}...';
  }

  bool _isTargetName(String value) {
    if (value.isEmpty || _deviceSn.isEmpty) return false;
    final left = value.toLowerCase();
    final right = _deviceSn.toLowerCase();
    return left == right;
  }

  int _crc16(List<int> data) {
    const table = <int>[
      0x0000,
      0x1021,
      0x2042,
      0x3063,
      0x4084,
      0x50A5,
      0x60C6,
      0x70E7,
      0x8108,
      0x9129,
      0xA14A,
      0xB16B,
      0xC18C,
      0xD1AD,
      0xE1CE,
      0xF1EF,
    ];
    var value = 0;
    for (final byte in data) {
      var temp = ((value >> 8) >> 4) & 0x0F;
      value = (value << 4) & 0xFFFF;
      var idx = temp ^ ((byte >> 4) & 0x0F);
      value ^= table[idx] & 0xFFFF;

      temp = ((value >> 8) >> 4) & 0x0F;
      value = (value << 4) & 0xFFFF;
      idx = temp ^ (byte & 0x0F);
      value ^= table[idx] & 0xFFFF;
    }
    return value & 0xFFFF;
  }

  List<int> _hexToBytes(String hex) {
    final out = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      out.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return out;
  }

  String _bytesToHex(List<int> bytes) {
    final b = StringBuffer();
    for (final v in bytes) {
      b.write(v.toRadixString(16).padLeft(2, '0'));
    }
    return b.toString();
  }
}
