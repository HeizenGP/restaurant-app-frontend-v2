# ETAPA 10 — Contexto preparatorio de Flutter | Chifa ASIA

**Estado:** preparación documental y [hoja de ruta por bloques para `customer_app`](etapa-10-hoja-ruta-clientes.md); **sin implementación Flutter iniciada ni aprobación formal registrada del diseño de clientes**. No es aprobación de ETAPA 08, 09 o 10. Progreso: [checkpoint](etapa-10-progreso-clientes.md).

**Fuente contrastada el 2026-10-22:** backend `develop`, HEAD `e3881305cb7900611ac6d9b54e1979a5fb72da16`; [plan de ETAPA 08](../../../restaurant-app-backend-v2/docs/etapas/etapa-08.md), [bitácora y matriz RF/CA](../../../restaurant-app-backend-v2/docs/etapas/etapa-08-progreso.md) e [informe de auditoría](../../../restaurant-app-backend-v2/docs/etapas/etapa-08-informe-auditoria.md). La especificación [ETAPA 03](etapa-03-requisitos.md) contiene **40 RF y 48 CA**; el informe acredita su cobertura **como contratos backend**, no como pantallas, y verificó 35 patrones de ruta/40 operaciones OpenAPI. Consultar OpenAPI del backend vigente antes de implementar: las rutas siguientes son solo el subconjunto de `customer_app`, no un contrato REST duplicado.

## 1. Puerta de entrada y alcance

