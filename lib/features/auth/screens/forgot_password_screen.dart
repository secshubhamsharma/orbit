import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/errors/app_exception.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/orbit_button.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _sent = false;

  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _emailCtrl.dispose();
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

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authServiceProvider)
          .sendPasswordReset(_emailCtrl.text);
      if (!mounted) return;
      setState(() => _sent = true);
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Reusable sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildErrorBanner() {
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
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button — matches signup screen style exactly
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.kSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15,
                    color: AppColors.kTextPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

                // Animated switcher between input and success states
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _sent
                      ? _SuccessView(
                          key: const ValueKey('success'),
                          email: _emailCtrl.text.trim(),
                          onResend: () => setState(() => _sent = false),
                          onBack: () => context.go('/auth/login'),
                        )
                      : _InputView(
                          key: const ValueKey('input'),
                          formKey: _formKey,
                          emailCtrl: _emailCtrl,
                          isLoading: _isLoading,
                          errorBanner: _buildErrorBanner(),
                          onSend: _sendReset,
                          animatedWrapper: _animated,
                        ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Input view
// ---------------------------------------------------------------------------

class _InputView extends StatelessWidget {
  const _InputView({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.errorBanner,
    required this.onSend,
    required this.animatedWrapper,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final Widget errorBanner;
  final VoidCallback onSend;
  final Widget Function(Widget child, double start) animatedWrapper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Forgot password?', style: AppTextStyles.headingLarge),
        const SizedBox(height: 8),
        Text(
          "Enter your email and we'll send you a reset link.",
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.kTextSecondary),
        ),
        const SizedBox(height: 32),
        Form(
          key: formKey,
          child: AuthTextField(
            controller: emailCtrl,
            label: 'Email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSend(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$')
                  .hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 12),
        errorBanner,
        const SizedBox(height: 24),
        OrbitButton(
          label: 'Send Reset Link',
          onTap: onSend,
          isLoading: isLoading,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Success view
// ---------------------------------------------------------------------------

class _SuccessView extends StatefulWidget {
  const _SuccessView({
    super.key,
    required this.email,
    required this.onResend,
    required this.onBack,
  });

  final String email;
  final VoidCallback onResend;
  final VoidCallback onBack;

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.easeOutBack,
    );
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Animated icon circle
        ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.kGradientPrimary,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Check your inbox',
          style: AppTextStyles.headingLarge,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          'We sent a password reset link to\n${widget.email}',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.kTextSecondary),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        OrbitButton(
          label: 'Back to Sign In',
          onTap: widget.onBack,
          isLoading: false,
        ),

        const SizedBox(height: 20),

        TextButton(
          onPressed: widget.onResend,
          child: Text(
            'Resend email',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.kPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
