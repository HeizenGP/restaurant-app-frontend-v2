# Restaurant App V2 — Reglas para agentes

## Autoridad y contexto

- El usuario aprueba etapas y cambios funcionales. No inferir aprobaciones ni alterar reglas de negocio.
- Fuentes: `docs/etapas/README.md` para el índice y `docs/etapas/etapa-10-progreso-clientes.md` para el estado mutable.
- Antes de actuar: confirmar repositorio, rama `develop` y cambios existentes. Leer este archivo, el checkpoint y los archivos afectados.
- Para el desarrollo visual y técnico de Flutter, aplicar los 8 skills instalados:
  - `.agents/skills/flutter-improve-design/SKILL.md`: Auditoría, revisión heurística y criterios avanzados de UI/UX para interfaces móviles.
  - `.agents/skills/flutter-custom-design-system/SKILL.md`: Tokens de diseño atómicos (`AsiaPalette`, `AsiaColors`, `AsiaTypography`, `AsiaRadii`), ThemeExtension y componentes de sistema.
  - `.agents/skills/flutter-build-responsive-layout/SKILL.md`: Adaptabilidad y ergonomía en layouts móviles y pantallas amplias (`MediaQuery.sizeOf`, `LayoutBuilder`, `SafeArea`).
  - `.agents/skills/flutter-animation/SKILL.md`: Animaciones implícitas, micro-interacciones interactivas, transiciones fluidas y curvas naturales.
  - `.agents/skills/flutter-ui-design/SKILL.md`: Dirección de arte, identidad visual del producto, jerarquía visual, composición de pantallas y estados completos.
  - `.agents/skills/flutter-ui-patterns/SKILL.md`: Arquitectura de widgets declarativos, separación de responsabilidades, límites de estado UI y manejo robusto de formularios.
  - `.agents/skills/flutter-navigation/SKILL.md`: Enrutamiento declarativo (GoRouter), navegación anidada por tabs/shells, deep links y back-stack determinista.
  - `.agents/skills/flutter-accessibility/SKILL.md`: Accesibilidad semántica, soporte a lectores de pantalla, contraste cromático, escalabilidad tipográfica y áreas táctiles ergonómicas.

## Alcance seguro

- Mantener M01–M07 y la arquitectura Hexagonal + Vertical Slicing. Trabajar únicamente en `customer_app`, sin modificar `staff_app`.
- Preservar intactas las funcionalidades, contratos REST, endpoints, modelos de dominio, validaciones y reglas de negocio existentes.
- Libertad de rediseño visual: modernizar paleta de colores, tipografías, iconografía, componentes, navegación y distribución espacial hacia una estética premium, minimalista, elegante, moderna y profesional.
- No reinstalar dependencias innecesarias, no registrar secretos ni usar servicios externos. No hacer commit ni push.

## Verificación y cierre

1. Ejecutar pruebas focales durante la implementación; ejecutar `flutter analyze` y suite completa de pruebas (`flutter test`) al cerrar el bloque.
2. Garantizar fidelidad y contraste en ambos temas (claro y oscuro).
3. Mantener el checkpoint compacto con estado, evidencia, pruebas y siguiente acción. Responder brevemente, sin repetir contexto ni transcribir archivos o logs.

Procedimiento excepcional de coordinación: `docs/agentes/README.md`.
