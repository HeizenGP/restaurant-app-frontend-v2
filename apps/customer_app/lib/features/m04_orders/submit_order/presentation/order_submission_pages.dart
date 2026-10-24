import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../app/theme/theme_mode_controller.dart';
import '../../../../../core/design_system/design_system.dart';
import '../application/order_contracts.dart';
import '../application/submit_order_controller.dart';
import '../domain/order_models.dart';

class OrderReviewPage extends StatefulWidget {
  const OrderReviewPage({
    required this.themeModeController,
    required this.controller,
    required this.onSubmitted,
    required this.onFailure,
    this.productsSubtitle = 'Ítems, cantidades y precios congelados',
    this.attentionSubtitle = 'Mesa o dirección, según modalidad',
    this.amountSubtitle = 'Revisión final y total del pedido',
    super.key,
  });

  final ThemeModeController themeModeController;
  final SubmitOrderController controller;
  final ValueChanged<OrderSnapshot> onSubmitted;
  final ValueChanged<OrderFailure> onFailure;
  final String productsSubtitle;
  final String attentionSubtitle;
  final String amountSubtitle;

  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  @override
  Widget build(BuildContext context) {
    return _OrderFrame(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, Widget? child) {
          final OrderSubmissionState state = widget.controller.state;
          return ChifaPageScaffold(
            pageKey: const Key('page-order-review'),
            title: 'Revisa tu solicitud',
            subtitle: 'Pedido de la modalidad seleccionada.',
            contentGap: 39,
            themeModeController: widget.themeModeController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ChifaCard(
                  key: const Key('order-review-products'),
                  icon: LucideIcons.utensilsCrossed,
                  iconColor: _figmaIconColor(context),
                  title: 'Resumen de productos',
                  subtitle: widget.productsSubtitle,
                  minimumHeight: 77,
                ),
                const SizedBox(height: 26),
                ChifaCard(
                  key: const Key('order-review-attention'),
                  icon: LucideIcons.mapPin,
                  iconColor: _figmaIconColor(context),
                  title: 'Datos de atención',
                  subtitle: widget.attentionSubtitle,
                  minimumHeight: 77,
                ),
                const SizedBox(height: 26),
                ChifaCard(
                  key: const Key('order-review-amount'),
                  icon: LucideIcons.wallet,
                  iconColor: _figmaIconColor(context),
                  title: 'Importe estimado',
                  subtitle: widget.amountSubtitle,
                  minimumHeight: 77,
                ),
                const SizedBox(height: 26),
                ChifaCard(
                  key: const Key('order-review-pending'),
                  icon: LucideIcons.clock3,
                  iconColor: _figmaIconColor(context),
                  title: 'Pendiente de aprobación',
                  subtitle: 'El envío no equivale a confirmación.',
                  minimumHeight: 77,
                ),
                const SizedBox(height: 71),
                ChifaButton(
                  key: const Key('order-submit'),
                  label: 'Enviar solicitud',
                  height: 54,
                  borderRadius: 14,
                  isLoading: state.phase == OrderSubmissionPhase.submitting,
                  onPressed:
                      state.command == null ||
                          state.phase == OrderSubmissionPhase.submitting
                      ? null
                      : _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final bool succeeded = await widget.controller.submit();
    if (!mounted) return;
    final OrderSubmissionState state = widget.controller.state;
    if (succeeded && state.order != null) {
      widget.onSubmitted(state.order!);
    } else if (state.failure != null) {
      widget.onFailure(state.failure!);
    }
  }
}

class OrderResultPage extends StatefulWidget {
  const OrderResultPage({
    required this.themeModeController,
    required this.controller,
    required this.orderId,
    required this.onViewOrders,
    required this.onBackToHome,
    super.key,
  });

  final ThemeModeController themeModeController;
  final SubmitOrderController controller;
  final String orderId;
  final VoidCallback onViewOrders;
  final VoidCallback onBackToHome;

  @override
  State<OrderResultPage> createState() => _OrderResultPageState();
}

class _OrderResultPageState extends State<OrderResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(widget.controller.loadOrderDetail(widget.orderId));
      }
    });
  }

  @override
  void didUpdateWidget(covariant OrderResultPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId ||
        oldWidget.controller != widget.controller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(widget.controller.loadOrderDetail(widget.orderId));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        final OrderSubmissionState state = widget.controller.state;
        if (state.phase == OrderSubmissionPhase.failure &&
            state.failedOperation == OrderOperation.detail &&
            state.failure != null) {
          return OrderExceptionPage(
            themeModeController: widget.themeModeController,
            failure: state.failure!,
            onBackToHome: widget.onBackToHome,
            onRetry: state.canRetryDetail
                ? () {
                    unawaited(widget.controller.retryDetail());
                  }
                : null,
          );
        }

        final OrderSnapshot? order = state.order?.id == widget.orderId
            ? state.order
            : null;
        if (order == null) {
          return OrderDetailLoadingPage(
            themeModeController: widget.themeModeController,
          );
        }
        return OrderSubmittedPage(
          themeModeController: widget.themeModeController,
          order: order,
          onViewOrders: widget.onViewOrders,
        );
      },
    );
  }
}

