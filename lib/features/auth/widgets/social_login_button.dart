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
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // Subtle top-to-bottom gradient gives a glassy depth feel
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.kSurfaceHigh, AppColors.kSurfaceVariant],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            splashColor: AppColors.kPrimary.withValues(alpha: 0.06),
            highlightColor: AppColors.kPrimary.withValues(alpha: 0.03),
            child: Padding(
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
                        // Icon pinned to left
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _leadingIcon,
                        ),
                        // Label always centred regardless of icon width
                        Text(
                          _label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.kTextPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
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

/// Google "G" — white rounded-square with Google-blue bold G.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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

/// Apple icon — subtle dark pill with the SF-style apple glyph.
class _AppleIcon extends StatelessWidget {
  const _AppleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: AppColors.kBorder.withValues(alpha: 0.6),
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.apple,
        size: 17,
        color: Colors.white,
      ),
    );
  }
}
