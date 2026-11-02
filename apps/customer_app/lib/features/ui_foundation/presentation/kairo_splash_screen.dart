import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/design_system/foundations/app_typography.dart';

/// Screen de bienvenida KAIRO con animación ceremonial oriental multi-etapa (~3.6s).
class KairoSplashScreen extends StatefulWidget {
  const KairoSplashScreen({
    this.onAnimationComplete,
    this.onFinished,
    super.key,
  });

  final VoidCallback? onAnimationComplete;
  final VoidCallback? onFinished;

  @override
  State<KairoSplashScreen> createState() => _KairoSplashScreenState();
}

class _KairoSplashScreenState extends State<KairoSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Staged Choreography Animations (~3.6 seconds total)
  late final Animation<double> _auraAnimation;
  late final Animation<double> _ringRotation;
  late final Animation<double> _sealScale;
  late final Animation<double> _sealFade;
  late final Animation<double> _sealGlow;
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _shimmerSweep;
  late final Animation<double> _separatorWidth;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _subtitleTracking;
  late final Animation<double> _exitFade;
  late final Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    // Phase 1 (0.00 - 0.35): Imperial Atmosphere & Ambient Rings
    _auraAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _ringRotation = Tween<double>(begin: 0.0, end: math.pi / 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.90, curve: Curves.easeInOutCubic),
      ),
    );

    // Phase 2 (0.15 - 0.55): Sello Oriental Seal (凱)
    _sealFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.12, 0.40, curve: Curves.easeOut),
    );

    _sealScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutBack),
      ),
    );

    _sealGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.65, curve: Curves.easeInOut),
      ),
    );

    // Phase 3 (0.35 - 0.75): KAIRO Title Float & Gold Sweep
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.60, curve: Curves.easeIn),
    );

    _titleSlide = Tween<double>(begin: 28.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _shimmerSweep = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.82, curve: Curves.easeInOut),
      ),
    );

    // Phase 4 (0.50 - 0.85): Elegant Divider & Subtitle Tracking
    _separatorWidth = Tween<double>(begin: 0.0, end: 88.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.78, curve: Curves.easeOutQuart),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.88, curve: Curves.easeIn),
    );

    _subtitleTracking = Tween<double>(begin: 3.0, end: 7.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 5 (0.90 - 1.00): Ceremonial Dissolve Exit
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.92, 1.00, curve: Curves.easeIn),
      ),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.90, 1.00, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onAnimationComplete?.call();
        widget.onFinished?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // KAIRO Sophisticated Oriental Palette: Black, deep imperial crimson, radiant gold
    final Color bgTop = isDark ? const Color(0xFF090708) : const Color(0xFF140507);
    final Color bgBottom = isDark ? const Color(0xFF150A0D) : const Color(0xFF260A0E);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color goldShimmer = Color(0xFFF6E8B1);
    const Color goldDeep = Color(0xFFAA8022);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF090708),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgTop,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Transform.scale(
              scale: _exitScale.value,
              child: Opacity(
                opacity: _exitFade.value.clamp(0.0, 1.0),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.05),
                      radius: 1.25,
                      colors: <Color>[
                        const Color(0xFF381016),
                        bgBottom,
                        bgTop,
                      ],
                      stops: const <double>[0.0, 0.55, 1.0],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      // Ambient Subtle Oriental Concentric Circles
                      Opacity(
                        opacity: (_auraAnimation.value * 0.40).clamp(0.0, 1.0),
                        child: CustomPaint(
                          size: const Size(360, 360),
                          painter: _OrientalRingsPainter(
                            rotation: _ringRotation.value,
                            primaryColor: goldAccent.withValues(alpha: 0.35),
                            secondaryColor: goldShimmer.withValues(alpha: 0.18),
                          ),
                        ),
                      ),

                      // Central Brand Composition
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            // 1. Sello Oriental Emblem (Kanji 凱: Triunfo / Victoria)
                            Opacity(
                              opacity: _sealFade.value,
                              child: Transform.scale(
                                scale: _sealScale.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B1A24),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: goldAccent,
                                      width: 2.2,
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                        color: const Color(0xFFB52B3A).withValues(
                                          alpha: 0.35 * _sealGlow.value,
                                        ),
                                        blurRadius: 28,
                                        spreadRadius: 4 * _sealGlow.value,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: goldAccent.withValues(
                                          alpha: 0.30 * _sealGlow.value,
                                        ),
                                        blurRadius: 18,
                                        spreadRadius: 2 * _sealGlow.value,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      // Inner golden thin perimeter
                                      Container(
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: goldAccent.withValues(alpha: 0.55),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      // Kanji symbol
                                      Text(
                                        '凱',
                                        style: TextStyle(
                                          color: goldShimmer,
                                          fontFamily: AppTypography.displayFontFamily,
                                          fontSize: 42,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 2. KAIRO Typographic Brand with Golden Shimmer Sweep
                            Transform.translate(
                              offset: Offset(0, _titleSlide.value),
                              child: Opacity(
                                opacity: _titleFade.value,
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (Rect bounds) {
                                    final double pos = _shimmerSweep.value;
                                    return LinearGradient(
                                      begin: Alignment(pos - 1.0, 0),
                                      end: Alignment(pos + 1.0, 0),
                                      colors: const <Color>[
                                        goldDeep,
                                        goldShimmer,
                                        goldAccent,
                                        goldDeep,
                                      ],
                                      stops: const <double>[0.0, 0.45, 0.75, 1.0],
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    'KAIRO',
                                    key: const Key('kairo-splash-title'),
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 10.0,
                                      color: Colors.white,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 3. Golden Divider expanding from center
                            SizedBox(
                              width: _separatorWidth.value,
                              child: Container(
                                height: 1.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Colors.transparent,
                                      goldAccent.withValues(alpha: 0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // 4. Subtitle with Animated Tracking Expansion
                            Opacity(
                              opacity: _subtitleFade.value,
                              child: Text(
                                'ALTA COCINA ASIÁTICA',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: _subtitleTracking.value,
                                  color: goldShimmer.withValues(alpha: 0.90),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 5. Bottom Welcoming Tagline
                      Positioned(
                        bottom: 44,
                        child: Opacity(
                          opacity: _subtitleFade.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'UNA EXPERIENCIA EXÓTICA Y REFINADA',
                                style: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2.6,
                                  color: Colors.white.withValues(alpha: 0.60),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Subtle loading bar indicator
                              Container(
                                width: 36,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: goldAccent.withValues(
                                    alpha: 0.25 + 0.35 * _sealGlow.value,
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for the ceremonial oriental rings
class _OrientalRingsPainter extends CustomPainter {
  const _OrientalRingsPainter({
    required this.rotation,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double rotation;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = math.min(size.width, size.height) / 2;

    final Paint ringPaint1 = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint ringPaint2 = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Draw concentric rings
    canvas.drawCircle(center, maxRadius * 0.45, ringPaint2);
    canvas.drawCircle(center, maxRadius * 0.70, ringPaint1);
    canvas.drawCircle(center, maxRadius * 0.95, ringPaint2);

    // Draw subtle 8-fold radial accents rotated smoothly
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final Paint tickPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final double angle = (i * math.pi) / 4;
      final double x1 = math.cos(angle) * (maxRadius * 0.65);
      final double y1 = math.sin(angle) * (maxRadius * 0.65);
      final double x2 = math.cos(angle) * (maxRadius * 0.75);
      final double y2 = math.sin(angle) * (maxRadius * 0.75);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrientalRingsPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
