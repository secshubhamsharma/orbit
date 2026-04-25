import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/progress_model.dart';
import 'package:orbitapp/models/review_session_model.dart';
import 'package:orbitapp/models/user_model.dart';
import 'package:orbitapp/providers/auth_provider.dart';
import 'package:orbitapp/providers/progress_provider.dart';
import 'package:orbitapp/providers/user_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Local providers
// ---------------------------------------------------------------------------

final _recentSessionsProvider =
    FutureProvider<List<ReviewSessionModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return FirestoreService.instance.getSessions(user.uid, limit: 5);
});

final _weeklyActivityProvider = FutureProvider<List<int>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return List.filled(7, 0);
  return FirestoreService.instance.getWeeklyActivity(user.uid);
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final allProgressAsync = ref.watch(allProgressProvider);
    final sessionsAsync = ref.watch(_recentSessionsProvider);
    final weeklyAsync = ref.watch(_weeklyActivityProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: RefreshIndicator(
        color: AppColors.kPrimary,
        backgroundColor: AppColors.kSurface,
        onRefresh: () async {
          ref.invalidate(allProgressProvider);
          ref.invalidate(_recentSessionsProvider);
          ref.invalidate(_weeklyActivityProvider);
          ref.invalidate(userProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── App bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Header(userAsync: userAsync),
            ),

            // ── Summary stats ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: userAsync.when(
                data: (user) => _SummaryCard(user: user),
                loading: () => _SummaryCard(user: null),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Weekly activity chart ────────────────────────────────────
            SliverToBoxAdapter(
              child: weeklyAsync.when(
                data: (counts) => _WeeklyChart(counts: counts),
                loading: () => _WeeklyChart(counts: List.filled(7, 0)),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Mastery breakdown ────────────────────────────────────────
            SliverToBoxAdapter(
              child: allProgressAsync.when(
                data: (list) => _MasteryBreakdown(topics: list),
                loading: () => const _SectionSkeleton(height: 140),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Recent sessions ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: sessionsAsync.when(
                data: (sessions) => sessions.isEmpty
                    ? const SizedBox.shrink()
                    : _RecentSessions(sessions: sessions),
                loading: () => const _SectionSkeleton(height: 200),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // ── Topic list ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: allProgressAsync.when(
                data: (list) => _TopicList(topics: list),
                loading: () => const _SectionSkeleton(height: 300),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final AsyncValue<UserModel?> userAsync;
  const _Header({required this.userAsync});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 56, AppSpacing.lg, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress', style: AppTextStyles.headingLarge),
                Text(
                  'Track your learning journey',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: const Icon(Icons.bar_chart_rounded,
                size: 20, color: AppColors.kPrimary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card — animated counters
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final UserModel? user;
  const _SummaryCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1240), Color(0xFF0E1F30)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
              color: AppColors.kPrimary.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _AnimatedStat(
                  value: user?.totalCardsReviewed ?? 0,
                  label: 'Cards reviewed',
                  icon: Icons.style_rounded,
                  color: AppColors.kPrimary,
                ),
                _VerticalDivider(),
                _AnimatedStat(
                  value: ((user?.overallAccuracy ?? 0) * 100).round(),
                  label: 'Accuracy',
                  suffix: '%',
                  icon: Icons.track_changes_rounded,
                  color: AppColors.kSuccess,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(height: 1, color: AppColors.kBorder),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _AnimatedStat(
                  value: user?.currentStreak ?? 0,
                  label: 'Day streak',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.kAccent,
                ),
                _VerticalDivider(),
                _AnimatedStat(
                  value: user?.totalStudyMinutes ?? 0,
                  label: 'Minutes studied',
                  icon: Icons.schedule_rounded,
                  color: AppColors.kSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedStat extends StatelessWidget {
  final int value;
  final String label;
  final String suffix;
  final IconData icon;
  final Color color;

  const _AnimatedStat({
    required this.value,
    required this.label,
    this.suffix = '',
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOut,
                  builder: (_, v, __) => Text(
                    '$v$suffix',
                    style: AppTextStyles.headingMedium
                        .copyWith(color: AppColors.kTextPrimary),
                  ),
                ),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: AppColors.kBorder,
      );
}

// ---------------------------------------------------------------------------
// Weekly activity bar chart
// ---------------------------------------------------------------------------

class _WeeklyChart extends StatefulWidget {
  final List<int> counts;
  const _WeeklyChart({required this.counts});

  @override
  State<_WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<_WeeklyChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'This week',
      child: SizedBox(
        height: 140,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => CustomPaint(
            painter: _BarChartPainter(
              counts: widget.counts,
              progress: _anim.value,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<int> counts;
  final double progress;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  _BarChartPainter({required this.counts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 22.0;
    const barPad = 10.0;
    final chartH = size.height - labelH;
    final max = counts.reduce(math.max).clamp(1, 9999).toDouble();
    final barW = (size.width - barPad * (counts.length + 1)) / counts.length;

    final today = DateTime.now().weekday - 1; // 0=Mon

    for (int i = 0; i < counts.length; i++) {
      final x = barPad + i * (barW + barPad);
      final fraction = (counts[i] / max) * progress;
      final barH = fraction * (chartH - 20);

      final isToday = i == today;

      // bar
      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, chartH - barH, barW, barH),
        const Radius.circular(6),
      );

      final paint = Paint()
        ..shader = LinearGradient(
          colors: isToday
              ? [AppColors.kPrimary, AppColors.kPrimaryLight]
              : [AppColors.kSurfaceVariant, AppColors.kSurfaceHigh],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ).createShader(
            Rect.fromLTWH(x, chartH - barH, barW, barH));

      canvas.drawRRect(barRect, paint);

      // count label above bar
      if (counts[i] > 0 && progress > 0.8) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${counts[i]}',
            style: TextStyle(
              fontSize: 9,
              color: isToday
                  ? AppColors.kPrimary
                  : AppColors.kTextDisabled,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset(x + barW / 2 - tp.width / 2, chartH - barH - 14),
        );
      }

      // day label
      final dayLabel = TextPainter(
        text: TextSpan(
          text: _days[i % 7],
          style: TextStyle(
            fontSize: 10,
            color: isToday
                ? AppColors.kPrimary
                : AppColors.kTextDisabled,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dayLabel.paint(
        canvas,
        Offset(x + barW / 2 - dayLabel.width / 2, size.height - labelH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.progress != progress || old.counts != counts;
}

// ---------------------------------------------------------------------------
// Mastery breakdown
// ---------------------------------------------------------------------------

class _MasteryBreakdown extends StatelessWidget {
  final List<ProgressModel> topics;
  const _MasteryBreakdown({required this.topics});

  @override
  Widget build(BuildContext context) {
    final learning =
        topics.where((t) => t.masteryLevel == 'learning').length;
    final reviewing =
        topics.where((t) => t.masteryLevel == 'reviewing').length;
    final mastered =
        topics.where((t) => t.masteryLevel == 'mastered').length;
    final total = topics.length;

    return _Section(
      title: 'Mastery overview',
      child: Column(
        children: [
          _MasteryBar(
            label: 'Learning',
            count: learning,
            total: total,
            color: AppColors.kWarning,
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          _MasteryBar(
            label: 'Reviewing',
            count: reviewing,
            total: total,
            color: AppColors.kPrimary,
            icon: Icons.refresh_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          _MasteryBar(
            label: 'Mastered',
            count: mastered,
            total: total,
            color: AppColors.kSuccess,
            icon: Icons.verified_rounded,
          ),
        ],
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final IconData icon;

  const _MasteryBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : count / total;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 72,
          child: Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.kTextPrimary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: AppColors.kSurfaceVariant,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 30,
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.kTextPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Recent sessions
// ---------------------------------------------------------------------------

class _RecentSessions extends StatelessWidget {
  final List<ReviewSessionModel> sessions;
  const _RecentSessions({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Recent sessions',
      child: Column(
        children: sessions.asMap().entries.map((e) {
          return _AnimatedListItem(
            index: e.key,
            child: _SessionTile(session: e.value),
          );
        }).toList(),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ReviewSessionModel session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final acc = (session.accuracy * 100).round();
    final accColor = acc >= 80
        ? AppColors.kSuccess
        : acc >= 60
            ? AppColors.kWarning
            : AppColors.kError;
    final dur = _formatDuration(session.durationSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(Icons.history_edu_rounded, size: 20, color: accColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.topicName.isNotEmpty
                      ? session.topicName
                      : 'Review session',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.cardsReviewed} cards · $dur · ${_timeAgo(session.startedAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: accColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              '$acc%',
              style: AppTextStyles.labelSmall.copyWith(
                color: accColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    return '${m}m';
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${m[dt.month - 1]}';
  }
}

// ---------------------------------------------------------------------------
// Topic list
// ---------------------------------------------------------------------------

class _TopicList extends StatelessWidget {
  final List<ProgressModel> topics;
  const _TopicList({required this.topics});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return _EmptyState();
    }

    // Sort: mastered last, then by accuracy descending
    final sorted = [...topics]..sort((a, b) {
        final levelOrder = {'mastered': 2, 'reviewing': 1, 'learning': 0};
        final la = levelOrder[a.masteryLevel] ?? 0;
        final lb = levelOrder[b.masteryLevel] ?? 0;
        if (la != lb) return lb.compareTo(la);
        return b.accuracy.compareTo(a.accuracy);
      });

    return _Section(
      title: 'Topics studied',
      trailing: Text(
        '${topics.length} total',
        style: AppTextStyles.caption.copyWith(color: AppColors.kPrimary),
      ),
      child: Column(
        children: sorted.asMap().entries.map((e) {
          return _AnimatedListItem(
            index: e.key,
            child: _TopicTile(topic: e.value),
          );
        }).toList(),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final ProgressModel topic;
  const _TopicTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    final (levelColor, levelLabel, levelIcon) = _levelInfo(topic.masteryLevel);
    final acc = (topic.accuracy * 100).round();
    final mastery = topic.masteryPercent.round();

    return GestureDetector(
      onTap: () => context.push('/home/progress/${topic.topicId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Row(
          children: [
            // Mastery ring
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                        begin: 0, end: topic.masteryPercent / 100),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CustomPaint(
                      painter: _RingPainter(
                          progress: v, color: levelColor),
                      child: const SizedBox(width: 48, height: 48),
                    ),
                  ),
                  Text(
                    '$mastery%',
                    style: TextStyle(
                      fontSize: 10,
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(levelIcon, size: 11, color: levelColor),
                      const SizedBox(width: 3),
                      Text(
                        levelLabel,
                        style: AppTextStyles.caption
                            .copyWith(color: levelColor, fontSize: 10),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '·  ${topic.totalSessions} sessions',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '·  $acc% accuracy',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: topic.accuracy),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 4,
                        backgroundColor: AppColors.kSurfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          acc >= 80
                              ? AppColors.kSuccess
                              : acc >= 60
                                  ? AppColors.kWarning
                                  : AppColors.kError,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.kTextDisabled),
          ],
        ),
      ),
    );
  }

  (Color, String, IconData) _levelInfo(String level) {
    return switch (level) {
      'mastered' => (
          AppColors.kSuccess,
          'Mastered',
          Icons.verified_rounded,
        ),
      'reviewing' => (
          AppColors.kPrimary,
          'Reviewing',
          Icons.refresh_rounded,
        ),
      _ => (
          AppColors.kWarning,
          'Learning',
          Icons.school_outlined,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// Circular ring painter
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const strokeW = 4.0;
    final radius = cx - strokeW / 2;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = AppColors.kSurfaceVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: const Icon(
                Icons.insights_rounded,
                size: 40,
                color: AppColors.kTextDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No progress yet', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start reviewing flashcards to see your\nlearning stats here.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: () => context.go('/home/library'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.kPrimary,
                side: const BorderSide(color: AppColors.kPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md),
              ),
              child: Text('Browse Library',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.kPrimary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared section wrapper
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _Section({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.headingSmall),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated list item (staggered entrance)
// ---------------------------------------------------------------------------

class _AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedListItem({required this.index, required this.child});

  @override
  State<_AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<_AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: widget.index * 50),
        () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ---------------------------------------------------------------------------
// Skeleton loader
// ---------------------------------------------------------------------------

class _SectionSkeleton extends StatefulWidget {
  final double height;
  const _SectionSkeleton({required this.height});

  @override
  State<_SectionSkeleton> createState() => _SectionSkeletonState();
}

class _SectionSkeletonState extends State<_SectionSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final color = Color.lerp(
            AppColors.kSurface,
            AppColors.kSurfaceVariant,
            (0.5 - (_ctrl.value - 0.5).abs()) * 2,
          )!;
          return Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          );
        },
      ),
    );
  }
}
