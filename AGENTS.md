# Restaurant App V2 — Reglas para Codex y AGY

## Estado y autoridad

- **ETAPAS 00–07 aprobadas expresamente por el usuario; ETAPA 08 con bloques 08.00–08.10 verificados técnicamente en el backend, pendiente de aprobación final del usuario; ETAPA 09 con diseño de clientes existente en Figma, pendiente de aprobación formal; ETAPA 10 con bloques 10.00–10.03 implementados y verificados en `customer_app`, pendientes de aprobación expresa; ETAPA 11 sin implementación.** No aprobar etapas por inferencia.
- Índice oficial: `docs/etapas/README.md`. Fuente de verdad de ETAPA 08: `docs/etapas/etapa-08.md`, `etapa-08-progreso.md` e `etapa-08-informe-auditoria.md` del backend en `develop`. Contexto y ejecución frontend: `docs/etapas/etapa-10.md`; planificación por bloques de clientes: `docs/etapas/etapa-10-hoja-ruta-clientes.md`; checkpoint mínimo: `docs/etapas/etapa-10-progreso-clientes.md`.
- Las ETAPAS 01–03 prevalecen como línea base de negocio y requisitos (40 RF / 48 CA). ETAPA 04 es línea base documental de casos de uso aprobada, pero no resuelve por sí sola RN-20/RN-21, RNF-08 ni comprobantes. Los permisos M07 quedaron aprobados en 08.09: Mozo registra servido; Administrador registra recojo, entrega y cierre; Super Administrador conserva acceso total.

## Carga selectiva

1. Leer este archivo, el índice y el documento de la etapa vigente.
2. Abrir solo los RF/RN/RNF y diagramas que afecten la tarea; no releer etapas completas si una referencia puntual basta.
3. **Skills técnicas bajo demanda:** activar `restaurant-fastapi-slice` solo para diseñar/revisar un caso de uso del backend (implementación desde ETAPA 08), y `restaurant-flutter-slice` solo para una funcionalidad Flutter (implementación desde ETAPA 10). Durante ETAPA 06, diseñar la BD sin activar Skills de implementación; en ETAPA 07, configurar herramientas sin adelantar funcionalidades. Cada Skill vive en `.agents/skills/<nombre>/SKILL.md` de su respectivo repositorio. No cargar ambas salvo revisión transversal.
4. Los documentos compartidos se leen en un repositorio y se comparan por hash/diff con el otro; no cargar dos copias idénticas al contexto.

## Alcance seguro

- Mantener los siete módulos M01–M07 y las decisiones aprobadas. Distinguir siempre heredado, propuesto y pendiente.
- ETAPA 07 es la base técnica aprobada. La ETAPA 08 implementó y auditó el backend, **no la interfaz**. Ejecutar ETAPA 10 solo por bloques autorizados de `customer_app`; 10.00–10.03 ya están implementados y verificados, pendientes de aprobación expresa. No adelantar `staff_app`, el bloque siguiente ni inventar pantallas, permisos o estados.
- Hacer cambios mínimos dentro de la etapa. No sobrescribir trabajo ajeno, registrar secretos, ejecutar commits/push/merge ni usar conectores externos sin necesidad.
- Mantener iguales los documentos de línea base realmente compartidos; los planes, bitácoras e informes exclusivos de backend no se duplican por sistema. Las Skills específicas viven solo en su repositorio.
- Usar archivos y Git locales primero. GitHub se reserva para operaciones remotas solicitadas; Figma para ETAPA 09; otros MCP requieren una necesidad vigente.

## Verificación y cierre

- Confirmar repositorio y rama `develop`, revisar cambios existentes y validar enlaces, trazabilidad y diferencias entre repositorios.
- Reportar archivos modificados, comprobaciones reales, riesgos y pendientes. No presentar inspección documental como prueba de ejecución.
- La aprobación de una etapa corresponde exclusivamente al usuario.

Procedimiento operativo ampliado: `docs/agentes/README.md`.
