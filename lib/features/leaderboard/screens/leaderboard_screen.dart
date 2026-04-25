import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/leaderboard_model.dart';
import 'package:orbitapp/providers/auth_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _currentWeekId() {
  final now = DateTime.now();
  // ISO week number
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
  final weekNum =
      ((dayOfYear - now.weekday + 10) / 7).floor();
  return '${now.year}-W${weekNum.toString().padLeft(2, '0')}';
}

String _weekLabel() {
  final now = DateTime.now();
  final monday =
      now.subtract(Duration(days: now.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  final months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${monday.day} ${months[monday.month]} – '
      '${sunday.day} ${months[sunday.month]}';
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final _leaderboardProvider =
    FutureProvider<List<LeaderboardEntryModel>>((ref) async {
  final weekId = _currentWeekId();
  try {
    return await FirestoreService.instance
        .getWeeklyLeaderboard(weekId, limit: 50);
  } catch (_) {
    return [];
  }
});

final _myEntryProvider =
    FutureProvider<LeaderboardEntryModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final weekId = _currentWeekId();
  try {
    return await FirestoreService.instance
        .getUserLeaderboardEntry(weekId, user.uid);
  } catch (_) {
    return null;
  }
});

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _interval(double start, double end) =>
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    final leaderboardAsync = ref.watch(_leaderboardProvider);
    final myEntryAsync = ref.watch(_myEntryProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: leaderboardAsync.when(
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(e.toString()),
        data: (entries) {
          final myEntry = myEntryAsync.valueOrNull;
          return _buildContent(
            entries: entries,
            myEntry: myEntry,
            currentUid: currentUser?.uid,
          );
        },
      ),
    );
  }

  Widget _buildContent({
    required List<LeaderboardEntryModel> entries,
    required LeaderboardEntryModel? myEntry,
    required String? currentUid,
  }) {
    final top3 = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntryModel>[];
    final isInTop50 = entries.any((e) => e.userId == currentUid);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App Bar ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _interval(0.0, 0.4),
            child: _Header(weekLabel: _weekLabel()),
          ),
        ),

        // ── My Rank Banner (if not in visible top 50) ────────────────────────
        if (myEntry != null && !isInTop50)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _interval(0.1, 0.5),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding, 0, AppSpacing.pagePadding, AppSpacing.lg),
                child: _MyRankBanner(entry: myEntry),
              ),
            ),
          ),

        // ── Podium ───────────────────────────────────────────────────────────
        if (top3.isNotEmpty)
          SliverToBoxAdapter(
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(_interval(0.1, 0.6)),
              child: FadeTransition(
                opacity: _interval(0.1, 0.6),
                child: _Podium(
                  top3: top3,
                  currentUid: currentUid,
                ),
              ),
            ),
          ),

        // ── Section label ────────────────────────────────────────────────────
        if (rest.isNotEmpty)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _interval(0.4, 0.7),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding, AppSpacing.xl,
                    AppSpacing.pagePadding, AppSpacing.md),
                child: Text(
                  'Rankings',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.kTextSecondary),
                ),
              ),
            ),
          ),

        // ── Rest of list ─────────────────────────────────────────────────────
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final entry = rest[i];
              final isMe = entry.userId == currentUid;
              return _AnimatedItem(
                index: i,
                ctrl: _ctrl,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding, 0,
                      AppSpacing.pagePadding, AppSpacing.sm),
                  child: _RankTile(
                    entry: entry,
                    isCurrentUser: isMe,
                  ),
                ),
              );
            },
            childCount: rest.length,
          ),
        ),

        // ── Current user at bottom if in top 50 ──────────────────────────────
        if (myEntry != null && isInTop50 && currentUid != null)
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _interval(0.5, 0.9),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding, AppSpacing.lg,
                    AppSpacing.pagePadding, AppSpacing.xxl),
                child: _MyRankBanner(entry: myEntry, compact: true),
              ),
            ),
          ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.huge),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(weekLabel: _weekLabel()),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: _Skeleton(),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String msg) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Header(weekLabel: _weekLabel()),
        ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.signal_wifi_off_rounded,
                    size: 52, color: AppColors.kTextDisabled),
                const SizedBox(height: AppSpacing.lg),
                Text('Could not load leaderboard',
                    style: AppTextStyles.headingSmall),
                const SizedBox(height: AppSpacing.sm),
                Text('Check your connection and try again',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(_leaderboardProvider),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.kPrimary,
                  ),
                  child: Text('Retry',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.weekLabel});
  final String weekLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.lg,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
        bottom: AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.kBackground,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leaderboard', style: AppTextStyles.headingLarge),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppColors.kTextSecondary),
                  const SizedBox(width: 4),
                  Text(weekLabel,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.kTextSecondary)),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.refresh_rounded,
                    size: 14, color: AppColors.kTextSecondary),
                const SizedBox(width: 4),
                Text('Weekly',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.kTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Podium
// ---------------------------------------------------------------------------

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, required this.currentUid});
  final List<LeaderboardEntryModel> top3;
  final String? currentUid;

  @override
  Widget build(BuildContext context) {
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1730), Color(0xFF12141F)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(
        children: [
          // Crown row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              Expanded(
                child: _PodiumSlot(
                  entry: second,
                  position: 2,
                  height: 90,
                  isCurrentUser: second?.userId == currentUid,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 1st place
              Expanded(
                flex: 1,
                child: _PodiumSlot(
                  entry: first,
                  position: 1,
                  height: 120,
                  isCurrentUser: first?.userId == currentUid,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // 3rd place
              Expanded(
                child: _PodiumSlot(
                  entry: third,
                  position: 3,
                  height: 70,
                  isCurrentUser: third?.userId == currentUid,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Stats row
          Row(
            children: [
              if (second != null)
                Expanded(
                  child: _PodiumStat(entry: second),
                ),
              if (second != null) const SizedBox(width: AppSpacing.md),
              if (first != null)
                Expanded(
                  child: _PodiumStat(entry: first, highlight: true),
                ),
              if (first != null && third != null)
                const SizedBox(width: AppSpacing.md),
              if (third != null)
                Expanded(
                  child: _PodiumStat(entry: third),
                ),
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
    required this.height,
    required this.isCurrentUser,
  });
  final LeaderboardEntryModel? entry;
  final int position;
  final double height;
  final bool isCurrentUser;

  Color get _medalColor {
    switch (position) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFB0BEC5);
      default:
        return const Color(0xFFCD7F32);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (entry == null) return const SizedBox();
    final name = entry!.displayName;
    final initials =
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Medal
        if (position == 1)
          Icon(Icons.workspace_premium_rounded,
              size: 20, color: _medalColor),
        if (position != 1) const SizedBox(height: 20),
        const SizedBox(height: 4),
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: position == 1 ? 72 : 56,
              height: position == 1 ? 72 : 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentUser
                      ? AppColors.kPrimary
                      : _medalColor.withOpacity(0.6),
                  width: isCurrentUser ? 2.5 : 2,
                ),
                color: AppColors.kSurfaceVariant,
              ),
              child: ClipOval(
                child: entry!.photoUrl != null &&
                        entry!.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: entry!.photoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Center(
                          child: Text(initials,
                              style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.kTextPrimary,
                                  fontSize: position == 1 ? 22 : 16)),
                        ),
                      )
                    : Center(
                        child: Text(initials,
                            style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.kTextPrimary,
                                fontSize: position == 1 ? 22 : 16)),
                      ),
              ),
            ),
            // Rank badge
            Positioned(
              bottom: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _medalColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.kBackground, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$position',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Name
        Text(
          name.split(' ').first,
          style: AppTextStyles.labelSmall
              .copyWith(color: AppColors.kTextPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        // Podium block
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: height.toDouble(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _medalColor.withOpacity(0.3),
                _medalColor.withOpacity(0.08),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppSpacing.radiusSm),
              topRight: Radius.circular(AppSpacing.radiusSm),
            ),
            border: Border(
              top: BorderSide(color: _medalColor.withOpacity(0.5)),
              left: BorderSide(color: _medalColor.withOpacity(0.2)),
              right: BorderSide(color: _medalColor.withOpacity(0.2)),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${entry!.weeklyCardsReviewed}',
            style: AppTextStyles.headingSmall
                .copyWith(color: _medalColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _PodiumStat extends StatelessWidget {
  const _PodiumStat({required this.entry, this.highlight = false});
  final LeaderboardEntryModel entry;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final acc = (entry.weeklyAccuracy * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.kPrimaryContainer
            : AppColors.kSurfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: highlight
            ? Border.all(color: AppColors.kPrimary.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Text('$acc%',
              style: AppTextStyles.labelMedium.copyWith(
                  color: highlight
                      ? AppColors.kPrimaryLight
                      : AppColors.kTextPrimary)),
          const SizedBox(height: 2),
          Text('accuracy',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.kTextSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rank tile (4th place onwards)
// ---------------------------------------------------------------------------

class _RankTile extends StatelessWidget {
  const _RankTile({required this.entry, required this.isCurrentUser});
  final LeaderboardEntryModel entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final name = entry.displayName;
    final initials =
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final acc = (entry.weeklyAccuracy * 100).round();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.kPrimaryContainer
            : AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.kPrimary.withOpacity(0.4)
              : AppColors.kBorder,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.labelMedium.copyWith(
                color: isCurrentUser
                    ? AppColors.kPrimaryLight
                    : AppColors.kTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.kSurfaceVariant,
              border: isCurrentUser
                  ? Border.all(
                      color: AppColors.kPrimary, width: 1.5)
                  : null,
            ),
            child: ClipOval(
              child: entry.photoUrl != null && entry.photoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: entry.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Center(
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        isCurrentUser ? '$name (You)' : name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isCurrentUser
                              ? AppColors.kPrimaryLight
                              : AppColors.kTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.local_fire_department_rounded,
                        size: 11,
                        color: AppColors.kWarning.withOpacity(0.8)),
                    const SizedBox(width: 2),
                    Text('${entry.currentStreak}d streak',
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          // Cards + accuracy
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.weeklyCardsReviewed}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: isCurrentUser
                      ? AppColors.kPrimaryLight
                      : AppColors.kTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$acc% acc',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My rank banner
// ---------------------------------------------------------------------------

class _MyRankBanner extends StatelessWidget {
  const _MyRankBanner({required this.entry, this.compact = false});
  final LeaderboardEntryModel entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final acc = (entry.weeklyAccuracy * 100).round();
    final name = entry.displayName;
    final initials =
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2A2060), Color(0xFF1A1A40)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border:
              Border.all(color: AppColors.kPrimary.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_rounded,
                size: 16, color: AppColors.kPrimaryLight),
            const SizedBox(width: AppSpacing.sm),
            Text('Your rank',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kPrimaryLight)),
            const Spacer(),
            Text('#${entry.rank}',
                style: AppTextStyles.headingSmall
                    .copyWith(color: AppColors.kPrimaryLight)),
            const SizedBox(width: AppSpacing.md),
            Text('${entry.weeklyCardsReviewed} cards',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.kTextSecondary)),
          ],
        ),
      );
    }

    // Full banner (not in top 50)
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2060), Color(0xFF1A1A40)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.kPrimary.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your position',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.kTextSecondary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kPrimaryContainer,
                  border:
                      Border.all(color: AppColors.kPrimary, width: 1.5),
                ),
                child: ClipOval(
                  child: entry.photoUrl != null &&
                          entry.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: entry.photoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Center(
                            child: Text(initials,
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.kPrimaryLight)),
                          ),
                        )
                      : Center(
                          child: Text(initials,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.kPrimaryLight)),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name (You)',
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.kPrimaryLight),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded,
                            size: 12, color: AppColors.kWarning),
                        const SizedBox(width: 3),
                        Text('${entry.currentStreak}d streak',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ),
              // Rank badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('#${entry.rank}',
                      style: AppTextStyles.headingMedium
                          .copyWith(color: AppColors.kPrimaryLight)),
                  Text('rank',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.kTextSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.kBorder, height: 1),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _BannerStat(
                icon: Icons.style_rounded,
                label: 'Cards',
                value: '${entry.weeklyCardsReviewed}',
              ),
              _VertDiv(),
              _BannerStat(
                icon: Icons.track_changes_rounded,
                label: 'Accuracy',
                value: '$acc%',
              ),
              _VertDiv(),
              _BannerStat(
                icon: Icons.local_fire_department_rounded,
                label: 'Streak',
                value: '${entry.currentStreak}d',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat(
      {required this.icon,
      required this.label,
      required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.kPrimaryLight),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.kTextPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.kTextSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}

class _VertDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.kBorder,
    );
  }
}

// ---------------------------------------------------------------------------
// Animated list item
// ---------------------------------------------------------------------------

class _AnimatedItem extends StatelessWidget {
  const _AnimatedItem({
    required this.index,
    required this.ctrl,
    required this.child,
  });
  final int index;
  final AnimationController ctrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = math.min(0.35 + index * 0.04, 0.85);
    final end = math.min(start + 0.25, 1.0);
    final anim = CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Skeleton loader
// ---------------------------------------------------------------------------

class _Skeleton extends StatefulWidget {
  @override
  State<_Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<_Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      builder: (_, __) {
        final opacity = 0.3 + _ctrl.value * 0.3;
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              // Podium skeleton
              Container(
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusXl),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              ...List.generate(
                5,
                (i) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.kSurface,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
