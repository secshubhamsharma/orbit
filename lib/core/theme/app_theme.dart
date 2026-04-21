import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

const _font = 'PlusJakartaSans';

TextStyle _ts({
  required double size,
  required FontWeight weight,
  required Color color,
  double? letterSpacing,
  double? height,
}) =>
    TextStyle(
      fontFamily: _font,
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildDark();
  static ThemeData get light => _buildLight();

  static ThemeData _buildDark() {
    const brightness = Brightness.dark;

    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: _font,
      scaffoldBackgroundColor: AppColors.kBackground,
    );

    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: brightness,
        primary: AppColors.kPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.kPrimaryContainer,
        onPrimaryContainer: AppColors.kPrimaryLight,
        secondary: AppColors.kSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.kSecondaryContainer,
        onSecondaryContainer: AppColors.kSecondaryLight,
        error: AppColors.kError,
        onError: Colors.white,
        errorContainer: AppColors.kErrorContainer,
        onErrorContainer: AppColors.kError,
        surface: AppColors.kSurface,
        onSurface: AppColors.kTextPrimary,
        onSurfaceVariant: AppColors.kTextSecondary,
        outline: AppColors.kBorder,
        outlineVariant: AppColors.kDivider,
        scrim: AppColors.kScrim,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: _font,
        bodyColor: AppColors.kTextPrimary,
        displayColor: AppColors.kTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.kTextPrimary),
        titleTextStyle: _ts(
          size: 18,
          weight: FontWeight.w600,
          color: AppColors.kTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.kBackground,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.kBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kError, width: 1.5),
        ),
        hintStyle: _ts(size: 14, weight: FontWeight.w400, color: AppColors.kTextDisabled),
        labelStyle: _ts(size: 14, weight: FontWeight.w400, color: AppColors.kTextSecondary),
        errorStyle: _ts(size: 12, weight: FontWeight.w400, color: AppColors.kError),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _ts(size: 15, weight: FontWeight.w600, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          side: const BorderSide(color: AppColors.kBorder),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _ts(size: 15, weight: FontWeight.w600, color: AppColors.kPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          textStyle: _ts(size: 14, weight: FontWeight.w600, color: AppColors.kPrimary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.kSurfaceVariant,
        selectedColor: AppColors.kPrimaryContainer,
        labelStyle: _ts(size: 13, weight: FontWeight.w500, color: AppColors.kTextSecondary),
        side: const BorderSide(color: AppColors.kBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.kDivider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        titleTextStyle: _ts(size: 18, weight: FontWeight.w600, color: AppColors.kTextPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.kSurfaceHigh,
        contentTextStyle: _ts(size: 14, weight: FontWeight.w400, color: AppColors.kTextPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kPrimary,
        linearTrackColor: AppColors.kSurfaceVariant,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.kTextDisabled;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.kPrimary;
          return AppColors.kSurfaceVariant;
        }),
      ),
    );
  }

  static ThemeData _buildLight() {
    const brightness = Brightness.light;

    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      fontFamily: _font,
      scaffoldBackgroundColor: AppColors.kBackgroundLight,
    );

    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: brightness,
        primary: AppColors.kPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.kPrimaryContainerLight,
        onPrimaryContainer: AppColors.kPrimaryDark,
        secondary: AppColors.kSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.kSecondaryContainerLight,
        onSecondaryContainer: Color(0xFF1A6B67),
        error: AppColors.kError,
        onError: Colors.white,
        errorContainer: AppColors.kErrorContainerLight,
        onErrorContainer: Color(0xFFB00020),
        surface: AppColors.kSurfaceLight,
        onSurface: AppColors.kTextPrimaryLight,
        onSurfaceVariant: AppColors.kTextSecondaryLight,
        outline: AppColors.kBorderLight,
        outlineVariant: AppColors.kDividerLight,
        scrim: AppColors.kScrim,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: _font,
        bodyColor: AppColors.kTextPrimaryLight,
        displayColor: AppColors.kTextPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.kBackgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.kTextPrimaryLight),
        titleTextStyle: _ts(
          size: 18,
          weight: FontWeight.w600,
          color: AppColors.kTextPrimaryLight,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.kBackgroundLight,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.kSurfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.kBorderLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kSurfaceVariantLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: const BorderSide(color: AppColors.kError, width: 1.5),
        ),
        hintStyle: _ts(size: 14, weight: FontWeight.w400, color: AppColors.kTextDisabledLight),
        labelStyle: _ts(size: 14, weight: FontWeight.w400, color: AppColors.kTextSecondaryLight),
        errorStyle: _ts(size: 12, weight: FontWeight.w400, color: AppColors.kError),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _ts(size: 15, weight: FontWeight.w600, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          side: const BorderSide(color: AppColors.kBorderLight),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: _ts(size: 15, weight: FontWeight.w600, color: AppColors.kPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          textStyle: _ts(size: 14, weight: FontWeight.w600, color: AppColors.kPrimary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.kSurfaceVariantLight,
        selectedColor: AppColors.kPrimaryContainerLight,
        labelStyle: _ts(size: 13, weight: FontWeight.w500, color: AppColors.kTextSecondaryLight),
        side: const BorderSide(color: AppColors.kBorderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.kDividerLight,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.kSurfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.kSurfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        titleTextStyle: _ts(size: 18, weight: FontWeight.w600, color: AppColors.kTextPrimaryLight),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.kTextPrimaryLight,
        contentTextStyle: _ts(size: 14, weight: FontWeight.w400, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.kPrimary,
        linearTrackColor: AppColors.kSurfaceVariantLight,
      ),
    );
  }
}
