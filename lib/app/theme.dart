import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'styles/colors.dart';
import 'styles/typography.dart';

class BaseTheme {
  // Brand colors
  static const Color primaryColor = AppColors.primaryColor; // main_color
  static const Color hiveBrown = Color(0xFF61729D); // color_61729d
  static const Color energyOrange = Color(0xFFFFA034); // color_ffa034
  static const Color paperIvory = Color(0xFFF5F6F7); // color_f5f6f7
  static const Color textDark = Color(0xFF1E2126); // color_1e2126
  static const Color textMuted = Color(0xFF6C7180); // color_6c7180

  static ThemeData lightTheme({TargetPlatform? platform}) {
    final base = ThemeData.light();
    final pf = platform ?? defaultTargetPlatform;
    final isIOS = pf == TargetPlatform.iOS || pf == TargetPlatform.macOS;
    final adjustedTextTheme = AppTypography.buildBase(
      base.textTheme,
      isIOS: isIOS,
    ).apply(bodyColor: textDark, displayColor: textDark);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: energyOrange,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: paperIvory,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0.0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
      textTheme: adjustedTextTheme,
    );
  }

  static ThemeData darkTheme({TargetPlatform? platform}) {
    final base = ThemeData.dark();
    final pf = platform ?? defaultTargetPlatform;
    final isIOS = pf == TargetPlatform.iOS || pf == TargetPlatform.macOS;
    final adjusted = AppTypography.buildBase(
      base.textTheme,
      isIOS: isIOS,
    ).apply(bodyColor: Colors.white, displayColor: Colors.white);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: energyOrange,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
      textTheme: adjusted,
    );
  }
}
