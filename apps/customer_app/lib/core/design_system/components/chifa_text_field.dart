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

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExcludeSemantics(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: palette.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: label,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            enabled: enabled,
            validator: validator,
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: leadingIcon == null
                  ? null
                  : Icon(leadingIcon, color: palette.textSecondary, size: 20),
              suffixIcon: trailing,
            ),
          ),
        ),
      ],
    );
  }
}
