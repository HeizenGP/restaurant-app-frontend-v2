# ETAPA 10 — Checkpoint · App de clientes

**Estado:** 10.00 y 10.01 aprobados; **10.02 — Acceso M01 implementado y listo para revisión**, aún sin aprobación; 10.03+ sin iniciar.
**Repositorio:** `restaurant-app-frontend-v2` · rama `develop` · base `2360f4304bf63355c9c16dafd3d6a45f5dc5d925` · cambios locales sin commit/push.

- **Alcance 10.02:** pantallas 01 Login, 02 Registro, 03 Invitado y 19 Cuenta; claro/oscuro; responsive con `SafeArea`/scroll; `staff_app` intacta.
- **Contratos exclusivos:** `POST /auth/register`, `/auth/login`, `/auth/guest`, `/auth/refresh` y `/auth/logout`; sin endpoints ni datos inventados.
- **Sesión:** almacenamiento seguro, validación estricta USER/GUEST, renovación, cierre local aun si falla la confirmación remota, expiración y guardas declarativas de rutas.
- **Cuenta:** identidad registrada/invitada diferenciada. El avatar abre la confirmación de cierre sin alterar la composición base de Figma.
- **Figma verificado:** nodos claro/oscuro 01 `172:4/70`, 02 `179:2/449`, 03 `179:19/466`, 19 `179:390/837`; viewport 390×844.
- **Comparación M01:** 8/8 aprobadas; similitud media por canal `0.973619–0.988852` (umbral `0.97`) y acuerdo tolerante `0.944387–0.973098` (umbral `0.94`); estimación **9.7/10**.
- **Pruebas:** `flutter analyze --no-pub` sin incidencias; `flutter test --no-pub` **121/121**; flujos de formularios, errores, registro, login, invitado, logout, expiración, guardas y responsive 320×568 al 140 %.
- **Android:** `flutter build apk --debug --no-pub` completado; no se detectó dispositivo Android ni AVD, por lo que no se afirmó arranque físico/emulado.
- **Límites verificados:** login muestra «Correo electrónico» porque el contrato acepta email, no celular; recuperación de contraseña permanece informativa y sin acción al no existir endpoint; el chrome del sistema no se duplica como widget.
- **Siguiente acción única:** revisión del usuario de 10.02. No avanzar a 10.03 ni realizar commit/push sin autorización expresa.
