import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/progress_model.dart';
import 'package:orbitapp/models/user_model.dart';
import 'package:orbitapp/providers/progress_provider.dart';
import 'package:orbitapp/providers/user_provider.dart';

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  Animation<double> _section(double start, double end) => CurvedAnimation(
        parent: _entranceCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final allProgressAsync = ref.watch(allProgressProvider);
    final weakTopicsAsync = ref.watch(weakTopicsProvider);

    // Compute derived values
    final user = userAsync.valueOrNull;
    final allProgress = allProgressAsync.valueOrNull ?? [];
    final weakTopics = weakTopicsAsync.valueOrNull ?? [];

    final totalDue = allProgress.fold(0, (s, p) => s + p.cardsDue);

    // Most recently studied topic
    final recentTopics = [...allProgress]
      ..sort((a, b) => (b.lastStudied ?? DateTime(0))
          .compareTo(a.lastStudied ?? DateTime(0)));
    final lastTopic = recentTopics.isNotEmpty ? recentTopics.first : null;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: RefreshIndicator(
        color: AppColors.kPrimary,
        backgroundColor: AppColors.kSurface,
        onRefresh: () async {
          ref.invalidate(userProvider);
          ref.invalidate(allProgressProvider);
          ref.invalidate(weakTopicsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Greeting ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlide(
                animation: _section(0.0, 0.4),
                child: _GreetingHeader(user: user),
              ),
            ),

            // ── Streak card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlide(
                animation: _section(0.1, 0.5),
                child: _StreakCard(user: user),
              ),
            ),

            // ── Due cards banner ──────────────────────────────────────────
            if (totalDue > 0)
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _section(0.2, 0.6),
                  child: _DueBanner(count: totalDue),
                ),
              ),

            // ── Continue learning ─────────────────────────────────────────
            if (lastTopic != null)
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _section(0.25, 0.65),
                  child: _ContinueLearning(topic: lastTopic),
                ),
              ),

            // ── Quick actions ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlide(
                animation: _section(0.3, 0.7),
                child: _QuickActions(),
              ),
            ),

            // ── Needs attention ───────────────────────────────────────────
            if (weakTopics.isNotEmpty)
              SliverToBoxAdapter(
                child: _FadeSlide(
                  animation: _section(0.4, 0.8),
                  child: _NeedsAttention(topics: weakTopics),
                ),
              ),

            // ── Stats grid ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FadeSlide(
                animation: _section(0.5, 0.9),
                child: _StatsGrid(user: user),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable entrance animator
