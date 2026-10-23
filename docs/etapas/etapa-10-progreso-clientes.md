# ETAPA 10 — Checkpoint · App de clientes

**Estado:** 10.00 y 10.01 aprobados; **10.02 — Acceso M01 implementado y listo para revisión**, aún sin aprobación; 10.03+ sin iniciar.
**Repositorio:** `restaurant-app-frontend-v2` · rama `develop` · base `89ef7d6bc178d8375b945a4cc4f1d25f2d099873` · cambios locales sin commit/push.

- **Alcance 10.02:** pantallas 01 Login, 02 Registro, 03 Invitado y 19 Cuenta; claro/oscuro; responsive con `SafeArea`/scroll; `staff_app` intacta.
- **Contratos exclusivos:** `POST /auth/register`, `/auth/login`, `/auth/guest`, `/auth/refresh` y `/auth/logout`; sin endpoints ni datos inventados.
- **Sesión:** almacenamiento seguro, validación estricta USER/GUEST, renovación, cierre local aun si falla la confirmación remota, expiración y guardas declarativas de rutas.
- **Cuenta:** identidad registrada/invitada diferenciada. El avatar abre la confirmación de cierre sin alterar la composición base de Figma.
- **Figma verificado:** nodos claro/oscuro 01 `172:4/70`, 02 `179:2/449`, 03 `179:19/466`, 19 `179:390/837`; viewport 390×844.
- **Comparación M01:** 8/8 aprobadas; similitud media por canal `0.973619–0.988852` (umbral `0.97`) y acuerdo tolerante `0.944387–0.973098` (umbral `0.94`); estimación **9.7/10**.
- **Última validación automatizada (previa al ajuste final de padding):** `flutter analyze --no-pub` sin incidencias; `flutter test --no-pub` **122/122**; las 8 comparaciones Figma a 390×844 permanecen aprobadas.
- **Android:** APK debug generado e instalado; arranque y capturas verificados en Motorola Edge 60 Fusion, Android 15 (1220×2712 físicos), sin bordes blancos en Login y con iconos de estado legibles en Invitado claro.
- **Ajuste pendiente de validación del usuario:** el contenido del Login admite hasta 432 px para conservar 28 px laterales también en el teléfono ancho; no se repitieron pruebas ni instalación por solicitud expresa.
- **Límites verificados:** login muestra «Correo electrónico» porque el contrato acepta email, no celular; recuperación de contraseña permanece informativa y sin acción al no existir endpoint; el chrome del sistema no se duplica como widget.
- **Siguiente acción única:** revisión del usuario de 10.02. No avanzar a 10.03 ni realizar commit/push sin autorización expresa.
