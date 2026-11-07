import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/design_system.dart';
import '../manage_cart/application/cart_controller.dart';
import '../manage_cart/domain/cart_models.dart';

String _formatCents(int cents) {
  final double s = cents / 100.0;
  return 'S/ ${s.toStringAsFixed(2)}';
}

class CartPage extends StatelessWidget {
  const CartPage({
    required this.cartController,
    required this.onBack,
    required this.onProceedToFulfillment,
    required this.onBrowseCatalog,
    super.key,
  });

  final CartController cartController;
  final VoidCallback onBack;
  final VoidCallback onProceedToFulfillment;
  final VoidCallback onBrowseCatalog;

  void _editItemNotes(BuildContext context, CartItem item) {
    final TextEditingController textCtrl = TextEditingController(
      text: item.notes ?? '',
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        final AsiaTheme theme = ctx.asiaTheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Observación para ${item.product.name}',
                        style: AsiaTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textCtrl,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Ej. Sin cebolla china, salsa agridulce aparte, término bien cocido...',
                    border: OutlineInputBorder(borderRadius: AsiaRadii.brMd),
                  ),
                ),
                const SizedBox(height: 16),
                AsiaButton(
                  label: 'Guardar observación',
                  leading: LucideIcons.check,
                  onPressed: () {
                    cartController.updateNotes(item.product.id, textCtrl.text);
                    Navigator.of(ctx).pop();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    return AnimatedBuilder(
      animation: cartController,
      builder: (BuildContext context, _) {
        final CartState state = cartController.state;
        final bool isEmpty = state.isEmpty;

        return AsiaScaffold(
          title: 'Tu Carrito',
          subtitle: isEmpty
              ? 'El carrito está vacío'
              : '${state.totalQuantity} productos en tu pedido',
          showBack: true,
          onBack: onBack,
          bottomAction: !isEmpty
              ? AsiaButton(
                  key: const Key('cart-proceed-button'),
                  label:
                      'Continuar Pedido · ${_formatCents(state.subtotalCents)}',
                  leading: LucideIcons.arrowRight,
                  onPressed: onProceedToFulfillment,
                )
              : null,
          body: isEmpty
              ? AsiaStateView(
                  kind: AsiaStateKind.empty,
                  title: 'Aún no has agregado platos',
                  message: 'Descubre nuestros deliciosos chaufas, tallarines y especialidades al wok.',
                  icon: LucideIcons.shoppingBag,
                  actionLabel: 'Ver la carta',
                  onAction: onBrowseCatalog,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    // Header de acciones del carrito
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Detalle de platos',
                          style: AsiaTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AsiaPressable(
                          onPressed: cartController.clear,
                          child: Text(
                            'Vaciar carrito',
                            style: AsiaTypography.labelMedium.copyWith(
                              color: theme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Lista de items
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.items.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final CartItem item = state.items[index];
                        final int lineTotal =
                            item.product.unitPriceCents * item.quantity;

                        return AsiaCard(
                          key: ValueKey<String>('cart-item-${item.product.id}'),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: theme.surfaceSubtle,
                                      borderRadius: AsiaRadii.brSm,
                                      border: Border.all(
                                        color: theme.border,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Icon(
                                      LucideIcons.utensilsCrossed,
                                      size: 20,
                                      color: theme.brandCrimson,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.product.name,
                                          style: AsiaTypography.titleSmall
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_formatCents(item.product.unitPriceCents)} c/u',
                                          style: AsiaTypography.bodySmall
                                              .copyWith(
                                                color: theme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatCents(lineTotal),
                                    style: AsiaTypography.titleSmall.copyWith(
                                      color: theme.brandCrimson,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              // Observaciones del plato
                              InkWell(
                                onTap: () => _editItemNotes(context, item),
                                borderRadius: AsiaRadii.brSm,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (item.notes != null &&
                                            item.notes!.isNotEmpty)
                                        ? theme.brandGold.withValues(
                                            alpha: 0.08,
                                          )
                                        : theme.surfaceSubtle,
                                    borderRadius: AsiaRadii.brSm,
                                    border: Border.all(
                                      color:
                                          (item.notes != null &&
                                              item.notes!.isNotEmpty)
                                          ? theme.brandGold.withValues(
                                              alpha: 0.3,
                                            )
                                          : theme.border.withValues(alpha: 0.5),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        LucideIcons.messageSquare,
                                        size: 14,
                                        color:
                                            (item.notes != null &&
                                                item.notes!.isNotEmpty)
                                            ? theme.brandGold
                                            : theme.textTertiary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          (item.notes != null &&
                                                  item.notes!.isNotEmpty)
                                              ? 'Obs: ${item.notes!}'
                                              : 'Agregar observación / nota (ej. sin cebolla)',
                                          style: AsiaTypography.bodySmall
                                              .copyWith(
                                                color:
                                                    (item.notes != null &&
                                                        item.notes!.isNotEmpty)
                                                    ? theme.textPrimary
                                                    : theme.textTertiary,
                                                fontStyle:
                                                    (item.notes != null &&
                                                        item.notes!.isNotEmpty)
                                                    ? FontStyle.normal
                                                    : FontStyle.italic,
                                                fontSize: 12,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        LucideIcons.pencil,
                                        size: 13,
                                        color: theme.brandCrimson,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Controles de cantidad
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  AsiaPressable(
                                    onPressed: () =>
                                        cartController.remove(item.product.id),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          LucideIcons.trash2,
                                          size: 15,
                                          color: theme.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Eliminar',
                                          style: AsiaTypography.labelSmall
                                              .copyWith(
                                                color: theme.textTertiary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme.surfaceSubtle,
                                      borderRadius: AsiaRadii.brPill,
                                      border: Border.all(
                                        color: theme.border,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          icon: const Icon(
                                            LucideIcons.minus,
                                            size: 14,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: item.quantity > 1
                                              ? () =>
                                                    cartController.setQuantity(
                                                      item.product.id,
                                                      item.quantity - 1,
                                                    )
                                              : () => cartController.remove(
                                                  item.product.id,
                                                ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: AsiaTypography.labelMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            LucideIcons.plus,
                                            size: 14,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () =>
                                              cartController.setQuantity(
                                                item.product.id,
                                                item.quantity + 1,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Resumen de cuenta
                    AsiaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Resumen de pedido',
                            style: AsiaTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Subtotal platos',
                                style: AsiaTypography.bodyMedium,
                              ),
                              Text(
                                _formatCents(state.subtotalCents),
                                style: AsiaTypography.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Envío / Servicio',
                                style: AsiaTypography.bodyMedium,
                              ),
                              Text(
                                'Gratis',
                                style: AsiaTypography.bodyMedium.copyWith(
                                  color: theme.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Total a pagar',
                                style: AsiaTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                _formatCents(state.subtotalCents),
                                style: AsiaTypography.titleMedium.copyWith(
                                  color: theme.brandCrimson,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
        );
      },
    );
  }
}
