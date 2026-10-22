import 'package:flutter/material.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../../shared/application/catalog_contracts.dart';
import '../../shared/domain/catalog_models.dart';
import '../../shared/presentation/catalog_widgets.dart';
import '../application/product_detail_controller.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    required this.repository,
    required this.categoryId,
    required this.productId,
    required this.themeModeController,
    super.key,
  });

  final CatalogRepository repository;
  final String categoryId;
  final String productId;
  final ThemeModeController themeModeController;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductDetailController _controller;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(covariant ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.categoryId != widget.categoryId ||
        oldWidget.productId != widget.productId) {
      _controller.dispose();
      _createController();
    }
  }

  void _createController() {
    _controller = ProductDetailController(
      repository: widget.repository,
      categoryId: widget.categoryId,
      productId: widget.productId,
    );
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChifaPageScaffold(
      pageKey: const Key('page-product-detail'),
      title: 'Detalle del plato',
      subtitle: 'Información vigente proporcionada por el catálogo.',
      themeModeController: widget.themeModeController,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          return _ProductDetailBody(
            state: _controller.state,
            onRetry: _controller.retry,
          );
        },
      ),
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({required this.state, required this.onRetry});

  final ProductDetailState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      ProductDetailStatus.initial ||
      ProductDetailStatus.loading => const ChifaStateView(
        kind: ChifaStateKind.loading,
        title: 'Cargando plato',
        message: 'Estamos consultando su información.',
      ),
      ProductDetailStatus.notFound => ChifaStateView(
        kind: ChifaStateKind.empty,
        title: 'Producto no encontrado',
        message:
            state.failure?.message ??
            'Este producto ya no aparece en la categoría seleccionada.',
        actionLabel: 'Volver a intentar',
        onAction: onRetry,
      ),
      ProductDetailStatus.error => ChifaStateView(
        kind: ChifaStateKind.error,
        title: 'No pudimos cargar el producto',
        message:
            state.failure?.message ??
            'Revisa tu conexión e inténtalo nuevamente.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      ),
      ProductDetailStatus.success => _ProductInformation(
        product: state.product!,
      ),
    };
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final String availability = product.availableForSale
        ? 'Disponible para la venta'
        : 'No disponible para la venta';

    return Column(
      key: const Key('product-detail-content'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const CatalogFoodGlyph(),
        const SizedBox(height: AppSpacing.xxl),
        Semantics(
          header: true,
          child: Text(
            product.name,
            key: const Key('product-detail-name'),
            style: Theme.of(context).textTheme.displayMedium
                ?.copyWith(fontSize: 27),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          formatCatalogPrice(product.priceCents),
          key: const Key('product-detail-price'),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: palette.brandRed,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          label: availability,
          liveRegion: true,
          excludeSemantics: true,
          child: Text(
            availability,
            key: const Key('product-detail-availability'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: product.availableForSale
                  ? palette.success
                  : palette.brandRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const CatalogDescriptionNotice(),
      ],
    );
  }
}
