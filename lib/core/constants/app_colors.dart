import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- dark backgrounds ---
  static const kBackground = Color(0xFF0A0B14);
  static const kSurface = Color(0xFF12141F);
  static const kSurfaceVariant = Color(0xFF1C1F2E);
  static const kSurfaceHigh = Color(0xFF252838);

  // --- light backgrounds ---
  static const kBackgroundLight = Color(0xFFF8F9FF);
  static const kSurfaceLight = Color(0xFFFFFFFF);
  static const kSurfaceVariantLight = Color(0xFFF0F2FF);
  static const kSurfaceHighLight = Color(0xFFE8EBFF);

  // --- primary (indigo) ---
  static const kPrimary = Color(0xFF7C6FE8);
  static const kPrimaryLight = Color(0xFF9D94F0);
  static const kPrimaryDark = Color(0xFF5A4FBE);
  static const kPrimaryContainer = Color(0xFF1E1A3A);
  static const kPrimaryContainerLight = Color(0xFFEDE9FF);

  // --- secondary (mint teal) ---
  static const kSecondary = Color(0xFF4ECDC4);
  static const kSecondaryLight = Color(0xFF7EDDD6);
  static const kSecondaryContainer = Color(0xFF0F2A28);
  static const kSecondaryContainerLight = Color(0xFFE0F7F5);

  // --- accent — only for streaks, XP, badges ---
  static const kAccent = Color(0xFFFF6B9D);
  static const kAccentLight = Color(0xFFFF9DBD);
  static const kAccentContainer = Color(0xFF2D0F1C);
  static const kAccentContainerLight = Color(0xFFFFE4EE);

  // --- semantic ---
  static const kSuccess = Color(0xFF51CF66);
  static const kSuccessContainer = Color(0xFF0D2B13);
  static const kSuccessContainerLight = Color(0xFFDFF7E3);

  static const kError = Color(0xFFFF6B6B);
  static const kErrorContainer = Color(0xFF2B0D0D);
  static const kErrorContainerLight = Color(0xFFFFE4E4);

  static const kWarning = Color(0xFFFFD43B);
  static const kWarningContainer = Color(0xFF2B2106);
  static const kWarningContainerLight = Color(0xFFFFF8DC);

  // --- text dark ---
  static const kTextPrimary = Color(0xFFF1F3F9);
  static const kTextSecondary = Color(0xFF8B8FA8);
  static const kTextDisabled = Color(0xFF4A4D5E);

  // --- text light ---
  static const kTextPrimaryLight = Color(0xFF1A1B2E);
  static const kTextSecondaryLight = Color(0xFF6B7280);
  static const kTextDisabledLight = Color(0xFFB0B3C0);

  // --- borders ---
  static const kBorder = Color(0xFF2A2D3E);
  static const kBorderLight = Color(0xFFE5E7F0);

  // --- misc ---
  static const kDivider = Color(0xFF1E2130);
  static const kDividerLight = Color(0xFFEEF0F8);
  static const kScrim = Color(0x80000000);

  // --- card difficulty chips ---
  static const kDifficultyEasy = Color(0xFF51CF66);
  static const kDifficultyMedium = Color(0xFFFFD43B);
  static const kDifficultyHard = Color(0xFFFF6B6B);

  // --- domain colors ---
  static const kDomainSchool = Color(0xFF4ECDC4);
  static const kDomainCompetitive = Color(0xFFFF6B9D);
  static const kDomainCertification = Color(0xFF7C6FE8);
  static const kDomainFinance = Color(0xFFFFD43B);
  static const kDomainLanguage = Color(0xFF51CF66);

  // --- gradients (use these to build LinearGradient) ---
  static const kGradientPrimary = [Color(0xFF7C6FE8), Color(0xFF4ECDC4)];
  static const kGradientAccent = [Color(0xFFFF6B9D), Color(0xFFFF9F43)];
  static const kGradientSuccess = [Color(0xFF51CF66), Color(0xFF4ECDC4)];
  static const kGradientDark = [Color(0xFF12141F), Color(0xFF0A0B14)];
}
