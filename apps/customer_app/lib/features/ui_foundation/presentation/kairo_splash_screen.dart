import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/design_system/components/kairo_logo.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_typography.dart';

/// Splash Screen animado oficial de KAIRO.
///
/// Proporciona una entrada cinematográfica y fluida a la experiencia
/// gastronómica con micro-animaciones escalonadas y respeto a accesibilidad.
class KairoSplashScreen extends StatefulWidget {
  const KairoSplashScreen({
    required this.onFinished,
    this.duration = const Duration(milliseconds: 2000),
    super.key,
  });

  final VoidCallback onFinished;
  final Duration duration;

  @override
  State<KairoSplashScreen> createState() => _KairoSplashScreenState();
}

class _KairoSplashScreenState extends State<KairoSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _emblemScale;
  late final Animation<double> _emblemOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _loaderOpacity;
  Timer? _finishTimer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _emblemScale = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _emblemOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.70, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _finishTimer = Timer(widget.duration, _completeSplash);
  }

  void _completeSplash() {
    if (_finished || !mounted) return;
    _finished = true;
    widget.onFinished();
  }

  @override
  void dispose() {
    _finishTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
    final Size size = MediaQuery.sizeOf(context);
    final double emblemSize = (size.width * 0.28).clamp(90.0, 150.0);

    if (disableAnimations && !_finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _completeSplash());
    }

    return Scaffold(
      backgroundColor: AsiaColors.darkBg,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. Fondo atmosférico: Resplandor radial rojo profundo / ámbar
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.15),
                  radius: 1.2,
                  colors: <Color>[
                    AsiaColors.brandCrimson.withValues(alpha: 0.28),
                    AsiaColors.brandGoldDarkMuted.withValues(alpha: 0.14),
                    AsiaColors.darkBg,
                  ],
                  stops: const <double>[0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // 2. Contenido Central: Logo y Wordmark
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Emblema con escala y fade
                    Opacity(
                      opacity: disableAnimations ? 1.0 : _emblemOpacity.value,
                      child: Transform.scale(
                        scale: disableAnimations ? 1.0 : _emblemScale.value,
                        child: KairoEmblem(
                          size: emblemSize,
                          isDark: true,
                        ),
                      ),
                    ),

                    SizedBox(height: emblemSize * 0.22),

                    // Tipografía KAIRO y subtítulo
                    Opacity(
                      opacity: disableAnimations ? 1.0 : _textOpacity.value,
                      child: SlideTransition(
                        position: disableAnimations
                            ? const AlwaysStoppedAnimation<Offset>(Offset.zero)
                            : _textSlide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'K A I R O',
                              style: AsiaTypography.displayLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8.0,
                                fontSize: 26.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 22,
                                  height: 1.4,
                                  color: AsiaColors.brandGoldLight.withValues(alpha: 0.7),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'ALTA COCINA ASIÁTICA',
                                    style: AsiaTypography.labelSmall.copyWith(
                                      color: AsiaColors.brandGoldLight,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 3.0,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 1.4,
                                  color: AsiaColors.brandGoldLight.withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // 3. Indicador de carga inferior pulcro y botón saltar accesible
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.paddingOf(context).bottom + 28,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                return Opacity(
                  opacity: disableAnimations ? 1.0 : _loaderOpacity.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Barra de progreso dorada estilizada
                      SizedBox(
                        width: 72,
                        child: ClipRRect(
                          borderRadius: AsiaRadii.brPill,
                          child: const LinearProgressIndicator(
                            minHeight: 2.2,
                            backgroundColor: Color(0xFF1E2129),
                            valueColor: AlwaysStoppedAnimation<Color>(AsiaColors.brandGoldLight),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Preparando sabores y wok...',
                        style: AsiaTypography.bodySmall.copyWith(
                          color: AsiaColors.darkTextTertiary,
                          fontSize: 11.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
