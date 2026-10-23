# Restaurant App V2 — Frontend

Monorepo Flutter de Chifa ASIA. `customer_app` conserva la línea base técnica,
el design system y las capas no visuales de M01/M02. **10.01 — UI Foundation
está aprobada por el usuario (2026-10-23)** con componentes, navegación y
temas claro/oscuro reconstruidos; las pantallas de **10.02–10.03** siguen
pendientes. `staff_app` permanece en la línea base de ETAPA 07.

- `apps/customer_app`: Cliente e Invitado en Android.
- `apps/staff_app`: personal en Android y panel administrativo en Flutter Web.
- Configuración de API: `--dart-define=API_BASE_URL=<url-absoluta>`.

## Verificación

Ejecutar en cada aplicación:

```powershell
flutter pub get
flutter analyze
flutter test
```

Para comprobar el destino Web de `staff_app`:

```powershell
flutter build web --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

Para comprobar Android en cualquiera de las dos aplicaciones:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

La compilación Android requiere Flutter y un Android SDK configurado. En el
emulador Android, la API del host se alcanza normalmente mediante
`http://10.0.2.2:8000/api/v1`. Ese tráfico HTTP se permite solo en el variant
debug; los builds release conservan la política segura de Android y deben usar HTTPS.

- [Plan maestro de etapas 00–11](docs/etapas/README.md)
- [ETAPA 07 — configuración técnica aprobada](docs/etapas/etapa-07.md)
- [ETAPA 10 — contexto preparatorio de `customer_app`](docs/etapas/etapa-10.md)
- [ETAPA 10 — hoja de ruta de la app de clientes](docs/etapas/etapa-10-hoja-ruta-clientes.md)
- [Checkpoint compacto para Codex/AGY](docs/etapas/etapa-10-progreso-clientes.md)
- [Inventario Figma 01–20, claro y oscuro](docs/referencias-visuales/etapa-10-00-figma.md)
- [Guía para Codex y AGY](docs/agentes/README.md)

**Estado:** ETAPA 07 aprobada. ETAPA 08 verificada técnicamente en el backend y pendiente de aprobación final del usuario; ETAPA 09 tiene diseños de clientes existentes en Figma (pendientes de aprobación formal); ETAPA 10 tiene **10.00 aprobado expresamente por el usuario (2026-10-23)**, con ejecución Android real comprobada. **10.01 — UI Foundation aprobada expresamente por el usuario (2026-10-23)**, con 94/94 pruebas informadas por Codex y fidelidad de referencia estimada 9.6/10. La ejecución Android de 10.01 y la conectividad móvil–API siguen pendientes. **10.02 y posteriores no están aprobados ni autorizados**.
