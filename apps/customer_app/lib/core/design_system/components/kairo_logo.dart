import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../foundations/asia_colors.dart';
import '../foundations/asia_typography.dart';
import '../theme/asia_theme.dart';

enum KairoLogoVariant {
  /// Solo el emblema circular asiático (Ensō + Monograma K + Llama de Wok)
  emblemOnly,

  /// Emblema arriba, tipografía "K A I R O" y subtítulo abajo
  vertical,

  /// Emblema a la izquierda, tipografía a la derecha
  horizontal,
}

/// Logo oficial de KAIRO: Alta Cocina Asiática.
///
/// Renderizado vectorial puro vía [CustomPainter] con adaptación a tema claro y oscuro.
class KairoLogo extends StatelessWidget {
  const KairoLogo({
    this.variant = KairoLogoVariant.vertical,
    this.emblemSize = 64.0,
    this.isDark,
    this.showSubtitle = true,
    super.key,
  });

  final KairoLogoVariant variant;
  final double emblemSize;
  final bool? isDark;
  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final bool effectiveDark = isDark ?? theme.isDark;

    final Widget emblem = KairoEmblem(
      size: emblemSize,
      isDark: effectiveDark,
    );

    if (variant == KairoLogoVariant.emblemOnly) {
      return emblem;
    }

    final Color titleColor = effectiveDark ? Colors.white : AsiaColors.lightTextPrimary;
    final Color subtitleColor = effectiveDark ? AsiaColors.brandGoldLight : AsiaColors.brandGold;

    final Widget textBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: variant == KairoLogoVariant.vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'K A I R O',
          textAlign: variant == KairoLogoVariant.vertical ? TextAlign.center : TextAlign.left,
          style: AsiaTypography.titleLarge.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 6.0,
            fontSize: emblemSize * 0.36 > 18 ? emblemSize * 0.36 : 18,
            height: 1.1,
          ),
        ),
        if (showSubtitle) ...<Widget>[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 14,
                height: 1.2,
                color: subtitleColor.withValues(alpha: 0.6),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'ALTA COCINA ASIÁTICA',
                  style: AsiaTypography.labelSmall.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                    fontSize: 9.5,
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 1.2,
                color: subtitleColor.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ],
    );

    if (variant == KairoLogoVariant.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          emblem,
          const SizedBox(width: 14),
          textBlock,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        emblem,
        SizedBox(height: emblemSize * 0.18),
        textBlock,
      ],
    );
  }
}

/// Emblema vectorial circular de KAIRO.
///
/// Incorpora el círculo Ensō imperial, el monograma geométrico 'K' inspirado
/// en palillos de bambú cruzados y el destello ascendente de llama de wok.
class KairoEmblem extends StatelessWidget {
  const KairoEmblem({
    this.size = 64.0,
    this.isDark = true,
    super.key,
  });

  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _KairoEmblemPainter(isDark: isDark),
      ),
    );
  }
}

class _KairoEmblemPainter extends CustomPainter {
  const _KairoEmblemPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2.0;
    final double cy = size.height / 2.0;
    final Offset center = Offset(cx, cy);
    final double r = size.width / 2.0;

    // Colores de lujo KAIRO
    const Color crimsonDeep = Color(0xFF8B0000);
    const Color crimsonVibrant = Color(0xFFB91C1C);
    const Color crimsonGlow = Color(0xFFDC2626);
    const Color goldWarm = Color(0xFFD97706);
    const Color goldRadiant = Color(0xFFF59E0B);

    // 1. Halo sutil de fondo
    final Paint haloPaint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          (isDark ? crimsonVibrant : crimsonDeep).withValues(alpha: isDark ? 0.22 : 0.12),
          goldWarm.withValues(alpha: isDark ? 0.08 : 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r, haloPaint);

