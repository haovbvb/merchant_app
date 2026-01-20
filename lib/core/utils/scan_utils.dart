import 'package:merchant_app/app/app_router.dart';
import 'package:merchant_app/core/utils/context_extensions.dart';
import 'package:merchant_app/core/utils/toast.dart';

class ScanUtils {
  static final RegExp _chinesePattern = RegExp(r'[\u4e00-\u9fa5]');

  static bool ensureNoChinese(String value) {
    if (value.isEmpty) return true;
    if (_chinesePattern.hasMatch(value)) {
      final context = AppRouter.navigatorKey.currentContext;
      if (context != null) {
        showToast(context.l10n.scanNoChinese);
      }
      return false;
    }
    return true;
  }

  static String getDeviceSn(String value) {
    if (value.trim().isEmpty) return '';
    if (!ensureNoChinese(value)) return '';
    var result = value.trim();

    if (result.toUpperCase().startsWith('B:')) {
      result = result
          .substring(2)
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .trim();
      return result;
    }

    final lower = result.toLowerCase();
    if ((lower.contains('sn:') || lower.contains('sn=')) &&
        _isContainsKeyValue(result)) {
      return parseBatteryQr(result, 0).sn ?? result;
    }

    if (lower.contains('sn=')) {
      final sn = result.split(RegExp('sn=', caseSensitive: false));
      if (sn.length > 1) {
        final valuePart = sn[1].split(',').first.trim();
        if (valuePart.isNotEmpty) return valuePart;
      }
    }
    if (lower.contains('sn:')) {
      final idx = lower.indexOf('sn:');
      if (idx != -1) {
        final start = idx + 3;
        final end = result.indexOf(',', start);
        final valuePart = (end == -1)
            ? result.substring(start)
            : result.substring(start, end);
        if (valuePart.trim().isNotEmpty) return valuePart.trim();
      }
    }

    if ((lower.contains('vin:') || lower.contains('vin=')) &&
        _isContainsKeyValue(result)) {
      return parseVehicleQr(result, 0).sn ?? result;
    }

    if (lower.contains('vin:')) {
      final idx = lower.indexOf('vin:');
      if (idx != -1) {
        final start = idx + 4;
        final end = result.indexOf(',', start);
        return (end == -1
            ? result.substring(start)
            : result.substring(start, end)).trim();
      }
    }
    if (lower.contains('vin=')) {
      final idx = lower.indexOf('vin=');
      if (idx != -1) {
        final start = idx + 4;
        final end = result.indexOf(',', start);
        return (end == -1
            ? result.substring(start)
            : result.substring(start, end)).trim();
      }
    }

    return result;
  }

  static QrCodeBattery parseBatteryQr(String qr, int clickType) {
    if (!ensureNoChinese(qr)) return const QrCodeBattery();
    var result = qr.trim();
    if (result.toUpperCase().startsWith('B:')) {
      result = result
          .substring(2)
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .trim();
      return QrCodeBattery(sn: result, imei: '', iccid: '');
    }

    if (qr.contains(',')) {
      if (_isContainsKeyValue(qr)) {
        final map = _splitKeyValue(qr, lowerKeys: true);
        final sn = map['sn'];
        final imei = map['imei'];
        final iccid = map['iccid'];
        if ((sn ?? '').isNotEmpty || (imei ?? '').isNotEmpty || (iccid ?? '').isNotEmpty) {
          return QrCodeBattery(sn: sn, imei: imei, iccid: iccid);
        }
        return QrCodeBattery(sn: qr, imei: '', iccid: '');
      }
      return _dealBatteryNotContainsKeyValue(qr.trim(), clickType);
    }
    return _dealBatteryNotContainsKeyValue(qr.trim(), clickType);
  }

  static QrCodeVehicle parseVehicleQr(String qr, int clickType) {
    if (!ensureNoChinese(qr)) return const QrCodeVehicle();
    var result = qr.trim();
    if (result.toUpperCase().startsWith('B:')) {
      result = result
          .substring(2)
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .replaceAll(' ', '')
          .replaceAll('\n', '')
          .trim();
      return QrCodeVehicle(sn: result, vin: result, vcu: '');
    }

    if (qr.contains(',')) {
      if (_isContainsKeyValue(qr)) {
        final map = _splitKeyValue(qr, upperKeys: true);
        final sn = map['VIN'];
        final vin = map['VIN'];
        final vcu = map['VCU'];
        if ((sn ?? '').isNotEmpty || (vin ?? '').isNotEmpty || (vcu ?? '').isNotEmpty) {
          return QrCodeVehicle(sn: sn, vin: vin, vcu: vcu);
        }
        return QrCodeVehicle(sn: qr, vin: qr, vcu: '');
      }
      return _dealVehicleNotContainsKeyValue(qr.trim(), clickType);
    }
    return _dealVehicleNotContainsKeyValue(qr.trim(), clickType);
  }

  static QrCodeStation parseStationQr(String qr) {
    if (!ensureNoChinese(qr)) return const QrCodeStation();
    final lower = qr.toLowerCase();
    if (lower.contains('sn=') && lower.contains('bt=') && qr.contains('&')) {
      final query = qr.contains('?') ? qr.split('?').last : qr;
      final map = query.split('&').fold<Map<String, String>>({}, (acc, part) {
        final kv = part.split('=');
        if (kv.length == 2) {
          acc[kv[0].toLowerCase().trim()] = kv[1].trim();
        }
        return acc;
      });
      return QrCodeStation(sn: map['sn'] ?? '', lockDevId: map['bt'] ?? '');
    }

    if (lower.contains('sn=') && !lower.contains('bt=')) {
      if (qr.contains(',')) {
        if (_isContainsKeyValue(qr)) {
          final map = _splitKeyValue(qr, lowerKeys: true, delimiter: ',');
          return QrCodeStation(sn: map['sn'] ?? '', lockDevId: '');
        }
        return QrCodeStation(sn: _extractAfter(qr, 'sn='), lockDevId: '');
      }
      return QrCodeStation(sn: _extractAfter(qr, 'sn='), lockDevId: '');
    }

    return QrCodeStation(sn: qr, lockDevId: '');
  }

