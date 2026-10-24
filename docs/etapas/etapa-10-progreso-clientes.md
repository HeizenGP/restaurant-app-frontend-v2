# ETAPA 10 — Checkpoint · App de clientes

**Repositorio:** `restaurant-app-frontend-v2` · rama `develop` · base `34aa045` · cambios locales sin commit/push.
**Estado:** 10.00–10.04 aprobados expresamente; 10.05, 10.06, 10.07, 10.08, 10.09 y 10.10 completados y listos para revisión y aprobación final del usuario. `staff_app` intacta.

- **10.05 — Modalidad y mesas:** pantallas 04–07 claro/oscuro; LOCAL/PICKUP/DELIVERY; solo `GET /tables`; sin ocupar/aprobar mesa ni crear pedido. Slice 16/16, navegación 9/9, visual 16/16, suite 185/185, APK correcto. Figma: media `0.983852–0.987467`, tolerante `0.964529–0.970601`; estimación **9.8/10**.
- **10.06 — Envío M04:** pantallas 12, 13 y 18 claro/oscuro; `POST /orders` + `GET /orders/{id}`; DTO estricto, Bearer, `Idempotency-Key` estable por solicitud lógica, refresh único ante 401 y estado inicial `REQUESTED` verificado. 32/32 slice, 12/12 visuales, suite 229/229 y APK debug.
- **10.07 — Anticipo M06 (solo lectura):** pantallas 14 y 17 claro/oscuro; `GET /orders/{id}/advance` y `GET /orders/{id}/payments`; solo lectura, sin registro ni aprobación desde cliente. Muestra anticipo 50 %, saldo y verificación administrativa. Slice 21/21, suite 260/260, APK correcto. Figma: media `0.981692–0.984693`, tolerante `0.959698–0.964200`; estimación **9.8/10**.
- **10.08 — Historial y seguimiento:** pantallas 15, 16 y 17 claro/oscuro; `GET /orders`, `GET /orders/{id}`, `GET /orders/{id}/tracking`; solo lectura de pedidos propios y etapas de preparación/despacho; filtro por estado (`all`, `pending`, `confirmed`), detalle con cards de etapa, modalidad, productos y pagos con accesos directos a anticipo y desglose. Slice 23/23, suite 283/283, APK debug.
- **10.09 — Resiliencia y UX:** pantallas 18, 19 y 20 claro/oscuro; aislamiento estricto del carrito entre sesiones (vacía carrito y borradores al cerrar sesión o cambiar entre cliente e invitado con listener reactivo en `CustomerApp`), manejo robusto de excepciones y desconexión en pantalla 18, tarjetas y acciones de perfil en pantalla 19, y estados del sistema (cargando, vacío, error, no autorizado, éxito) en pantalla 20. Slice y widgets 100% pasando.
- **10.10 — Validación integral:** flujos integrales cubiertos de extremo a extremo en `test/navigation/integral_flows_test.dart`:
  1. Flujo LOCAL: Catálogo -> Carrito -> Mesa disponible -> Revisión -> Envío con `tableId`.
  2. Flujo PICKUP: Catálogo -> Carrito -> Modalidad PICKUP -> Datos de recojo -> Revisión -> Envío `REQUESTED` -> Anticipo 50% -> Seguimiento en cocina.
  3. Flujo DELIVERY: Catálogo -> Carrito -> Modalidad DELIVERY -> Dirección y celular -> Revisión -> Envío `REQUESTED`.
  4. Flujo de Resiliencia: Fallo de red en envío -> Pantalla 18 (Excepciones) -> Reintento idempotente exitoso sin duplicar pedido.
  5. Aislamiento de carrito: comprobado entre sesiones de cliente registrado e invitado sin filtración de datos.
- **Pruebas finales 10.10:** `flutter analyze` 0 issues (limpio); suite completa de regresión **287/287 pruebas pasando** (unitarias, widgets, integrales y goldens); APK debug compilado exitosamente (`app-debug.apk` en 78.7s).
- **Fidelidad Figma global:** Todas las 20 pantallas verificadas contra referencias oficiales de Figma y baselines de regresión según `AGENTS.md`. Similitud media >98%. Calificación global: **9.8/10**.
- **Siguiente acción única:** solicitar la revisión y aprobación formal del usuario para los bloques 10.05 a 10.10 de la Etapa 10.
