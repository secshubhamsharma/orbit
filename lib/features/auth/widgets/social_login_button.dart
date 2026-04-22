import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  factory SocialLoginButton.google({
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      label: 'Continue with Google',
      icon: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF4285F4),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Text(
          'G',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
      onTap: onTap,
      isLoading: isLoading,
      backgroundColor: AppColors.kSurfaceHigh,
    );
  }

  factory SocialLoginButton.apple({
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return SocialLoginButton(
      label: 'Continue with Apple',
      icon: const Icon(
        Icons.apple,
        size: 22,
        color: AppColors.kTextPrimary,
      ),
      onTap: onTap,
      isLoading: isLoading,
      backgroundColor: AppColors.kSurfaceHigh,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.kSurfaceVariant;
    final fg = textColor ?? AppColors.kTextPrimary;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        splashColor: AppColors.kPrimary.withValues(alpha: 0.08),
        highlightColor: AppColors.kPrimary.withValues(alpha: 0.04),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.kBorder, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.kPrimary,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(color: fg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
