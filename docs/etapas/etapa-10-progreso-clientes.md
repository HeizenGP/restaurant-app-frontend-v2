# ETAPA 10 — Checkpoint de ejecución · App de clientes

**Estado:** 10.02 — Acceso M01 implementado y verificado; **listo para revisión y pendiente de aprobación expresa del usuario**. No iniciar 10.03.
**Repo/rama:** `restaurant-app-frontend-v2` / `develop`; inicio limpio en `094145759fec34a17d9ae0f5a8385593eee0dd33`. **Alcance:** `apps/customer_app`, este checkpoint y la columna `Estado` de la hoja de ruta; cambios locales sin commit/push.
**Guía:** [hoja de ruta con estado por bloque](etapa-10-hoja-ruta-clientes.md) · [contratos cliente](etapa-10.md) · [Figma claro/oscuro](https://www.figma.com/design/7ZiwUZOnUFwu1cz21rWOMs/Untitled?node-id=0-1).

- **10.01 verificado antes de continuar:** `flutter analyze` limpio y 14/14 pruebas aprobadas; UI Foundation existente preservada.
- **Figma leído, no modificado:** Login `172:4`/`172:70`, Registro `179:2`/`179:449`, Invitado `179:19`/`179:466` y Cuenta `179:390`/`179:837`, claro/oscuro. Se integraron sus SVG visibles y Lucide; 8 goldens M01 inspeccionadas a 390×844.
- **Contratos backend reales:** `POST /auth/register` 201 sin login, `/auth/login` 200, `/auth/guest` 201, `/auth/refresh` 200 con rotación de token y `/auth/logout` 204 Bearer. Errores 401/409/422 mapeados sin exponer detalle interno.
- **Registro y acceso:** formularios validados con límites M01, login solo por correo, mensajes inline de carga/error y confirmación de cuenta creada antes de volver a iniciar sesión. Recuperación de contraseña permanece no interactiva porque no existe API.
- **Sesión:** JWT y metadatos persistidos con `flutter_secure_storage`; contraseña nunca persistida. Restauración, refresh de un solo vuelo, rotación segura, expiración automática del invitado, logout remoto y limpieza local con reintento; una falla del almacenamiento nunca conserva una sesión inválida en memoria. Backup Android deshabilitado.
- **Invitado y rutas:** sesión temporal sin `refresh_token`, protección declarativa de rutas con splash de restauración y shell Inicio/Menú/Pedidos/Cuenta solo tras renovación confirmada o con JWT local aún no expirado.
- **Cuenta/UX:** variante registrada e invitada, logout, tema claro/oscuro, `SafeArea`, scroll, objetivos táctiles y adaptación comprobada a 320×568 hasta texto 2.0; Atrás del sistema queda bloqueado mientras Registro o Invitado esperan respuesta. Editar perfil, preferencias y notificaciones quedan deshabilitados/sin API.
- **Arquitectura:** `features/m01_access/<caso_de_uso>/` con dominio puro, estado inmutable unidireccional, puertos de repositorio/almacenamiento, adaptador REST y presentación separada.
- **Pruebas finales:** `flutter analyze` → **No issues found**; `flutter test` → **61/61 passed** (47 específicas M01: validadores, REST, almacenamiento seguro, controlador, carreras de sesión/navegación, formularios/rutas, adaptación y 8 goldens M01; más 14 de regresión 10.01).
- **Build:** `flutter build apk --debug` → **correcto**, `build/app/outputs/flutter-apk/app-debug.apk` (202 862 578 bytes).
- **Límites reales:** sin AVD/teléfono disponible y sin prueba contra un backend vivo; contratos contrastados con OpenAPI/código/pruebas de integración reales del backend y adaptador Flutter probado con respuestas contractuales. Goldens verifican render Linux, no captura Android nativa.
- **Calificación técnica 10.02:** **9/10**. Cumple alcance, contratos, seguridad, fidelidad y pruebas; falta validación táctil Android y recorrido contra backend desplegado para 10/10.
- **Próxima acción única:** revisión y aprobación expresa del usuario; mantener 10.03 pendiente.

> La hoja de ruta ahora muestra `Estado`; “implementado y verificado” no equivale a “aprobado”.