class OrderSubmittedPage extends StatelessWidget {
  const OrderSubmittedPage({
    required this.themeModeController,
    required this.order,
    required this.onViewOrders,
    super.key,
  });

  final ThemeModeController themeModeController;
  final OrderSnapshot order;
  final VoidCallback onViewOrders;

  @override
  Widget build(BuildContext context) {
    return _OrderFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-order-submitted'),
        title: 'Solicitud enviada',
        subtitle: 'El restaurante revisará tu pedido.',
        contentGap: 29,
        themeModeController: themeModeController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Semantics(
                label: 'Solicitud recibida por el restaurante',
                excludeSemantics: true,
                child: Container(
                  key: const Key('order-submitted-badge'),
                  width: 122,
                  height: 122,
                  decoration: BoxDecoration(
                    color: context.appPalette.surfaceTint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: CustomPaint(
                    size: const Size.square(58),
                    painter: _CheckMarkPainter(
                      color: context.appPalette.success,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 35),
            SizedBox(
              height: 37,
              child: Center(
                child: Text(
                  _statusHeading(order.status),
                  key: const Key('order-submitted-heading'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium
                      ?.copyWith(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ChifaCard(
              key: const Key('order-submitted-status'),
              icon: LucideIcons.info,
              iconColor: _figmaIconColor(context),
              title: 'Estado: ${order.status}',
              subtitle: _statusSubtitle(order.status),
              minimumHeight: 77,
              semanticLabel:
                  'Estado devuelto por el servidor: ${order.status}. ${_statusSubtitle(order.status)}',
            ),
            const SizedBox(height: 29),
            ChifaCard(
              key: const Key('order-submitted-reviewer'),
              icon: LucideIcons.info,
              iconColor: _figmaIconColor(context),
              title: 'Revisión por personal',
              subtitle: 'Local: mesa · Recojo/Delivery: Admin',
              minimumHeight: 77,
            ),
            const SizedBox(height: 49),
            ChifaButton(
              key: const Key('order-view-orders'),
              label: 'Ver mis pedidos',
              height: 54,
              borderRadius: 14,
              onPressed: onViewOrders,
            ),
          ],
        ),
      ),
    );
  }
}

class OrderExceptionPage extends StatelessWidget {
  const OrderExceptionPage({
    required this.themeModeController,
    required this.failure,
    required this.onBackToHome,
    this.onRetry,
    super.key,
  });

  final ThemeModeController themeModeController;
  final OrderFailure failure;
  final VoidCallback onBackToHome;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final bool retryable = failure.canRetrySafely && onRetry != null;
    return _OrderFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-order-exception'),
        title: 'Estados y excepciones',
        subtitle: 'Mensajes claros y próximos pasos.',
        contentGap: 17,
        themeModeController: themeModeController,
        child: Semantics(
          liveRegion: true,
          label: failure.message,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ChifaCard(
                key: const Key('order-exception-rejected'),
                icon: LucideIcons.circleAlert,
                iconColor: _figmaIconColor(context),
                title: 'Solicitud rechazada',
                subtitle: _exceptionSubtitle(
                  failure,
                  _ExceptionCard.rejected,
                  'REJECTED: no se generará comanda',
                ),
                minimumHeight: 116,
              ),
              const SizedBox(height: 10),
              ChifaCard(
                key: const Key('order-exception-product'),
                icon: LucideIcons.utensilsCrossed,
                iconColor: _figmaIconColor(context),
                title: 'Producto no disponible',
                subtitle: _exceptionSubtitle(
                  failure,
                  _ExceptionCard.product,
                  'Revisa existencias antes de solicitar',
                ),
                minimumHeight: 116,
              ),
              const SizedBox(height: 10),
              ChifaCard(
                key: const Key('order-exception-session'),
                icon: LucideIcons.userRound,
                iconColor: _figmaIconColor(context),
                title: 'Sesión no válida',
                subtitle: _exceptionSubtitle(
                  failure,
                  _ExceptionCard.session,
                  'Vuelve a iniciar sesión',
                ),
                minimumHeight: 116,
              ),
              const SizedBox(height: 10),
              ChifaCard(
                key: const Key('order-exception-connection'),
                icon: LucideIcons.circleAlert,
                iconColor: _figmaIconColor(context),
                title: 'Error de conexión',
                subtitle: _exceptionSubtitle(
                  failure,
                  _ExceptionCard.connection,
                  'Reintentar sin duplicar el pedido',
                ),
                minimumHeight: 116,
                trailing: retryable ? const SizedBox.shrink() : null,
                onTap: retryable ? onRetry : null,
                semanticLabel: retryable
                    ? 'Error de conexión. ${failure.message}. Reintentar sin duplicar el pedido.'
                    : 'Error de conexión. Reintentar sin duplicar el pedido.',
              ),
              const SizedBox(height: 28),
              ChifaButton(
                key: const Key('order-exception-home'),
                label: 'Volver al inicio',
                height: 54,
                borderRadius: 14,
                onPressed: onBackToHome,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderDetailLoadingPage extends StatelessWidget {
  const OrderDetailLoadingPage({required this.themeModeController, super.key});

  final ThemeModeController themeModeController;

  @override
  Widget build(BuildContext context) {
    return _OrderFrame(
      child: ChifaPageScaffold(
        pageKey: const Key('page-order-detail-loading'),
        title: 'Consultando pedido',
        subtitle: 'Actualizando el estado desde Chifa ASIA.',
        themeModeController: themeModeController,
        child: const ChifaStateView(
          kind: ChifaStateKind.loading,
          title: 'Cargando pedido',
          message: 'Espera un momento.',
        ),
      ),
    );
  }
}

String _statusHeading(String status) {
  return switch (status) {
    'REQUESTED' => 'En espera de aprobación',
    'APPROVED' => 'Solicitud aprobada',
    'REJECTED' => 'Solicitud rechazada',
    _ => 'Estado del pedido',
  };
}

String _statusSubtitle(String status) {
  return switch (status) {
    'REQUESTED' => 'Todavía no se ha generado comanda.',
    'APPROVED' => 'La solicitud fue aprobada por el restaurante.',
    'REJECTED' => 'No se generará comanda para esta solicitud.',
    _ => 'Consulta el seguimiento para ver los próximos pasos.',
  };
}

enum _ExceptionCard { rejected, product, session, connection }

String _exceptionSubtitle(
  OrderFailure failure,
  _ExceptionCard card,
  String fallback,
) {
  final _ExceptionCard target = switch (failure.kind) {
    OrderFailureKind.productUnavailable ||
    OrderFailureKind.idempotencyConflict ||
    OrderFailureKind.conflict ||
    OrderFailureKind.validation => _ExceptionCard.product,
    OrderFailureKind.unauthorized ||
    OrderFailureKind.forbidden ||
    OrderFailureKind.notFound => _ExceptionCard.session,
    OrderFailureKind.timeout ||
    OrderFailureKind.network ||
    OrderFailureKind.server ||
    OrderFailureKind.malformedResponse => _ExceptionCard.connection,
  };
  return target == card ? failure.message : fallback;
}

Color _figmaIconColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFFE2BC75)
      : const Color(0xFF922832);
}

final class _CheckMarkPainter extends CustomPainter {
  const _CheckMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final Path path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.53)
      ..lineTo(size.width * 0.39, size.height * 0.76)
      ..lineTo(size.width * 0.82, size.height * 0.23);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _OrderFrame extends StatelessWidget {
  const _OrderFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.appPalette;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: palette.background,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(body: child),
    );
  }
}
