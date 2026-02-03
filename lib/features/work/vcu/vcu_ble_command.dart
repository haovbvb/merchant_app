import 'dart:convert';

class VcuBleCommandParam {
  final String id;
  final Object value;

  const VcuBleCommandParam(this.id, this.value);
}

class VcuBleCommand {
  final String payload;
  final int txnNo;
  final List<VcuBleCommandParam> params;

  const VcuBleCommand({
    required this.payload,
    required this.txnNo,
    required this.params,
  });
}

class VcuBleCommandBuilder {
  static VcuBleCommand build({
    required List<VcuBleCommandParam> params,
    String devId = 'TEST',
    int? txnNo,
  }) {
    final tx = txnNo ?? DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'msgType': 500,
      'devId': devId,
      'txnNo': tx,
      'paramList': params
          .map((p) => <String, Object>{'id': p.id, 'value': p.value})
          .toList(),
    });
    return VcuBleCommand(payload: payload, txnNo: tx, params: params);
  }
}

class VcuBleCommandIds {
  static const String lock = '043010011';
  static const String launch = '043010012';
  static const String antiTheft = '043010013';
  static const String find = '043110011';
  static const String remoteLock = '043110012';
  static const String remoteUnlock = '043110013';
  static const String queryStatus = '043110015';
  static const String queryMcuVersion = '043130001';
  static const String otaVerifyVersion = '043130003';
  static const String otaUpgrade = '043130004';
  static const String otaData = '043130005';
  static const String queryIccid = '043110023';
  static const String editUrl = '043110016';
  static const String editPort = '043110017';
  static const String editApn = '043110018';
  static const String editFrequencyVehicle = '043110019';
  static const String editFrequencyVehicle1 = '043110020';
  static const String editFrequencyGps = '043110021';
  // 4轮车命令
  static const String lockCut4 = '043010005';
  static const String unlockCut4 = '043010004';
  static const String find4 = '043010006';
  // 高尔夫车命令 (解锁和锁车使用相同的 BLE ID，通过 bleValue 区分)
  static const String golfCommand = '043010007';
  // 其他命令
  static const String electronicFence = '044010013';
  static const String reset = '043110004';
}

class VcuBleUpDataIds {
  static const String mcuVersion = '043130002';
  static const String verifyResult = '043130006';
  static const String otaResult = '043130007';
}

const Map<String, String> vcuBleIdToLabel = {
  VcuBleCommandIds.lock: '一键锁车',
  VcuBleCommandIds.launch: '一键启动',
  VcuBleCommandIds.antiTheft: '防盗模式',
  VcuBleCommandIds.find: '一键找车',
  VcuBleCommandIds.remoteLock: '远程锁车',
  VcuBleCommandIds.remoteUnlock: '远程解锁',
  VcuBleCommandIds.queryStatus: '查询车辆状态',
  VcuBleCommandIds.queryMcuVersion: '查询 MCU 版本',
  VcuBleCommandIds.otaVerifyVersion: 'OTA 校验版本',
  VcuBleCommandIds.otaUpgrade: 'OTA 升级',
  VcuBleCommandIds.otaData: 'OTA 数据包',
  VcuBleCommandIds.queryIccid: '查询 ICCID',
  VcuBleCommandIds.editUrl: '设置平台地址',
  VcuBleCommandIds.editPort: '设置平台端口',
  VcuBleCommandIds.editApn: '设置 APN',
  VcuBleCommandIds.editFrequencyVehicle: '设置车辆上传频率',
  VcuBleCommandIds.editFrequencyVehicle1: '设置车辆上传频率(锂电池)',
  VcuBleCommandIds.editFrequencyGps: '设置 GPS 频率',
  // 4轮车命令
  VcuBleCommandIds.lockCut4: '一键锁车+断电(4轮车)',
  VcuBleCommandIds.unlockCut4: '一键解锁(4轮车)',
  VcuBleCommandIds.find4: '一键找车(4轮车)',
  // 高尔夫车命令
  VcuBleCommandIds.golfCommand: '高尔夫电门控制',
  // 其他命令
  VcuBleCommandIds.electronicFence: '电子围栏',
  VcuBleCommandIds.reset: '复位',
};
