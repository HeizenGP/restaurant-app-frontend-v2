# ETAPA 10 — Checkpoint · App de clientes

**Estado:** 10.00 revalidado el 2026-10-23 y listo para revisión, con arranque Android real pendiente por falta de dispositivo; 10.01–10.03 siguen reabiertos y sin UI vigente. No iniciar 10.01 ni bloques posteriores sin autorización.
**Base:** `restaurant-app-frontend-v2` / `develop` / `1250dfca32fb710f3cfb7eebf567a87e23a94c7f` (`1250dfc`, `renicio fase 10`), igual a `origin/develop` y con árbol limpio al iniciar. Cambios documentales de esta revisión sin commit ni push.

- **Toolchain:** Flutter stable **3.47.5**, Dart **3.13.4**, DevTools **2.60.0**, Android SDK/build-tools **36.0.0**, JDK **21.0.12.1** y licencias aceptadas. `flutter doctor -v` marca únicamente Chrome ausente y toolchain Linux desktop incompleto, fuera del destino Android.
- **Android:** `flutter devices --device-timeout 10` detectó solo Linux; no había emulador ni teléfono Android y no se ejecutó `flutter run`. El APK debug sí compiló con el `API_BASE_URL` previsto en `build/app/outputs/flutter-apk/app-debug.apk`; Gradle mostró un aviso no bloqueante por SDK XML v4.
- **API:** `String.fromEnvironment('API_BASE_URL')`, valor predeterminado `http://10.0.2.2:8000/api/v1`, rechazo de URL relativa/esquema no HTTP(S), permiso INTERNET y cleartext restringido a `10.0.2.2`/`localhost` en debug. OpenAPI local respondió **HTTP 200**, versión **3.1.0**, API **0.1.0**, con **35 paths**.
- **Pruebas:** `flutter analyze --no-pub` sin incidencias; `flutter test --no-pub` **58/58**. El anterior 96/96 pertenece a la UI retirada y no es evidencia vigente.
- **Figma:** [inventario 01–20](../referencias-visuales/etapa-10-00-figma.md) verificado en solo lectura: **20/20** claro + **20/20** oscuro, todos visibles, emparejados y de **390×844**, sin faltantes ni duplicados. Es evidencia estructural, no paridad visual de Flutter. Se conservaron intactas las 14 capturas locales existentes.
- **Arquitectura y funcionalidad:** permanecen design system, temas, recursos y capas no visuales M01/M02 bajo Hexagonal + Vertical Slicing. Las rutas usan placeholders neutros; contratos y reglas de negocio no cambiaron.
- **Calificación 10.00:** **9/10**. Base reproducible, pruebas, build Android, API y Figma verificados; falta ejecutar el APK en un dispositivo Android real/emulado y resolver o confirmar el aviso de herramientas SDK.
- **Próxima acción:** revisión del usuario sobre 10.00. No reconstruir 10.01 ni avanzar a otro bloque hasta autorización expresa.