- La ETAPA 07 está aprobada. Los bloques 08.00–08.10 están verificados técnicamente, pero **la ETAPA 08 espera aprobación final expresa del usuario**. La ETAPA 09 ya tiene [diseño de 20 pantallas de clientes en dos temas](https://www.figma.com/design/7ZiwUZOnUFwu1cz21rWOMs/Untitled?node-id=0-1), pero no consta su aprobación formal final. Por tanto, este documento y la hoja de ruta **solo preparan** ETAPA 10 y no autorizan modificar código.
- Cuando esas aprobaciones existan y se autorice implementar, comenzar **solo por `apps/customer_app`** para cliente registrado e invitado en Android. `staff_app`, incluido el panel Flutter Web, queda fuera de la primera implementación; sigue siendo la segunda aplicación prevista por la [arquitectura aprobada](etapa-05.md).
- Tomar del Figma aprobado navegación, componentes, textos y estados visuales. Antes de codificar cada recorrido, cotejar **pantalla → RF/CA → endpoint/esquema OpenAPI → estados/error**. No reemplazar el diseño faltante por decisiones de interfaz inventadas. La Skill local [`restaurant-flutter-slice`](../../.agents/skills/restaurant-flutter-slice/SKILL.md) se activa cuando exista una funcionalidad Flutter autorizada, no por esta preparación documental.

## 2. Capacidades de cliente y API existente

Todas las rutas usan el prefijo `/api/v1`. Las lecturas del catálogo y del listado de mesas son públicas; las consultas de pedidos, anticipos, pagos y seguimiento exigen sesión y visibilidad del propio pedido. El servidor decide autorización, importes, disponibilidad y transiciones; Flutter no los recalcula como fuente de verdad.

| RF/CA de cliente | Capacidad para planificar según Figma | Contrato backend verificado |
|---|---|---|
| RF-M01-01/02; CA-M01-01-01/02, CA-M01-02-01 | Cuenta, ingreso o sesión de invitado | `POST /auth/register`, `/auth/login`, `/auth/guest`; `/auth/refresh` y `/auth/logout` según tipo de sesión |
| RF-M02-01; CA-M02-01-01 | Categorías, producto, precio y disponibilidad | `GET /catalog/categories`, `GET /catalog/categories/{category_id}/products` |
| RF-M03-02; CA-M03-02-01 | Consulta de mesas para consumo local | `GET /tables` (incluye `is_occupied`; consultar estado actual al operar) |
| RF-M04-01/02/05/08/11; CA respectivos | Modalidad `LOCAL`, `PICKUP` o `DELIVERY`, productos/cantidades, envío de solicitud, detalle y rechazo | `POST /orders` con `Idempotency-Key`; `GET /orders`, `GET /orders/{order_id}`. Canal cliente `APP`; el backend conserva snapshots de precio y total. |
| RF-M06-02/06; CA respectivos | Consulta de anticipo obligatorio y situación de pago, sin ejecutar verificación/cobro desde cliente | `GET /orders/{order_id}/advance`, `GET /orders/{order_id}/payments` y saldo/estado en seguimiento |
| RF-M04-10; CA-M04-10-01 | Seguimiento desde solicitud hasta cierre | `GET /orders/{order_id}/tracking`; consumir `stage`, `order_status`, `kitchen_status`, `fulfillment_kind`, `payment_status` y `balance` de la respuesta |

En `POST /orders`, una solicitud `APP` queda `REQUESTED` y no ocupa la mesa ni descuenta stock. Para local, el personal verifica presencialmente la mesa antes de aprobar; al aprobar, la ocupación se registra según la regla implementada. Un pedido adicional en mesa ocupada solo corresponde al **mismo cliente registrado o a la misma sesión invitada asociados a la ocupación vigente**; el QR o identificador de mesa no acredita pertenencia. Otros clientes reciben rechazo del servidor. Para recojo/delivery, el Administrador aprueba y verifica el anticipo manual/simulado del **50 %**, redondeado al céntimo superior cuando corresponda, antes de confirmar/enviar a cocina; el saldo se cobra después del recojo o entrega registrada. La app muestra el resultado del backend y sus errores, sin simular una autorización exitosa.

La confirmación comprueba stock y descuenta existencias una sola vez; solo el pedido confirmado genera comanda. El cierre requiere `READY`, atención/entrega registrada y saldo **S/ 0.00**. Caja admite medios simulados Efectivo, Yape, Plin y Tarjeta con las referencias validadas por backend, pero su registro no pertenece a `customer_app`.

## 3. Estados, permisos y errores que debe representar el diseño

- El pedido expone `REQUESTED`, `APPROVED`, `REJECTED`, `CONFIRMED` y, tras el cierre, `CLOSED`. La preparación expone `RECEIVED`, `PREPARING`, `READY`; la atención/entrega expone `SERVED`, `PICKED_UP`, `DELIVERED` según modalidad. El seguimiento compone estos datos en `stage`; **no persistir ni deducir un segundo estado global en Flutter**. Pago: `UNPAID`, `PARTIAL`, `PAID` y saldo exacto de la respuesta.
- Las operaciones de aprobación/verificación, pedido directo de Mozo, confirmación, cocina, cobro, atención/entrega y cierre **no son acciones del cliente**. Permisos M07 aprobados: Mozo registra `SERVED`; Administrador registra `PICKED_UP`, `DELIVERED` y cierre; Super Administrador conserva acceso total. Administrador no adquiere rol de Cajero por esas operaciones. Su interfaz corresponde después a `staff_app`.
- Tratar `401` como sesión no válida, `403` como permiso insuficiente, `404` como recurso inexistente/no visible, `409` como conflicto de estado, stock, saldo o clave repetida con contenido distinto, y `422` como datos inválidos. Presentar éxito solo tras respuesta confirmada. Conservar la misma `Idempotency-Key` al reintentar **la misma** creación de pedido; no reusarla con contenido diferente. La ocultación de UI no sustituye los permisos del servidor.

## 4. Pendientes y condición para implementar

1. **Aprobaciones:** la ETAPA 08 requiere decisión final del usuario; la ETAPA 09 cuenta con archivo Figma de clientes localizado, pero falta la aprobación formal del diseño/recorrido y mapa pantalla → RF/CA → API. Tomar las pantallas existentes como referencia, no como aprobación tácita; no modificar Figma en esta planificación.
2. **Decisiones no inventadas:** RN-20/RN-21 esperan ratificación de su redacción, aunque sus protecciones de stock/cierre ya tengan respaldo en RF/CA; RNF-08 carece de umbral aprobado. Los comprobantes simulados requieren RF/CA antes de emitirlos. No añadir pasarelas reales, WhatsApp automático, SUNAT, mapas, repartidores ni rutas.
3. **Validación futura, no ejecutada aquí:** pruebas de widgets/navegación, Android, estados de carga/vacío/error, sesión, reintentos e integración visual contra el Figma aprobado. HTTPS operativo, experiencia ante desconexión y rendimiento con umbral aprobado pertenecen a su entorno/etapa; la auditoría backend no los certifica.

**Siguiente paso permitido tras las aprobaciones y autorización para codificar:** ejecutar [10.00 — Línea base](etapa-10-hoja-ruta-clientes.md) y avanzar por bloques, revisando primero Figma, RF-M01-01/02 y OpenAPI vigente para acceso/invitado; detenerse antes de `staff_app` hasta recibir alcance expreso.
