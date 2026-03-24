import 'package:flutter/material.dart';

class AppTypography {
  static bool useBundledFonts = false;

  static const String bundledLatin = 'Inter';
  static const String bundledCJK = 'NotoSansSC';
  static const String systemCJKiOS = 'PingFang SC';

  static TextTheme buildBase(TextTheme base, {required bool isIOS}) {
    final bodyW = FontWeight.w400;
    final titleW = FontWeight.w600;
    final useBundledHere = useBundledFonts && !isIOS;
    final latin =
        useBundledHere ? bundledLatin : (isIOS ? 'Helvetica Neue' : 'Roboto');
    final cjk = useBundledHere ? bundledCJK : (isIOS ? systemCJKiOS : 'NotoSans');
    final familyFallback = <String>{
      latin,
      cjk,
      'PingFang SC',
      'Helvetica Neue',
      'Roboto',
      'Arial',
    };

    TextStyle merge(TextStyle? src, double size, FontWeight w, {double? height}) {
      return (src ?? const TextStyle()).copyWith(
        fontSize: size,
        fontWeight: w,
        height: height ?? 1.25,
        fontFamily: latin,
        fontFamilyFallback: familyFallback.toList(),
      );
    }

    return base.copyWith(
      bodySmall: merge(base.bodySmall, 12, bodyW),
      bodyMedium: merge(base.bodyMedium, 14, bodyW),
      bodyLarge: merge(base.bodyLarge, 15, bodyW, height: 1.28),
      labelLarge: merge(base.labelLarge, 13, FontWeight.w600),
      titleMedium: merge(base.titleMedium, 15, FontWeight.w500),
      titleLarge: merge(base.titleLarge, 18, titleW, height: 1.3),
      headlineSmall: merge(base.headlineSmall, 20, titleW, height: 1.3),
    );
  }
}
