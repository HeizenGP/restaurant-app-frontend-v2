# ETAPA 10 — Checkpoint de ejecución · App de clientes

**Estado:** 10.03 — Catálogo M02 implementado y verificado; **listo para revisión y pendiente de aprobación expresa del usuario**. No iniciar 10.04.
**Repo/rama/HEAD observado:** `restaurant-app-frontend-v2` / `develop` / `6f9b4dcc9d917063d0cefde066c6efb32f7b5f21`, alineado con `origin/develop`; este cambio remoto apareció durante la ejecución y no fue creado ni publicado por este agente. Ajustes finales locales sin commit ni push.
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
- **Validación final:** `flutter analyze` → **No issues found**.
- **Suite final:** `flutter test` → **96/96 passed**: 61 de regresión 10.00–10.02 y 35 incorporadas para M02 (21 de dominio/aplicación/REST, 6 de widgets/estados, 6 goldens claro/oscuro y 2 de navegación integrada).
- **Goldens/widgets:** seis baselines M02 a 390×844 inspeccionadas visualmente (Inicio, Catálogo y Detalle, claro/oscuro); se renovaron además las dos baselines históricas de Inicio. Adaptación sin overflow comprobada a 320×568 con texto 1.6.
- **Build Android:** `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1` → **correcto**; `build/app/outputs/flutter-apk/app-debug.apk` (202 862 578 bytes). Gradle informó una advertencia no bloqueante por diferencia de versiones XML entre Android Studio y command-line tools.
- **Límites reales:** no hay AVD/teléfono ni backend escuchando en `127.0.0.1:8000` (`HTTP 000`); las pruebas REST Flutter usan respuestas acordes con el código y las pruebas de integración reales auditadas del backend, sin datos comerciales inventados. Goldens verifican render Linux, no captura Android nativa.
- **Calificación técnica 10.03:** **9/10**. Cumple alcance, contratos, arquitectura, estados, fidelidad y pruebas; para 10/10 faltan validación táctil Android y recorrido contra backend desplegado.
- **Próxima acción única:** revisión y aprobación expresa del usuario; mantener 10.04 y posteriores pendientes.

> “Implementado y verificado” no equivale a “aprobado”; la aprobación corresponde exclusivamente al usuario.
