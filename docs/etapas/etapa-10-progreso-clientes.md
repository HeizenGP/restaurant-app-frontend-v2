# ETAPA 10 — Checkpoint · App de clientes

**Estado:** **10.00 — Línea base APROBADA expresamente por el usuario (2026-10-23)**; 10.01–10.03 sin UI vigente y pendientes de reconstrucción. No avanzar a 10.01 sin autorización específica.
**Repo:** `restaurant-app-frontend-v2` · `develop` · base de la aprobación: `5c4a538`. Evidencia visual: [inventario Figma 01–20](../referencias-visuales/etapa-10-00-figma.md).

- **Herramientas (Codex):** Flutter 3.47.5, Dart 3.13.4, Android SDK 36.0.0, JDK 21; Chrome y Linux desktop incompletos, sin impacto en destino Android.
- **Pruebas técnicas (Codex):** `flutter analyze --no-pub` sin incidencias, `flutter test --no-pub` **58/58**; `flutter build apk --debug` exitoso. Resultados documentados por Codex, no por CI de GitHub.
- **Android real (usuario, 2026-10-23):** `flutter run` reconoció **motorola edge 60 fusion**; `assembleDebug` y `Installing ... app-debug.apk` finalizaron; motor Flutter y servicio Dart VM iniciaron correctamente. Se confirmó **compilación, instalación y arranque en dispositivo físico**. Se observó `Skipped 246 frames` al iniciar, sin excepción fatal visible.
- **Red/API:** `API_BASE_URL` por `--dart-define`; el predeterminado `http://10.0.2.2:8000/api/v1` sirve para emulador, **no para Motorola físico**. OpenAPI local respondió 200 con 35 rutas según Codex; la **conectividad teléfono→FastAPI permanece sin verificar** y requiere IP accesible desde el teléfono.
- **Figma:** inventario verificado 20/20 pantallas claro + 20/20 oscuro (390×844); 14 capturas de referencia conservadas. No existe UI Flutter vigente para comparar paridad visual.
- **Arquitectura:** se conservaron Hexagonal + Vertical Slicing, rutas con placeholders neutros, temas, recursos, M01/M02 no visuales y pruebas. `staff_app` sin cambios.
- **Valoración:** **9.5/10** como base técnica con observación de conectividad Android–API; esta aprobación **no** aprueba ETAPAS 08/09/10 completas ni pruebas funcionales futuras.
- **Skills/tokens:** Skill Flutter optimizada para cargar contexto mínimo y comparar una pantalla activa a la vez. Skill FastAPI revisada sin cambios en backend.
- **Próximo paso:** implementar **10.01 — UI Foundation** solo tras nueva autorización; comparar capturas reales con Figma en ambos temas y registrar evidencia concreta.
