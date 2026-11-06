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
          subtitle: isEmpty ? 'El carrito está vacío' : '${state.totalQuantity} productos en tu pedido',
          showBack: true,
          onBack: onBack,
          bottomAction: !isEmpty
              ? AsiaButton(
                  key: const Key('cart-proceed-button'),
                  label: 'Continuar Pedido · ${_formatCents(state.subtotalCents)}',
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
                          style: AsiaTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
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
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final CartItem item = state.items[index];
                        final int lineTotal = item.product.unitPriceCents * item.quantity;

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
                                      border: Border.all(color: theme.border, width: 0.8),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.product.name,
                                          style: AsiaTypography.titleSmall.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_formatCents(item.product.unitPriceCents)} c/u',
                                          style: AsiaTypography.bodySmall.copyWith(
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
                              if (item.notes != null && item.notes!.isNotEmpty) ...<Widget>[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: theme.surfaceSubtle,
                                    borderRadius: AsiaRadii.brSm,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(LucideIcons.messageSquare, size: 13, color: theme.textTertiary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          'Nota: ${item.notes!}',
                                          style: AsiaTypography.bodySmall.copyWith(
                                            color: theme.textSecondary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Controles de cantidad
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  AsiaPressable(
                                    onPressed: () => cartController.remove(item.product.id),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(LucideIcons.trash2, size: 15, color: theme.textTertiary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Eliminar',
                                          style: AsiaTypography.labelSmall.copyWith(
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
                                      border: Border.all(color: theme.border, width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        IconButton(
                                          icon: const Icon(LucideIcons.minus, size: 14),
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: item.quantity > 1
                                              ? () => cartController.setQuantity(item.product.id, item.quantity - 1)
                                              : () => cartController.remove(item.product.id),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            '${item.quantity}',
                                            style: AsiaTypography.labelMedium.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(LucideIcons.plus, size: 14),
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () => cartController.setQuantity(item.product.id, item.quantity + 1),
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
                            style: AsiaTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Subtotal platos', style: AsiaTypography.bodyMedium),
                              Text(_formatCents(state.subtotalCents), style: AsiaTypography.bodyMedium),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Envío / Servicio', style: AsiaTypography.bodyMedium),
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
                                style: AsiaTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
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
