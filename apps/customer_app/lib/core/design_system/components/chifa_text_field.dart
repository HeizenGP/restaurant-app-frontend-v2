import 'package:flutter/material.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_spacing.dart';

class ChifaTextField extends StatelessWidget {
  const ChifaTextField({
    required this.label,
    required this.hintText,
    this.controller,
    this.leadingIcon,
    this.trailing,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autovalidateMode,
    this.autofillHints,
    this.focusNode,
    this.labelGap = AppSpacing.sm,
    this.labelHeight,
    this.borderRadius,
    this.contentPadding,
    this.hintStyle,
    this.inputStyle,
    this.fieldHeight,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final IconData? leadingIcon;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final AutovalidateMode? autovalidateMode;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final double labelGap;
  final double? labelHeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? inputStyle;
  final double? fieldHeight;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExcludeSemantics(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: labelHeight ?? 0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(color: palette.textPrimary),
              ),
            ),
          ),
        ),
        SizedBox(height: labelGap),
        Semantics(
          label: label,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: fieldHeight ?? 0),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              enabled: enabled,
              validator: validator,
              onChanged: onChanged,
              onFieldSubmitted: onFieldSubmitted,
              autovalidateMode: autovalidateMode,
              autofillHints: autofillHints,
              focusNode: focusNode,
              style: inputStyle ?? Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: hintStyle,
                contentPadding: contentPadding,
                constraints: fieldHeight == null
                    ? null
                    : BoxConstraints(minHeight: fieldHeight!),
                enabledBorder: borderRadius == null
                    ? null
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(color: palette.controlBorder),
                      ),
                focusedBorder: borderRadius == null
                    ? null
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(
                          color: palette.brandRed,
                          width: 1.4,
                        ),
                      ),
                errorBorder: borderRadius == null
                    ? null
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                focusedErrorBorder: borderRadius == null
                    ? null
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(borderRadius!),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1.4,
                        ),
                      ),
                prefixIcon: leadingIcon == null
                    ? null
                    : Icon(leadingIcon, color: palette.textSecondary, size: 20),
                suffixIcon: trailing,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
