import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/design_system/design_system.dart';
import '../domain/catalog_models.dart';

typedef CatalogCategoryCallback = void Function(CatalogCategory category);
typedef CatalogProductCallback = void Function(
  CatalogCategory category,
  CatalogProduct product,
);

String formatCatalogPrice(int priceCents) {
  final String sign = priceCents < 0 ? '-' : '';
  final int absoluteCents = priceCents.abs();
  final int soles = absoluteCents ~/ 100;
  final String cents = (absoluteCents % 100).toString().padLeft(2, '0');
  return '$sign'
      'S/ $soles.$cents';
}

class CatalogCategoryStrip extends StatelessWidget {
  const CatalogCategoryStrip({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    this.enabled = true,
    super.key,
  });

  final List<CatalogCategory> categories;
  final String? selectedCategoryId;
  final CatalogCategoryCallback onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Categorías del catálogo',
      child: SingleChildScrollView(
        key: const Key('catalog-category-strip'),
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            for (int index = 0; index < categories.length; index++) ...<Widget>[
              _CatalogCategoryChip(
                category: categories[index],
                selected: categories[index].id == selectedCategoryId,
                enabled: enabled,
                onTap: () => onSelected(categories[index]),
              ),
              if (index != categories.length - 1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}

class CatalogProductCard extends StatelessWidget {
  const CatalogProductCard({
    required this.product,
    required this.category,
    required this.onSelected,
    super.key,
  });

  final CatalogProduct product;
  final CatalogCategory category;
  final CatalogProductCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final bool available = product.availableForSale;
    final String price = formatCatalogPrice(product.priceCents);
    final String availability = available
        ? 'Disponible'
        : 'No disponible para la venta';

    return ChifaCard(
      key: Key('catalog-product-${product.id}'),
      icon: LucideIcons.utensilsCrossed,
      title: product.name,
      subtitle: '$price · $availability',
      minimumHeight: 98,
      enabled: available,
      onTap: available ? () => onSelected(category, product) : null,
      semanticLabel:
          '${product.name}. Precio $price. $availability. '
          '${available ? 'Abrir detalle.' : 'No se puede seleccionar.'}',
    );
  }
}

class CatalogFoodGlyph extends StatelessWidget {
  const CatalogFoodGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;

    return Semantics(
      image: true,
      label: 'Representación gráfica del plato',
      excludeSemantics: true,
      child: Container(
        key: const Key('catalog-product-glyph'),
        height: 190,
        decoration: BoxDecoration(
          color: palette.surfaceTint,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.utensilsCrossed,
          color: palette.accentGold,
          size: 72,
        ),
      ),
    );
  }
}

class CatalogDescriptionNotice extends StatelessWidget {
  const CatalogDescriptionNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChifaCard(
      icon: LucideIcons.info,
      title: 'Descripción',
      subtitle: 'No hay una descripción disponible para este producto.',
      minimumHeight: 84,
    );
  }
}

class _CatalogCategoryChip extends StatelessWidget {
  const _CatalogCategoryChip({
    required this.category,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final CatalogCategory category;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final Color foreground = selected
        ? palette.selectedForeground
        : palette.textPrimary;
    final Color background = selected
        ? palette.brandRed.withValues(alpha: 0.10)
        : palette.surfaceTint;

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: 'Categoría ${category.name}',
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: SizedBox(
        key: Key('catalog-category-${category.id}'),
        height: AppSpacing.minimumTouchTarget,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppRadii.chip),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(minWidth: 103, minHeight: 35),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                ),
                alignment: Alignment.center,
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
