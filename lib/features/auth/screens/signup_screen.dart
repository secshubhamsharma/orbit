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
    );
    _enterCtrl.forward();
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
  // Password strength score (mirrors PasswordStrengthWidget logic)
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
        _errorMessage =
            'Password is not strong enough. Please meet all requirements.';
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
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: AppColors.kTextPrimary,
                  ),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                const SizedBox(height: 16),

                // Title + subtitle
                _animated(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create account',
                        style: AppTextStyles.headingLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Join Orbit and start learning.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.kTextSecondary),
                      ),
                    ],
                  ),
                  0.0,
                ),

                const SizedBox(height: 28),

                // Form
                _animated(
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full name
                        AuthTextField(
                          controller: _nameCtrl,
                          label: 'Full name',
                          prefixIcon: Icons.person_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Email
                        AuthTextField(
                          controller: _emailCtrl,
                          label: 'Email address',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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

                        const SizedBox(height: 16),

                        // Password
                        AuthTextField(
                          controller: _passCtrl,
                          label: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.next,
                          onChanged: (v) => setState(() => _passwordText = v),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        // Password strength — only shown when password is non-empty
                        if (_passwordText.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          PasswordStrengthWidget(password: _passwordText),
                        ],

                        const SizedBox(height: 16),

                        // Confirm password
                        AuthTextField(
                          controller: _confirmCtrl,
                          label: 'Confirm password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _signup(),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (v != _passCtrl.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  0.15,
                ),

                const SizedBox(height: 12),

                // Error banner
                _buildErrorBanner(),

                const SizedBox(height: 28),

                // Create account button
                _animated(
                  OrbitButton(
                    label: 'Create Account',
                    onTap: _signup,
                    isLoading: _isLoading,
                  ),
                  0.3,
                ),

                const SizedBox(height: 32),

                // Sign in link
                _animated(
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.kTextSecondary),
                        children: [
                          TextSpan(
                            text: 'Sign in',
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
                  ),
                  0.35,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
