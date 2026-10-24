# ETAPA 10 — Checkpoint · App de clientes

**Repositorio:** `restaurant-app-frontend-v2` · rama `develop` · base `34aa045` · cambios locales sin commit/push.
**Estado:** 10.00–10.04 aprobados expresamente; 10.05 y 10.06 listos para revisión técnica, no aprobados automáticamente; 10.07 es el siguiente bloque autorizado. `staff_app` intacta.

- **10.05 — Modalidad y mesas:** pantallas 04–07 claro/oscuro; LOCAL/PICKUP/DELIVERY; solo `GET /tables`; sin ocupar/aprobar mesa ni crear pedido. Slice 16/16, navegación 9/9, visual 16/16, suite 185/185, APK correcto. Figma: media `0.983852–0.987467`, tolerante `0.964529–0.970601`; estimación **9.8/10**.
- **10.06 — Envío M04:** pantallas 12, 13 y 18 claro/oscuro; `POST /orders` + `GET /orders/{id}`; DTO estricto, Bearer, `Idempotency-Key` estable por solicitud lógica, refresh único ante 401 y estado inicial `REQUESTED` verificado.
- **Flujo 10.06:** carrito → modalidad → revisión → creación real → consulta del pedido. Carrito/modalidad se limpian únicamente tras `201`; un fallo de consulta reintenta solo `GET`, nunca repite `POST`.
- **Errores:** 400/401/403/404/409/422/5xx, timeout, red y respuesta inválida tipados; 409 distingue producto no disponible y colisión de idempotencia. No se muestran tokens ni detalles internos.
- **Figma 10.06:** nodos 12 `179:226/673`, 13 `179:249/696`, 18 `179:367/814`; seis referencias originales 390×844 conservadas en `figma/10.06/`. Similitud media mínima `0.982617` y acuerdo tolerante mínimo `0.962069`; estimación **9.8/10**.
- **Pruebas 10.06:** slice **32/32**, navegación **9/9**, visual **12/12**, foco total **53/53**; `flutter analyze` sin incidencias; suite completa **229/229**; APK debug generado. Advertencia SDK XML v3/v4 no bloqueante.
- **API local:** `/health` 200, invitado 201, categorías 200 con lista vacía y pedidos propios 200 con lista vacía. `GET /tables` devuelve 500; sin catálogo no se pudo crear un pedido real sin inventar datos.
- **Android:** `flutter devices --machine` detectó solo Linux/WSL; Motorola Edge 60 Fusion/AVD no disponibles para esta validación.
- **Deuda asignada a 10.09:** aislar el carrito entre sesiones y cerrar observaciones pendientes de navegación/resiliencia.
- **Siguiente acción única:** implementar y validar **10.07 — Anticipo M06 (solo lectura)** con `GET /orders/{id}/advance` y `/payments`; no usar endpoints administrativos.
