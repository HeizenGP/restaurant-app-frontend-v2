# ETAPA 10 — Checkpoint · App de clientes

**Estado:** **10.00 y 10.01 APROBADOS expresamente por el usuario (2026-10-23)**; 10.02 y posteriores pendientes, sin autorización para avanzar.
**Repositorio:** `restaurant-app-frontend-v2` · rama `develop` · implementación 10.01 auditada en `acd85f1`.

- **10.01 implementado:** tokens de UI, temas claro/oscuro, Lucide, componentes compartidos, estados loading/empty/error, navegación por cuatro pestañas y Perfil adaptable; arquitectura Hexagonal + Vertical Slicing conservada. `staff_app` sin cambios.
- **Correcciones verificadas en código:** Inicio/Catálogo/Pedidos operativos sin datos ficticios; datos de referencia solo en fixtures de pruebas. Perfil con `SafeArea`, scroll y restricciones flexibles; sesiones registrada e invitada diferenciadas mediante estado de sesión.
- **Figma:** referencia oficial de 20 pantallas por tema; para 10.01, capturas 08/09/15/19/20 en claro y oscuro (390×844). Comparador con 10 fixtures: similitud mínima reportada 0.9736, acuerdo tolerante mínimo 0.9444; estimación de fidelidad de referencia **9.6/10**. Los estados operativos vacíos no tienen comparativa directa equivalente en Figma.
- **Pruebas de Codex:** `flutter analyze --no-pub` sin incidencias, **94/94** pruebas reportadas, APK debug compilado; pruebas responsive documentadas a 320×568 (140 %), 390×844 (200 %) y 600×960. Sin CI GitHub independiente para este commit.
- **Observaciones sin bloquear la aprobación:** mensajes de estados vacíos deben evitar insinuar consulta de backend inexistente; alinear cualquier README pendiente; validar 10.01 con `flutter run` en el Motorola Edge 60 Fusion. El arranque Android confirmado anteriormente corresponde a 10.00, no a esta versión.
- **Red:** conectividad real Motorola→FastAPI aún sin comprobar; `10.0.2.2` corresponde al emulador, no al teléfono físico.
- **Próxima acción:** esperar autorización expresa para **10.02 — Acceso M01**, usando Figma como fuente visual. No iniciar 10.03+, `staff_app`, ni cambiar requisitos o contratos sin autorización.
