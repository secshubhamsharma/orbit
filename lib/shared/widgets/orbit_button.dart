import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

enum OrbitButtonVariant { primary, secondary, outline, ghost, danger }

class OrbitButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final OrbitButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final double? height;

  const OrbitButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = OrbitButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height,
  });

  const OrbitButton.secondary({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height,
  }) : variant = OrbitButtonVariant.secondary;

  const OrbitButton.outline({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height,
  }) : variant = OrbitButtonVariant.outline;

  const OrbitButton.ghost({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
    this.height,
  }) : variant = OrbitButtonVariant.ghost;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 52,
      child: _buildButton(isDark),
    );
  }

  Widget _buildButton(bool isDark) {
    switch (variant) {
      case OrbitButtonVariant.primary:
        return _PrimaryButton(label: label, onTap: onTap, isLoading: isLoading, icon: icon);
      case OrbitButtonVariant.secondary:
        return _SecondaryButton(label: label, onTap: onTap, isLoading: isLoading, icon: icon);
      case OrbitButtonVariant.outline:
        return _OutlineButton(label: label, onTap: onTap, isLoading: isLoading, icon: icon, isDark: isDark);
      case OrbitButtonVariant.ghost:
        return _GhostButton(label: label, onTap: onTap, isLoading: isLoading, icon: icon);
      case OrbitButtonVariant.danger:
        return _DangerButton(label: label, onTap: onTap, isLoading: isLoading, icon: icon);
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const _PrimaryButton({
    required this.label,
    this.onTap,
    required this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.kGradientPrimary,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.kPrimary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: Colors.white),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(label, style: AppTextStyles.labelLarge.copyWith(color: Colors.white)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const _SecondaryButton({
    required this.label,
    this.onTap,
    required this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? AppColors.kSurfaceVariant : AppColors.kSurfaceVariantLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.kBorder : AppColors.kBorderLight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: isDark ? AppColors.kTextPrimary : AppColors.kTextPrimaryLight,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(label, style: AppTextStyles.labelLarge),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final bool isDark;

  const _OutlineButton({
    required this.label,
    this.onTap,
    required this.isLoading,
    this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kPrimary),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.kPrimary,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: AppColors.kPrimary),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.kPrimary),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const _GhostButton({
    required this.label,
    this.onTap,
    required this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label, style: AppTextStyles.labelLarge.copyWith(color: AppColors.kPrimary)),
        ],
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const _DangerButton({
    required this.label,
    this.onTap,
    required this.isLoading,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.kErrorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kError.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.kError),
            ),
          ),
        ),
      ),
    );
  }
}
