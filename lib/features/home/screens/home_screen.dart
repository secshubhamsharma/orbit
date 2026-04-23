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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final weakTopicsAsync = ref.watch(weakTopicsProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: CustomScrollView(
        slivers: [
          // ── Greeting header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _GreetingHeader(userAsync: userAsync),
          ),

          // ── Streak + stats card ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: userAsync.when(
              data: (user) =>
                  user != null ? _StreakCard(user: user) : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, e) => const SizedBox.shrink(),
            ),
          ),

          // ── Quick start CTA ─────────────────────────────────────────────
          SliverToBoxAdapter(child: _QuickStartCard()),

          // ── Weak topics ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: weakTopicsAsync.when(
              data: (topics) => topics.isEmpty
                  ? const SizedBox.shrink()
                  : _WeakTopicsSection(topics: topics),
              loading: () => const SizedBox.shrink(),
              error: (_, e) => const SizedBox.shrink(),
            ),
          ),

          // ── Lifetime stats ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: userAsync.when(
              data: (user) =>
                  user != null ? _StatsRow(user: user) : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, e) => const SizedBox.shrink(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting header
// ---------------------------------------------------------------------------

class _GreetingHeader extends StatelessWidget {
  final AsyncValue<UserModel?> userAsync;

  const _GreetingHeader({required this.userAsync});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final fsName = userAsync.valueOrNull?.displayName ?? '';
    final authName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final resolvedName = fsName.isNotEmpty ? fsName : authName;
    final name = resolvedName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 56, AppSpacing.lg, AppSpacing.lg),
      child: Row(
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
                const SizedBox(height: 2),
                Text(
                  name.isEmpty ? 'Welcome back 👋' : '$name 👋',
                  style: AppTextStyles.headingLarge,
                ),
              ],
            ),
          ),
          userAsync.when(
            data: (user) => _Avatar(user: user),
            loading: () => const _AvatarPlaceholder(),
            error: (_, e) => const _AvatarPlaceholder(),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final UserModel? user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    // Priority: Firestore photoUrl → Firebase Auth photoURL → initials fallback.
    // This matches the same resolution chain used in ProfileScreen and EditProfileScreen.
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final fsPhoto = user?.photoUrl ?? '';
    final photoUrl = fsPhoto.isNotEmpty ? fsPhoto : firebaseUser?.photoURL;

    final fsName = user?.displayName ?? '';
    final name = fsName.isNotEmpty ? fsName : (firebaseUser?.displayName ?? '');
    final initials = _initials(name);

    return GestureDetector(
      onTap: () => context.go('/home/profile'),
      child: photoUrl != null && photoUrl.isNotEmpty
          ? CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.kSurfaceVariant,
              backgroundImage: CachedNetworkImageProvider(photoUrl),
            )
          : CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.kPrimaryContainer,
              child: Text(
                initials,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kPrimary),
              ),
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

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.kSurfaceVariant,
    );
  }
}

// ---------------------------------------------------------------------------
// Streak card
// ---------------------------------------------------------------------------

class _StreakCard extends StatelessWidget {
  final UserModel user;

  const _StreakCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final streak = user.currentStreak;
    final total = user.totalCardsReviewed;
    final accuracy = user.overallAccuracy;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1040), Color(0xFF0F2028)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.kPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$streak',
                    style: AppTextStyles.displayMedium
                        .copyWith(color: AppColors.kAccent),
                  ),
                ],
              ),
              Text('day streak', style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          Container(width: 1, height: 48, color: AppColors.kBorder),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$total',
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.kTextPrimary),
              ),
              Text('cards reviewed', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(accuracy * 100).round()}%',
                style: AppTextStyles.headingMedium
                    .copyWith(color: AppColors.kSuccess),
              ),
              Text('accuracy', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick start CTA
// ---------------------------------------------------------------------------

class _QuickStartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
      child: GestureDetector(
        onTap: () => context.go('/home/library'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.kGradientPrimary,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.kPrimary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse Library',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pick a book and start generating flashcards',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.library_books_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weak topics section
// ---------------------------------------------------------------------------

class _WeakTopicsSection extends StatelessWidget {
  final List<ProgressModel> topics;

  const _WeakTopicsSection({required this.topics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Text('Needs attention', style: AppTextStyles.headingSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...topics.map((t) => _WeakTopicTile(topic: t)),
        ],
      ),
    );
  }
}

class _WeakTopicTile extends StatelessWidget {
  final ProgressModel topic;

  const _WeakTopicTile({required this.topic});

  @override
  Widget build(BuildContext context) {
    final accuracy = topic.accuracy;
    final percent = (accuracy * 100).round();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kError.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: accuracy,
                  strokeWidth: 3,
                  backgroundColor: AppColors.kError.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation(AppColors.kError),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.kTextPrimary,
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
                  topic.topicName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.kTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${topic.totalSessions} sessions · ${topic.totalCardsReviewed} cards',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.kTextSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final UserModel user;

  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your stats', style: AppTextStyles.headingSmall),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatCard(
                emoji: '📚',
                label: 'Topics started',
                value: '${user.topicsStarted}',
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(
                emoji: '🏆',
                label: 'Best streak',
                value: '${user.longestStreak}d',
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(
                emoji: '⏱️',
                label: 'Study time',
                value: _formatMinutes(user.totalStudyMinutes),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.kTextPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
