import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/models/user_model.dart';
import 'package:orbitapp/providers/user_provider.dart';
import 'package:orbitapp/services/firestore_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        backgroundColor: AppColors.kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.kTextPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings', style: AppTextStyles.headingSmall),
      ),
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.kPrimary)),
        error: (e, _) =>
            Center(child: Text(e.toString(), style: AppTextStyles.bodyMedium)),
        data: (user) => _SettingsBody(user: user),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _SettingsBody extends ConsumerWidget {
  final UserModel? user;
  const _SettingsBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = user?.settings ?? const UserSettings();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // ── Notifications ─────────────────────────────────────────────
        _SectionLabel('Notifications'),
        _SettingsCard(
          children: [
            _ToggleTile(
              icon: Icons.notifications_outlined,
              label: 'Daily reminder',
              subtitle: 'Get reminded to review cards each day',
              value: settings.reminderEnabled,
              onChanged: (v) => _updateSettings(
                  ref, settings.copyWith(reminderEnabled: v)),
            ),
            _Divider(),
            _TapTile(
              icon: Icons.access_time_rounded,
              label: 'Reminder time',
              trailing: Text(settings.reminderTime,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kPrimary)),
              onTap: settings.reminderEnabled
                  ? () => _pickTime(context, ref, settings)
                  : null,
            ),
            _Divider(),
            _ToggleTile(
              icon: Icons.local_fire_department_outlined,
              label: 'Streak alerts',
              subtitle: 'Warn when your streak is at risk',
              value: settings.streakAlertEnabled,
              onChanged: (v) => _updateSettings(
                  ref, settings.copyWith(streakAlertEnabled: v)),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Study ─────────────────────────────────────────────────────
        _SectionLabel('Study'),
        _SettingsCard(
          children: [
            _TapTile(
              icon: Icons.flag_outlined,
              label: 'Daily goal',
              trailing: Text('${user?.dailyGoalMinutes ?? 10} min',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kPrimary)),
              onTap: () => _pickDailyGoal(context, ref, user),
            ),
            _Divider(),
            _TapTile(
              icon: Icons.sort_rounded,
              label: 'Card order',
              trailing: Text(
                _cardOrderLabel(settings.defaultCardOrder),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kPrimary),
              ),
              onTap: () => _pickCardOrder(context, ref, settings),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Appearance ────────────────────────────────────────────────
        _SectionLabel('Appearance'),
        _SettingsCard(
          children: [
            _TapTile(
              icon: Icons.text_fields_rounded,
              label: 'Font size',
              trailing: Text(
                _capitalize(settings.fontSize),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.kPrimary),
              ),
              onTap: () => _pickFontSize(context, ref, settings),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Privacy ───────────────────────────────────────────────────
        _SectionLabel('Privacy'),
        _SettingsCard(
          children: [
            _ToggleTile(
              icon: Icons.visibility_off_outlined,
              label: 'Hide from leaderboard',
              subtitle: 'Your name won\'t appear in weekly rankings',
              value: settings.hideFromLeaderboard,
              onChanged: (v) => _updateSettings(
                  ref, settings.copyWith(hideFromLeaderboard: v)),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // ── Account ───────────────────────────────────────────────────
        _SectionLabel('Account'),
        _SettingsCard(
          children: [
            _TapTile(
              icon: Icons.person_outline_rounded,
              label: 'Edit profile',
              onTap: () => context.push('/home/profile/edit'),
            ),
            _Divider(),
            _TapTile(
              icon: Icons.lock_outline_rounded,
              label: 'Change password',
              subtitle: 'Send a reset link to your email',
              onTap: () => _sendPasswordReset(context),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xxl),

        // App version note
        Center(
          child: Text(
            'Orbit v1.0.0',
            style: AppTextStyles.caption,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Future<void> _updateSettings(WidgetRef ref, UserSettings updated) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirestoreService.instance.updateUser(uid, {
        'settings': updated.toJson(),
      });
    } catch (_) {}
  }

  Future<void> _updateDailyGoal(WidgetRef ref, int minutes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirestoreService.instance
          .updateUser(uid, {'dailyGoalMinutes': minutes});
    } catch (_) {}
  }

  Future<void> _pickTime(
      BuildContext context, WidgetRef ref, UserSettings settings) async {
    final parts = settings.reminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '20') ?? 20,
      minute: int.tryParse(parts.lastOrNull ?? '0') ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.kPrimary,
            surface: AppColors.kSurface,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    final timeStr =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await _updateSettings(ref, settings.copyWith(reminderTime: timeStr));
  }

  Future<void> _pickDailyGoal(
      BuildContext context, WidgetRef ref, UserModel? user) async {
    const options = [5, 10, 20, 30];
    final current = user?.dailyGoalMinutes ?? 10;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily goal', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.lg),
            ...options.map((min) => ListTile(
                  title: Text('$min minutes',
                      style: AppTextStyles.bodyMedium),
                  trailing: current == min
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.kPrimary)
                      : null,
                  onTap: () {
                    _updateDailyGoal(ref, min);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _pickCardOrder(
      BuildContext context, WidgetRef ref, UserSettings settings) async {
    const options = [
      ('due_first', 'Due first', 'Show overdue cards at the top'),
      ('random', 'Random', 'Shuffle cards each session'),
      ('new_first', 'New first', 'Prioritise cards you\'ve never seen'),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Card order', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.lg),
            ...options.map((o) => ListTile(
                  title: Text(o.$2, style: AppTextStyles.bodyMedium),
                  subtitle: Text(o.$3, style: AppTextStyles.caption),
                  trailing: settings.defaultCardOrder == o.$1
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.kPrimary)
                      : null,
                  onTap: () {
                    _updateSettings(
                        ref,
                        settings.copyWith(
                            defaultCardOrder: o.$1));
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFontSize(
      BuildContext context, WidgetRef ref, UserSettings settings) async {
    const options = [
      ('small', 'Small', 'Compact text'),
      ('medium', 'Medium', 'Default size'),
      ('large', 'Large', 'Easier to read'),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Font size', style: AppTextStyles.headingSmall),
            const SizedBox(height: AppSpacing.lg),
            ...options.map((o) => ListTile(
                  title: Text(o.$2, style: AppTextStyles.bodyMedium),
                  subtitle: Text(o.$3, style: AppTextStyles.caption),
                  trailing: settings.fontSize == o.$1
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.kPrimary)
                      : null,
                  onTap: () {
                    _updateSettings(
                        ref, settings.copyWith(fontSize: o.$1));
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset link sent to $email'),
            backgroundColor: AppColors.kSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send reset email'),
            backgroundColor: AppColors.kError,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      }
    }
  }

  String _cardOrderLabel(String order) {
    return switch (order) {
      'random' => 'Random',
      'new_first' => 'New first',
      _ => 'Due first',
    };
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ---------------------------------------------------------------------------
// Shared UI components
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(letterSpacing: 0.8),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.kTextSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.kTextPrimary,
                        fontWeight: FontWeight.w500)),
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.caption),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.kPrimary.withValues(alpha: 0.3),
            inactiveTrackColor: AppColors.kSurfaceVariant,
            inactiveThumbColor: AppColors.kTextDisabled,
          ),
        ],
      ),
    );
  }
}

class _TapTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _TapTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
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
            Icon(icon,
                size: 20,
                color: onTap != null
                    ? AppColors.kTextSecondary
                    : AppColors.kTextDisabled),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: onTap != null
                          ? AppColors.kTextPrimary
                          : AppColors.kTextDisabled,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: AppSpacing.sm),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: onTap != null
                  ? AppColors.kTextDisabled
                  : AppColors.kTextDisabled.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        thickness: 1,
        color: AppColors.kBorder,
        indent: AppSpacing.lg,
      );
}
