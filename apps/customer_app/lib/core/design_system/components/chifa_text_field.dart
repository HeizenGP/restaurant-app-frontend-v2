import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../foundations/app_colors.dart';
import '../foundations/app_spacing.dart';
import '../foundations/app_typography.dart';

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
    this.inputFormatters,
    this.labelGap = AppSpacing.sm,
    this.labelHeight,
    this.borderRadius,
    this.contentPadding,
    this.hintStyle,
    this.inputStyle,
    this.fieldHeight,
    this.fillColor,
    this.errorText,
    this.isValid,
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
  final List<TextInputFormatter>? inputFormatters;
  final double labelGap;
  final double? labelHeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? inputStyle;
  final double? fieldHeight;
  final Color? fillColor;
  final String? errorText;
  final bool? isValid;

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
              inputFormatters: inputFormatters,
              style: inputStyle ?? Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: hintStyle,
                fillColor: fillColor,
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
                errorText: errorText,
                errorMaxLines: 2,
                errorStyle: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 11.5,
                  fontFamily: AppTypography.bodyFontFamily,
                ),
                prefixIcon: leadingIcon == null
                    ? null
                    : Icon(leadingIcon, color: palette.textSecondary, size: 20),
                suffixIcon: trailing ??
                    (isValid == true
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              LucideIcons.circleCheck,
                              color: palette.success,
                              size: 18,
                            ),
                          )
                        : (isValid == false || errorText != null)
                            ? Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  LucideIcons.circleAlert,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 18,
                                ),
                              )
                            : null),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
