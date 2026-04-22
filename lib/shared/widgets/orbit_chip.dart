import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

class OrbitChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  const OrbitChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = color ?? AppColors.kPrimary;

    final bgColor = isSelected
        ? activeColor.withValues(alpha: 0.15)
        : (isDark ? AppColors.kSurfaceVariant : AppColors.kSurfaceVariantLight);

    final borderColor = isSelected
        ? activeColor.withValues(alpha: 0.5)
        : (isDark ? AppColors.kBorder : AppColors.kBorderLight);

    final labelColor = isSelected
        ? activeColor
        : (isDark ? AppColors.kTextSecondary : AppColors.kTextSecondaryLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: labelColor),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: labelColor)),
          ],
        ),
      ),
    );
  }
}
