# ETAPA 10 — Checkpoint · App de clientes

**Estado:** **10.01 — UI Foundation implementada y pendiente de revisión expresa del usuario (2026-10-23)**. 10.02 y posteriores no iniciados.
**Repo:** `restaurant-app-frontend-v2` · rama `develop` · HEAD base `63a79e2` · cambios locales sin commit ni push. Evidencia: [inventario Figma 01–20](../referencias-visuales/etapa-10-00-figma.md).

- **Alcance 10.01:** temas y tokens, tipografía, encabezado, tarjetas, chips, botones, campos, navegación inferior, `SafeArea`, rutas declarativas y estados loading/empty/error. Se mantuvieron Hexagonal + Vertical Slicing, funcionalidades existentes y `staff_app`; no se añadió lógica de negocio de 10.02+.
- **Figma:** acceso oficial de solo lectura; pantalla 08 `179:38/485`, 09 `179:67/514`, 15 `179:290/737`, 19 `179:390/837` y 20 `179:418/865`, todas en claro/oscuro y viewport **390×844**. Se conservan **18 PNG** locales; el archivo Figma no fue modificado.
- **Fidelidad:** diez capturas Flutter comparadas pantalla por pantalla. Similitud media mínima por canal **0.9772**, umbral **0.97** y acuerdo de píxel tolerante **0.94**; estimación **9.7/10**. Diferencias residuales: rasterización de fuente/iconos y esquinas externas del dispositivo, no diseño inventado.
- **Validación 10.01:** `flutter analyze --no-pub` sin incidencias; **81/81** pruebas de la suite completa y **10/10** comparaciones Figma superadas; APK debug compilado en `build/app/outputs/flutter-apk/app-debug.apk`.
- **Línea base 10.00 conservada:** Flutter 3.47.5, Dart 3.13.4, Android SDK 36.0.0 y JDK 21; en la validación anterior se aprobaron analyze, 58/58 tests, APK debug y arranque en un Motorola físico. `API_BASE_URL` continúa por `--dart-define`; la conectividad teléfono→FastAPI sigue pendiente.
- **Pendientes:** revisión visual del usuario y ejecución Android real; en este cierre no había dispositivo ni emulador Android disponible. No avanzar a 10.02 ni realizar commit/push sin autorización.
