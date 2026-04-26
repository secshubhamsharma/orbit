import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/domain_model.dart';
import 'package:orbitapp/models/subject_model.dart';
import 'package:orbitapp/providers/library_provider.dart';

// ---------------------------------------------------------------------------
// Domain colour / emoji helpers (mirrored from library_screen)
// ---------------------------------------------------------------------------

Color _domainColor(String domainId) {
  return switch (domainId) {
    'school' => AppColors.kDomainSchool,
    'competitive_exams' => AppColors.kDomainCompetitive,
    'it_certifications' => AppColors.kDomainCertification,
    'finance_certifications' => AppColors.kDomainFinance,
    'language_aptitude' => AppColors.kDomainLanguage,
    _ => AppColors.kPrimary,
  };
}

String _domainEmoji(String domainId) {
  return switch (domainId) {
    'school' => '📚',
    'competitive_exams' => '🏆',
    'it_certifications' => '💻',
    'finance_certifications' => '💹',
    'language_aptitude' => '🌐',
    _ => '🎓',
  };
}

List<Color> _domainGradient(String domainId) {
  final base = _domainColor(domainId);
  return switch (domainId) {
    'school' => const [Color(0xFF4ECDC4), Color(0xFF2EB5AD)],
    'competitive_exams' => const [Color(0xFFFF6B9D), Color(0xFFE0587F)],
    'it_certifications' => const [Color(0xFF7C6FE8), Color(0xFF5A4FBE)],
    'finance_certifications' => const [Color(0xFFFFD43B), Color(0xFFE0B800)],
    'language_aptitude' => const [Color(0xFF51CF66), Color(0xFF37B34D)],
    _ => [base, base.withValues(alpha: 0.7)],
  };
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class DomainScreen extends ConsumerStatefulWidget {
  final String domainId;

  const DomainScreen({super.key, required this.domainId});

  @override
  ConsumerState<DomainScreen> createState() => _DomainScreenState();
}

class _DomainScreenState extends ConsumerState<DomainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final domainsAsync = ref.watch(domainsProvider);
    final subjectsAsync = ref.watch(subjectsProvider(widget.domainId));

    final domain = domainsAsync.whenOrNull(
      data: (domains) {
        try {
          return domains.firstWhere((d) => d.id == widget.domainId);
        } catch (_) {
          return null;
        }
      },
    );

    final color = _domainColor(widget.domainId);
    final gradient = _domainGradient(widget.domainId);
    final emoji = _domainEmoji(widget.domainId);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _DomainSliverHeader(
            domain: domain,
            domainId: widget.domainId,
            color: color,
            gradient: gradient,
            emoji: emoji,
            ctrl: _ctrl,
          ),
          subjectsAsync.when(
            loading: () => _buildLoading(),
            error: (e, _) => _buildError(e),
            data: (subjects) {
              if (subjects.isEmpty) return _buildEmpty();
              return _SubjectList(
                subjects: subjects,
                domainId: widget.domainId,
                color: color,
                ctrl: _ctrl,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, _) => _SubjectShimmer(),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildError(Object e) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.kError, size: 48),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load subjects',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.kTextPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                e.toString(),
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No subjects yet',
              style:
                  AppTextStyles.bodyLarge.copyWith(color: AppColors.kTextPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Check back soon', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sliver header
// ---------------------------------------------------------------------------

class _DomainSliverHeader extends StatelessWidget {
  final DomainModel? domain;
  final String domainId;
  final Color color;
  final List<Color> gradient;
  final String emoji;
  final AnimationController ctrl;

  const _DomainSliverHeader({
    required this.domain,
    required this.domainId,
    required this.color,
    required this.gradient,
    required this.emoji,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    final fadeSlide = CurvedAnimation(
      parent: ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.kBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.kTextPrimary, size: 20),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeaderBackground(
          domain: domain,
          domainId: domainId,
          color: color,
          gradient: gradient,
          emoji: emoji,
          animation: fadeSlide,
        ),
        title: AnimatedBuilder(
          animation: ctrl,
          builder: (_, child) => Opacity(
            opacity: ctrl.value,
            child: child,
          ),
          child: Text(
            domain?.name ?? '',
            style: AppTextStyles.headingSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }
}

class _HeaderBackground extends StatelessWidget {
  final DomainModel? domain;
  final String domainId;
  final Color color;
  final List<Color> gradient;
  final String emoji;
  final Animation<double> animation;

  const _HeaderBackground({
    required this.domain,
    required this.domainId,
    required this.color,
    required this.gradient,
    required this.emoji,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred glow orb
        Positioned(
          right: -40,
          top: -40,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
        // Bottom gradient to background
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, AppColors.kBackground],
              stops: [0.55, 1.0],
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xxxl, AppSpacing.lg, AppSpacing.lg),
          child: AnimatedBuilder(
            animation: animation,
            builder: (_, child) => Opacity(
              opacity: animation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animation.value)),
                child: child,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji badge
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(domain?.name ?? '', style: AppTextStyles.headingLarge),
                if (domain != null && domain!.description.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    domain!.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (domain != null && domain!.totalTopics > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _StatPill(
                    label: '${domain!.totalTopics} topics',
                    color: color,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subject list
// ---------------------------------------------------------------------------

class _SubjectList extends StatelessWidget {
  final List<SubjectModel> subjects;
  final String domainId;
  final Color color;
  final AnimationController ctrl;

  const _SubjectList({
    required this.subjects,
    required this.domainId,
    required this.color,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) {
            final delay = 0.15 + index * 0.06;
            final end = (delay + 0.35).clamp(0.0, 1.0);
            final anim = CurvedAnimation(
              parent: ctrl,
              curve: Interval(delay, end, curve: Curves.easeOut),
            );
            return _AnimatedSubjectTile(
              subject: subjects[index],
              domainId: domainId,
              color: color,
              animation: anim,
            );
          },
          childCount: subjects.length,
        ),
      ),
    );
  }
}

class _AnimatedSubjectTile extends StatelessWidget {
  final SubjectModel subject;
  final String domainId;
  final Color color;
  final Animation<double> animation;

  const _AnimatedSubjectTile({
    required this.subject,
    required this.domainId,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: _SubjectTile(
        subject: subject,
        domainId: domainId,
        color: color,
      ),
    );
  }
}

class _SubjectTile extends StatefulWidget {
  final SubjectModel subject;
  final String domainId;
  final Color color;

  const _SubjectTile({
    required this.subject,
    required this.domainId,
    required this.color,
  });

  @override
  State<_SubjectTile> createState() => _SubjectTileState();
}

class _SubjectTileState extends State<_SubjectTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _press.forward();
      },
      onTapUp: (_) {
        _press.reverse();
        context.push('/home/library/${widget.domainId}/${widget.subject.id}');
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.kBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Avatar
                _SubjectAvatar(
                  name: widget.subject.name,
                  color: widget.color,
                ),
                const SizedBox(width: AppSpacing.md),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.subject.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.kTextPrimary,
                        ),
                      ),
                      if (widget.subject.applicableExams.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        _ExamTagRow(exams: widget.subject.applicableExams),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${widget.subject.totalTopics} books',
                        style: AppTextStyles.caption.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chevron
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: widget.color,
                    size: 18,
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

class _SubjectAvatar extends StatelessWidget {
  final String name;
  final Color color;

  const _SubjectAvatar({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.headingMedium.copyWith(color: color),
      ),
    );
  }
}

class _ExamTagRow extends StatelessWidget {
  final List<String> exams;

  const _ExamTagRow({required this.exams});

  @override
  Widget build(BuildContext context) {
    final visible = exams.take(3).toList();
    return Wrap(
      spacing: AppSpacing.xs,
      children: visible
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                tag.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.kTextSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer loading tile
// ---------------------------------------------------------------------------

class _SubjectShimmer extends StatefulWidget {
  @override
  State<_SubjectShimmer> createState() => _SubjectShimmerState();
}

class _SubjectShimmerState extends State<_SubjectShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: LinearGradient(
            begin: Alignment(_anim.value * 3 - 1.5, 0),
            end: Alignment(_anim.value * 3 + 0.5, 0),
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
