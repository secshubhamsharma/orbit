import 'package:flutter/gestures.dart';
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
import '../widgets/password_strength_widget.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String _passwordText = '';

  late final AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Animation helper
  // ---------------------------------------------------------------------------

  Widget _fade(Widget child, double start) {
    final anim = CurvedAnimation(
      parent: _enterCtrl,
      curve: Interval(start, (start + 0.45).clamp(0.0, 1.0), curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Password strength score
  // ---------------------------------------------------------------------------

  int get _passwordScore {
    int s = 0;
    if (_passwordText.length >= 8) { s++; }
    if (RegExp(r'[A-Z]').hasMatch(_passwordText)) { s++; }
    if (RegExp(r'[a-z]').hasMatch(_passwordText)) { s++; }
    if (RegExp(r'[0-9]').hasMatch(_passwordText)) { s++; }
    if (RegExp(r'[!@#\$&*~%^()_+=\-\[\]{};:"\\|,.<>\/?]').hasMatch(_passwordText)) { s++; }
    return s;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_passwordScore < 4) {
      setState(() => _errorMessage = 'Please create a stronger password.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authServiceProvider).signUpWithEmail(
            email: _emailCtrl.text,
            password: _passCtrl.text,
            displayName: _nameCtrl.text,
          );

      if (!mounted) return;
      context.go('/auth/verify-email');
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      // PopScope ensures Android hardware back pops instead of exiting the app.
      // Since login used context.push() to get here, canPop is true automatically.
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Back button row
              _fade(_buildTopBar(), 0.0),

              const SizedBox(height: 32),

              // Headline
              _fade(_buildHeadline(), 0.08),

              const SizedBox(height: 36),

              // Form
              _fade(_buildForm(), 0.16),

              const SizedBox(height: 24),

              // Error banner
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: _errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildErrorBanner(),
                      )
                    : const SizedBox.shrink(),
              ),

              // Create Account CTA
              _fade(
                OrbitButton(
                  label: 'Create Account',
                  onTap: _signup,
                  isLoading: _isLoading,
                ),
                0.28,
              ),

              const SizedBox(height: 16),

              // Terms caption
              _fade(
                Center(
                  child: Text(
                    'By creating an account you agree to our\nTerms of Service and Privacy Policy.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.kTextDisabled,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                0.32,
              ),

              const SizedBox(height: 40),

              // Footer
              _fade(_buildFooter(), 0.38),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  /// Back button + wordmark in one row.
  Widget _buildTopBar() {
    return Row(
      children: [
        // Back button — tapping this pops back to login (works because
        // login used context.push to get here)
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
        const SizedBox(width: AppSpacing.md),
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.kPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'orbit',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.kPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start your',
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.05,
            color: AppColors.kTextPrimary,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.kGradientPrimary,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'journey.',
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
              height: 1.05,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join thousands of learners mastering\nmore in less time.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.kTextSecondary,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _nameCtrl,
            label: 'Full name',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Name is required';
              return null;
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _emailCtrl,
            label: 'Email address',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passCtrl,
            label: 'Password',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.next,
            onChanged: (v) => setState(() => _passwordText = v),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 8) return 'At least 8 characters required';
              return null;
            },
          ),
          if (_passwordText.isNotEmpty) ...[
            const SizedBox(height: 10),
            PasswordStrengthWidget(password: _passwordText),
          ],
          const SizedBox(height: 14),
          AuthTextField(
            controller: _confirmCtrl,
            label: 'Confirm password',
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signup(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passCtrl.text) return 'Passwords do not match';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.kErrorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kError.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.kError, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.kError),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close_rounded, color: AppColors.kError, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account?  ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.kTextSecondary),
          children: [
            TextSpan(
              text: 'Sign in',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.kPrimary,
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.pop(), // go back, not go()
            ),
          ],
        ),
      ),
    );
  }
}
