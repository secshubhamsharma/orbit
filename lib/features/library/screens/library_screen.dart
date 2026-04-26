import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/providers/library_provider.dart';
import 'package:orbitapp/providers/progress_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Header section
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;

  // Search bar
  late final Animation<double> _searchFade;
  late final Animation<Offset> _searchSlide;

  // Section label
  late final Animation<double> _sectionFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _headerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

    _searchFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.12, 0.55, curve: Curves.easeOut),
    );
    _searchSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.12, 0.55, curve: Curves.easeOutCubic),
    ));

    _sectionFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Staggered animation for each domain card.
  Animation<double> _cardAnim(int index) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(
          (0.30 + index * 0.07).clamp(0.0, 0.85),
          (0.65 + index * 0.07).clamp(0.35, 1.0),
          curve: Curves.easeOutCubic,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final domainsAsync   = ref.watch(domainsProvider);
    final allProgressAsync = ref.watch(allProgressProvider);

    // Domains the user has studied at least once
    final studiedDomains = {
      for (final p in allProgressAsync.valueOrNull ?? []) p.domainId,
    };

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: domainsAsync.when(
        loading: () => _LoadingView(
          headerFade: _headerFade,
          headerSlide: _headerSlide,
          searchFade: _searchFade,
          searchSlide: _searchSlide,
        ),
        error: (e, _) => _ErrorView(
          onRetry: () => ref.invalidate(domainsProvider),
        ),
        data: (domains) => CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Decorative header ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _headerFade,
                child: SlideTransition(
                  position: _headerSlide,
                  child: _LibraryHeader(domains: domains),
                ),
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _searchFade,
                child: SlideTransition(
                  position: _searchSlide,
                  child: const _SearchBar(),
                ),
              ),
            ),

            // ── Section label ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _sectionFade,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
                  child: Row(
                    children: [
                      Text(
                        'Browse Domains',
                        style: AppTextStyles.headingSmall,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimary.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '${domains.length} domains',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.kPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Domain grid ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final domain = domains[index];
                    return _AnimatedDomainCard(
                      domain: domain,
                      animation: _cardAnim(index),
                      isStudied: studiedDomains.contains(domain.id),
                      index: index,
                    );
                  },
                  childCount: domains.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Library header  — decorative orbs + title + stats
// ─────────────────────────────────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  final List<DomainModel> domains;
  const _LibraryHeader({required this.domains});

  @override
  Widget build(BuildContext context) {
    final totalTopics =
        domains.fold<int>(0, (sum, d) => sum + d.totalTopics);

    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          // ── Decorative background orbs ─────────────────────────────────
          Positioned(
            top: -30,
            right: -20,
            child: _Orb(size: 180, color: AppColors.kPrimary, opacity: 0.10),
          ),
          Positioned(
            top: 60,
            left: -40,
            child: _Orb(size: 140, color: AppColors.kSecondary, opacity: 0.08),
          ),
          Positioned(
            bottom: 0,
            right: 60,
            child: _Orb(size: 100, color: AppColors.kAccent, opacity: 0.06),
          ),

          // ── Status bar spacer + content ────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: title + optional icon
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Eyebrow
                            Text(
                              'KNOWLEDGE BASE',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.kPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Main title
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                colors: [
                                  AppColors.kTextPrimary,
                                  AppColors.kPrimaryLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(bounds),
                              child: Text(
                                'Your\nLibrary',
                                style: AppTextStyles.displayLarge.copyWith(
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Stats pill
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.kSurface,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.kBorder),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalTopics',
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.kPrimary,
                              ),
                            ),
                            Text('topics',
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Subtitle
                  Text(
                    '${domains.length} domains · Tap to explore',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decorative blurred orb
// ─────────────────────────────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _Orb(
      {required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: opacity),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky search bar — tapping navigates to search
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, _) => GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.go('/home/search');
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.kPrimary
                    .withValues(alpha: 0.2 * _glow.value + 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.kPrimary
                      .withValues(alpha: 0.06 * _glow.value),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.search_rounded,
                  color: AppColors.kPrimary.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Search topics, books, chapters...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.kTextDisabled,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimary.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '⌘ K',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.kPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Animated domain card wrapper (entrance animation)
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedDomainCard extends StatelessWidget {
  final DomainModel domain;
  final Animation<double> animation;
  final bool isStudied;
  final int index;

  const _AnimatedDomainCard({
    required this.domain,
    required this.animation,
    required this.isStudied,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 36 * (1 - animation.value)),
          child: Transform.scale(
            scale: 0.88 + 0.12 * animation.value,
            child: child,
          ),
        ),
      ),
      child: _DomainCard(
        domain: domain,
        isStudied: isStudied,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain card — interactive with press animation
// ─────────────────────────────────────────────────────────────────────────────

class _DomainCard extends StatefulWidget {
  final DomainModel domain;
  final bool isStudied;

  const _DomainCard({
    required this.domain,
    required this.isStudied,
  });

  @override
  State<_DomainCard> createState() => _DomainCardState();
}

class _DomainCardState extends State<_DomainCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _pressScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Color get _domainColor {
    final h = widget.domain.colorHex.replaceAll('#', '');
    try {
      return Color(int.parse('0xFF$h'));
    } catch (_) {
      return AppColors.kPrimary;
    }
  }

  String _emojiForDomain(String id) => switch (id) {
        'school'                  => '🏫',
        'competitive_exams'       => '🎯',
        'it_certifications'       => '💻',
        'finance_certifications'  => '📈',
        'language_aptitude'       => '🌐',
        _                         => '📚',
      };

  @override
  Widget build(BuildContext context) {
    final color = _domainColor;
    final emoji = _emojiForDomain(widget.domain.id);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _pressCtrl.reverse();
      },
      onTapUp: (_) {
        _pressCtrl.forward();
        context.push('/home/library/${widget.domain.id}');
      },
      onTapCancel: () => _pressCtrl.forward(),
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (_, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            // Multi-stop gradient for depth
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: 0.30),
              width: 1.5,
            ),
            boxShadow: [
              // Colour glow
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              // Dark shadow for depth
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Stack(
              children: [
                // ── Radial highlight (top-right) ───────────────────────
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          color.withValues(alpha: 0.20),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Noise grain overlay ────────────────────────────────
                Positioned.fill(
                  child: CustomPaint(painter: _GrainPainter(color: color)),
                ),

                // ── Card content ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emoji icon in frosted container
                      _EmojiContainer(emoji: emoji, color: color),

                      const Spacer(),

                      // Domain name
                      Text(
                        widget.domain.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.kTextPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Bottom row: topics + studied badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Topics pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.collections_bookmark_rounded,
                                    size: 10, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.domain.totalTopics}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          // Studied indicator OR arrow
                          if (widget.isStudied)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.kSuccess
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      size: 10,
                                      color: AppColors.kSuccess),
                                  SizedBox(width: 3),
                                  Text(
                                    'Studied',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.kSuccess,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: color.withValues(alpha: 0.7),
                            ),
                        ],
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Frosted emoji container inside each domain card
// ─────────────────────────────────────────────────────────────────────────────

class _EmojiContainer extends StatelessWidget {
  final String emoji;
  final Color color;

  const _EmojiContainer({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 26)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtle noise grain painter — adds micro-texture to cards
// ─────────────────────────────────────────────────────────────────────────────

class _GrainPainter extends CustomPainter {
  final Color color;
  static final _rng = math.Random(42); // fixed seed for consistency

  const _GrainPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final r = _rng.nextDouble() * 1.2 + 0.3;
      paint.color = color.withValues(alpha: _rng.nextDouble() * 0.06);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => false; // static grain
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading view
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  final Animation<double> headerFade;
  final Animation<Offset> headerSlide;
  final Animation<double> searchFade;
  final Animation<Offset> searchSlide;

  const _LoadingView({
    required this.headerFade,
    required this.headerSlide,
    required this.searchFade,
    required this.searchSlide,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        // Placeholder header
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: headerFade,
            child: SlideTransition(
              position: headerSlide,
              child: _ShimmerBox(
                  height: 220, margin: EdgeInsets.zero),
            ),
          ),
        ),
        // Placeholder search
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: searchFade,
            child: SlideTransition(
              position: searchSlide,
              child: const _ShimmerBox(
                height: 52,
                margin: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl + AppSpacing.md)),
        // Grid shimmer
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.82,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, _) => const _ShimmerBox(
                  height: double.infinity,
                  margin: EdgeInsets.zero,
                  radius: AppSpacing.radiusXl),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer box widget
// ─────────────────────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double height;
  final EdgeInsets margin;
  final double radius;

  const _ShimmerBox({
    required this.height,
    required this.margin,
    this.radius = AppSpacing.radiusMd,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shCtrl;
  late final Animation<double> _shAnim;

  @override
  void initState() {
    super.initState();
    _shCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _shAnim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shAnim,
      builder: (ctx, _) => Container(
        height: widget.height == double.infinity ? null : widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(_shAnim.value - 1, 0),
            end: Alignment(_shAnim.value + 1, 0),
            colors: const [
              AppColors.kSurface,
              AppColors.kSurfaceVariant,
              AppColors.kSurface,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.kError.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    color: AppColors.kError, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Could not load library',
                  style: AppTextStyles.headingSmall,
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Check your connection and try again.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kTextSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.kPrimary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
