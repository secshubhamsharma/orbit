import 'dart:math' show sin, cos, pi;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // Nucleus: bounces in, then breathes continuously
  late final AnimationController _coreCtrl;
  late final AnimationController _pulseCtrl;

  // Three orbital rings draw themselves in sequence
  late final AnimationController _ringsCtrl;

  // Particles orbit continuously on the rings
  late final AnimationController _orbitCtrl;

  // Wordmark + tagline slide up and fade in
  late final AnimationController _textCtrl;

  // Derived animations
  late final Animation<double> _coreScale;
  late final Animation<double> _coreFade;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _ring1;
  late final Animation<double> _ring2;
  late final Animation<double> _ring3;
  late final Animation<double> _wordFade;
  late final Animation<Offset> _wordSlide;
  late final Animation<double> _tagFade;

  @override
  void initState() {
    super.initState();

    // ── Controllers ────────────────────────────────────────────
    _coreCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _ringsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000))
      ..repeat();
    _textCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));

    // ── Nucleus ────────────────────────────────────────────────
    _coreScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _coreCtrl, curve: Curves.easeOutBack),
    );
    _coreFade  = CurvedAnimation(parent: _coreCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.07).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // ── Rings — staggered via Interval so they cascade ─────────
    _ring1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringsCtrl,
        curve: const Interval(0.00, 0.52, curve: Curves.easeOut),
      ),
    );
    _ring2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringsCtrl,
        curve: const Interval(0.20, 0.75, curve: Curves.easeOut),
      ),
    );
    _ring3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringsCtrl,
        curve: const Interval(0.42, 1.00, curve: Curves.easeOut),
      ),
    );

    // ── Text ────────────────────────────────────────────────────
    _wordFade  = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _wordSlide = Tween<Offset>(
      begin: const Offset(0, 0.28),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _tagFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _runSequence();
    _navigate();
  }

  // Staggered entrance: core → rings → text
  Future<void> _runSequence() async {
    await _coreCtrl.forward();                                        // 0–700 ms
    _ringsCtrl.forward();                                             // 700 ms start
    await Future<void>.delayed(const Duration(milliseconds: 560));   // wait to 1260 ms
    _textCtrl.forward();                                              // 1260 ms
  }

  @override
  void dispose() {
    _coreCtrl.dispose();
    _pulseCtrl.dispose();
    _ringsCtrl.dispose();
    _orbitCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Run prefs read and minimum display timer in parallel.
    final results = await Future.wait<dynamic>([
      SharedPreferences.getInstance(),
      Future<void>.delayed(const Duration(milliseconds: 2400)),
    ]);

    if (!mounted) return;

    final prefs           = results[0] as SharedPreferences;
    final onboardingDone  = prefs.getBool('onboarding_done') ?? false;
    final user            = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Refresh the token so emailVerified reflects the latest server state.
        await user.reload();
        if (!mounted) return;
        final refreshed = FirebaseAuth.instance.currentUser;
        if (refreshed?.emailVerified ?? false) {
          context.go('/home');
        } else {
          context.go('/auth/verify-email');
        }
      } on FirebaseAuthException catch (_) {
        // The cached user no longer exists on the server (deleted from console,
        // token revoked, etc.). Sign out locally and redirect to login.
        await FirebaseAuth.instance.signOut();
        if (!mounted) return;
        context.go(onboardingDone ? '/auth/login' : '/onboarding');
      }
    } else if (onboardingDone) {
      context.go('/auth/login');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: Stack(
        children: [

          // Ambient space glow — static, never rebuilds
          const _AmbientGlow(),

          // Logo + wordmark — rebuilt only when animations tick
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Orbit logo mark ──────────────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _coreCtrl, _pulseCtrl, _ringsCtrl, _orbitCtrl,
                  ]),
                  builder: (context, _) => SizedBox(
                    width: 224,
                    height: 224,
                    child: CustomPaint(
                      painter: _OrbitLogoPainter(
                        coreScale:  _coreScale.value,
                        coreFade:   _coreFade.value,
                        pulse:      _pulseAnim.value,
                        ring1:      _ring1.value,
                        ring2:      _ring2.value,
                        ring3:      _ring3.value,
                        orbitAngle: _orbitCtrl.value * 2 * pi,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Wordmark ─────────────────────────────────
                FadeTransition(
                  opacity: _wordFade,
                  child: SlideTransition(
                    position: _wordSlide,
                    child: Column(
                      children: [
                        Text(
                          'ORBIT',
                          style: AppTextStyles.displayLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 10,
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeTransition(
                          opacity: _tagFade,
                          child: Text(
                            'Learn Anything. Master Everything.',
                            style: AppTextStyles.caption.copyWith(
                              letterSpacing: 0.6,
                              color: AppColors.kTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

          // Loading dots — appears alongside the wordmark
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _wordFade,
              child: const _LoadingDots(),
            ),
          ),

        ],
      ),
    );
  }
}

// ─── Ambient background glow (static widget, zero rebuilds) ──────────────────

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right — primary indigo
        Positioned(
          top: -120,
          right: -90,
          child: Container(
            width: 380,
            height: 380,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x1A7C6FE8), Colors.transparent],
              ),
            ),
          ),
        ),
        // Bottom-left — teal
        Positioned(
          bottom: -90,
          left: -70,
          child: Container(
            width: 300,
            height: 300,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x124ECDC4), Colors.transparent],
              ),
            ),
          ),
        ),
        // Mid-field — very soft centre bloom
        Center(
          child: Container(
            width: 480,
            height: 480,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x0A7C6FE8), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Ring definition ──────────────────────────────────────────────────────────

class _RingDef {
  final double radiusX;
  final double radiusY;
  final double rotDeg;       // rotation of the ring's plane around centre
  final double strokeWidth;
  final double particleSize;
  final Color color;
  final double colorAlpha;   // ring arc opacity at full coreFade
  final double orbitSpeed;   // particle speed multiplier (negative = reverse)
  final double orbitOffset;  // initial angle offset so particles aren't bunched

  const _RingDef({
    required this.radiusX,
    required this.radiusY,
    required this.rotDeg,
    required this.strokeWidth,
    required this.particleSize,
    required this.color,
    required this.colorAlpha,
    required this.orbitSpeed,
    required this.orbitOffset,
  });
}

// ─── Logo custom painter ──────────────────────────────────────────────────────

class _OrbitLogoPainter extends CustomPainter {
  final double coreScale;
  final double coreFade;
  final double pulse;
  final double ring1;
  final double ring2;
  final double ring3;
  final double orbitAngle;

  _OrbitLogoPainter({
    required this.coreScale,
    required this.coreFade,
    required this.pulse,
    required this.ring1,
    required this.ring2,
    required this.ring3,
    required this.orbitAngle,
  });

  // Three orbital planes — wide equatorial, diagonal, and inner tilted ring.
  // Together they give the impression of a 3-D multi-plane orbit system.
  static final List<_RingDef> _rings = [
    // Ring 1 — dominant equatorial sweep (indigo)
    _RingDef(
      radiusX: 94,   radiusY: 30,
      rotDeg: 0,     strokeWidth: 2.0,
      particleSize: 7.5,
      color: AppColors.kPrimary, colorAlpha: 0.55,
      orbitSpeed: 1.0,   orbitOffset: 0,
    ),
    // Ring 2 — diagonal plane (teal)
    _RingDef(
      radiusX: 80,   radiusY: 34,
      rotDeg: 58,    strokeWidth: 1.5,
      particleSize: 5.5,
      color: AppColors.kSecondary, colorAlpha: 0.45,
      orbitSpeed: -0.72, orbitOffset: pi * 0.65,
    ),
    // Ring 3 — inner tilted ring (accent pink)
    _RingDef(
      radiusX: 62,   radiusY: 22,
      rotDeg: -38,   strokeWidth: 1.1,
      particleSize: 4.0,
      color: AppColors.kAccent, colorAlpha: 0.35,
      orbitSpeed: 1.45,  orbitOffset: pi * 1.35,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final progresses = [ring1, ring2, ring3];

    // ── Outer glow halo behind everything ────────────────────
    if (coreFade > 0.01) {
      final glowR = 90.0 * coreScale * pulse;
      canvas.drawCircle(
        c,
        glowR,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.kPrimary.withValues(alpha: 0.22 * coreFade),
              AppColors.kPrimary.withValues(alpha: 0.07 * coreFade),
              Colors.transparent,
            ],
            stops: const [0.0, 0.45, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: glowR)),
      );
    }

    // ── Rings + particles ─────────────────────────────────────
    for (int i = 0; i < _rings.length; i++) {
      final r = _rings[i];
      final p = progresses[i];
      if (p <= 0) continue;

      _drawRing(canvas, c, def: r, progress: p, fade: coreFade);

      // Particle fades in during the last 25 % of ring draw
      final particleFade = ((p - 0.75) / 0.25).clamp(0.0, 1.0);
      if (particleFade > 0) {
        _drawParticle(
          canvas, c,
          def: r,
          angle: orbitAngle * r.orbitSpeed + r.orbitOffset,
          opacity: particleFade * coreFade,
        );
      }
    }

    // ── Nucleus sphere ────────────────────────────────────────
    if (coreScale > 0.01) {
      final nr = 36.0 * coreScale * pulse;

      // Soft atmospheric bloom behind the sphere
      canvas.drawCircle(
        c,
        nr + 8,
        Paint()
          ..color = AppColors.kPrimary.withValues(alpha: 0.09 * coreFade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Main sphere — radial gradient creates the 3-D lit-sphere look.
      // Light source is top-left; shadow falls bottom-right.
      canvas.drawCircle(
        c,
        nr,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.38, -0.42),
            radius: 1.0,
            colors: const [
              Color(0xFFC4BDFA), // lavender highlight
              Color(0xFF7C6FE8), // mid indigo (kPrimary)
              Color(0xFF3B30A6), // deep shadow indigo
            ],
            stops: const [0.0, 0.48, 1.0],
          ).createShader(Rect.fromCircle(center: c, radius: nr)),
      );

      // Specular glint — offset top-left
      final hlC = Offset(c.dx - nr * 0.29, c.dy - nr * 0.30);
      canvas.drawCircle(
        hlC,
        nr * 0.36,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.30 * coreFade),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: hlC, radius: nr * 0.36)),
      );

      // Rim light — teal fringe on the shadow edge for a backlit 3-D look
      canvas.drawCircle(
        c,
        nr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..shader = SweepGradient(
            startAngle: pi * 0.85,
            endAngle:   pi * 1.75,
            colors: [
              Colors.transparent,
              AppColors.kSecondary.withValues(alpha: 0.38 * coreFade),
              Colors.transparent,
            ],
          ).createShader(Rect.fromCircle(center: c, radius: nr)),
      );
    }
  }

  // Draws one ring arc around the centre.  Canvas is rotated so the ellipse
  // appears at the correct orbital plane angle.
  void _drawRing(
    Canvas canvas,
    Offset center, {
    required _RingDef def,
    required double progress,
    required double fade,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(def.rotDeg * pi / 180);

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset.zero,
        width:  def.radiusX * 2,
        height: def.radiusY * 2,
      ),
      -pi / 2,          // start at 12 o'clock
      2 * pi * progress,
      false,
      Paint()
        ..color = def.color.withValues(alpha: def.colorAlpha * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = def.strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  // Draws a glowing particle at position [angle] on the ring ellipse.
  void _drawParticle(
    Canvas canvas,
    Offset center, {
    required _RingDef def,
    required double angle,
    required double opacity,
  }) {
    // Point on the un-rotated ellipse
    final ex = def.radiusX * cos(angle);
    final ey = def.radiusY * sin(angle);

    // Apply ring rotation to get screen-space position
    final rad = def.rotDeg * pi / 180;
    final sx  = ex * cos(rad) - ey * sin(rad);
    final sy  = ex * sin(rad) + ey * cos(rad);
    final pos = Offset(center.dx + sx, center.dy + sy);
    final ps  = def.particleSize;

    // Glow halo
    canvas.drawCircle(
      pos,
      ps * 2.4,
      Paint()
        ..color = def.color.withValues(alpha: 0.20 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Core dot
    canvas.drawCircle(
      pos,
      ps * 0.52,
      Paint()
        ..color = def.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill,
    );

    // Tiny specular highlight on the particle
    canvas.drawCircle(
      Offset(pos.dx - ps * 0.12, pos.dy - ps * 0.14),
      ps * 0.18,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55 * opacity)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_OrbitLogoPainter old) =>
      old.coreScale  != coreScale  ||
      old.coreFade   != coreFade   ||
      old.pulse      != pulse      ||
      old.ring1      != ring1      ||
      old.ring2      != ring2      ||
      old.ring3      != ring3      ||
      old.orbitAngle != orbitAngle;
}

// ─── Loading dots ─────────────────────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) {
            final delay  = i * 0.3;
            final t      = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final alpha  = sin(t * pi).clamp(0.2, 1.0);
            return Opacity(opacity: alpha, child: child);
          },
          child: Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: AppColors.kPrimary,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
