import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = AppSpacing.radiusMd,
  });

  const ShimmerLoader.card({
    super.key,
    this.width = double.infinity,
    this.height = 120,
  }) : radius = AppSpacing.radiusLg;

  const ShimmerLoader.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        radius = AppSpacing.radiusFull;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shimmer = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.kSurfaceVariant : AppColors.kSurfaceVariantLight;
    final highlight = isDark ? AppColors.kSurfaceHigh : AppColors.kSurfaceHighLight;

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: [
                (_shimmer.value - 1).clamp(0.0, 1.0),
                _shimmer.value.clamp(0.0, 1.0),
                (_shimmer.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