// ---------------------------------------------------------------------------

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeSlide({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting header
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  final UserModel? user;
  const _GreetingHeader({required this.user});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final fsName = user?.displayName ?? '';
    final authName = firebaseUser?.displayName ?? '';
    final name = (fsName.isNotEmpty ? fsName : authName).split(' ').first;

    final fsPhoto = user?.photoUrl ?? '';
    final photoUrl =
        fsPhoto.isNotEmpty ? fsPhoto : firebaseUser?.photoURL;

    final initials = _initials(name);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 56, AppSpacing.lg, AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  name.isEmpty ? 'Welcome back 👋' : '$name 👋',
                  style: AppTextStyles.headingLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () => context.go('/home/profile'),
            child: photoUrl != null && photoUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 23,
                    backgroundColor: AppColors.kSurfaceVariant,
                    backgroundImage: CachedNetworkImageProvider(photoUrl),
                  )
                : CircleAvatar(
                    radius: 23,
                    backgroundColor: AppColors.kPrimaryContainer,
                    child: Text(
                      initials,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.kPrimary),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Streak card
// ---------------------------------------------------------------------------

class _StreakCard extends StatelessWidget {
  final UserModel? user;
  const _StreakCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final streak = user?.currentStreak ?? 0;
    final longest = user?.longestStreak ?? 0;
    final cards = user?.totalCardsReviewed ?? 0;
    final accuracy = ((user?.overallAccuracy ?? 0.0) * 100).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          gradient: const LinearGradient(
            colors: [Color(0xFF1C1060), Color(0xFF0D2040)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            // Top row — streak hero
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.kAccent.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                          color: AppColors.kAccent.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.kAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: streak),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        builder: (_, v, __) => Text(
                          '$v day${v == 1 ? '' : 's'}',
                          style: AppTextStyles.displayMedium
                              .copyWith(color: AppColors.kAccent, height: 1),
                        ),
                      ),
                      Text(
                        'current streak',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.kAccent.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (longest > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${longest}d',
                          style: AppTextStyles.headingSmall
                              .copyWith(color: AppColors.kTextPrimary),
                        ),
                        Text('best', style: AppTextStyles.caption),
                      ],
                    ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg),
              color: AppColors.kPrimary.withValues(alpha: 0.15),
            ),

            // Bottom row — cards + accuracy
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  _StreakStat(
                    icon: Icons.style_rounded,
                    color: AppColors.kPrimary,
                    value: _compact(cards),
                    label: 'Cards reviewed',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    color: AppColors.kPrimary.withValues(alpha: 0.2),
                  ),
                  _StreakStat(
                    icon: Icons.track_changes_rounded,
                    color: AppColors.kSuccess,
                    value: '$accuracy%',
                    label: 'Accuracy',
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    color: AppColors.kPrimary.withValues(alpha: 0.2),
                  ),
                  _StreakStat(
                    icon: Icons.schedule_rounded,
                    color: AppColors.kSecondary,
                    value: _formatMinutes(user?.totalStudyMinutes ?? 0),
                    label: 'Study time',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compact(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  String _formatMinutes(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }
}

class _StreakStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StreakStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.kTextPrimary),
                ),
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Due cards banner
// ---------------------------------------------------------------------------

class _DueBanner extends StatelessWidget {
  final int count;
  const _DueBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/home/library'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.kWarning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                  color: AppColors.kWarning.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.kWarning.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(Icons.pending_actions_rounded,
                        size: 18, color: AppColors.kWarning),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count card${count == 1 ? '' : 's'} due today',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.kTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Keep your streak alive — review now',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.kWarning,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      'Review',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: const Color(0xFF1A1400),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Continue learning
// ---------------------------------------------------------------------------

class _ContinueLearning extends StatelessWidget {
  final ProgressModel topic;
  const _ContinueLearning({required this.topic});

  @override
  Widget build(BuildContext context) {
    final mastery = topic.masteryPercent / 100;
    final (levelColor, levelLabel) = _levelInfo(topic.masteryLevel);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 2, bottom: AppSpacing.sm),
            child: Text('Continue learning',
                style: AppTextStyles.headingSmall),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  context.push('/home/progress/${topic.topicId}'),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusMd),
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.kBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Mastery ring
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: mastery),
                              duration:
                                  const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => CustomPaint(
                                painter: _MiniRingPainter(
                                    progress: v, color: levelColor),
                                child: const SizedBox(
                                    width: 52, height: 52),
                              ),
                            ),
                            Text(
                              '${topic.masteryPercent.round()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: levelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.topicName.isNotEmpty
                                  ? topic.topicName
                                  : topic.topicId,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.kTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: levelColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    levelLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: levelColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${topic.totalSessions} sessions',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: mastery),
                                duration:
                                    const Duration(milliseconds: 800),
                                curve: Curves.easeOut,
                                builder: (_, v, __) =>
                                    LinearProgressIndicator(
                                  value: v,
                                  minHeight: 4,
                                  backgroundColor:
                                      AppColors.kSurfaceVariant,
                                  valueColor:
                                      AlwaysStoppedAnimation(levelColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.chevron_right_rounded,
                          size: 20, color: AppColors.kTextDisabled),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _levelInfo(String level) => switch (level) {
        'mastered' => (AppColors.kSuccess, 'Mastered'),
        'reviewing' => (AppColors.kPrimary, 'Reviewing'),
        _ => (AppColors.kWarning, 'Learning'),
      };
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _MiniRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const sw = 4.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx - sw / 2;

    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = AppColors.kSurfaceVariant
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw);

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniRingPainter o) =>
      o.progress != progress || o.color != color;
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

