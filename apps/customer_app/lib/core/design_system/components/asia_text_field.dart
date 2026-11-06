import 'package:flutter/material.dart';

import '../foundations/asia_radii.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';

class AsiaTextField extends StatefulWidget {
  const AsiaTextField({
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
    this.maxLines = 1,
    this.autofocus = false,
    this.semanticKey,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;
  final int maxLines;
  final bool autofocus;
  final Key? semanticKey;

  @override
  State<AsiaTextField> createState() => _AsiaTextFieldState();
}

class _AsiaTextFieldState extends State<AsiaTextField> {
  late bool _obscured;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.label != null) ...<Widget>[
          Text(
            widget.label!,
            style: AsiaTypography.labelMedium.copyWith(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Focus(
          onFocusChange: (bool focused) => setState(() => _isFocused = focused),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: theme.surfaceSubtle,
              borderRadius: AsiaRadii.brMd,
              border: Border.all(
                color: hasError
                    ? theme.error
                    : (_isFocused ? theme.brandCrimson : theme.border),
                width: _isFocused || hasError ? 1.4 : 0.8,
              ),
            ),
            child: Row(
              children: <Widget>[
                if (widget.prefixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused ? theme.brandCrimson : theme.textTertiary,
                    ),
                  ),
                Expanded(
                  child: TextFormField(
                    key: widget.semanticKey,
                    controller: widget.controller,
                    obscureText: _obscured,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    validator: widget.validator,
                    onChanged: widget.onChanged,
                    onFieldSubmitted: widget.onSubmitted,
                    enabled: widget.enabled,
                    maxLines: widget.maxLines,
                    autofocus: widget.autofocus,
                    style: AsiaTypography.bodyLarge.copyWith(
                      color: theme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: AsiaTypography.bodyLarge.copyWith(
                        color: theme.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.prefixIcon == null ? 16 : 0,
                        vertical: widget.maxLines > 1 ? 14 : 15,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                if (widget.obscureText)
                  IconButton(
                    icon: Icon(
                      _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      size: 20,
                      color: theme.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                else if (widget.suffixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffixIcon,
                  ),
              ],
            ),
          ),
        ),
        if (hasError) ...<Widget>[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.errorText!,
              style: AsiaTypography.bodySmall.copyWith(
                color: theme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

