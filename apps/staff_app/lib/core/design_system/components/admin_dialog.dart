import 'package:flutter/material.dart';
import '../foundations/asia_colors.dart';
import '../foundations/asia_radii.dart';
import '../foundations/asia_spacing.dart';
import '../foundations/asia_typography.dart';
import 'admin_button.dart';

class AdminDialog extends StatelessWidget {
  const AdminDialog({
    required this.title,
    required this.content,
    this.subtitle,
    this.confirmLabel = 'Confirmar',
    this.cancelLabel = 'Cancelar',
    this.onConfirm,
    this.onCancel,
    this.isConfirmLoading = false,
    this.isDanger = false,
    this.maxWidth = 520,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isConfirmLoading;
  final bool isDanger;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return Dialog(
      backgroundColor: tokens.card,
      shape: const RoundedRectangleBorder(borderRadius: AsiaRadii.lg),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.all(AsiaSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: AsiaTypography.headingLarge.copyWith(
                            color: tokens.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...<Widget>[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: AsiaTypography.caption.copyWith(
                              color: tokens.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: tokens.textTertiary),
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.lg),
              Flexible(child: SingleChildScrollView(child: content)),
              const SizedBox(height: AsiaSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  AdminButton(
                    label: cancelLabel,
                    variant: AdminButtonVariant.secondary,
                    onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AsiaSpacing.md),
                  if (onConfirm != null)
                    AdminButton(
                      label: confirmLabel,
                      variant: isDanger ? AdminButtonVariant.danger : AdminButtonVariant.primary,
                      isLoading: isConfirmLoading,
                      onPressed: onConfirm,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
