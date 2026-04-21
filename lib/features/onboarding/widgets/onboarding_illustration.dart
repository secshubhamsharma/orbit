import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingIllustration extends StatelessWidget {
  final int index;
  const OnboardingIllustration({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return switch (index) {
      0 => const _ReviewScene(),
      1 => const _RetentionScene(),
      _ => const _HeatmapScene(),
    };
  }
}

// ─── Scene 1 — Mini review screen (what the actual app looks like) ────────────

class _ReviewScene extends StatelessWidget {
  const _ReviewScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // glow
        _GlowBlob(color: AppColors.kPrimary, size: 260, opacity: 0.12),

        // depth card behind
        Transform.translate(
          offset: const Offset(10, 12),
          child: Transform.rotate(
            angle: 0.04,
            child: Container(
              width: 248,
              height: 192,
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.kBorder.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ),

        // main card
        Container(
          width: 248,
          height: 192,
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              // top bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.kBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.kSecondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CCNA',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.kSecondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Network Basics',
                          style: AppTextStyles.caption.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.kSurfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '12 / 30',
                        style: AppTextStyles.caption.copyWith(fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ),

              // question body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'What is the purpose\nof a subnet mask?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(height: 1, color: AppColors.kDivider),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'tap to reveal',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 8,
                                color: AppColors.kTextSecondary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(height: 1, color: AppColors.kDivider),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // rating buttons
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.kBorder)),
                ),
                child: Row(
                  children: [
                    _RatingBtn(label: 'Again', color: AppColors.kError),
                    const SizedBox(width: 5),
                    _RatingBtn(label: 'Hard', color: AppColors.kWarning),
                    const SizedBox(width: 5),
                    _RatingBtn(label: 'Good', color: AppColors.kPrimary, active: true),
                    const SizedBox(width: 5),
                    _RatingBtn(label: 'Easy', color: AppColors.kSuccess),
                  ],
                ),
              ),
            ],
          ),
        ),

        // floating badges
        Positioned(
          top: 22,
          right: 6,
          child: _Badge(
            label: 'AI Built',
            icon: Icons.auto_awesome_rounded,
            color: AppColors.kAccent,
          ),
        ),
        Positioned(
          bottom: 24,
          left: 6,
          child: _Badge(
            label: '30 cards',
            icon: Icons.layers_rounded,
            color: AppColors.kPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Scene 2 — Spaced repetition (concentric rings) ──────────────────────────

class _RetentionScene extends StatelessWidget {
  const _RetentionScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _GlowBlob(color: AppColors.kSecondary, size: 260, opacity: 0.14),

        // concentric rings
        _Ring(size: 240, color: AppColors.kSecondary, opacity: 0.08),
        _Ring(size: 180, color: AppColors.kSecondary, opacity: 0.12),
        _Ring(size: 120, color: AppColors.kSecondary, opacity: 0.18),

        // center card
        _CardShell(
          width: 140,
          height: 90,
          opacity: 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.kSuccess.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.kSuccess,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Due Today',
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '12 cards',
                style: AppTextStyles.headingMedium.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),

        // interval labels orbiting the rings
        _IntervalBadge(label: '+1 day', angle: -math.pi / 4, radius: 110),
        _IntervalBadge(label: '+6 days', angle: math.pi / 6, radius: 130),
        _IntervalBadge(label: '+14 days', angle: math.pi * 0.75, radius: 115),
        _IntervalBadge(label: '+21 days', angle: -math.pi * 0.65, radius: 125),

        // decorative dots
        Positioned(top: 40, left: 40, child: _Dot(color: AppColors.kSecondary, size: 7)),
        Positioned(bottom: 50, right: 35, child: _Dot(color: AppColors.kPrimary, size: 5)),
      ],
    );
  }
}

// ─── Scene 3 — Study heatmap ──────────────────────────────────────────────────

class _HeatmapScene extends StatelessWidget {
  const _HeatmapScene();

  // 0 = none  1 = low  2 = mid  3 = high
  static const _grid = [
    [0, 1, 2, 3, 2, 1, 0],
    [1, 3, 3, 2, 3, 2, 1],
    [0, 2, 3, 3, 1, 3, 2],
    [1, 1, 2, 3, 3, 2, 3],
    [0, 2, 3, 2, 3, 0, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _GlowBlob(color: AppColors.kAccent, size: 240, opacity: 0.12),

        Container(
          width: 264,
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Study Activity',
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 11),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.kAccent,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '14-day streak',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.kAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // day labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                  return SizedBox(
                    width: 28,
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 8,
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 5),

              // heat cells
              ...List.generate(_grid.length, (row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (col) {
                      final level = _grid[row][col];
                      final isToday = row == 4 && col == 4;
                      return _HeatCell(level: level, isToday: isToday);
                    }),
                  ),
                );
              }),

              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.kDivider),
              const SizedBox(height: 12),

              // stat row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(value: '87%', label: 'Accuracy', color: AppColors.kSuccess),
                  _Stat(value: '124', label: 'Mastered', color: AppColors.kPrimary),
                  _Stat(value: '14', label: 'Day streak', color: AppColors.kAccent),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Scene 2 helpers ─────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  final Widget child;

  const _CardShell({
    required this.width,
    required this.height,
    required this.opacity,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Ring({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: opacity), width: 1.5),
      ),
    );
  }
}

class _IntervalBadge extends StatelessWidget {
  final String label;
  final double angle;
  final double radius;

  const _IntervalBadge({
    required this.label,
    required this.angle,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(
        math.cos(angle) * radius,
        math.sin(angle) * radius,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.kSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double size;

  const _Dot({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── Shared primitives ────────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowBlob({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}

class _RatingBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool active;

  const _RatingBtn({
    required this.label,
    required this.color,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : AppColors.kSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: active ? Border.all(color: color.withValues(alpha: 0.45)) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            color: active ? color : AppColors.kTextSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final int level;
  final bool isToday;

  const _HeatCell({required this.level, this.isToday = false});

  Color get _fill {
    return switch (level) {
      0 => AppColors.kSurfaceVariant,
      1 => AppColors.kAccent.withValues(alpha: 0.18),
      2 => AppColors.kAccent.withValues(alpha: 0.45),
      _ => AppColors.kAccent.withValues(alpha: 0.82),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 16,
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(4),
        border: isToday
            ? Border.all(color: AppColors.kAccent, width: 1.5)
            : null,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headingSmall.copyWith(
            color: color,
            fontSize: 18,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontSize: 8),
        ),
      ],
    );
  }
}

