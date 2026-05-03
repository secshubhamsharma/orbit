import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/progress_model.dart';
import 'package:orbitapp/models/review_session_model.dart';
import 'package:orbitapp/providers/auth_provider.dart';
import 'package:orbitapp/providers/progress_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Local providers — both real-time streams so the screen updates live
// ---------------------------------------------------------------------------

/// Real-time stream of sessions for this topic (client-side filter).
final _topicSessionsProvider =
    StreamProvider.family<List<ReviewSessionModel>, String>((ref, topicId) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return FirestoreService.instance.topicSessionsStream(user.uid, topicId);
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class TopicDetailScreen extends ConsumerWidget {
  final String topicId;
  const TopicDetailScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final progressAsync = user == null
        ? const AsyncValue<ProgressModel?>.data(null)
        : ref.watch(
            topicProgressProvider((uid: user.uid, topicId: topicId)));
    final sessionsAsync = ref.watch(_topicSessionsProvider(topicId));

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: progressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kPrimary),
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (progress) => _Body(
          topicId: topicId,
          progress: progress,
          sessionsAsync: sessionsAsync,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String topicId;
  final ProgressModel? progress;
  final AsyncValue<List<ReviewSessionModel>> sessionsAsync;

  const _Body({
    required this.topicId,
    required this.progress,
    required this.sessionsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final name = progress?.topicName.isNotEmpty == true
        ? progress!.topicName
        : topicId;

    return CustomScrollView(
      slivers: [
        // ── SliverAppBar ────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppColors.kBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.kTextPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(name,
              style: AppTextStyles.headingSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),

        if (progress == null)
          SliverFillRemaining(
            child: _NoDataState(topicId: topicId),
          )
        else ...[
          // ── Hero: accuracy ring + stat row ────────────────────────────
          SliverToBoxAdapter(
            child: _HeroSection(progress: progress!),
          ),

          // ── MCQ Performance (replaces broken "Card status") ───────────
          SliverToBoxAdapter(
            child: _McqPerformance(progress: progress!),
          ),

          // ── Answer breakdown per-session ──────────────────────────────
          SliverToBoxAdapter(
            child: sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? const SizedBox.shrink()
                  : _AnswerBreakdown(sessions: sessions),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // ── Session history ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: sessionsAsync.when(
              data: (sessions) => sessions.isEmpty
                  ? const SizedBox.shrink()
                  : _SessionHistory(sessions: sessions),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Hero section — accuracy ring + key numbers
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  final ProgressModel progress;
  const _HeroSection({required this.progress});

  @override
  Widget build(BuildContext context) {
    final (levelColor, levelLabel, levelIcon) =
        _levelInfo(progress.masteryLevel);

    // Ring and percentage show accuracy (0–100 %) so every session moves it.
    final accuracy = progress.accuracy.clamp(0.0, 1.0);
    final accPct   = (accuracy * 100).round();

    // Format study time sensibly
    final mins = progress.totalStudyMinutes;
    final timeLabel = mins < 60
        ? '${mins}m'
        : '${mins ~/ 60}h ${mins % 60}m';

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Column(
          children: [
            // Accuracy ring
            SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: accuracy),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => CustomPaint(
                      painter:
                          _BigRingPainter(progress: v, color: levelColor),
                      child: const SizedBox(width: 130, height: 130),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: accPct),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOut,
                        builder: (_, v, __) => Text(
                          '$v%',
                          style: AppTextStyles.displayMedium
                              .copyWith(color: levelColor),
                        ),
                      ),
                      Text('accuracy', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
                border: Border.all(
                    color: levelColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(levelIcon, size: 14, color: levelColor),
                  const SizedBox(width: 6),
                  Text(levelLabel,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: levelColor)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Stat row — Questions / Sessions / Time
            Row(
              children: [
                _MiniStat(
                  label: 'Questions',
                  value: '${progress.totalCardsReviewed}',
                  color: AppColors.kPrimary,
                ),
                _StatDivider(),
                _MiniStat(
                  label: 'Sessions',
                  value: '${progress.totalSessions}',
                  color: AppColors.kSecondary,
                ),
                _StatDivider(),
                _MiniStat(
                  label: 'Study time',
                  value: mins == 0 ? '<1m' : timeLabel,
                  color: AppColors.kAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (Color, String, IconData) _levelInfo(String level) {
    return switch (level) {
      'mastered'  => (AppColors.kSuccess, 'Mastered',  Icons.verified_rounded),
      'reviewing' => (AppColors.kPrimary, 'Reviewing', Icons.refresh_rounded),
      _           => (AppColors.kWarning, 'Learning',  Icons.school_outlined),
    };
  }
}

class _BigRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _BigRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeW = 10.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = cx - strokeW / 2;

    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = AppColors.kSurfaceVariant
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..shader = SweepGradient(
            colors: [color.withValues(alpha: 0.5), color],
            startAngle: -math.pi / 2,
            endAngle: -math.pi / 2 + 2 * math.pi * progress,
          ).createShader(
              Rect.fromCircle(center: Offset(cx, cy), radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_BigRingPainter old) =>
      old.progress != progress || old.color != color;
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.headingSmall.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.kBorder);
}

// ---------------------------------------------------------------------------
// MCQ Performance — replaces the broken "Card status" section
// Shows real, always-populated data: total answered, correct, wrong
// ---------------------------------------------------------------------------

class _McqPerformance extends StatelessWidget {
  final ProgressModel progress;
  const _McqPerformance({required this.progress});

  @override
  Widget build(BuildContext context) {
    final total   = progress.totalCardsReviewed;
    final correct = progress.totalCorrect;
    final wrong   = progress.totalIncorrect;

    // Overall accuracy bar
    final accuracy = total > 0 ? correct / total : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MCQ Performance', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.md),
          // Tiles
          Row(
            children: [
              _PerfTile(
                icon: Icons.quiz_rounded,
                label: 'Answered',
                count: total,
                color: AppColors.kPrimary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _PerfTile(
                icon: Icons.check_circle_rounded,
                label: 'Correct',
                count: correct,
                color: AppColors.kSuccess,
              ),
              const SizedBox(width: AppSpacing.sm),
              _PerfTile(
                icon: Icons.cancel_rounded,
                label: 'Wrong',
                count: wrong,
                color: AppColors.kError,
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: AppSpacing.md),
            // Overall accuracy bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.kSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Overall accuracy',
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600)),
                      Text(
                        '${(accuracy * 100).round()}%',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: accuracy >= 0.7
                              ? AppColors.kSuccess
                              : accuracy >= 0.5
                                  ? AppColors.kWarning
                                  : AppColors.kError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: accuracy),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        backgroundColor:
                            AppColors.kSurfaceVariant,
                        valueColor: AlwaysStoppedAnimation(
                          v >= 0.7
                              ? AppColors.kSuccess
                              : v >= 0.5
                                  ? AppColors.kWarning
                                  : AppColors.kError,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Improves as you retry and answer more questions correctly',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.kTextDisabled),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerfTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;

  const _PerfTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: count),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              builder: (_, v, __) => Text(
                '$v',
                style: AppTextStyles.headingMedium.copyWith(color: color),
              ),
            ),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Answer breakdown — Correct vs Wrong stacked bar (MCQ-appropriate)
// Replaces the old Again/Hard/Good/Easy breakdown which doesn't apply to MCQ
// ---------------------------------------------------------------------------

class _AnswerBreakdown extends StatelessWidget {
  final List<ReviewSessionModel> sessions;
  const _AnswerBreakdown({required this.sessions});

  @override
  Widget build(BuildContext context) {
    int totalCorrect = 0;
    int totalWrong   = 0;

    for (final s in sessions) {
      totalCorrect += s.correctCount;
      totalWrong   += s.incorrectCount;
    }

    final total = totalCorrect + totalWrong;
    if (total == 0) return const SizedBox.shrink();

    final correctFrac = totalCorrect / total;
    final wrongFrac   = totalWrong   / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Answer breakdown', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              children: [
                // Stacked bar: green | red
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOut,
                    builder: (_, v, __) => SizedBox(
                      height: 10,
                      child: Row(
                        children: [
                          Flexible(
                            flex: (correctFrac * 1000 * v).round(),
                            child: Container(color: AppColors.kSuccess),
                          ),
                          Flexible(
                            flex: (wrongFrac * 1000 * v).round(),
                            child: Container(color: AppColors.kError),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Legend
                Row(
                  children: [
                    _BreakdownLegend(
                      label: 'Correct',
                      count: totalCorrect,
                      color: AppColors.kSuccess,
                    ),
                    _BreakdownLegend(
                      label: 'Wrong',
                      count: totalWrong,
                      color: AppColors.kError,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownLegend extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _BreakdownLegend(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
            Text(
              '$count',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.kTextPrimary),
            ),
          ],
        ),
      );
}

// ---------------------------------------------------------------------------
// Session history
// ---------------------------------------------------------------------------

class _SessionHistory extends StatelessWidget {
  final List<ReviewSessionModel> sessions;
  const _SessionHistory({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Session history', style: AppTextStyles.headingSmall),
              Text(
                '${sessions.length} '
                '${sessions.length == 1 ? 'session' : 'sessions'}',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.kPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...sessions.asMap().entries.map((e) => _SessionRow(
                session: e.value,
                isLast: e.key == sessions.length - 1,
              )),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final ReviewSessionModel session;
  final bool isLast;
  const _SessionRow({required this.session, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final acc = (session.accuracy * 100).round();
    final accColor = acc >= 80
        ? AppColors.kSuccess
        : acc >= 60
            ? AppColors.kWarning
            : AppColors.kError;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: accColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppColors.kBorder,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          // Card
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.kBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(session.startedAt),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.kTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${session.cardsReviewed} questions'
                            ' · ${_dur(session.durationSeconds)}'
                            ' · ${session.correctCount}✓ ${session.incorrectCount}✗',
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
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull),
                      ),
                      child: Text(
                        '$acc%',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: accColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${m[dt.month - 1]}, '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _dur(int s) {
    if (s < 60) return '${s}s';
    final m = s ~/ 60;
    final rem = s % 60;
    return rem == 0 ? '${m}m' : '${m}m ${rem}s';
  }
}

// ---------------------------------------------------------------------------
// No data state
// ---------------------------------------------------------------------------

class _NoDataState extends StatelessWidget {
  final String topicId;
  const _NoDataState({required this.topicId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.kSurfaceVariant,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusXl),
              ),
              child: const Icon(Icons.bar_chart_rounded,
                  size: 36, color: AppColors.kTextDisabled),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No data yet', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Answer some questions to start tracking your progress.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
