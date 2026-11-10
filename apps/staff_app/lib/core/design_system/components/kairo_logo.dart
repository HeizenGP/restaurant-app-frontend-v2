import 'package:flutter/material.dart';

import '../foundations/asia_colors.dart';
import '../foundations/asia_typography.dart';

class KairoAdminLogo extends StatelessWidget {
  const KairoAdminLogo({
    this.compact = false,
    this.subtitle = 'ADMIN PORTAL',
    super.key,
  });

  final bool compact;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    if (compact) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tokens.brandCrimson.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: tokens.brandCrimson.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'K',
          style: AsiaTypography.displaySmall.copyWith(
            color: tokens.brandCrimson,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tokens.brandCrimson.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: tokens.brandCrimson.withValues(alpha: 0.4),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'K',
            style: AsiaTypography.displaySmall.copyWith(
              color: tokens.brandCrimson,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'KAIRO',
              style: AsiaTypography.displaySmall.copyWith(
                color: tokens.textPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
                fontSize: 18,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: AsiaTypography.caption.copyWith(
                color: tokens.brandGold,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