  static String parseSnByDeviceType(String value, int? deviceType) {
    if (value.trim().isEmpty) return '';
    if (!ensureNoChinese(value)) return '';
    switch (deviceType) {
      case 1:
        return parseBatteryQr(value, 0).sn ?? '';
      case 2:
        return parseVehicleQr(value, 0).sn ?? '';
      case 3:
        return parseStationQr(value).sn ?? '';
      default:
        return getDeviceSn(value);
    }
  }

  static String getUserCarNum(String value) {
    if (value.trim().isEmpty) return '';
    if (!ensureNoChinese(value)) return '';
    final lower = value.toLowerCase();
    if (lower.contains('cardnum')) {
      final idx = lower.indexOf('cardnum=');
      if (idx != -1) {
        return value.substring(idx + 8).trim();
      }
    }
    return value.trim();
  }

  static String _extractAfter(String value, String key) {
    final lower = value.toLowerCase();
    final idx = lower.indexOf(key);
    if (idx == -1) return value;
    return value.substring(idx + key.length).trim();
  }

  static Map<String, String> _splitKeyValue(
    String input, {
    bool lowerKeys = false,
    bool upperKeys = false,
    String delimiter = ',',
  }) {
    final normalized = input.replaceAll(RegExp(r'[\r\n]+'), delimiter);
    final parts = normalized.split(delimiter);
    final map = <String, String>{};
    for (final part in parts) {
      final clean = part.trim();
      if (clean.isEmpty) continue;
      final kv = clean.split(RegExp('[:=]'));
      if (kv.length < 2) continue;
      final key = kv[0].trim();
      final value = clean.substring(clean.indexOf(RegExp('[:=]')) + 1).trim();
      if (key.isEmpty || value.isEmpty) continue;
      if (lowerKeys) {
        map[key.toLowerCase()] = value;
      } else if (upperKeys) {
        map[key.toUpperCase()] = value;
      } else {
        map[key] = value;
      }
    }
    return map;
  }

  static QrCodeVehicle _dealVehicleNotContainsKeyValue(String qr, int clickType) {
    final qrUpper = qr.toUpperCase();
    if (!(qrUpper.contains('VIN:') || qrUpper.contains('VIN='))) {
      if (clickType == 2) {
        return QrCodeVehicle(sn: '', vin: '', vcu: qr);
      }
      return QrCodeVehicle(sn: qr, vin: qr, vcu: '');
    }
    if (qrUpper.contains('VIN:')) {
      final idx = qrUpper.indexOf('VIN:');
      final vehicleSn = idx != -1 ? qr.substring(idx + 4).trim() : qr.trim();
      if (clickType == 2) {
        return QrCodeVehicle(sn: '', vin: '', vcu: qr);
      }
      return QrCodeVehicle(sn: vehicleSn, vin: vehicleSn, vcu: '');
    }
    if (qrUpper.contains('VIN=')) {
      final idx = qrUpper.indexOf('VIN=');
      final vehicleSn = idx != -1 ? qr.substring(idx + 4).trim() : qr.trim();
      if (clickType == 2) {
        return QrCodeVehicle(sn: '', vin: '', vcu: qr);
      }
      return QrCodeVehicle(sn: vehicleSn, vin: vehicleSn, vcu: '');
    }
    return QrCodeVehicle(sn: qr, vin: qr, vcu: '');
  }

  static QrCodeBattery _dealBatteryNotContainsKeyValue(String qr, int clickType) {
    if (!qr.toLowerCase().contains('sn=')) {
      if (clickType == 1) {
        return QrCodeBattery(sn: '', imei: qr, iccid: '');
      }
      if (clickType == 2) {
        return QrCodeBattery(sn: '', imei: '', iccid: qr);
      }
      return QrCodeBattery(sn: qr, imei: '', iccid: '');
    }
    var batterySn = qr;
    final idx = qr.toLowerCase().indexOf('sn=');
    if (idx > -1) {
      batterySn = qr.substring(idx + 3);
    }
    if (clickType == 1) {
      return QrCodeBattery(sn: '', imei: qr, iccid: '');
    }
    if (clickType == 2) {
      return QrCodeBattery(sn: '', imei: '', iccid: qr);
    }
    return QrCodeBattery(sn: batterySn, imei: '', iccid: '');
  }

  static bool _isContainsKeyValue(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    final normalized = trimmed
        .replaceAll(RegExp(r'[\r\n]+'), '')
        .replaceAll(RegExp(r'[;|]'), ',');
    final tokens = normalized
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return false;
    final allKeyValue = tokens.every((token) =>
        token.contains(':') || token.contains('='));
    return allKeyValue;
  }
}

class QrCodeBattery {
  final String? sn;
  final String? imei;
  final String? iccid;

  const QrCodeBattery({this.sn, this.imei, this.iccid});
}

class QrCodeVehicle {
  final String? sn;
  final String? vin;
  final String? vcu;

  const QrCodeVehicle({this.sn, this.vin, this.vcu});
}

class QrCodeStation {
  final String? sn;
  final String? lockDevId;

  const QrCodeStation({this.sn, this.lockDevId});
}
