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
  static final Guid _notifyUuid = Guid('00008911-0000-1000-8000-00805f9b34fb');
  static final Guid _writeUuid = Guid('00008912-0000-1000-8000-00805f9b34fb');

  BluetoothDevice? _device;
  BluetoothCharacteristic? _writeChar;
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  bool _scanning = false;
  bool _connecting = false;
  bool _authorized = false;
  bool _reconnectPending = false;
  String _deviceSn = '';
  String _secretKey = '';
  final List<int> _rxBuffer = <int>[];
  final List<String> _sendQueue = <String>[];
  bool _sending = false;

  bool get isConnected => _device != null && _writeChar != null;

  Future<void> start({
    required String deviceSn,
    required String secretKey,
  }) async {
    if (deviceSn.isEmpty || secretKey.isEmpty) return;
    final sameTarget = _deviceSn == deviceSn && _secretKey == secretKey;
    _deviceSn = deviceSn;
    _secretKey = secretKey;
    if (sameTarget && isConnected) {
      onPhaseChanged(CabinetBleConnectionPhase.connected);
      return;
    }
    await stop();

    final permission = await ensureBluetoothPermission();
    if (!permission.granted) {
      onConnectionChanged(false);
      onPhaseChanged(CabinetBleConnectionPhase.idle);
      onError('permission-denied');
      return;
    }

    if (Platform.isAndroid) {
      final adapterState = await FlutterBluePlus.adapterState.first;
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

  Future<void> stop() async {
    _authorized = false;
    _rxBuffer.clear();
    _sendQueue.clear();
    _sending = false;
    _scanning = false;
    _connecting = false;
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
    onPhaseChanged(CabinetBleConnectionPhase.scanning);
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();
    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (!_scanning) return;
      for (final result in results) {
        if (result.device.platformName == _deviceSn) {
          _scanning = false;
          FlutterBluePlus.stopScan();
          _connect(result.device);
          break;
        }
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 60),
        androidUsesFineLocation: true,
      );
      if (_scanning) {
        _scanning = false;
        onError('scan-timeout');
        _scheduleReconnect();
      }
    } catch (_) {
      _scanning = false;
      onError('scan-failed');
      _scheduleReconnect();
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    if (_connecting) return;
    _connecting = true;
    onPhaseChanged(CabinetBleConnectionPhase.connecting);
    try {
      await device.connect(timeout: const Duration(seconds: 12));
      final services = await device.discoverServices();
      BluetoothService? service;
      for (final s in services) {
        final uuid = s.uuid.toString().toLowerCase();
        if (uuid == _serviceUuid.toString().toLowerCase() ||
            uuid.contains('8910')) {
          service = s;
          break;
        }
      }
      service ??= services.isNotEmpty ? services.first : null;
      if (service == null) {
        throw StateError('ble-service-not-found');
      }

      BluetoothCharacteristic? write;
      BluetoothCharacteristic? notify;
      for (final c in service.characteristics) {
        final u = c.uuid.toString().toLowerCase();
        if (u == _writeUuid.toString().toLowerCase() || u.contains('8912')) {
          write = c;
        }
        if (u == _notifyUuid.toString().toLowerCase() || u.contains('8911')) {
          notify = c;
        }
      }
      write ??= service.characteristics.isNotEmpty
          ? service.characteristics.first
          : null;
      notify ??= service.characteristics.isNotEmpty
          ? service.characteristics.first
          : null;
      if (write == null || notify == null) {
        throw StateError('ble-characteristic-not-found');
      }

      await notify.setNotifyValue(true);
      await _notifySub?.cancel();
      _notifySub = notify.onValueReceived.listen(_onNotifyData);

      await _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        final connected = state == BluetoothConnectionState.connected;
        onConnectionChanged(connected);
        onPhaseChanged(
          connected
              ? CabinetBleConnectionPhase.connected
              : CabinetBleConnectionPhase.reconnecting,
        );
        if (!connected) {
          _authorized = false;
          _writeChar = null;
          _device = null;
          _scheduleReconnect();
        }
      });

      _device = device;
      _writeChar = write;
      onConnectionChanged(true);
      onPhaseChanged(CabinetBleConnectionPhase.connected);
      await _sendAuthorization();
    } catch (_) {
      onConnectionChanged(false);
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _scheduleReconnect() {
    if (_reconnectPending || _deviceSn.isEmpty || _secretKey.isEmpty) return;
    _reconnectPending = true;
    onPhaseChanged(CabinetBleConnectionPhase.reconnecting);
    Future<void>.delayed(const Duration(seconds: 10), () async {
      _reconnectPending = false;
      if (isConnected || _connecting || _scanning) return;
      await _scanAndConnect();
    });
  }

  Future<void> _sendAuthorization() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final signSource = '$_deviceSn||key_authorization||$timestamp';
    final sign = md5.convert(utf8.encode(signSource)).toString();
    final payload = '$timestamp$sign';
    final packet = _buildPacket(cmd: 0x01, payload: utf8.encode(payload));
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
    final signSource = '$jsonText||key_data||$_secretKey';
    final sign = md5.convert(utf8.encode(signSource)).toString();
    final body = '$jsonText$sign';
    final packet = _buildPacket(cmd: 0x03, payload: utf8.encode(body));
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
        await _writeChar!.write(data, withoutResponse: false);
        await Future<void>.delayed(const Duration(milliseconds: 50));
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
    final crc = _crc16(payload);
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
          _authorized = true;
          onAuthorized();
        } else {
          _authorized = false;
          onError('auth-failed');
        }
        continue;
      }

      if (cmd == 0x03) {
        final raw = utf8.decode(payload, allowMalformed: true);
        final jsonText = raw.length > 32
            ? raw.substring(0, raw.length - 32)
            : raw;
        if (jsonText.trim().isNotEmpty) {
          onJsonData(jsonText);
        }
      }
    }
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
