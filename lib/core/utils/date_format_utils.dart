import 'package:intl/intl.dart';

/// Date/time formatting helpers with a default English locale.
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
    return DateFormat(pattern, defaultLocale).format(date);
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

  static String formatTimestampSeconds(
    int? seconds, {
    String pattern = defaultPattern,
    String fallback = '-',
  }) {
    if (seconds == null || seconds <= 0) return fallback;
    return format(
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
      pattern: pattern,
      fallback: fallback,
    );
  }

  static String formatTimestampMillis(
    int? millis, {
    String pattern = defaultPattern,
    String fallback = '-',
  }) {
    if (millis == null || millis <= 0) return fallback;
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
    // Try ISO parsing.
    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;
    // Try common "yyyy/MM/dd HH:mm:ss" by converting to ISO.
    final normalized = raw.replaceAll('/', '-');
    final isoCandidate = normalized.contains('T')
        ? normalized
        : normalized.replaceFirst(' ', 'T');
    return DateTime.tryParse(isoCandidate);
  }

  static int? _normalizeToMillis(int? value) {
    if (value == null || value <= 0) return null;
    // If value looks like seconds (10 digits), convert to millis.
    return value < 100000000000 ? value * 1000 : value;
  }
}
