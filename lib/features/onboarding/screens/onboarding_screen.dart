import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/onboarding_illustration.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  late final PageController _pageController;
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;
  late AnimationController _enterController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  int _current = 0;

  static const _slides = [
    _SlideData(
      chip: 'Smart Flashcards',
      chipColor: AppColors.kPrimary,
      title: 'Turn any topic\ninto flashcards',
      body:
          'Choose from thousands of ready-made decks for JEE, UPSC, CCNA — or upload a PDF and let AI build the cards for you.',
    ),
    _SlideData(
      chip: 'Spaced Repetition',
      chipColor: AppColors.kSecondary,
      title: 'AI that knows\nwhen you\'ll forget',
      body:
          'Our SM-2 algorithm schedules every review at the exact right moment. Study less, retain more — for life.',
    ),
    _SlideData(
      chip: 'Track Progress',
      chipColor: AppColors.kAccent,
      title: 'Weak topics become\nyour strengths',
      body:
          'Mastery scores, streak tracking, and smart alerts keep you focused on exactly what needs your attention.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();

    _textFade = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeOut,
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _enterController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _current = index);
    _enterController.forward(from: 0);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/auth/login');
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final slide = _slides[_current];

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Stack(
        children: [
          // top-right ambient glow — shifts color per slide
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            top: -80,
            right: -60 + (_current * -20.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    slide.chipColor.withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // bottom-left ambient
          Positioned(
            bottom: -60,
            left: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    slide.chipColor.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.kGradientPrimary,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.public_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Orbit',
                            style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                      if (_current < _slides.length - 1)
                        TextButton(
                          onPressed: _finish,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.kTextSecondary,
                          ),
                          child: const Text('Skip'),
                        ),
                    ],
                  ),
                ),

                // illustration with float animation
                SizedBox(
                  height: size.height * 0.40,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _slides.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child,
                            );
                          },
                          child: OnboardingIllustration(index: i),
                        ),
                      );
                    },
                  ),
                ),

                // text — fades + slides in on each page change
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePadding,
                    ),
                    child: FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            _CategoryChip(
                              label: slide.chip,
                              color: slide.chipColor,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              slide.title,
                              style: AppTextStyles.displayMedium.copyWith(
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm + 2),
                            Text(
                              slide.body,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.kTextSecondary,
                                height: 1.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // dots + button row
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.sm,
                    AppSpacing.pagePadding,
                    AppSpacing.xl,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _PageDots(
                        count: _slides.length,
                        current: _current,
                        activeColor: slide.chipColor,
                      ),
                      _ProgressButton(
                        progress: (_current + 1) / _slides.length,
                        onTap: _next,
                        isLast: _current == _slides.length - 1,
                        color: slide.chipColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide data ───────────────────────────────────────────────────────────────

class _SlideData {
  final String chip;
  final Color chipColor;
  final String title;
  final String body;

  const _SlideData({
    required this.chip,
    required this.chipColor,
    required this.title,
    required this.body,
  });
}

// ─── Category chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page dots ────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;

  const _PageDots({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(right: 6),
          width: isActive ? 22.0 : 7.0,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? activeColor : AppColors.kBorder,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }
}

// ─── Circular progress next button ───────────────────────────────────────────

class _ProgressButton extends StatelessWidget {
  final double progress;
  final VoidCallback onTap;
  final bool isLast;
  final Color color;

  const _ProgressButton({
    required this.progress,
    required this.onTap,
    required this.isLast,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        height: 68,
        child: CustomPaint(
          painter: _ArcPainter(progress: progress, color: color),
          child: Center(
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
                  key: ValueKey(isLast),
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}
