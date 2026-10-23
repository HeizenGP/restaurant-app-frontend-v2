# Restaurant App V2 — Reglas para agentes

## Autoridad y contexto

- El usuario aprueba etapas y cambios funcionales. No inferir aprobaciones ni alterar reglas de negocio.
- Fuentes: `docs/etapas/README.md` para el índice y `docs/etapas/etapa-10-progreso-clientes.md` para el estado mutable.
- Antes de actuar: confirmar repositorio, rama `develop` y cambios existentes. Leer solo este archivo, el checkpoint, el bloque activo, sus RF/CA y los archivos afectados. Ampliar contexto únicamente ante una contradicción o un dato faltante.
- Para trabajo Flutter, cargar `.agents/skills/restaurant-flutter-slice/SKILL.md` una vez por sesión. Consultar solo RF/CA, endpoint, archivos y referencia Figma de la pantalla activa; no cargar etapas completas, pantallas ajenas ni logs.

## Alcance seguro

- Mantener M01–M07 y la arquitectura Hexagonal + Vertical Slicing. Trabajar solo en la app y el bloque autorizados.
- Hacer cambios mínimos. Conservar temas, componentes y recursos existentes; no inventar pantallas, datos, estados, permisos ni contratos.
- No reinstalar dependencias, inicializar proyectos, registrar secretos ni usar servicios externos sin necesidad. No hacer commit, push o merge.
- Para fidelidad visual, usar solo referencias verificadas guardadas en `docs/referencias-visuales/`. Un golden de Flutter prueba regresión, no coincidencia con Figma.

## Verificación y cierre

1. Ejecutar pruebas focales durante el bloque; ejecutar análisis y suite completa únicamente al cerrarlo.
2. Comparar cada pantalla autorizada, en tema claro y oscuro, con su referencia local; registrar diferencias de espaciado, tipografía, tamaños, colores y componentes.
3. Corregir solo diferencias verificadas y autorizadas. Sin referencia original, declarar la comparación bloqueada y no afirmar fidelidad.
4. Mantener el checkpoint compacto con estado, evidencia, pruebas y siguiente acción. Responder brevemente, sin repetir contexto ni transcribir archivos o logs.

Procedimiento excepcional de coordinación: `docs/agentes/README.md`.
