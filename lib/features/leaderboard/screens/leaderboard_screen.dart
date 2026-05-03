import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/leaderboard_model.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Real-time top-50 leaderboard stream.
final _leaderboardProvider =
    StreamProvider<List<LeaderboardEntryModel>>((ref) {
  return FirestoreService.instance.leaderboardStream(limit: 50);
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) => CurvedAnimation(
        parent: _entrance,
        curve: Interval(start, end, curve: Curves.easeOut),
      );

  Animation<Offset> _slide(double start, double end,
          [Offset begin = const Offset(0, 0.15)]) =>
      Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entrance,
            curve: Interval(start, end, curve: Curves.easeOutCubic)),
      );

  @override
  Widget build(BuildContext context) {
    final leaderAsync = ref.watch(_leaderboardProvider);
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: leaderAsync.when(
        loading: () => _buildShell(child: const _Shimmer()),
        error: (e, _) => _buildShell(
          child: _ErrorState(
            onRetry: () => ref.invalidate(_leaderboardProvider),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return _buildShell(child: const _EmptyState());
          }

          final myEntry  = entries.where((e) => e.userId == myUid).firstOrNull;
          final top3     = entries.take(3).toList();
          final rest     = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntryModel>[];
          final inTop50  = myEntry != null;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fade(0.0, 0.35),
                  child: const _Header(),
                ),
              ),

              // ── My rank if NOT in top 50 ─────────────────────────────────
              if (!inTop50)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fade(0.1, 0.45),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                      child: _NotRankedBanner(),
                    ),
                  ),
                ),

              // ── Podium ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slide(0.05, 0.55),
                  child: FadeTransition(
                    opacity: _fade(0.05, 0.55),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: _Podium(top3: top3, myUid: myUid),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl)),

              // ── "Rankings" label ────────────────────────────────────────
              if (rest.isNotEmpty)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fade(0.35, 0.65),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                      child: Row(
                        children: [
                          Text(
                            'Rankings',
                            style: AppTextStyles.headingSmall,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.kSurfaceVariant,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull),
                            ),
                            child: Text(
                              '${rest.length + 3} players',
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── List: 4th place onwards ──────────────────────────────────
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final entry = rest[i];
                    final isMe  = entry.userId == myUid;
                    return _AnimatedRow(
                      index: i,
                      ctrl:  _entrance,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                        child: _RankRow(entry: entry, isMe: isMe),
                      ),
                    );
                  },
                  childCount: rest.length,
                ),
              ),

              // ── Sticky "You" banner at bottom ────────────────────────────
              if (inTop50)
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fade(0.5, 0.9),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, AppSpacing.lg,
                          AppSpacing.lg, AppSpacing.xxl),
                      child: _MyRankBar(entry: myEntry),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShell({required Widget child}) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _Header()),
        SliverFillRemaining(
          hasScrollBody: false,
          child: child,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.kSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.kBorder),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  size: 20, color: AppColors.kTextPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leaderboard', style: AppTextStyles.headingLarge),
                const SizedBox(height: 2),
                Text(
                  'Top 50 • All-time rankings',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.kTextSecondary),
                ),
              ],
            ),
          ),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.kSuccess.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                  color: AppColors.kSuccess.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.kSuccess,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text('Live',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.kSuccess)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Podium (top 3)
