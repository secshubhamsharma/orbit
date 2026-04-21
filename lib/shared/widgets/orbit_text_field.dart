import 'package:flutter/material.dart';
import '../../core/constants/app_text_styles.dart';

class OrbitTextField extends StatefulWidget {
  final String hint;
  final String? label;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final bool autofocus;
  final bool enabled;

  const OrbitTextField({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.autofocus = false,
    this.enabled = true,
  });

  const OrbitTextField.password({
    super.key,
    required this.hint,
    this.label,
    this.controller,
    this.validator,
    this.prefix,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.autofocus = false,
    this.enabled = true,
  })  : obscureText = true,
        keyboardType = TextInputType.visiblePassword,
        suffix = null;

  @override
  State<OrbitTextField> createState() => _OrbitTextFieldState();
}

class _OrbitTextFieldState extends State<OrbitTextField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText ? _obscured : false,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hint,
        labelText: widget.label,
        prefixIcon: widget.prefix,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffix,
      ),
    );
  }
}