class _QuickActions extends StatelessWidget {
  static const _actions = [
    (
      Icons.menu_book_rounded,
      'Browse\nLibrary',
      AppColors.kPrimary,
      '/home/library',
    ),
    (
      Icons.upload_file_outlined,
      'Upload\nPDF',
      AppColors.kSecondary,
      '/upload',
    ),
    (
      Icons.bar_chart_rounded,
      'My\nProgress',
      AppColors.kSuccess,
      '/home/progress',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 2, bottom: AppSpacing.sm),
            child:
                Text('Quick actions', style: AppTextStyles.headingSmall),
          ),
          Row(
            children: _actions.asMap().entries.map((e) {
              final (icon, label, color, route) = e.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: e.key == 0 ? 0 : AppSpacing.sm / 2,
                    right: e.key == _actions.length - 1
                        ? 0
                        : AppSpacing.sm / 2,
                  ),
                  child: _ActionTile(
                    icon: icon,
                    label: label,
                    color: color,
                    onTap: () => context.go(route),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120),
        lowerBound: 0.96, upperBound: 1.0, value: 1.0);
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.reverse(),
      onTapUp: (_) {
        _press.forward();
        widget.onTap();
      },
      onTapCancel: () => _press.forward(),
      child: ScaleTransition(
        scale: _press,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
                color: widget.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(widget.icon,
                    size: 20, color: widget.color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.kTextPrimary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Needs attention
// ---------------------------------------------------------------------------

class _NeedsAttention extends StatelessWidget {
  final List<ProgressModel> topics;
  const _NeedsAttention({required this.topics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.sm),
            child: Row(
              children: [
                Text('Needs attention',
                    style: AppTextStyles.headingSmall),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.kError,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          ...topics.take(3).map((t) => _WeakRow(topic: t)),
        ],
      ),
    );
  }
}

class _WeakRow extends StatelessWidget {
  final ProgressModel topic;
  const _WeakRow({required this.topic});

  @override
  Widget build(BuildContext context) {
    final acc = (topic.accuracy * 100).round();

    return GestureDetector(
      onTap: () => context.push('/home/progress/${topic.topicId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md - 2),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
              color: AppColors.kError.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.kError.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.kError),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topicName.isNotEmpty
                        ? topic.topicName
                        : topic.topicId,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: topic.accuracy),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 4,
                        backgroundColor:
                            AppColors.kError.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.kError),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '$acc%',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.kError),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: AppColors.kTextDisabled),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats grid
// ---------------------------------------------------------------------------

class _StatsGrid extends StatelessWidget {
  final UserModel? user;
  const _StatsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        Icons.style_rounded,
        AppColors.kPrimary,
        _compact(user?.totalCardsReviewed ?? 0),
        'Total cards',
      ),
      (
        Icons.local_fire_department_rounded,
        AppColors.kAccent,
        '${user?.longestStreak ?? 0}d',
        'Best streak',
      ),
      (
        Icons.school_rounded,
        AppColors.kSecondary,
        '${user?.topicsStarted ?? 0}',
        'Topics studied',
      ),
      (
        Icons.schedule_rounded,
        AppColors.kSuccess,
        _formatTime(user?.totalStudyMinutes ?? 0),
        'Study time',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: 2, bottom: AppSpacing.sm),
            child:
                Text('Your journey', style: AppTextStyles.headingSmall),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.7,
            children: items
                .map((item) => _StatTile(
                      icon: item.$1,
                      color: item.$2,
                      value: item.$3,
                      label: item.$4,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  static String _compact(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  static String _formatTime(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    return '${h}h';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => Text(
                    value,
                    style: AppTextStyles.headingSmall
                        .copyWith(color: AppColors.kTextPrimary),
                  ),
                ),
                Text(label,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
