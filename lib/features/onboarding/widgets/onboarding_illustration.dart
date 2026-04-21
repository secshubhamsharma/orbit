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
      0 => const _FlashcardScene(),
      1 => const _AlgorithmScene(),
      _ => const _ProgressScene(),
    };
  }
}

// ─── Scene 1 — AI Flashcard Generation ───────────────────────────────────────

class _FlashcardScene extends StatelessWidget {
  const _FlashcardScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // glow blob
        const _GlowBlob(color: AppColors.kPrimary, size: 280, opacity: 0.15),

        // back card — tilted left
        Transform.translate(
          offset: const Offset(-24, 28),
          child: Transform.rotate(
            angle: -0.14,
            child: _CardShell(
              width: 220,
              height: 130,
              opacity: 0.45,
              child: _CardContent(
                topLabel: 'UPSC GS-1',
                lines: 3,
                lineColor: AppColors.kPrimary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        // mid card — tilted right
        Transform.translate(
          offset: const Offset(22, 18),
          child: Transform.rotate(
            angle: 0.1,
            child: _CardShell(
              width: 220,
              height: 130,
              opacity: 0.65,
              child: _CardContent(
                topLabel: 'JEE Mains',
                lines: 3,
                lineColor: AppColors.kSecondary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),

        // front card — straight
        _CardShell(
          width: 230,
          height: 138,
          opacity: 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniChip(label: 'CCNA', color: AppColors.kSecondary),
              const SizedBox(height: 10),
              Text(
                'What is the purpose of\na subnet mask?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.kPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: AppColors.kPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flip_rounded, size: 11, color: AppColors.kPrimary),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to flip',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.kPrimary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // floating domain tags
        Positioned(
          top: 30,
          right: 28,
          child: _FloatingTag(label: 'AI Generated', color: AppColors.kAccent),
        ),
        Positioned(
          bottom: 38,
          left: 22,
          child: _FloatingTag(label: '30 cards', color: AppColors.kPrimary),
        ),

        // decorative dots
        Positioned(top: 60, left: 30, child: _Dot(color: AppColors.kPrimary, size: 6)),
        Positioned(bottom: 80, right: 30, child: _Dot(color: AppColors.kSecondary, size: 5)),
        Positioned(top: 120, right: 18, child: _Dot(color: AppColors.kAccent, size: 4)),
      ],
    );
  }
}

// ─── Scene 2 — Spaced Repetition Algorithm ────────────────────────────────────

class _AlgorithmScene extends StatelessWidget {
  const _AlgorithmScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        const _GlowBlob(color: AppColors.kSecondary, size: 260, opacity: 0.14),

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

        // interval labels around the rings
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

// ─── Scene 3 — Progress & Mastery ────────────────────────────────────────────

class _ProgressScene extends StatelessWidget {
  const _ProgressScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        const _GlowBlob(color: AppColors.kAccent, size: 260, opacity: 0.13),

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // circular mastery ring
            SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _MasteryRingPainter(progress: 0.78),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '78%',
                        style: AppTextStyles.headingLarge.copyWith(fontSize: 28),
                      ),
                      Text(
                        'Mastery',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.kTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // topic progress bars
            _CardShell(
              width: 240,
              height: 110,
              opacity: 1.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _TopicBar(label: 'Physics', percent: 0.91, color: AppColors.kSuccess),
                  _TopicBar(label: 'Mathematics', percent: 0.72, color: AppColors.kPrimary),
                  _TopicBar(label: 'History', percent: 0.55, color: AppColors.kWarning),
                ],
              ),
            ),
          ],
        ),

        // streak badge
        Positioned(
          top: 20,
          right: 26,
          child: _CardShell(
            width: 74,
            height: 66,
            opacity: 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: AppColors.kAccent, size: 18),
                const SizedBox(height: 2),
                Text(
                  '14 days',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.kAccent,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(top: 55, left: 28, child: _Dot(color: AppColors.kAccent, size: 6)),
        Positioned(bottom: 65, right: 24, child: _Dot(color: AppColors.kSuccess, size: 5)),
      ],
    );
  }
}

// ─── Reusable building blocks ─────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _GlowBlob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}

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

class _CardContent extends StatelessWidget {
  final String topLabel;
  final int lines;
  final Color lineColor;

  const _CardContent({
    required this.topLabel,
    required this.lines,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(topLabel, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        ...List.generate(lines, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Container(
            height: 8,
            width: i == lines - 1 ? 80 : double.infinity,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        )),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class _FloatingTag extends StatelessWidget {
  final String label;
  final Color color;

  const _FloatingTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
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

class _TopicBar extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const _TopicBar({
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.kSurfaceHigh,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(percent * 100).toInt()}%',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MasteryRingPainter extends CustomPainter {
  final double progress;

  _MasteryRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 9.0;

    // track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.kSurfaceVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // gradient arc — fake it with two-color sweep
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.kPrimary, AppColors.kAccent],
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: GradientRotation(-math.pi / 2),
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(_MasteryRingPainter old) => old.progress != progress;
}
