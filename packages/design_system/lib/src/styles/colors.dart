import 'package:flutter/material.dart';

class AppColors {
  static const Color black09Text = Color(0xE6000000);
  static const Color black08Text = Color(0xCC000000);
  static const Color black07Text = Color(0xB3000000);
  static const Color black06Text = Color(0x99000000);
  static const Color black05Text = Color(0x7F000000);
  static const Color black04Text = Color(0x66000000);
  static const Color black03Text = Color(0x4D000000);
  static const Color black02Text = Color(0x33000000);
  static const Color black025Text = Color(0x40000000);
  static const Color black54 = Color(0x8A000000);

  static const Color white09Text = Color(0xE6FFFFFF);

  static const Color primaryColor = Color(0xFF08983B);
  static const Color secondaryColor = Color(0xFFFA4332);

  static const Color bgColor = Color(0xFFF5F6F7);
  static Color borderColor = Colors.black.withValues(alpha: 0.06);

  static Color divider = Colors.black.withValues(alpha: 0.06);
  static Color cardBg = Colors.white;
  static const Color greyBg = Color(0xFFF6F8FC);

  static const Color success = Color(0xFF08983B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFFA4332);

  static Color onColor(Color bg) {
    final l = bg.computeLuminance();
    return l > 0.5 ? const Color(0xFF111827) : Colors.white;
  }
}
