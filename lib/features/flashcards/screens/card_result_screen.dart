import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbitapp/core/constants/app_colors.dart';
import 'package:orbitapp/core/constants/app_spacing.dart';
import 'package:orbitapp/core/constants/app_text_styles.dart';
import 'package:orbitapp/providers/session_provider.dart';

class CardResultScreen extends ConsumerWidget {
  final SessionArgs args;

  const CardResultScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(sessionProvider(args));

    final total     = state.ratings.length;
    final correct   = state.correct;   // 'good' + 'easy'
    final incorrect = state.incorrect; // 'again'
    final accuracy  = state.accuracy;
    final xp        = state.xpEarned;
    final durationSec =
        DateTime.now().difference(state.startedAt).inSeconds;

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              _ResultHeader(accuracy: accuracy),
              const SizedBox(height: AppSpacing.xl),
              _XpBanner(xp: xp),
              const SizedBox(height: AppSpacing.lg),
              _AccuracyCircle(accuracy: accuracy),
              const SizedBox(height: AppSpacing.lg),
              _StatsRow(
                total: total,
                correct: correct,
                incorrect: incorrect,
                durationSec: durationSec,
              ),
              const SizedBox(height: AppSpacing.xxl),
              _ActionButtons(args: args),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ResultHeader extends StatelessWidget {
  final double accuracy;

  const _ResultHeader({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final (emoji, headline, sub) = _copy(accuracy);

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 64)),
        const SizedBox(height: AppSpacing.md),
        Text(headline, style: AppTextStyles.headingLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.sm),
        Text(sub,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.kTextSecondary),
            textAlign: TextAlign.center),
      ],
    );
  }

  (String, String, String) _copy(double acc) {
    if (acc >= 0.9) {
      return ('🏆', 'Outstanding!',
          'You crushed it. Keep the momentum going.');
    }
    if (acc >= 0.7) {
      return ('🎯', 'Great work!', 'Solid session. Practice missed questions soon.');
    }
    if (acc >= 0.5) {
      return ('📖', 'Keep going!',
          'Half way there — a little more practice and you\'ll nail it.');
    }
    return ('💪', 'Don\'t give up!',
        'Every review makes you stronger. Come back tomorrow.');
  }
}

// ---------------------------------------------------------------------------
// XP banner
// ---------------------------------------------------------------------------

class _XpBanner extends StatelessWidget {
  final int xp;

  const _XpBanner({required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.kGradientPrimary,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '+$xp XP earned',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Accuracy circle
// ---------------------------------------------------------------------------

class _AccuracyCircle extends StatelessWidget {
  final double accuracy;

  const _AccuracyCircle({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final percent = (accuracy * 100).round();
    final color = accuracy >= 0.7
        ? AppColors.kSuccess
        : accuracy >= 0.5
            ? AppColors.kWarning
            : AppColors.kError;

    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percent%',
            style: AppTextStyles.displayMedium.copyWith(color: color),
          ),
          Text('Accuracy', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats row (MCQ: Correct / Wrong / Questions / Time)
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final int total;
  final int correct;
  final int incorrect;
  final int durationSec;

  const _StatsRow({
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.durationSec,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    final timeStr = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

    return Row(
      children: [
        _StatCell(
          label: 'Correct',
          value: '$correct',
          color: AppColors.kSuccess,
          icon: Icons.check_circle_outline_rounded,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCell(
          label: 'Wrong',
          value: '$incorrect',
          color: AppColors.kError,
          icon: Icons.cancel_outlined,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCell(
          label: 'Questions',
          value: '$total',
          color: AppColors.kPrimary,
          icon: Icons.quiz_outlined,
        ),
        const SizedBox(width: AppSpacing.sm),
        _StatCell(
          label: 'Time',
          value: timeStr,
          color: AppColors.kSecondary,
          icon: Icons.timer_outlined,
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.kSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.headingSmall.copyWith(color: color),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action buttons
// ---------------------------------------------------------------------------

class _ActionButtons extends StatelessWidget {
  final SessionArgs args;

  const _ActionButtons({required this.args});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Study again
        _GradientButton(
          label: 'Study again',
          icon: Icons.replay_rounded,
          colors: AppColors.kGradientPrimary,
          onTap: () {
            // Pop result, then push a fresh session
            context.pop();
            context.push('/review/${args.chapterId}', extra: args);
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Back to chapter
        OutlinedButton(
          onPressed: () {
            // Pop back to the chapter screen (2 screens: result + review)
            context.go(
              '/home/library/${args.domainId}/${args.subjectId}/${args.bookId}/${args.chapterId}',
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.kBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
          child: Text(
            'Back to chapter',
            style: AppTextStyles.labelLarge
                .copyWith(color: AppColors.kTextSecondary),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(label,
                    style:
                        AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