// ---------------------------------------------------------------------------

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.myUid});
  final List<LeaderboardEntryModel> top3;
  final String? myUid;

  @override
  Widget build(BuildContext context) {
    final first  = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third  = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1260), Color(0xFF0D1230)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Podium avatars
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _PodiumSlot(
                  entry: second,
                  position: 2,
                  blockHeight: 80,
                  isMe: second?.userId == myUid,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PodiumSlot(
                  entry: first,
                  position: 1,
                  blockHeight: 112,
                  isMe: first?.userId == myUid,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PodiumSlot(
                  entry: third,
                  position: 3,
                  blockHeight: 60,
                  isMe: third?.userId == myUid,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Stats strip
          Row(
            children: [
              if (second != null)
                Expanded(child: _PodiumStat(entry: second)),
              if (second != null) const SizedBox(width: AppSpacing.sm),
              if (first != null)
                Expanded(child: _PodiumStat(entry: first, gold: true)),
              if (first != null && third != null)
                const SizedBox(width: AppSpacing.sm),
              if (third != null)
                Expanded(child: _PodiumStat(entry: third)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumSlot extends StatelessWidget {
  const _PodiumSlot({
    required this.entry,
    required this.position,
    required this.blockHeight,
    required this.isMe,
  });
  final LeaderboardEntryModel? entry;
  final int position;
  final double blockHeight;
  final bool isMe;

  Color get _medal => switch (position) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFB0BEC5),
        _ => const Color(0xFFCD7F32),
      };

  String get _posEmoji => switch (position) {
        1 => '👑',
        2 => '🥈',
        _ => '🥉',
      };

  @override
  Widget build(BuildContext context) {
    if (entry == null) return const SizedBox();
    final name     = entry!.displayName;
    final initials = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final avatarSz = position == 1 ? 68.0 : 52.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown / medal emoji
        Text(_posEmoji,
            style: TextStyle(fontSize: position == 1 ? 22 : 16)),
        const SizedBox(height: 6),

        // Avatar with medal ring
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSz,
              height: avatarSz,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMe ? AppColors.kPrimary : _medal,
                  width: isMe ? 2.5 : 2.0,
                ),
                color: AppColors.kSurfaceVariant,
              ),
              child: ClipOval(
                child: entry!.photoUrl != null &&
                        entry!.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: entry!.photoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (ctx, err, _) => Center(
                          child: Text(initials,
                              style: TextStyle(
                                fontSize: position == 1 ? 22 : 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.kTextPrimary,
                              )),
                        ),
                      )
                    : Center(
                        child: Text(initials,
                            style: TextStyle(
                              fontSize: position == 1 ? 22 : 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kTextPrimary,
                            )),
                      ),
              ),
            ),
            // Rank badge
            Positioned(
              bottom: -5,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _medal,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFF0D1230), width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$position',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Name
        Text(
          isMe ? 'You' : name.split(' ').first,
          style: AppTextStyles.labelSmall.copyWith(
            color: isMe ? AppColors.kPrimaryLight : AppColors.kTextPrimary,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Podium block
        Container(
          height: blockHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _medal.withValues(alpha: 0.30),
                _medal.withValues(alpha: 0.07),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            // Border must be uniform color when borderRadius is set —
            // Flutter constraint. Use a single alpha that reads well.
            border: Border.all(color: _medal.withValues(alpha: 0.35)),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _fmtCards(entry!.totalCardsReviewed),
                style: AppTextStyles.labelLarge
                    .copyWith(color: _medal, fontSize: 15),
              ),
              Text(
                'cards',
                style: AppTextStyles.caption
                    .copyWith(color: _medal.withValues(alpha: 0.7), fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmtCards(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class _PodiumStat extends StatelessWidget {
  const _PodiumStat({required this.entry, this.gold = false});
  final LeaderboardEntryModel entry;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final acc   = (entry.overallAccuracy * 100).round();
    final score = _fmtScore(entry.score);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: gold
            ? const Color(0xFFFFD700).withValues(alpha: 0.08)
            : AppColors.kSurface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: gold
            ? Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.25))
            : null,
      ),
      child: Column(
        children: [
          Text(
            '$acc%',
            style: AppTextStyles.labelMedium.copyWith(
                color: gold
                    ? const Color(0xFFFFD700)
                    : AppColors.kTextPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            '$score pts',
            style: AppTextStyles.caption.copyWith(
                color: AppColors.kTextSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  String _fmtScore(double s) {
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}k';
    return s.round().toString();
  }
}

// ---------------------------------------------------------------------------
// Rank row (4th place onward)
// ---------------------------------------------------------------------------

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.isMe});
  final LeaderboardEntryModel entry;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final name     = entry.displayName;
    final initials = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final acc      = (entry.overallAccuracy * 100).round();
    final score    = _fmtScore(entry.score);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.kPrimaryContainer
            : AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isMe
              ? AppColors.kPrimary.withValues(alpha: 0.4)
              : AppColors.kBorder,
          width: isMe ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 34,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.labelMedium.copyWith(
                color: isMe
                    ? AppColors.kPrimaryLight
                    : entry.rank <= 10
                        ? AppColors.kAccent
                        : AppColors.kTextSecondary,
                fontWeight: entry.rank <= 10
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kSurfaceVariant,
              border: isMe
                  ? Border.all(color: AppColors.kPrimary, width: 1.5)
                  : null,
            ),
            child: ClipOval(
              child: entry.photoUrl != null && entry.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: entry.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, err, _) => Center(
                        child: Text(initials,
                            style: AppTextStyles.labelMedium
                                .copyWith(color: AppColors.kTextPrimary)),
                      ),
                    )
                  : Center(
                      child: Text(initials,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.kTextPrimary)),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Name + streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '${name.split(' ').first} (You)' : name,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isMe
                        ? AppColors.kPrimaryLight
                        : AppColors.kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 12,
                      color: AppColors.kAccent.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${entry.currentStreak}d streak',
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Score + accuracy
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score pts',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isMe
                      ? AppColors.kPrimaryLight
                      : AppColors.kTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    '${entry.totalCardsReviewed} cards',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: _accColor(acc).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$acc%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _accColor(acc),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _accColor(int acc) {
    if (acc >= 80) return AppColors.kSuccess;
    if (acc >= 60) return AppColors.kWarning;
    return AppColors.kError;
  }

  String _fmtScore(double s) {
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}k';
    return s.round().toString();
  }
}

// ---------------------------------------------------------------------------
// My rank sticky banner (visible at bottom for ranked users)
// ---------------------------------------------------------------------------

class _MyRankBar extends StatelessWidget {
  const _MyRankBar({required this.entry});
  final LeaderboardEntryModel entry;

  @override
  Widget build(BuildContext context) {
    final acc   = (entry.overallAccuracy * 100).round();
    final score = entry.score >= 1000
        ? '${(entry.score / 1000).toStringAsFixed(1)}k'
        : entry.score.round().toString();

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F80), Color(0xFF121040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_rounded,
              size: 18, color: AppColors.kPrimaryLight),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Your rank',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.kPrimaryLight),
          ),
          const Spacer(),
          Text(
            '#${entry.rank}',
            style: AppTextStyles.headingSmall
                .copyWith(color: AppColors.kPrimaryLight),
          ),
          const SizedBox(width: AppSpacing.lg),
          _Pip(label: '$score pts', icon: Icons.star_rounded),
          const SizedBox(width: AppSpacing.md),
          _Pip(label: '$acc%', icon: Icons.track_changes_rounded),
        ],
      ),
    );
  }
}

