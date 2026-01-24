import 'dart:io';

class VcuOtaUtil {
  static Future<List<String>> buildOtaSegments(
    File file, {
    int segmentBytes = 58,
  }) async {
    if (!await file.exists()) return [];
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return [];
    final segments = <List<int>>[];
    var start = 0;
    while (start < bytes.length) {
      var end = start + segmentBytes;
      if (end > bytes.length) {
        end = bytes.length;
      }
      segments.add(bytes.sublist(start, end));
      start = end;
    }

    final total = segments.length;
    return List.generate(total, (index) {
      final hex = _bytesToHex(segments[index]);
      return _buildOtaData(hex, total, index);
    });
  }

  static String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final value in bytes) {
      buffer.write(value.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase();
  }

  static String _intTo2ByteHexString(int value) {
    if (value < 0 || value > 65535) {
      throw ArgumentError('value out of range');
    }
    final high = (value >> 8) & 0xFF;
    final low = value & 0xFF;
    return high.toRadixString(16).padLeft(2, '0').toUpperCase() +
        low.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  static String _intToByteHexString(int value) {
    if (value < 0 || value > 65535) {
      throw ArgumentError('value out of range');
    }
    final low = value & 0xFF;
    return low.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  static String _buildOtaData(String data, int size, int index) {
    final byteLength = data.length ~/ 2;
    final lengthHex = _intToByteHexString(byteLength + 4);
    final sizeHex = _intTo2ByteHexString(size);
    final currentPack = _intTo2ByteHexString(index + 1);
    return '01A3$lengthHex$sizeHex$currentPack$data'
        '0D';
  }
}
