import 'package:flutter/material.dart';

class AppColors {
  // Naming guide:
  // 1) Prefer semantic tokens in UI code (text/surface/border/status/overlay).
  // 2) Keep component-scoped tokens under dedicated sections (profile/scan).
  // 3) Legacy aliases are compatibility-only; avoid using them in new code.

  // Brand
  static const Color primaryColor = Color(0xFF08983B);
  static const Color secondaryColor = Color(0xFFFA4332);

  // Semantic - text/icon
  static const Color textPrimary = Color(0xE6000000);
  static const Color textSecondary = Color(0xCC000000);
  static const Color textTertiary = Color(0xB3000000);
  static const Color textQuaternary = Color(0x99000000);
  static const Color textDisabled = Color(0x7F000000);
  static const Color textHint = Color(0x66000000);
  static const Color textSubtle = Color(0x4D000000);
  static const Color textUltraSubtle = Color(0x33000000);
  static const Color textInversePrimary = Color(0xE6FFFFFF);
  static const Color textPlaceholder = Color(0xFF999999);

  // Semantic - surfaces
  static const Color surfacePage = Color(0xFFF5F6F7);
  static const Color surfaceCard = Colors.white;
  static const Color surfaceMuted = Color(0xFFF6F8FC);
  static const Color iconMuted = Color(0x8A000000);

  // Semantic - borders/dividers
  static final Color borderSubtle = Colors.black.withValues(alpha: 0.06);
  static final Color dividerDefault = Colors.black.withValues(alpha: 0.06);
  static const Color inputBorderDefault = Color(0xFFE5E5E5);
  static const Color inputBorderFocused = Color(0xFFB7E1A8);

  // Primitive palette (keep for utility-style usage)
  static const Color slate500 = Color(0xFF64748B);

  // Component tokens (profile)
  static const Color profileActionMessageBg = Color(0xFFFFD54F);
  static const Color profileActionPasswordBg = Color(0xFF9575CD);
  static const Color profileActionLanguageBg = Color(0xFF64B5F6);
  static const Color profileActionAgreementBg = Color(0xFF66BB6A);
  static const Color profileActionAboutBg = Color(0xFFFFB74D);
  static const Color profileAvatarPlaceholderBg = Color(0xFFECEFF3);
  static const Color profileAvatarPlaceholderFg = Color(0xFF8D95A3);
  static const Color profileActionIcon = Color(0xFF5B6270);
  static const Color profileBadgeBg = Color(0xFFFF6F61);
  static const Color profileChevron = Color(0xFFB0B8C4);
  static const Color profileAvatarHintBorder = Color(0xFFDFE3E8);
  static const Color profileAboutHeroStart = Color(0xFF2D3440);
  static const Color profileAboutHeroEnd = Color(0xFF5A6474);
  static const Color profileAboutIconBg = Color(0x33FFFFFF);
  static const Color profileAboutVersionDot = Color(0xFFFA4B51);

  // Component tokens (scan)
  static const Color scanPanelBg = Color(0xCC3C3C3C);
  static const Color scanTorchOn = Color(0xFF0A84FF);
  static const Color scanTorchOff = Color(0x80808080);
  static const Color scanMask = Color(0x99000000);
  static const Color scanLine = Color(0xAA18E0A1);
  static const Color scanLineTransparent = Color(0x0018E0A1);

  // Status
  static const Color success = Color(0xFF08983B);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFFA4332);

  // Legacy compatibility aliases (gradual migration)
  static const Color black09Text = textPrimary;
  static const Color black08Text = textSecondary;
  static const Color black07Text = textTertiary;
  static const Color black06Text = textQuaternary;
  static const Color black05Text = textDisabled;
  static const Color black04Text = textHint;
  static const Color black03Text = textSubtle;
  static const Color black02Text = textUltraSubtle;
  static const Color black025Text = Color(0x40000000);
  static const Color black54 = iconMuted;
  static const Color white09Text = textInversePrimary;
  static const Color bgColor = surfacePage;
  static final Color borderColor = borderSubtle;
  static final Color divider = dividerDefault;
  static const Color cardBg = surfaceCard;
  static const Color greyBg = surfaceMuted;

  static Color onColor(Color bg) {
    final l = bg.computeLuminance();
    return l > 0.5 ? const Color(0xFF111827) : Colors.white;
  }
}
