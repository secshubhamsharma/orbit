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
import '../widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

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
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await ref
          .read(authServiceProvider)
          .signInWithEmail(_emailCtrl.text, _passCtrl.text);

      if (!mounted) return;
      if (cred.user?.emailVerified ?? false) {
        context.go('/home');
      } else {
        context.go('/auth/verify-email');
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      if (cred == null) return;

      if (cred.user?.emailVerified ?? true) {
        context.go('/home');
      } else {
        context.go('/auth/verify-email');
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
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
              const SizedBox(height: 56),

              // Headline
              _fade(_buildHeadline(), 0.0),

              const SizedBox(height: 40),

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
                        child: _fade(_buildErrorBanner(), 0.0),
                      )
                    : const SizedBox.shrink(),
              ),

              // Sign In CTA
              _fade(
                OrbitButton(label: 'Sign In', onTap: _login, isLoading: _isLoading),
                0.24,
              ),

              const SizedBox(height: 32),

              // Divider
              _fade(_buildDivider(), 0.30),

              const SizedBox(height: 20),

              // Social buttons
              _fade(
                Column(
                  children: [
                    SocialLoginButton.google(
                      onTap: _isLoading ? null : _loginWithGoogle,
                      isLoading: _isGoogleLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SocialLoginButton.apple(onTap: _isLoading ? null : () {}),
                  ],
                ),
                0.36,
              ),

              const SizedBox(height: 52),

              // Footer — uses push so signup stacks on top of login
              _fade(_buildFooter(), 0.42),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: AppTextStyles.displayMedium.copyWith(
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
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
            'back.',
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.05,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your flashcards and streaks are\nwaiting for you.',
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
        children: [
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
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/auth/forgot-password'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot password?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.kPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.kBorder, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'or',
            style: AppTextStyles.caption.copyWith(color: AppColors.kTextDisabled),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.kBorder, thickness: 1)),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account?  ",
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.kTextSecondary),
          children: [
            TextSpan(
              text: 'Sign up',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.kPrimary,
                fontWeight: FontWeight.w700,
              ),
              // push keeps login in the stack so hardware back works
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push('/auth/signup'),
            ),
          ],
        ),
      ),
    );
  }
}
