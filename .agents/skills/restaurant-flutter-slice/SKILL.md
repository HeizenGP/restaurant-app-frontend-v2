---
name: restaurant-flutter-slice
description: Diseña, implementa o revisa un slice Flutter de Restaurant App V2 en customer_app o staff_app, con módulo, estado, permisos y contrato REST trazables. No usar para trabajo exclusivamente backend o para inventar pantallas y funciones sin RF.
---

# Slice Flutter de Restaurant App V2

## Contexto mínimo

Lee `AGENTS.md`, `docs/etapas/README.md` y las secciones Flutter/REST pertinentes de `docs/etapas/etapa-05.md`. Abre únicamente los RF/CA del módulo afectado. Los CU de ETAPA 04 están aprobados documentalmente; sus decisiones de permisos pendientes siguen abiertas.

## Procedimiento

1. Elige aplicación por actor: Cliente/Invitado en `customer_app`; Mozo, Cajero, Cocina, Administrador y Super Administrador en `staff_app`. Mantén el panel administrativo en Flutter Web dentro del mismo `staff_app`, sin crear una tercera aplicación.
2. Ubica el caso de uso dentro de `features/mXX_nombre/<verbo_objeto>/`. Separa presentación, aplicación y adaptador REST; conserva dominio Dart puro compartido dentro del módulo solo cuando sea estable.
3. No uses DTO en widgets ni importes infraestructura de otro slice. La composición de la app conecta puertos y adaptadores.
4. Modela estado unidireccional e inmutable y navegación declarativa por sesión/capacidad. Ocultar UI mejora experiencia, pero nunca sustituye autorización del servidor.
5. Trata el backend como fuente de verdad. Muestra éxito de una mutación solo tras confirmación; reutiliza `Idempotency-Key` en reintentos y traduce los códigos de error uniformes.
6. Comparte únicamente `foundation`, `rest_api`, `auth_session` y `design_system` hasta demostrar otra reutilización. No dupliques reglas del backend en Flutter.
7. Conserva pendientes: no asignes actores de recojo/delivery/cierre ni agregues pasarelas, mapas, SUNAT o logística.
8. Verifica controlador/caso de uso, mapeo REST, guardas y estados de error pertinentes. Reporta RF/RNF, aplicación elegida, archivos y pruebas reales.

No inicialices Flutter ni elijas/instales paquetes si la etapa vigente no lo autoriza.
