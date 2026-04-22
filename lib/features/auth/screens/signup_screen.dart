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
      duration: const Duration(milliseconds: 700),
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

  Widget _animated(Widget child, double start) {
    final anim = CurvedAnimation(
      parent: _enterCtrl,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
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
      setState(() {
        _errorMessage = 'Please create a stronger password to continue.';
      });
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
      body: Stack(
        children: [
          // ── Ambient background glows (mirrored from login for variety) ────
          Positioned(
            top: -110,
            left: -90,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.kSecondary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.kPrimary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Back button — boxed for a premium feel
                  _animated(_buildBackButton(), 0.0),

                  const SizedBox(height: 28),

                  // Brand eyebrow
                  _animated(_buildEyebrow(), 0.06),

                  const SizedBox(height: 20),

                  // Hero headline
                  _animated(_buildHeadline(), 0.12),

                  const SizedBox(height: 36),

                  // Form fields
                  _animated(_buildForm(), 0.20),

                  const SizedBox(height: 20),

                  // Error banner
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    child: _errorMessage != null
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildErrorBanner(),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Create Account CTA
                  _animated(
                    OrbitButton(
                      label: 'Create Account',
                      onTap: _signup,
                      isLoading: _isLoading,
                    ),
                    0.30,
                  ),

                  const SizedBox(height: 20),

                  // Terms caption
                  _animated(
                    Center(
                      child: Text(
                        'By signing up you agree to our Terms & Privacy Policy.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.kTextDisabled,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    0.34,
                  ),

                  const SizedBox(height: 36),

                  // Footer
                  _animated(_buildFooter(), 0.40),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.kSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.kBorder),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: AppColors.kTextPrimary,
        ),
      ),
    );
  }

  Widget _buildEyebrow() {
    return Row(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: AppColors.kGradientPrimary,
          ).createShader(bounds),
          child: Text(
            'ORBIT',
            style: AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.5,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.kSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Text(
          'Create your account',
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: 11,
            color: AppColors.kTextDisabled,
          ),
        ),
      ],
    );
  }

  /// "Start your" in white, "journey." in gradient.
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

          // Password strength meter — only visible when user has typed
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
        border: Border.all(color: AppColors.kError.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.kError, size: 16),
          const SizedBox(width: AppSpacing.sm + 2),
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
          text: 'Already a member?  ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.kTextSecondary),
          children: [
            TextSpan(
              text: 'Sign in →',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.kPrimary,
                fontWeight: FontWeight.w700,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.go('/auth/login'),
            ),
          ],
        ),
      ),
    );
  }
}