    // 2. Anillo exterior fino en oro cálido
    final Paint outerGoldRing = Paint()
      ..color = goldWarm.withValues(alpha: isDark ? 0.65 : 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.035
      ..isAntiAlias = true;
    canvas.drawCircle(center, r * 0.88, outerGoldRing);

    // 3. Ensō Imperial Carmesí (Anillo con apertura zen en 45°)
    final Rect ensoRect = Rect.fromCircle(center: center, radius: r * 0.74);
    final Paint ensoPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 2,
        colors: <Color>[
          crimsonDeep,
          crimsonVibrant,
          crimsonGlow,
          crimsonDeep,
        ],
      ).createShader(ensoRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.14
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // El arco del Ensō abarca aproximadamente 300° (dejando una apertura elegante de 60°)
    canvas.drawArc(
      ensoRect,
      math.pi * 0.35,  // Ángulo de inicio
      math.pi * 1.62,  // Barrido
      false,
      ensoPaint,
    );

    // 4. Anillo interior de acento dorado
    final Paint innerGoldRing = Paint()
      ..color = goldRadiant.withValues(alpha: isDark ? 0.85 : 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03
      ..isAntiAlias = true;
    canvas.drawCircle(center, r * 0.58, innerGoldRing);

    // 5. Monograma Central K (Fusión de palillos de bambú geométricos)
    final Paint goldGlyphPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          goldRadiant,
          goldWarm,
          Color(0xFFB45309),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.50))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 5a. Tallo vertical izquierdo de la K (con extremos angulados estilo caligrafía)
    final double stemX = cx - r * 0.18;
    final double stemW = r * 0.09;
    final double stemTop = cy - r * 0.36;
    final double stemBottom = cy + r * 0.36;

    final Path stemPath = Path()
      ..moveTo(stemX, stemTop + stemW * 0.6)
      ..lineTo(stemX + stemW * 0.5, stemTop)
      ..lineTo(stemX + stemW, stemTop + stemW * 0.3)
      ..lineTo(stemX + stemW, stemBottom - stemW * 0.4)
      ..lineTo(stemX + stemW * 0.4, stemBottom)
      ..lineTo(stemX, stemBottom - stemW * 0.5)
      ..close();
    canvas.drawPath(stemPath, goldGlyphPaint);

    // 5b. Brazo diagonal superior de la K
    final Path upperArm = Path()
      ..moveTo(cx - r * 0.08, cy - r * 0.02)
      ..lineTo(cx + r * 0.22, cy - r * 0.32)
      ..lineTo(cx + r * 0.29, cy - r * 0.26)
      ..lineTo(cx - r * 0.02, cy + r * 0.05)
      ..close();
    canvas.drawPath(upperArm, goldGlyphPaint);

    // 5c. Brazo diagonal inferior de la K
    final Path lowerArm = Path()
      ..moveTo(cx - r * 0.04, cy - r * 0.02)
      ..lineTo(cx + r * 0.23, cy + r * 0.34)
      ..lineTo(cx + r * 0.15, cy + r * 0.38)
      ..lineTo(cx - r * 0.11, cy + r * 0.06)
      ..close();
    canvas.drawPath(lowerArm, goldGlyphPaint);

    // 6. Llama de Wok ascendente (*Wok Hei*) en la cúspide central
    final Paint flamePaint = Paint()
      ..shader = const RadialGradient(
        colors: <Color>[
          Colors.white,
          goldRadiant,
          crimsonGlow,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx + r * 0.02, cy - r * 0.34), radius: r * 0.14))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Path flamePath = Path()
      ..moveTo(cx + r * 0.02, cy - r * 0.46) // Punta de la llama
      ..quadraticBezierTo(
        cx + r * 0.11, cy - r * 0.32,
        cx + r * 0.06, cy - r * 0.22,
      )
      ..quadraticBezierTo(
        cx + r * 0.02, cy - r * 0.28,
        cx - r * 0.02, cy - r * 0.24,
      )
      ..quadraticBezierTo(
        cx - r * 0.06, cy - r * 0.33,
        cx + r * 0.02, cy - r * 0.46,
      )
      ..close();
    canvas.drawPath(flamePath, flamePaint);
  }

  @override
  bool shouldRepaint(covariant _KairoEmblemPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