class _Pip extends StatelessWidget {
  const _Pip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.kTextSecondary),
        const SizedBox(width: 4),
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.kTextSecondary)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Banner when user has no leaderboard entry yet
// ---------------------------------------------------------------------------

class _NotRankedBanner extends StatelessWidget {
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
          const Text('🏁', style: TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You\'re not ranked yet',
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: 3),
                Text(
                  'Complete a quiz to get on the board!',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.kTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated list row
// ---------------------------------------------------------------------------

class _AnimatedRow extends StatelessWidget {
  const _AnimatedRow(
      {required this.index, required this.ctrl, required this.child});
  final int index;
  final AnimationController ctrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = math.min(0.35 + index * 0.035, 0.88);
    final end   = math.min(start + 0.22, 1.0);
    final anim  = CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(anim),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.lg),
            Text('No rankings yet', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Be the first! Complete a quiz to claim the #1 spot.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_off_rounded,
                size: 52, color: AppColors.kTextDisabled),
            const SizedBox(height: AppSpacing.lg),
            Text('Could not load leaderboard',
                style: AppTextStyles.headingSmall),
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
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.kPrimary),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer skeleton loader
// ---------------------------------------------------------------------------

class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        final opacity = 0.25 + _ctrl.value * 0.25;
        return Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Podium skeleton
                Container(
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.kSurface,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Row skeletons
                ...List.generate(6, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Container(
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.kSurface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
