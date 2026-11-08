import 'package:flutter/material.dart';
import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_spacing.dart';
import '../foundations/asia_typography.dart';

class AdminTextField extends StatefulWidget {
  const AdminTextField({
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false,
    this.initialValue,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;
  final String? initialValue;
  final bool enabled;
  final bool autofocus;

  @override
  State<AdminTextField> createState() => _AdminTextFieldState();
}

class _AdminTextFieldState extends State<AdminTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: AsiaTypography.caption.copyWith(
              color: tokens.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AsiaSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: widget.isPassword && _obscured,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          keyboardType: widget.keyboardType,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          style: AsiaTypography.bodyMedium.copyWith(
            color: tokens.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AsiaTypography.bodyMedium.copyWith(
              color: tokens.textTertiary,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: 18, color: tokens.textTertiary)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18,
                      color: tokens.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: tokens.cardElevated,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: AsiaRadii.md,
              borderSide: BorderSide(color: tokens.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AsiaRadii.md,
              borderSide: BorderSide(color: tokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AsiaRadii.md,
              borderSide: BorderSide(color: tokens.brandCrimson, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
