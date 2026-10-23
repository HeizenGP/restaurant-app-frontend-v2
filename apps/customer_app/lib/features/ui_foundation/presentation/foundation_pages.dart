import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../../../core/design_system/design_system.dart';

class FoundationHomePage extends StatelessWidget {
  const FoundationHomePage({
    required this.themeModeController,
    this.onOpenMenu,
    super.key,
  });

  final ThemeModeController themeModeController;
  final VoidCallback? onOpenMenu;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-inicio'),
      title: 'El sabor nos reúne',
      subtitle: 'Una tradición china con alma peruana.',
      contentGap: 15,
      themeModeController: themeModeController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _BrandHero(),
          const SizedBox(height: 23),
          SizedBox(
            height: 30,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Explora nuestras categorías',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _FixedChipRow(
            children: <Widget>[
              ChifaChip(label: 'Arroces', width: 103),
              SizedBox(width: 11),
              ChifaChip(label: 'Tallarines', width: 103),
              SizedBox(width: 10),
              ChifaChip(label: 'Especiales', width: 115),
            ],
          ),
          const SizedBox(height: 30),
          ChifaCard(
            icon: LucideIcons.utensilsCrossed,
            title: 'Nuestro menú',
            subtitle: 'Platos y precios desde el catálogo.',
            onTap: onOpenMenu,
            trailing: Icon(
              LucideIcons.chevronRight,
              color: context.appPalette.cardTextSecondary,
              size: 17,
            ),
          ),
          const SizedBox(height: 10),
          const ChifaCard(
            icon: LucideIcons.info,
            title: 'Disponibilidad',
            subtitle: 'Productos habilitados para venta.',
          ),
        ],
      ),
    );
  }
}

class FoundationCatalogPage extends StatelessWidget {
  const FoundationCatalogPage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    final Widget chevron = Icon(
      LucideIcons.chevronRight,
      color: context.appPalette.cardTextSecondary,
      size: 17,
    );

    return ChifaPageScaffold(
      pageKey: const Key('page-menu'),
      title: 'Nuestro menú',
      subtitle: 'Elige una categoría y descubre los platos.',
      contentGap: 14,
      themeModeController: themeModeController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _FixedChipRow(
            children: <Widget>[
              ChifaChip(label: 'Arroces', width: 99),
              SizedBox(width: 11),
              ChifaChip(label: 'Tallarines', width: 111),
              SizedBox(width: 11),
              ChifaChip(label: 'Especiales', width: 110),
            ],
          ),
          const SizedBox(height: 23),
          ChifaCard(
            icon: LucideIcons.utensilsCrossed,
            title: 'Plato del catálogo',
            subtitle: 'Nombre · precio desde API · disponible',
            minimumHeight: 98,
            trailing: chevron,
          ),
          const SizedBox(height: 10),
          ChifaCard(
            icon: LucideIcons.info,
            title: 'Otra opción disponible',
            subtitle: 'Nombre · precio desde API · disponible',
            minimumHeight: 98,
            trailing: chevron,
          ),
          const SizedBox(height: 10),
          const ChifaCard(
            icon: LucideIcons.utensilsCrossed,
            title: 'Producto agotado',
            subtitle: 'No disponible para incorporar',
            minimumHeight: 98,
          ),
          const SizedBox(height: 10),
          ChifaCard(
            icon: LucideIcons.utensilsCrossed,
            title: 'Otra categoría',
            subtitle: 'Se actualiza al seleccionar categoría',
            minimumHeight: 98,
            trailing: chevron,
          ),
          const SizedBox(height: 29),
          Text(
            'Fotos y descripciones: API no disponible',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class FoundationOrdersPage extends StatelessWidget {
  const FoundationOrdersPage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    final Widget chevron = Icon(
      LucideIcons.chevronRight,
      color: context.appPalette.cardTextSecondary,
      size: 17,
    );

    return ChifaPageScaffold(
      pageKey: const Key('page-pedidos'),
      title: 'Mis pedidos',
      subtitle: 'Solicitudes e historial de esta cuenta.',
      contentGap: 13,
      themeModeController: themeModeController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const _FixedChipRow(
            children: <Widget>[
              ChifaChip(label: 'Todos', width: 98),
              SizedBox(width: 14),
              ChifaChip(label: 'Pendientes', width: 113),
              SizedBox(width: 10),
              ChifaChip(label: 'Confirmados', width: 107),
            ],
          ),
          const SizedBox(height: 24),
          ChifaCard(
            icon: LucideIcons.receiptText,
            title: 'Pedido # · reciente',
            subtitle: 'REQUESTED · pendiente de aprobación',
            minimumHeight: 119,
            trailing: chevron,
          ),
          const SizedBox(height: 10),
          ChifaCard(
            icon: LucideIcons.receiptText,
            title: 'Pedido # · confirmado',
            subtitle: 'CONFIRMED · ver detalle',
            minimumHeight: 119,
            trailing: chevron,
          ),
          const SizedBox(height: 10),
          ChifaCard(
            icon: LucideIcons.receiptText,
            title: 'Pedido # · rechazado',
            subtitle: 'REJECTED · consultar motivo/estado',
            minimumHeight: 119,
            trailing: chevron,
          ),
        ],
      ),
    );
  }
}

