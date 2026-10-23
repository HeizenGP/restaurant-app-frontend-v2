# Guía operativa de agentes — Restaurant App V2

`AGENTS.md` contiene las reglas permanentes; el checkpoint contiene el estado mutable. Esta guía solo resuelve consultas y coordinación excepcionales.

## Contexto bajo demanda

| Tarea | Contexto adicional |
|---|---|
| Slice Flutter | Skill local, RF/CA, contrato REST y referencia visual local de las pantallas afectadas. |
| Arquitectura transversal | Solo las secciones implicadas de `etapa-05.md` y los módulos tocados. |
| Duda de negocio | RF/RN/RNF puntual de ETAPA 03; ampliar a 01–02 solo si no basta. |
| Documento compartido | Archivo editado y su homólogo; comparar por hash/diff sin cargar ambas copias completas. |

## Flujo

1. Confirmar checkout, `develop`, cambios previos y bloque autorizado.
2. Formar una matriz mínima: pantalla o flujo → RF/CA → contrato → archivo → prueba.
3. Inspeccionar y modificar únicamente los archivos de esa matriz.
4. Ejecutar pruebas focales; reservar análisis y suite completa para el cierre del bloque.
5. Actualizar el checkpoint con estado, evidencia, resultados y próxima acción, sin bitácora extensa.

## Auditoría visual

- Guardar en `docs/referencias-visuales/` solo capturas o especificaciones verificadas proporcionadas por el usuario, indicando pantalla, tema, tamaño y procedencia.
- Capturar Flutter con el mismo viewport y comparar pantalla por pantalla en claro y oscuro.
- Registrar diferencias de espaciado, tipografía, tamaños, colores y componentes. Corregir únicamente las verificadas y autorizadas.
- Si falta el original, marcar la comparación como bloqueada. Un golden generado por Flutter no sustituye la referencia.

## Coordinación excepcional

- Mantener un escritor por archivo. Revisar ambos repositorios solo en tareas transversales.
- Sincronizar por hash únicamente la línea base compartida que cambió; no duplicar planes o bitácoras específicos.
- Validar una Skill solo cuando cambie; revisar la trazabilidad global solo al cerrar una etapa o una auditoría global.
- Usar archivos y Git locales primero; recurrir a servicios externos solo cuando la tarea y la evidencia lo exijan.
