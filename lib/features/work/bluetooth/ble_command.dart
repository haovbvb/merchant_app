class BleCommandBuilder {
  static const String serviceId = '0000FFE0-0000-1000-8000-00805F9B34FB';
  static const String readUuid = '0000FFE4-0000-1000-8000-00805F9B34FB';
  static const String writeUuid = '0000FFE9-0000-1000-8000-00805F9B34FB';

  static const String commandHead = '7E';
  static const String commandEnd = '7E7E';
  static const String command1 = '01';
  static const String command2 = '00';
  static const String command3 = '32';
  static const String command4 = '00';

  static const String userPwd = '55707578';
  static const String rights = '00';
  static const String lockPwd = '5570757890354130';
  static const String lockBlock = '00000000';
  static const String bleKeyBlock = '00000000';

  static String buildReadKeyIdData() => userPwd;

  static String buildClearAuthorizationData(String keyId) {
    return userPwd + keyId + bleKeyBlock;
  }

  static String buildResetAuthorizationData(DateTime now) {
    final setKeyTime = _getBCD(DateTime(now.year + 10, now.month, now.day, now.hour, now.minute));
    return userPwd + setKeyTime + bleKeyBlock;
  }

  static String buildAddAuthorizationData({
    required String keyId,
    required String lockId,
    required String userNum,
    required int days,
  }) {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    final end = DateTime.now().add(Duration(days: days));
    final startTime = _getBCD(now);
    final endTime = _getBCD(end);
    final userChar = _getUserChar(keyId);
    return userChar + lockId + rights + startTime + endTime + userNum + lockPwd + lockBlock;
  }

  static String buildFactoryAuthorizationData({
    required String keyId,
    required int days,
  }) {
    final now = DateTime.now().subtract(const Duration(hours: 1));
    final end = DateTime.now().add(Duration(days: days));
    final startTime = _getBCD(now);
    final endTime = _getBCD(end);
    final userChar = _getUserChar(keyId);
    const facLockId = '0a000000';
    const facRight = '06';
    const facUserNum = '00000000';
    return userChar + facLockId + facRight + startTime + endTime + facUserNum + lockPwd + lockBlock;
  }

  static String buildCommand({
    required String signal,
    required String plainHex,
    required String encryptedHex,
  }) {
    final length = (plainHex.length ~/ 2) + 2;
    var commandLen = '00${length.toRadixString(16)}';
    if (commandLen.length < 4) {
      commandLen = '0$commandLen';
    }
    final crcStr = command1 + command2 + command3 + command4 + commandLen + signal + encryptedHex;
    final crc = _crc16(crcStr);
    var commandBody = (crcStr + crc).toLowerCase();
    final escaped = StringBuffer();
    for (var i = 0; i < commandBody.length; i += 2) {
      var part = commandBody.substring(i, i + 2);
      if (part == '7d') {
        part = '7d5d';
      } else if (part == '7e') {
        part = '7d5e';
      }
      escaped.write(part);
    }
    commandBody = escaped.toString();
    return (commandHead + commandBody + commandEnd).toLowerCase();
  }

  static String unescapeResponse(String hex) {
    return hex.replaceAll('7d5d', '7d').replaceAll('7d5e', '7e');
  }

  static String extractSignal(String hex) {
    if (hex.length < 18) return hex;
    return hex.substring(14, 18);
  }

  static String extractDecryptStr(String hex) {
    if (hex.length < 18) return hex;
    return hex.substring(18, hex.length - 8);
  }

  static String _getUserChar(String keyId) {
    final userPwdArray = _toArray(userPwd);
    final keyIdArray = _toArray(keyId);
    var result = userPwdArray[0];
    result ^= userPwdArray[1];
    result ^= userPwdArray[2];
    result ^= userPwdArray[3];
    result ^= keyIdArray[0];
    result ^= keyIdArray[1];
    result ^= keyIdArray[2];
    result ^= keyIdArray[3];
    var resultData = result.toRadixString(16);
    if (resultData.length < 2) {
      resultData = '0$resultData';
    }
    return resultData;
  }

  static List<int> _toArray(String hexStr) {
    final count = hexStr.length ~/ 2;
    final array = <int>[];
    for (var i = 0; i < count; i++) {
      final item = int.parse(hexStr.substring(i * 2, 2 * (i + 1)), radix: 16);
      array.add(item);
    }
    return array;
  }

  static String _getBCD(DateTime dateTime) {
    var year = dateTime.year - 2000;
    if (year < 0) year = 0;
    final month = dateTime.month;
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    return _formatNumber(year) +
        _formatNumber(month) +
        _formatNumber(day) +
        _formatNumber(hour) +
        _formatNumber(minute);
  }

  static String _formatNumber(int n) => n.toString().padLeft(2, '0');

  static String _crc16(String hex) {
    final clean = hex.replaceAll(' ', '');
    if (clean.length.isOdd) return '0000';
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i += 2) {
      bytes.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return _crcBySoft(bytes);
  }

  static String _crcBySoft(List<int> data) {
    final crcTable = <int>[
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
    var wValue = 0;
    for (final value in data) {
      var ucTemp = ((wValue >> 8) >> 4) & 0x0F;
      wValue = (wValue << 4) & 0xFFFF;
      var temp = ucTemp ^ ((value >> 4) & 0x0F);
      wValue ^= crcTable[temp] & 0xFFFF;

      ucTemp = ((wValue >> 8) >> 4) & 0x0F;
      wValue = (wValue << 4) & 0xFFFF;
      temp = ucTemp ^ (value & 0x0F);
      wValue ^= crcTable[temp] & 0xFFFF;
    }
    final crc0 = ((wValue >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final crc1 = (wValue & 0xFF).toRadixString(16).padLeft(2, '0');
    return crc0 + crc1;
  }
}
