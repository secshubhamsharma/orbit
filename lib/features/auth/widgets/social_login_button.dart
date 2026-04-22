import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Full-width social authentication button.
///
/// Usage:
///   SocialLoginButton.google(onTap: _loginWithGoogle, isLoading: _isLoading)
///   SocialLoginButton.apple(onTap: _loginWithApple)
class SocialLoginButton extends StatelessWidget {
  final String _label;
  final Widget _leadingIcon;
  final VoidCallback? onTap;
  final bool isLoading;

  const SocialLoginButton._({
    required String label,
    required Widget leadingIcon,
    this.onTap,
    this.isLoading = false,
  })  : _label = label,
        _leadingIcon = leadingIcon;

  factory SocialLoginButton.google({
    VoidCallback? onTap,
    bool isLoading = false,
  }) =>
      SocialLoginButton._(
        label: 'Continue with Google',
        leadingIcon: const _GoogleIcon(),
        onTap: onTap,
        isLoading: isLoading,
      );

  factory SocialLoginButton.apple({
    VoidCallback? onTap,
    bool isLoading = false,
  }) =>
      SocialLoginButton._(
        label: 'Continue with Apple',
        leadingIcon: const _AppleIcon(),
        onTap: onTap,
        isLoading: isLoading,
      );

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;

    return SizedBox(
      height: 54,
      child: Material(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: AppColors.kPrimary.withValues(alpha: 0.06),
          highlightColor: AppColors.kPrimary.withValues(alpha: 0.03),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.kBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.kTextSecondary,
                      ),
                    ),
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Icon stays pinned to the left
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _leadingIcon,
                      ),
                      // Label is always optically centred
                      Text(
                        _label,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.kTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon widgets
// ---------------------------------------------------------------------------

/// White rounded square with Google-blue bold "G".
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4285F4),
          height: 1,
        ),
      ),
    );
  }
}

/// Dark square matching the surface with the Apple glyph in white.
class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.kBorder),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.apple, size: 17, color: Colors.white),
    );
  }
}
