import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.isPassword = false,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.focusNode,
  });

  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool isPassword;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with TickerProviderStateMixin {
  late final AnimationController _focusCtrl;
  late final AnimationController _shakeCtrl;
  late final FocusNode _focusNode;
  late final Animation<double> _shakeAnim;

  bool _obscure = true;
  bool _usingInternalFocusNode = false;

  @override
  void initState() {
    super.initState();

    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _usingInternalFocusNode = true;
    }

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText == null &&
        widget.errorText != null &&
        widget.errorText!.isNotEmpty) {
      _shakeCtrl.forward(from: 0);
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _focusCtrl.forward();
    } else {
      _focusCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _focusCtrl.dispose();
    _shakeCtrl.dispose();
    _focusNode.removeListener(_onFocusChanged);
    if (_usingInternalFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return AnimatedBuilder(
      animation: Listenable.merge([_focusCtrl, _shakeCtrl]),
      builder: (context, child) {
        final focusValue = _focusCtrl.value;
        final borderColor = hasError
            ? AppColors.kError
            : Color.lerp(AppColors.kBorder, AppColors.kPrimary, focusValue)!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(_shakeAnim.value, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.kSurface,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kPrimary
                          .withValues(alpha: focusValue * 0.12),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.isPassword && _obscure,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  autofocus: widget.autofocus,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.kTextPrimary),
                  cursorColor: AppColors.kPrimary,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    labelText: widget.label,
                    labelStyle: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.kTextSecondary),
                    floatingLabelStyle: AppTextStyles.caption.copyWith(
                      color: hasError
                          ? AppColors.kError
                          : AppColors.kPrimary,
                    ),
                    prefixIcon: Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: hasError
                          ? AppColors.kError
                          : Color.lerp(
                              AppColors.kTextSecondary,
                              AppColors.kPrimary,
                              focusValue,
                            ),
                    ),
                    suffixIcon: widget.isPassword
                        ? GestureDetector(
                            onTap: () =>
                                setState(() => _obscure = !_obscure),
                            child: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: AppColors.kTextSecondary,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Text(
                  widget.errorText!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.kError),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
