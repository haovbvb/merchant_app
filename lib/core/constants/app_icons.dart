import 'package:flutter/material.dart';

/// 应用图标常量
class AppIcons {
  AppIcons._();

  /// 扫码图标（黑色）
  static const String scanBlack = 'assets/android/mipmap-xxhdpi/icon_black_scan.png';

  /// 扫码图标 Widget
  static Widget scanIcon({double size = 24, Color? color}) {
    return Image.asset(
      scanBlack,
      width: size,
      height: size,
      color: color,
    );
  }
}