class FoundationInterfaceStatesPage extends StatelessWidget {
  const FoundationInterfaceStatesPage({
    required this.themeModeController,
    super.key,
  });

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-estados'),
      title: 'Estados de interfaz',
      subtitle: 'Variantes comunes para pantallas móviles.',
      contentGap: 20,
      themeModeController: themeModeController,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ChifaStateView(
            kind: ChifaStateKind.loading,
            title: 'Cargando…',
            message: 'Indicador de espera y contenido reservado',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.empty,
            title: 'Sin resultados',
            message: 'No hay elementos disponibles',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.error,
            title: 'No disponible',
            message: 'Producto agotado o deshabilitado',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.error,
            title: 'No autorizado',
            message: 'Sesión caducada o acceso denegado',
          ),
          SizedBox(height: 10),
          ChifaStateView(
            kind: ChifaStateKind.success,
            title: 'Solicitud realizada',
            message: 'Éxito tras respuesta real del backend',
          ),
        ],
      ),
    );
  }
}

class FoundationAccountPage extends StatelessWidget {
  const FoundationAccountPage({
    required this.themeModeController,
    this.displayName = 'Nombre del cliente',
    this.email = 'correo@ejemplo.com',
    this.initials = 'C',
    this.onOpenOrders,
    super.key,
  });

