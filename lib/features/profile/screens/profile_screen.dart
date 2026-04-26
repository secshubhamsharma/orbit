import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbitapp/models/user_model.dart';
import 'package:orbitapp/providers/progress_provider.dart';
import 'package:orbitapp/providers/user_provider.dart';
import 'package:orbitapp/services/auth_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final allProgressAsync = ref.watch(allProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: userAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.kPrimary),
        ),
        error: (e, _) => Center(
          child: Text(e.toString(), style: AppTextStyles.bodyMedium),
        ),
        data: (user) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ProfileHeader(user: user)),
            SliverToBoxAdapter(
              child: _StatsRow(
                user: user,
                topicsStudied: allProgressAsync.valueOrNull?.length ?? 0,
              ),
            ),
            if (user != null && user.earnedBadges.isNotEmpty)
              SliverToBoxAdapter(
                child: _BadgesSection(badges: user.earnedBadges),
              ),
            SliverToBoxAdapter(child: _AccountSection()),
            SliverToBoxAdapter(child: _AppSection()),
            SliverToBoxAdapter(child: _SignOutTile(ref: ref)),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    // Fall back to Firebase Auth if Firestore doc fields are empty
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final fsName = user?.displayName ?? '';
    final name = fsName.isNotEmpty ? fsName : (firebaseUser?.displayName ?? 'User');

    final fsEmail = user?.email ?? '';
    final email = fsEmail.isNotEmpty ? fsEmail : (firebaseUser?.email ?? '');

    final fsPhoto = user?.photoUrl ?? '';
    final photoUrl = fsPhoto.isNotEmpty ? fsPhoto : firebaseUser?.photoURL;
    final createdAt = user?.createdAt;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.kBorder),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _Avatar(photoUrl: photoUrl, name: name, radius: 48),
                  GestureDetector(
                    onTap: () => context.push('/home/profile/edit'),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.kPrimary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.kBackground, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Text(name,
                  style: AppTextStyles.headingMedium,
                  textAlign: TextAlign.center),

              const SizedBox(height: 2),

              Text(
                email,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),

              if (createdAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Joined ${_formatJoined(createdAt)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatJoined(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ---------------------------------------------------------------------------
// Reusable avatar
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;

  const _Avatar({
    required this.photoUrl,
    required this.name,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(photoUrl!),
        backgroundColor: AppColors.kSurfaceVariant,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.kPrimaryContainer,
      child: Text(
        _initials(name),
        style: TextStyle(
          fontSize: radius * 0.55,
          fontWeight: FontWeight.w700,
          color: AppColors.kPrimary,
        ),
      ),
    );
  }

  String _initials(String n) {
    final p = n.trim().split(' ');
    if (p.isEmpty || p.first.isEmpty) return '?';
    if (p.length == 1) return p.first[0].toUpperCase();
    return (p.first[0] + p.last[0]).toUpperCase();
  }
}

// ---------------------------------------------------------------------------
// Stats row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final UserModel? user;
  final int topicsStudied;

  const _StatsRow({required this.user, required this.topicsStudied});

  @override
  Widget build(BuildContext context) {
    final streak = user?.currentStreak ?? 0;
    final cards = user?.totalCardsReviewed ?? 0;
    final accuracy = (user?.overallAccuracy ?? 0.0) * 100;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _StatCell(value: '$streak', label: 'Streak'),
          _Divider(),
          _StatCell(value: '$cards', label: 'MCQs'),
          _Divider(),
          _StatCell(value: '${accuracy.round()}%', label: 'Accuracy'),
          _Divider(),
          _StatCell(value: '$topicsStudied', label: 'Topics'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.kBorder);
}

// ---------------------------------------------------------------------------
// Badges
// ---------------------------------------------------------------------------

const _badgeMeta = <String, (String, String)>{
  'first_review': ('First Launch', 'Completed your first review session'),
  'streak_7': ('Week Warrior', '7-day study streak'),
  'streak_30': ('Month Master', '30-day study streak'),
  'perfect_session': ('Perfect Score', '100% accuracy in a session'),
  'first_upload': ('Uploader', 'Uploaded your first PDF'),
  'topic_master': ('Topic Master', 'Mastery ≥ 85% on any topic'),
  'explorer': ('Explorer', 'Studied in 3 different domains'),
  'centurion': ('Centurion', 'Reviewed 100 cards total'),
  'ccna_starter': ('Network Nerd', 'Started a CCNA topic'),
  'jee_challenger': ('JEE Challenger', 'Started a JEE topic'),
};

class _BadgesSection extends StatelessWidget {
  final List<String> badges;
  const _BadgesSection({required this.badges});

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
              Text('Badges', style: AppTextStyles.headingSmall),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${badges.length}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.kPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              children: badges.asMap().entries.map((e) {
                final id = e.value;
                final meta = _badgeMeta[id];
                final label = meta?.$1 ?? id;
                final desc = meta?.$2 ?? '';
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.kPrimary.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded,
                                size: 18, color: AppColors.kPrimary),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.kTextPrimary,
                                    )),
                                if (desc.isNotEmpty)
                                  Text(desc, style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (e.key < badges.length - 1)
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.kBorder,
                          indent: AppSpacing.lg),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Account section
// ---------------------------------------------------------------------------

class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MenuGroup(
      title: 'Account',
      items: [
        _MenuRow(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profile',
          onTap: () => context.push('/home/profile/edit'),
        ),
        _MenuRow(
          icon: Icons.upload_file_outlined,
          label: 'My Uploads',
          onTap: () => context.push('/home/profile/uploads'),
        ),
        _MenuRow(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// App section
// ---------------------------------------------------------------------------

class _AppSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _MenuGroup(
      title: 'App',
      items: [
        _MenuRow(
          icon: Icons.leaderboard_outlined,
          label: 'Leaderboard',
          onTap: () => context.push('/leaderboard'),
        ),
        _MenuRow(
          icon: Icons.help_outline_rounded,
          label: 'Help & Feedback',
          onTap: () => _showHelp(context),
        ),
        _MenuRow(
          icon: Icons.info_outline_rounded,
          label: 'About',
          trailing: Text('v1.0.0', style: AppTextStyles.caption),
          onTap: () => _showAbout(context),
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Help & Feedback', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Found a bug or have a suggestion? We\'d love to hear from you.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('support@orbitapp.ai',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kPrimary)),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text('Close',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kTextSecondary)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orbit', style: AppTextStyles.headingMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('Version 1.0.0',
                style: AppTextStyles.caption),
            const SizedBox(height: AppSpacing.md),
            Text(
              'AI-powered flashcards with spaced repetition. Built for students, competitive exam aspirants, and certification candidates.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.kTextSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.kBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: Text('Close',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.kTextSecondary)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable menu group
// ---------------------------------------------------------------------------

class _MenuGroup extends StatelessWidget {
  final String title;
  final List<_MenuRow> items;

  const _MenuGroup({required this.title, required this.items});

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
                left: 4, bottom: AppSpacing.sm),
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(letterSpacing: 0.8),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.kSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.kBorder),
            ),
            child: Column(
              children: items.asMap().entries.map((e) {
                final row = e.value;
                return Column(
                  children: [
                    row,
                    if (e.key < items.length - 1)
                      const Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.kBorder,
                          indent: AppSpacing.lg),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.kTextSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: AppSpacing.sm),
            ],
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.kTextDisabled),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sign out
// ---------------------------------------------------------------------------

class _SignOutTile extends StatelessWidget {
  final WidgetRef ref;
  const _SignOutTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: InkWell(
        onTap: () => _confirmSignOut(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.kSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.kBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  size: 20, color: AppColors.kError),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Sign out',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.kError,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text('Sign out?', style: AppTextStyles.headingSmall),
        content: Text(
          'You\'ll need to sign in again to access your account.',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.kTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.kError)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.instance.signOut();
      if (context.mounted) context.go('/auth/login');
    }
  }
}
