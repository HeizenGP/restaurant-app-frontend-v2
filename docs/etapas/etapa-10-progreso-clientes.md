# ETAPA 10 — Checkpoint de ejecución · App de clientes

**Estado:** 10.01 — UI Foundation implementada y verificada; **pendiente de revisión/aprobación del usuario**. No iniciar 10.02.
**Repo/rama:** `restaurant-app-frontend-v2` / `develop`, HEAD `8af9dbd11481b96f0f0fda8f6efdce85b9237dec`. **Alcance:** `apps/customer_app` y este checkpoint; cambios locales sin commit/push.
**Guía:** [hoja de ruta](etapa-10-hoja-ruta-clientes.md) · [contratos cliente](etapa-10.md) · [Figma claro/oscuro](https://www.figma.com/design/7ZiwUZOnUFwu1cz21rWOMs/Untitled?node-id=0-1).

- **10.00 verificado (2026-10-22):** `develop = origin/develop`, árbol limpio al inicio y commit `8af9dbd` «10.00 — Línea base». Flutter 3.47.5/Dart 3.13.4; `flutter analyze` limpio y 2/2 pruebas base aprobadas antes de implementar.
- **Figma leído, no modificado:** páginas claro `0:1` y oscuro `176:2`; contextos y capturas de 08 Inicio (`179:38`/`179:485`), 09 Menú (`179:67`/`179:514`), 15 Pedidos (`179:290`/`179:737`), 19 Cuenta (`179:390`/`179:837`) y 20 Estados (`179:418`/`179:865`).
- **Design System:** paletas semánticas claro/oscuro, DM Sans + Cormorant Garamond locales, escalas tipográficas, espaciado, radios, bordes, controles y `ThemeData` Material 3 alineados con Figma; los tokens legibles derivados cumplen contraste WCAG AA ≥ 4.5:1.
- **Componentes:** tarjeta e icon tile, botón primario/secundario con loading, campo de texto y estados loading/empty/error/success; Lucide real, tamaños táctiles y semántica accesible.
- **Navegación:** `go_router` con `StatefulShellRoute.indexedStack`; barra inferior Inicio/Menú/Pedidos/Cuenta, pestaña activa persistente y rutas declarativas `/`, `/menu`, `/pedidos`, `/cuenta`.
- **Estructura/UX:** `SafeArea`, shell modular, layout con ancho máximo, scroll vertical, gutter adaptable y corrección comprobada de overflow a 320×568 con escala de texto 1.4.
- **Alcance funcional:** vistas neutras de fundación; sin autenticación, REST de negocio, catálogo, carrito ni funciones de 10.02+. `ApiEnvironment` de 10.00 se conserva sin consumo HTTP nuevo.
- **Pruebas finales:** `flutter analyze` → **No issues found**; `flutter test` → **14/14 passed**: entorno API, tokens/temas, contraste, componentes, estados habilitado/deshabilitado, acciones semánticas, navegación, cambio de tema, pantalla estrecha y 2 golden tests 390×844 claro/oscuro. `flutter build apk --debug` → **APK generado correctamente**.
- **Correcciones guiadas por pruebas:** campo expuesto como un único nodo editable; acciones TalkBack ejecutadas mediante eventos semánticos; botón, tarjeta, reintento, navegación y selector de tema conservan su acción/estado; navegación/header ajustados para crecimiento vertical con texto ampliado.
- **Límites reales:** no existe AVD/dispositivo Android disponible; no se ejecutó `flutter run` físico/emulado. Las goldens verifican render Linux del widget, no certifican una captura Android nativa.
- **Calificación técnica 10.01:** **9/10**. Implementación, análisis y pruebas cumplen el bloque; falta validación visual/táctil en Android real para aspirar a 10/10.
- **Próxima acción única:** detenerse para revisión y aprobación del usuario; no iniciar 10.02.

> Mantener este estado vivo y breve. La aprobación expresa del bloque corresponde al usuario.
