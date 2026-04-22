import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class PasswordStrengthWidget extends StatelessWidget {
  const PasswordStrengthWidget({super.key, required this.password});

  final String password;

  // ---------------------------------------------------------------------------
  // Rule checks
  // ---------------------------------------------------------------------------

  bool get _hasLength => password.length >= 8;
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get _hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get _hasDigit => RegExp(r'[0-9]').hasMatch(password);
  bool get _hasSpecial =>
      RegExp(r'[!@#\$&*~%^()_+=\-\[\]{};:"\\|,.<>\/?]').hasMatch(password);

  int get _score {
    int s = 0;
    if (_hasLength) s++;
    if (_hasUpper) s++;
    if (_hasLower) s++;
    if (_hasDigit) s++;
    if (_hasSpecial) s++;
    return s;
  }

  // ---------------------------------------------------------------------------
  // Derived colours / labels
  // ---------------------------------------------------------------------------

  Color _strengthColor(int score) {
    if (score <= 1) return AppColors.kError;
    if (score == 2) return const Color(0xFFFF9F43); // orange
    if (score == 3) return AppColors.kWarning;
    return AppColors.kSuccess;
  }

  String _strengthLabel(int score) {
    if (score <= 1) return 'Weak';
    if (score == 2) return 'Fair';
    if (score == 3) return 'Good';
    return 'Strong';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final score = _score;
    final color = _strengthColor(score);
    final label = _strengthLabel(score);
    final litCount = score <= 1 ? 1 : score == 2 ? 2 : score == 3 ? 3 : 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Strength segments
        Row(
          children: List.generate(4, (i) {
            final isLit = i < litCount;
            return Flexible(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? AppSpacing.xs : 0),
                decoration: BoxDecoration(
                  color: isLit ? color : AppColors.kSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Strength label (right-aligned)
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              key: ValueKey(label),
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Rule rows
        _RuleRow(passes: _hasLength, text: '8 or more characters'),
        const SizedBox(height: AppSpacing.xs),
        _RuleRow(passes: _hasUpper, text: 'Uppercase letter (A-Z)'),
        const SizedBox(height: AppSpacing.xs),
        _RuleRow(passes: _hasLower, text: 'Lowercase letter (a-z)'),
        const SizedBox(height: AppSpacing.xs),
        _RuleRow(passes: _hasDigit, text: 'Number (0–9)'),
        const SizedBox(height: AppSpacing.xs),
        _RuleRow(passes: _hasSpecial, text: 'Special character (!@#...)'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private rule row widget
// ---------------------------------------------------------------------------

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.passes, required this.text});

  final bool passes;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: passes
              ? _FilledCheck(key: const ValueKey('filled'))
              : _OutlineCircle(key: const ValueKey('outline')),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.caption.copyWith(
              color: passes
                  ? AppColors.kTextPrimary
                  : AppColors.kTextSecondary,
            ),
            child: Text(text),
          ),
        ),
      ],
    );
  }
}

class _FilledCheck extends StatelessWidget {
  const _FilledCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: AppColors.kPrimary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, size: 10, color: Colors.white),
    );
  }
}

class _OutlineCircle extends StatelessWidget {
  const _OutlineCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.kBorder, width: 1.5),
      ),
    );
  }
}
