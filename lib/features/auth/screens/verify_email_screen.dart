import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/errors/app_exception.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/orbit_button.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with TickerProviderStateMixin {
  bool _isSending = false;
  bool _isChecking = false;
  String? _errorMessage;
  String? _successMessage;
  int _resendCooldown = 0;

  Timer? _pollTimer;
  Timer? _countdownTimer;

  late final AnimationController _enterCtrl;
  late final AnimationController _iconPulseCtrl;

  @override
  void initState() {
    super.initState();

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _enterCtrl.forward();

    _iconPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Poll Firebase every 5 seconds to detect when email is verified.
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkVerification(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    _enterCtrl.dispose();
    _iconPulseCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Animation helper
  // ---------------------------------------------------------------------------

  Widget _animated(Widget child, double start) {
    final anim = CurvedAnimation(
      parent: _enterCtrl,
      curve: Interval(start, (start + 0.5).clamp(0, 1), curve: Curves.easeOut),
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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _checkVerification() async {
    if (!mounted) return;
    setState(() => _isChecking = true);

    try {
      final verified = await ref
          .read(authServiceProvider)
          .reloadAndCheckVerification();
      if (!mounted) return;
      if (verified) {
        _pollTimer?.cancel();
        context.go('/home');
      }
    } catch (_) {
      // Silent — poll failures should not surface as errors.
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _resendEmail() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(authServiceProvider).sendVerificationEmail();
      if (!mounted) return;

      setState(() => _resendCooldown = 60);
      _successMessage = 'Verification email sent!';

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _resendCooldown = 0;
            t.cancel();
          }
        });
      });
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _successMessage = null;
          _errorMessage = e.message;
        });
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _signOut() async {
    await ref.read(authServiceProvider).signOut();
    if (!mounted) return;
    context.go('/auth/login');
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildPulsingIcon() {
    return AnimatedBuilder(
      animation: _iconPulseCtrl,
      builder: (_, child) => Transform.scale(
        scale: 1.0 + _iconPulseCtrl.value * 0.05,
        child: child,
      ),
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.kPrimary.withValues(alpha: 0.15),
              AppColors.kPrimary.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: AppColors.kPrimary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.mark_email_unread_rounded,
          size: 44,
          color: AppColors.kPrimary,
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    final canResend = _resendCooldown <= 0;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: (canResend && !_isSending) ? _resendEmail : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: canResend ? AppColors.kPrimary : AppColors.kBorder,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          foregroundColor:
              canResend ? AppColors.kPrimary : AppColors.kTextDisabled,
          disabledForegroundColor: AppColors.kTextDisabled,
        ),
        child: _isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.kPrimary,
                ),
              )
            : Text(
                canResend
                    ? 'Resend verification email'
                    : 'Resend in ${_resendCooldown}s',
                style: AppTextStyles.labelLarge.copyWith(
                  color: canResend
                      ? AppColors.kPrimary
                      : AppColors.kTextDisabled,
                ),
              ),
      ),
    );
  }

  Widget _buildBanner() {
    // Show success banner if present, otherwise error banner.
    if (_successMessage != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: const ValueKey('success'),
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.kSuccessContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.kSuccess.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.kSuccess,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _successMessage!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.kSuccess),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _successMessage = null),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.kSuccess,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _errorMessage == null
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('error'),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.kErrorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.kError.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.kError,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.kError),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _errorMessage = null),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.kError,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final userEmail =
        ref.watch(authStateProvider).valueOrNull?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back / sign out row
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.kTextPrimary,
                  ),
                  onPressed: _signOut,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),

              const Spacer(),

              // Pulsing envelope icon
              _animated(_buildPulsingIcon(), 0.0),

              const SizedBox(height: 32),

              // Title
              _animated(
                Text(
                  'Verify your email',
                  style: AppTextStyles.headingLarge,
                  textAlign: TextAlign.center,
                ),
                0.1,
              ),

              const SizedBox(height: 12),

              // Subtitle
              _animated(
                Text(
                  'We sent a verification link to\n$userEmail',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextSecondary),
                  textAlign: TextAlign.center,
                ),
                0.15,
              ),

              const SizedBox(height: 40),

              // Primary CTA — check verification
              _animated(
                OrbitButton(
                  label: "I've Verified — Continue",
                  onTap: _checkVerification,
                  isLoading: _isChecking,
                ),
                0.2,
              ),

              const SizedBox(height: 16),

              // Resend button
              _animated(_buildResendButton(), 0.25),

              const SizedBox(height: 24),

              // Banner (success or error)
              _buildBanner(),

              const Spacer(),

              // Sign out link
              _animated(
                TextButton(
                  onPressed: _signOut,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.kTextSecondary,
                  ),
                  child: Text(
                    'Sign out and go back',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.kTextSecondary,
                    ),
                  ),
                ),
                0.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
