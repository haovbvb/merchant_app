import 'package:intl/intl.dart';

class DateFormatUtils {
  DateFormatUtils._();

  static const String defaultLocale = 'en';
  static const String defaultPattern = 'MMM dd, yyyy HH:mm:ss';
  static const String datePattern = 'MMM dd, yyyy';
  static const String dateTimeNoSecondsPattern = 'MMM dd, yyyy HH:mm';

  static String format(
    DateTime? date, {
    String pattern = defaultPattern,
    String fallback = '-',
  }) {
    if (date == null) return fallback;
    try {
      return DateFormat(pattern, defaultLocale).format(date);
    } catch (_) {
      // Keep UI available even when locale data has not been initialized yet.
      return _formatFallback(date);
    }
  }

  static String formatTimestamp(
    int? value, {
    String pattern = defaultPattern,
    String fallback = '-',
  }) {
    final millis = _normalizeToMillis(value);
    if (millis == null) return fallback;
    return format(
      DateTime.fromMillisecondsSinceEpoch(millis),
      pattern: pattern,
      fallback: fallback,
    );
  }

  static String formatString(
    String? value, {
    String pattern = defaultPattern,
    String fallback = '-',
  }) {
    final date = parse(value);
    if (date == null) return fallback;
    return format(date, pattern: pattern, fallback: fallback);
  }

  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is num) {
      final millis = _normalizeToMillis(value.toInt());
      return millis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(millis);
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    final numeric = int.tryParse(raw);
    if (numeric != null) {
      final millis = _normalizeToMillis(numeric);
      return millis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(millis);
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;

    final normalized = raw.replaceAll('/', '-');
    final isoCandidate = normalized.contains('T')
        ? normalized
        : normalized.replaceFirst(' ', 'T');
    return DateTime.tryParse(isoCandidate);
  }

  static int? _normalizeToMillis(int? value) {
    if (value == null || value <= 0) return null;
    return value < 100000000000 ? value * 1000 : value;
  }

  static String _formatFallback(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }
}
