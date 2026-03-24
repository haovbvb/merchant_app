import 'package:flutter/material.dart';

import 'colors.dart';

class AppDimens {
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double radius12 = 12;
  static const double radius16 = 16;
  static const double listHeaderVertical = 6;
  static const double listRowVertical = 8;
}

class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

class AppDivider {
  static Divider thin() => Divider(
        height: 1,
        thickness: 1,
        color: AppColors.divider,
      );

  static Divider short({double indent = 0, double endIndent = 0}) => Divider(
        height: 1,
        thickness: 1,
        indent: indent,
        endIndent: endIndent,
        color: AppColors.divider,
      );
}
