import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/domain/catalog_models.dart';
import '../application/product_detail_controller.dart';

typedef AddSelectedProduct = bool Function(
  CatalogProduct product,
  int quantity,
);

class CatalogProductDetailPage extends StatefulWidget {
  const CatalogProductDetailPage({
    required this.themeModeController,
    required this.controller,
    required this.onAddProduct,
    required this.onOpenCart,
    this.onProductAdded,
    this.onBackPressed,
    this.showBackButton,
    this.showCartInHeader = false,
    this.tableLabel,
    super.key,
  });

  final ThemeModeController themeModeController;
  final ProductDetailController controller;
  final AddSelectedProduct onAddProduct;
  final VoidCallback onOpenCart;
  final VoidCallback? onProductAdded;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final bool showCartInHeader;
  final String? tableLabel;

  @override
  State<CatalogProductDetailPage> createState() {
    return _CatalogProductDetailPageState();
  }
}

class _CatalogProductDetailPageState extends State<CatalogProductDetailPage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final AppPalette palette = context.appPalette;
    final CatalogProduct? product = widget.controller.state.product;
    final SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: palette.background,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        body: product == null
            ? FoundationProductDetailUnavailablePage(
                themeModeController: widget.themeModeController,
              )
            : FoundationProductDetailPage(
                themeModeController: widget.themeModeController,
                product: product,
                quantity: _quantity,
                onDecrease: _quantity > 1
                    ? () => setState(() => _quantity -= 1)
                    : null,
                onIncrease: () => setState(() => _quantity += 1),
                onAddToCart: () {
                  final bool added = widget.onAddProduct(product, _quantity);
                  if (added) {
                    if (widget.onProductAdded != null) {
                      widget.onProductAdded!();
                    } else {
                      widget.onOpenCart();
                    }
                  }
                },
                onBackPressed: widget.onBackPressed,
                showBackButton: widget.showBackButton,
                onCartPressed: widget.showCartInHeader ? widget.onOpenCart : null,
                tableLabel: widget.tableLabel,
              ),
      ),
    );
  }
}

class FoundationProductDetailPage extends StatelessWidget {
  const FoundationProductDetailPage({
    required this.themeModeController,
    required this.product,
    this.quantity = 1,
    this.onDecrease,
    this.onIncrease,
    this.onAddToCart,
    this.onBackPressed,
    this.showBackButton,
    this.onCartPressed,
    this.tableLabel,
    super.key,
  });

  final ThemeModeController themeModeController;
  final CatalogProduct product;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final VoidCallback? onCartPressed;
  final String? tableLabel;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool available = product.availableForSale;

    return ChifaPageScaffold(
      pageKey: const Key('page-product-detail'),
      title: 'Detalle del plato',
      subtitle: 'Producto seleccionado del catálogo.',
      contentGap: 15,
      safeBottom: true,
      themeModeController: themeModeController,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      onCartPressed: onCartPressed,
      tableLabel: tableLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            image: true,
            label: 'Representación del plato ${product.name}',
            excludeSemantics: true,
            child: Container(
              key: const Key('product-visual-placeholder'),
              height: 190,
              decoration: BoxDecoration(
                color: palette.surfaceTint,
                borderRadius: BorderRadius.circular(AppRadii.hero),
              ),
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -16),
                child: SvgPicture.asset(
                  'assets/images/m02/food_glyph.svg',
                  width: 79,
                  height: 78,
                  colorFilter: ColorFilter.mode(
                    palette.accentGold,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 31),
          ConstrainedBox(
            key: const Key('product-detail-name'),
            constraints: const BoxConstraints(minHeight: 34),
            child: Text(
              product.name,
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 11),
          ConstrainedBox(
            key: const Key('product-detail-price'),
            constraints: const BoxConstraints(minHeight: 28),
            child: Text(
              'Precio · ${_formatPrice(product.priceCents)}',
              style: TextStyle(
                color: palette.brandRed,
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            key: const Key('product-detail-availability'),
            constraints: const BoxConstraints(minHeight: 26),
            child: Text(
              available ? 'Disponible para venta' : 'No disponible para venta',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 21),
          _QuantityCard(
            available: available,
            quantity: quantity,
            onDecrease: available ? onDecrease : null,
            onIncrease: available ? onIncrease : null,
          ),
          const SizedBox(height: 39),
          Semantics(
            button: true,
            enabled: available && onAddToCart != null,
            label: available
                ? 'Agregar $quantity al carrito'
                : 'Agregar al carrito, producto no disponible',
            excludeSemantics: true,
            child: IgnorePointer(
              ignoring: !available || onAddToCart == null,
              child: Opacity(
                opacity: available ? 1 : 0.62,
                child: ChifaButton(
                  key: const Key('product-add-to-cart'),
                  label: 'Agregar al carrito',
                  onPressed: onAddToCart ?? () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FoundationProductDetailUnavailablePage extends StatelessWidget {
  const FoundationProductDetailUnavailablePage({
    required this.themeModeController,
    super.key,
  });

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-product-detail-unavailable'),
      title: 'Detalle del plato',
      subtitle: 'Producto seleccionado del catálogo.',
      safeBottom: true,
      themeModeController: themeModeController,
      child: const ChifaStateView(
        key: Key('product-detail-not-found'),
        kind: ChifaStateKind.error,
        title: 'Producto no disponible',
        message: 'Vuelve al menú y selecciona un producto del catálogo',
      ),
    );
  }
}

class _QuantityCard extends StatelessWidget {
  const _QuantityCard({
    required this.available,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final bool available;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    return Semantics(
      container: true,
      enabled: available,
      label: available
          ? 'Cantidad seleccionada: $quantity'
          : 'Cantidad. Producto no disponible',
      child: Opacity(
        opacity: available ? 1 : 0.62,
        child: Container(
          key: const Key('product-quantity'),
          constraints: const BoxConstraints(minHeight: 77),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: <Widget>[
              const ChifaIconTile(icon: LucideIcons.info),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 168,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Cantidad',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 20,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _QuantityAction(
                              key: const Key('product-quantity-decrease'),
                              label: 'Disminuir cantidad',
                              symbol: '−',
                              alignment: Alignment.centerLeft,
                              onPressed: onDecrease,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$quantity',
                                key: const Key('product-quantity-value'),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _QuantityAction(
                              key: const Key('product-quantity-increase'),
                              label: 'Aumentar cantidad',
                              symbol: '+',
                              alignment: Alignment.centerRight,
                              onPressed: onIncrease,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityAction extends StatelessWidget {
  const _QuantityAction({
    required this.label,
    required this.symbol,
    required this.alignment,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String symbol;
  final Alignment alignment;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Align(
          alignment: alignment,
          child: Text(
            symbol,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: context.appPalette.cardTextSecondary),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(int priceCents) {
  final int units = priceCents ~/ 100;
  final int cents = priceCents.remainder(100);
  return 'S/ $units.${cents.toString().padLeft(2, '0')}';
}
