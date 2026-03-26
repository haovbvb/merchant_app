import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../styles/colors.dart';
import '../styles/design.dart';
import '../styles/typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      useMaterial3: true,
    );

    final textTheme = AppTypography.buildBase(
      base.textTheme,
      isIOS: defaultTargetPlatform == TargetPlatform.iOS,
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.surfacePage,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceCard,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radius16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDefault,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.surfaceCard,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(color: AppColors.borderSubtle),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textHint),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorderDefault),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.inputBorderFocused, width: 1.5),
        ),
      ),
    );
  }
}