  final ThemeModeController themeModeController;
  final String displayName;
  final String email;
  final String initials;
  final VoidCallback? onOpenOrders;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double scale = constraints.maxWidth < 390
              ? constraints.maxWidth / 390
              : 1;
          return SingleChildScrollView(
            key: const Key('page-cuenta'),
            child: SizedBox(
              width: constraints.maxWidth,
              height: 736 * scale,
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 390 * scale,
                  height: 736 * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 390,
                      height: 736,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 18,
                            top: 10,
                            width: 354,
                            height: 51,
                            child: ChifaAppHeader(
                              isDarkMode: isDark,
                              onToggleTheme: themeModeController.toggle,
                              initials: initials,
                            ),
                          ),
                          Positioned(
                            left: 18,
                            top: 83,
                            width: 354,
                            height: 196,
                            child: _ProfileCover(palette: palette),
                          ),
                          Positioned(
                            left: 30,
                            top: 222,
                            width: 112,
                            height: 112,
                            child: SvgPicture.asset(
                              isDark
                                  ? 'assets/images/m01/account_avatar_ring_dark.svg'
                                  : 'assets/images/m01/account_avatar_ring_light.svg',
                            ),
                          ),
                          Positioned(
                            left: 36.5,
                            top: 228.5,
                            width: 99,
                            height: 99,
                            child: SvgPicture.asset(
                              isDark
                                  ? 'assets/images/m01/account_avatar_dark.svg'
                                  : 'assets/images/m01/account_avatar_light.svg',
                            ),
                          ),
                          Positioned(
                            left: 36.5,
                            top: 248,
                            width: 99,
                            height: 60,
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColors.onBrand,
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 25,
                            top: 342,
                            width: 338,
                            height: 41,
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                height: 41 / 32,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 27,
                            top: 382,
                            width: 330,
                            height: 23,
                            child: Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: palette.textSecondary,
                                    fontSize: 13,
                                  ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            top: 408,
                            width: 157,
                            height: 22,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: palette.surfaceTint,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.chip,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 11),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: palette.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'CUENTA REGISTRADA',
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: palette.success,
                                            fontFamily:
                                                AppTypography.bodyFontFamily,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 22,
                            top: 445,
                            width: 168,
                            height: 47,
                            child: _AccountAction(
                              label: 'Ver mis pedidos',
                              onPressed: onOpenOrders,
                            ),
                          ),
                          const Positioned(
                            left: 200,
                            top: 445,
                            width: 168,
                            height: 47,
                            child: _DisabledAccountAction(),
                          ),
                          Positioned(
                            left: 20,
                            top: 504,
                            width: 350,
                            height: 45,
                            child: _ProfileTabs(palette: palette),
                          ),
                          Positioned(
                            left: 23,
                            top: 562,
                            width: 333,
                            height: 29,
                            child: Text(
                              'Datos personales',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            top: 596,
                            width: 350,
                            height: 120,
                            child: _AccountDataCard(palette: palette),
                          ),
                          Positioned(
                            left: 25,
                            top: 719,
                            width: 340,
                            height: 17,
                            child: Text(
                              'Fotos, teléfonos y edición: sin API actual',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: palette.textSecondary,
                                    fontSize: 10,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BrandHero extends StatelessWidget {
  const _BrandHero();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Semantics(
      container: true,
      label: 'Cocina Chifa. Un antojo, un gran momento.',
      excludeSemantics: true,
      child: Container(
        height: 167,
        decoration: BoxDecoration(
          color: palette.brandSurface,
          borderRadius: BorderRadius.circular(AppRadii.hero),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 24,
              top: 22,
              width: 270,
              height: 24,
              child: Text(
                'COCINA CHIFA',
                maxLines: 1,
                style: TextStyle(
                  color: palette.onBrand,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 60,
              width: 282,
              height: 76,
              child: Text(
                'Un antojo,\nun gran momento',
                style: TextStyle(
                  color: palette.onBrand,
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 31,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCover extends StatelessWidget {
  const _ProfileCover({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: ColoredBox(
        color: palette.profileCover,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 207,
              top: -63,
              width: 255,
              height: 255,
              child: SvgPicture.asset('assets/images/m01/account_orbit.svg'),
            ),
            Positioned(
              left: 258,
              top: -10,
              width: 151,
              height: 151,
              child: SvgPicture.asset(
                'assets/images/m01/account_orbit_inner.svg',
              ),
            ),
            Positioned(
              left: 260,
              top: 52,
              width: 70,
              height: 70,
              child: SvgPicture.asset('assets/images/m01/account_sun.svg'),
            ),
            Positioned(
              left: 21,
              top: 29,
              child: Container(
                width: 42,
                height: 2,
                decoration: BoxDecoration(
                  color: palette.accentGold,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const Positioned(
              left: 21,
              top: 43,
              width: 306,
              height: 19,
              child: Text(
                'CHIFA ASIA  ·  DESDE EL CORAZÓN',
                style: TextStyle(
                  color: AppColors.onBrand,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Positioned(
              left: 21,
              top: 91,
              width: 290,
              height: 54,
              child: Text(
                'Tu lugar especial',
                style: TextStyle(
                  color: AppColors.onBrand,
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 33,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 227,
              top: 153,
              width: 107,
              height: 23,
              child: _DiamondPattern(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondPattern extends StatelessWidget {
  const _DiamondPattern();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(
          4,
          (int index) => Transform.rotate(
            angle: -0.785398,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0x6BE5BC74)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  const _AccountAction({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget content = Center(
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.onBrand,
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: context.appPalette.brandSurface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: onPressed == null
            ? content
            : InkWell(onTap: onPressed, child: content),
      ),
    );
  }
}

class _DisabledAccountAction extends StatelessWidget {
  const _DisabledAccountAction();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Semantics(
      button: true,
      enabled: false,
      label: 'Editar perfil. API pendiente',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surfaceTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: palette.controlBorder, width: 1.2),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 6,
              top: 7,
              width: 155,
              height: 19,
              child: Text(
                'Editar perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ),
            Positioned(
              left: 6,
              top: 26,
              width: 155,
              height: 14,
              child: Text(
                'API pendiente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textSecondary,
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FixedChipRow extends StatelessWidget {
  const _FixedChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: SizedBox(width: 342, height: 35, child: Row(children: children)),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 4,
            top: 5,
            width: 116,
            height: 35,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surfaceTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'Información',
                  style: TextStyle(
                    color: palette.brandRed,
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 125,
            top: 5,
            width: 105,
            height: 35,
            child: Center(child: _ProfileTabLabel('Pedidos', palette)),
          ),
          Positioned(
            left: 231,
            top: 5,
            width: 113,
            height: 35,
            child: Center(child: _ProfileTabLabel('Preferencias', palette)),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabLabel extends StatelessWidget {
  const _ProfileTabLabel(this.label, this.palette);

  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: palette.textSecondary,
        fontFamily: AppTypography.bodyFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _AccountDataCard extends StatelessWidget {
  const _AccountDataCard({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = TextStyle(
      color: palette.textSecondary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final TextStyle valueStyle = TextStyle(
      color: palette.textPrimary,
      fontFamily: AppTypography.bodyFontFamily,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.controlBorder),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 16,
            top: 10,
            child: Text('Nombre', style: labelStyle),
          ),
          Positioned(
            left: 16,
            top: 29,
            child: Text('Nombre desde tu cuenta', style: valueStyle),
          ),
          Positioned(
            left: 17,
            top: 59,
            child: Container(
              width: 314,
              height: 1,
              color: palette.controlBorder,
            ),
          ),
          Positioned(
            left: 16,
            top: 68,
            child: Text('Correo electrónico', style: labelStyle),
          ),
          Positioned(
            left: 16,
            top: 87,
            child: Text('Correo desde tu cuenta', style: valueStyle),
          ),
        ],
      ),
    );
  }
}
