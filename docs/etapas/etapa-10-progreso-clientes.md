# ETAPA 10 — Checkpoint de ejecución · App de clientes

**Estado:** 10.03 — Catálogo M02 implementado y verificado; **listo para revisión y pendiente de aprobación expresa del usuario**. No iniciar 10.04.
**Repo/rama/base:** `restaurant-app-frontend-v2` / `develop` / `b5744c4c48709a5b7a92c22a2153b994a0ebb0b7`; cambios locales de 10.03 sin commit/push.
**Alcance:** solo `apps/customer_app` y documentación de estado; `staff_app`, backend y Figma no modificados.
**Guía:** [hoja de ruta](etapa-10-hoja-ruta-clientes.md) · [contratos cliente](etapa-10.md) · [Figma claro/oscuro](https://www.figma.com/design/7ZiwUZOnUFwu1cz21rWOMs/Untitled?node-id=0-1).

- **10.02 verificado antes de continuar:** línea base con `flutter analyze` limpio y `flutter test` **61/61 passed**; acceso M01 y UI Foundation preservados.
- **Figma leído, no modificado:** Inicio `179:38`/`179:485`, Catálogo `179:67`/`179:514` y Producto `179:101`/`179:548`, claro/oscuro.
- **RF/CA:** RF-M02-01 y CA-M02-01-01; categorías, nombre, precio y disponibilidad de venta, sin abarcar mantenimiento administrativo ni stock operativo.
- **Contratos backend reales:** `GET /api/v1/catalog/categories` y `GET /api/v1/catalog/categories/{category_id}/products`, ambos públicos; 404 de categoría, 422 de UUID inválido y fallos de red/servidor tratados.
- **Límite contractual:** no existe `GET /catalog/products/{product_id}` ni campos de descripción, imagen o stock exacto. El detalle reutiliza/refresca el listado de la categoría y muestra la ausencia de descripción sin inventar datos.
- **Modelos:** categoría `{id, name}` y producto `{id, category_id, name, price, available_for_sale}`; precio decimal del JSON convertido a centavos sin `double` como fuente monetaria.
- **Arquitectura:** `features/m02_catalog/` aplica Hexagonal + Vertical Slicing con dominio/modelos, puertos de aplicación, adaptador REST, `browse_catalog` y `view_product`; sin dependencias HTTP/widgets en dominio.
- **Estado:** controladores unidireccionales para carga, éxito, vacío, error, cambio de categoría, reintento y detalle/no encontrado; versión de solicitud evita que una respuesta obsoleta sobrescriba la vigente.
- **UX/UI:** Inicio, catálogo por categorías y detalle usan el sistema visual 10.01, Lucide, temas claro/oscuro, `SafeArea`, componentes reutilizables y estados de carga/vacío/error/no disponible.
- **Navegación:** acceso declarativo desde Inicio a Menú, selección de categoría y apertura/retorno del detalle; Pedidos, carrito y acciones de compra permanecen fuera de 10.03.
- **Pruebas núcleo M02:** **21/21 passed** para mapeo JSON, adaptador REST contractual, catálogo y detalle; no se usó un endpoint ficticio.
- **Validación final:** `[ROOT: registrar resultado exacto de flutter analyze]`.
- **Suite final:** `[ROOT: registrar N/N exacto de flutter test y desglose M02/regresión]`.
- **Goldens/widgets:** `[ROOT: registrar cantidad y revisión visual final de claro/oscuro y adaptación]`.
- **Build Android:** `[ROOT: registrar resultado de flutter build apk --debug y artefacto]`.
- **Límites reales:** `[ROOT: confirmar disponibilidad de AVD/teléfono y backend vivo]`; las pruebas REST Flutter usan respuestas acordes con contratos auditados del backend, no datos comerciales inventados.
- **Calificación técnica provisional 10.03:** **9/10**; sujeta a confirmar la suite final. Para 10/10 faltan validación táctil Android y recorrido contra backend desplegado si esos entornos siguen no disponibles.
- **Próxima acción única:** revisión y aprobación expresa del usuario; mantener 10.04 y posteriores pendientes.

> “Implementado y verificado” no equivale a “aprobado”; la aprobación corresponde exclusivamente al usuario.
