# ETAPA 10 — Checkpoint · App de clientes

**Estado:** 10.00 y 10.01 aprobados; **10.02 — Acceso M01**, **10.03 — Catálogo M02** y **10.04 — Carrito** implementados y listos para revisión, aún sin aprobación; 10.05 no iniciado.
**Repositorio:** `restaurant-app-frontend-v2` · rama `develop` · base `a4329f1add3d62f961a44edef52118aff66c519b` · cambios locales sin commit/push.

- **Alcance 10.02:** pantallas 01 Login, 02 Registro, 03 Invitado y 19 Cuenta; claro/oscuro; responsive con `SafeArea`/scroll; `staff_app` intacta.
- **Contratos exclusivos:** `POST /auth/register`, `/auth/login`, `/auth/guest`, `/auth/refresh` y `/auth/logout`; sin endpoints ni datos inventados.
- **Sesión:** almacenamiento seguro, validación estricta USER/GUEST, renovación, cierre local aun si falla la confirmación remota, expiración y guardas declarativas de rutas.
- **Cuenta:** identidad registrada/invitada diferenciada. El avatar abre la confirmación de cierre sin alterar la composición base de Figma.
- **Figma verificado:** nodos claro/oscuro 01 `172:4/70`, 02 `179:2/449`, 03 `179:19/466`, 19 `179:390/837`; viewport 390×844.
- **Comparación M01:** 8/8 aprobadas; similitud media por canal `0.973619–0.988852` (umbral `0.97`) y acuerdo tolerante `0.944387–0.973098` (umbral `0.94`); estimación **9.7/10**.
- **Última validación automatizada (previa al ajuste final de padding):** `flutter analyze --no-pub` sin incidencias; `flutter test --no-pub` **122/122** y 8/8 comparaciones Figma aprobadas a 390×844. Ese ajuste posterior no se revalidó por solicitud expresa del usuario.
- **Android:** APK debug generado e instalado; arranque y capturas verificados en Motorola Edge 60 Fusion, Android 15 (1220×2712 físicos), sin bordes blancos en Login y con iconos de estado legibles en Invitado claro.
- **Ajuste pendiente de validación del usuario:** el contenido del Login admite hasta 432 px para conservar 28 px laterales también en el teléfono ancho; no se repitieron pruebas ni instalación por solicitud expresa.
- **Límites verificados:** login muestra «Correo electrónico» porque el contrato acepta email, no celular; recuperación de contraseña permanece informativa y sin acción al no existir endpoint; el chrome del sistema no se duplica como widget.

## 10.03 — Catálogo M02 · cierre independiente

- **Alcance:** pantallas 08 Inicio, 09 Catálogo y 10 Detalle, claro/oscuro; navegación, carga, vacío, error y producto no disponible.
- **Contratos exclusivos:** `GET /catalog/categories` y `GET /catalog/categories/{category_id}/products`. El detalle reutiliza el producto seleccionado; no existe ni se inventó un endpoint de detalle, imagen o descripción.
- **Figma verificado:** nodos 08 `179:38/485`, 09 `179:67/514` y 10 `179:101/548`; seis referencias 390×844. Se incorporó el glifo `食` exportado del nodo oficial, con color ligado al tema.
- **Validación:** `flutter analyze --no-pub` sin incidencias; pruebas focales **31/31**; suite completa **138/138**; comparaciones Figma **6/6** por encima de similitud media `0.97` y acuerdo tolerante `0.94`; estimación **9.6/10**.
- **Android:** `flutter devices` solo detectó Linux/WSL; no hubo teléfono ni AVD disponible para validar este cierre en hardware real.
- **Estado del bloque:** listo para revisión, no aprobado automáticamente.

## 10.04 — Carrito · cierre independiente

- **Alcance:** controles de cantidad en pantalla 10 y pantalla 11 Carrito, claro/oscuro. Agrega y acumula productos disponibles, edita cantidades sin bajar de uno, elimina y calcula subtotales locales en centavos.
- **Arquitectura y límite:** estado en memoria con instantánea propia de M04; el router desacopla M02/M04. Sin API, persistencia, reserva de stock ni checkout. «Continuar con pedido» conserva Figma pero queda funcional y semánticamente inactivo para no adelantar 10.05.
- **Figma verificado:** pantalla 10 `179:101/548` y pantalla 11 `179:117/564`, a 390×844. La edición/eliminación se abre al tocar la tarjeta, sin alterar la composición base de la pantalla 11. Referencias 11 conservadas en `docs/referencias-visuales/figma/10.04/`.
- **Comparación:** pantalla 10, similitud `0.985881–0.986478` y acuerdo tolerante `0.969950–0.970778`; pantalla 11, similitud `0.983467–0.984230` y acuerdo tolerante `0.962085–0.962240`. Las **4/4** variantes pertinentes superan `0.97/0.94`; estimación **9.7/10**.
- **Validación:** pruebas focales **39/39**; `flutter analyze --no-pub` sin incidencias; suite completa **150/150**; `flutter build apk --debug --no-pub` exitoso (`build/app/outputs/flutter-apk/app-debug.apk`). El build emitió una advertencia no bloqueante: el lector del SDK admite XML hasta v3 y encontró XML v4.
- **Android:** `flutter devices` solo detectó Linux/WSL; no hubo teléfono ni AVD disponible para validar gestos, barras del sistema o captura en hardware real.
- **Pendiente de producto:** no existe una regla aprobada sobre vaciar el carrito al cambiar de sesión; por ahora permanece solo en memoria durante la ejecución y no se inventó ese comportamiento.
- **Estado del bloque:** listo para revisión, no aprobado automáticamente. **Siguiente acción única:** revisión del usuario; no avanzar a 10.05 ni realizar commit/push.

## Ajuste responsive transversal · 2026-10-24

- **Corrección:** el límite móvil compartido sube de 390 a 432 dp para eliminar el margen de centrado adicional en teléfonos anchos. Se aplica a Registro, Invitado, Inicio, Catálogo, Detalle, Carrito, Pedidos y Estados; Cuenta amplía su contenido de 354 a 396 dp. Login ya utilizaba 432 dp.
- **Fidelidad conservada:** no se modificaron los gutters oficiales ni los espacios internos: Login 28 dp, pantallas generales 24 dp y Cuenta 18 dp. A 390×844 el render permanece idéntico a las referencias de Figma.
- **Validación:** `flutter analyze --no-pub` sin incidencias; pruebas responsive focales **21/21**; goldens **34/34**; comparaciones Figma **26/26**; suite completa **151/151**; APK debug regenerado correctamente.
- **Alcance real:** 04–07 todavía no están implementadas y no se inventaron pantallas. La comprobación final en el teléfono físico queda para la revisión del usuario.
