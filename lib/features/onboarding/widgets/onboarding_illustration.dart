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
            label: '30 MCQs',
            icon: Icons.layers_rounded,
            color: AppColors.kPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Scene 2 — Memory retention curve ────────────────────────────────────────

class _RetentionScene extends StatelessWidget {
  const _RetentionScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        _GlowBlob(color: AppColors.kSecondary, size: 260, opacity: 0.12),

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
                    'Memory Retention',
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 11),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.kSuccess.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '↑ 94%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.kSuccess,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 96,
                width: double.infinity,
                child: CustomPaint(painter: _RetentionPainter()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _LegendDot(color: AppColors.kSecondary, label: 'With Orbit'),
                  const SizedBox(width: 14),
                  _LegendDot(
                    color: AppColors.kTextSecondary.withValues(alpha: 0.4),
                    label: 'Without review',
                  ),
                ],
              ),
            ],
          ),
        ),

        // due today badge
        Positioned(
          top: 14,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.kSurfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DUE TODAY',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 7,
                    letterSpacing: 1.4,
                    color: AppColors.kTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '12',
                  style: AppTextStyles.headingMedium.copyWith(
                    color: AppColors.kSecondary,
                    fontSize: 22,
                    height: 1,
                  ),
                ),
                Text(
                  'cards',
                  style: AppTextStyles.caption.copyWith(fontSize: 8),
                ),
              ],
            ),
          ),
        ),
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
      ],
    );
  }
}

class _RetentionPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final labelStyle = TextStyle(
      color: AppColors.kTextSecondary.withValues(alpha: 0.5),
      fontSize: 7,
      fontFamily: 'PlusJakartaSans',
    );
    for (final pct in [100, 50]) {
      final y = pct == 100 ? 0.0 : h * 0.6;
      final tp = TextPainter(
        text: TextSpan(text: '$pct%', style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y));
    }

    const chartLeft = 24.0;
    final chartW = w - chartLeft;

    // dashed threshold line
    final dashPaint = Paint()
      ..color = AppColors.kTextSecondary.withValues(alpha: 0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    double dx = chartLeft;
    final threshY = h * 0.58;
    while (dx < w) {
      canvas.drawLine(
        Offset(dx, threshY),
        Offset(math.min(dx + 4, w), threshY),
        dashPaint,
      );
      dx += 7;
    }

    // without-review decay curve (grey)
    final decayPath = Path()
      ..moveTo(chartLeft, h * 0.04)
      ..cubicTo(
        chartLeft + chartW * 0.25, h * 0.12,
        chartLeft + chartW * 0.5, h * 0.55,
        w, h * 0.88,
      );
    canvas.drawPath(
      decayPath,
      Paint()
        ..color = AppColors.kTextSecondary.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // with Orbit — sawtooth that stays high (teal)
    final reviewsX = [0.0, 0.22, 0.44, 0.68, 0.88];
    final orbitPath = Path();
    orbitPath.moveTo(chartLeft, h * 0.04);
    for (int i = 0; i < reviewsX.length - 1; i++) {
      final x0 = chartLeft + reviewsX[i] * chartW;
      final x1 = chartLeft + reviewsX[i + 1] * chartW;
      final dropY = h * (0.14 + i * 0.06);
      orbitPath.cubicTo(
        x0 + (x1 - x0) * 0.55, dropY + h * 0.12,
        x1 - (x1 - x0) * 0.15, dropY,
        x1, h * 0.06,
      );
    }
    final lx = chartLeft + reviewsX.last * chartW;
    orbitPath.cubicTo(lx + (w - lx) * 0.4, h * 0.10, w, h * 0.08, w, h * 0.07);
    canvas.drawPath(
      orbitPath,
      Paint()
        ..color = AppColors.kSecondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // review dot markers
    for (int i = 1; i < reviewsX.length; i++) {
      final cx = chartLeft + reviewsX[i] * chartW;
      const cy = 6.0;
      canvas.drawCircle(Offset(cx, cy), 5.5,
          Paint()..color = AppColors.kSecondary.withValues(alpha: 0.18));
      canvas.drawCircle(Offset(cx, cy), 3,
          Paint()..color = AppColors.kSecondary);
    }
  }

  @override
  bool shouldRepaint(_RetentionPainter old) => false;
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

