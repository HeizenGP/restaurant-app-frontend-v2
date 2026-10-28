import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme/theme_mode_controller.dart';
import '../../../../core/design_system/design_system.dart';
import '../application/cart_controller.dart';
import '../domain/cart_models.dart';

class CartPage extends StatelessWidget {
  const CartPage({
    required this.themeModeController,
    required this.cartController,
    this.onContinue,
    this.onBackPressed,
    this.tableLabel,
    this.showBackButton,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    super.key,
  });

  final ThemeModeController themeModeController;
  final CartController cartController;
  final VoidCallback? onContinue;
  final VoidCallback? onBackPressed;
  final String? tableLabel;
  final bool? showBackButton;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartController,
      builder: (BuildContext context, Widget? child) {
        return ChifaPageScaffold(
          pageKey: const Key('page-cart'),
          title: 'Tu carrito',
          subtitle: 'Confirma cantidades antes de enviar.',
          contentGap: 36,
          themeModeController: themeModeController,
          onBackPressed: onBackPressed,
          showBackButton: showBackButton,
          tableLabel: tableLabel,
          initials: initials,
          avatarPath: avatarPath,
          onAvatarPressed: onAvatarPressed,
          cartItemCount: cartController.state.totalQuantity,
          child: cartController.state.isEmpty
              ? const ChifaStateView(
                  key: Key('cart-empty-state'),
                  kind: ChifaStateKind.empty,
                  title: 'Tu carrito está vacío',
                  message: 'Agrega un producto disponible desde el menú',
                )
              : _CartContent(
                  cartController: cartController,
                  onContinue: onContinue,
                ),
        );
      },
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.cartController, this.onContinue});

  final CartController cartController;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final CartState state = cartController.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int index = 0; index < state.items.length; index++) ...<Widget>[
          _CartProductCard(
            item: state.items[index],
            onEdit: () => _showCartItemEditor(
              context,
              cartController,
              state.items[index].product.id,
            ),
          ),
          if (index != state.items.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 36),
        ChifaCard(
          key: const Key('cart-summary-card'),
          icon: LucideIcons.utensilsCrossed,
          title: 'Resumen del pedido',
          subtitle: 'Subtotal local · ${formatCartPrice(state.subtotalCents)}',
          minimumHeight: 103,
          semanticLabel:
              'Resumen del pedido. Subtotal local ${formatCartPrice(state.subtotalCents)}',
        ),
        const SizedBox(height: 34),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: ConstrainedBox(
            key: const Key('cart-server-note'),
            constraints: const BoxConstraints(minHeight: 35),
            child: const Text('El servidor recalculará el importe real.'),
          ),
        ),
        const SizedBox(height: 31),
        Semantics(
          button: true,
          enabled: onContinue != null,
          label: onContinue == null
              ? 'Continuar con pedido, no disponible'
              : 'Continuar con pedido',
          excludeSemantics: true,
          child: IgnorePointer(
            ignoring: onContinue == null,
            child: ChifaButton(
              key: Key(
                onContinue == null ? 'cart-continue-disabled' : 'cart-continue',
              ),
              label: 'Continuar con pedido',
              onPressed: onContinue ?? _noAction,
            ),
          ),
        ),
      ],
    );
  }
}

class _CartProductCard extends StatelessWidget {
  const _CartProductCard({required this.item, required this.onEdit});

  final CartItem item;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final String units = item.quantity == 1
        ? '1 unidad'
        : '${item.quantity} unidades';
    final String subtotal = formatCartPrice(item.subtotalCents);
    return ChifaCard(
      key: ValueKey<String>('cart-product-${item.product.id}'),
      icon: LucideIcons.utensilsCrossed,
      title: item.product.name,
      subtitle: '$units · $subtotal',
      minimumHeight: 102,
      trailing: const SizedBox.shrink(),
      onTap: onEdit,
      semanticLabel:
          '${item.product.name}. $units. Subtotal $subtotal. Toca para editar o eliminar.',
    );
  }
}

Future<void> _showCartItemEditor(
  BuildContext context,
  CartController cartController,
  String productId,
) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return AnimatedBuilder(
        animation: cartController,
        builder: (BuildContext context, Widget? child) {
          final CartItem? item = cartController.state.itemFor(productId);
          if (item == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  item.product.name,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Subtotal local · ${formatCartPrice(item.subtotalCents)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      key: ValueKey<String>('cart-decrease-$productId'),
                      tooltip: 'Disminuir cantidad',
                      onPressed: item.quantity > 1
                          ? () => cartController.decrement(productId)
                          : null,
                      icon: const Icon(LucideIcons.minus),
                    ),
                    SizedBox(
                      width: 64,
                      child: Text(
                        '${item.quantity}',
                        key: ValueKey<String>('cart-quantity-$productId'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      key: ValueKey<String>('cart-increase-$productId'),
                      tooltip: 'Aumentar cantidad',
                      onPressed: () => cartController.increment(productId),
                      icon: const Icon(LucideIcons.plus),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ChifaButton(
                  key: ValueKey<String>('cart-remove-$productId'),
                  label: 'Eliminar del carrito',
                  variant: ChifaButtonVariant.secondary,
                  onPressed: () {
                    cartController.remove(productId);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

String formatCartPrice(int priceCents) {
  final int units = priceCents ~/ 100;
  final int cents = priceCents.remainder(100);
  return 'S/ $units.${cents.toString().padLeft(2, '0')}';
}

void _noAction() {}
