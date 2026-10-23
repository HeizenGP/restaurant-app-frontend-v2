---
name: restaurant-flutter-slice
description: Usar al diseñar, implementar o revisar un slice Flutter/Dart de customer_app o staff_app de Chifa ASIA, incluyendo Flutter Web administrativo, estados, permisos y consumo REST. No usar para diseñar PostgreSQL, implementar backend ni inventar pantallas sin RF.
---

# Slice Flutter de Restaurant App V2

## Contexto mínimo

Sigue la carga selectiva de `AGENTS.md`: checkpoint, bloque activo, RF/CA y contrato REST implicados, más los archivos afectados. Abre arquitectura o etapas completas solo si falta una decisión necesaria.

## Procedimiento

1. Elige aplicación por actor: Cliente/Invitado en `customer_app`; Mozo, Cajero, Cocina, Administrador y Super Administrador en `staff_app`. Mantén el panel administrativo en Flutter Web dentro del mismo `staff_app`, sin crear una tercera aplicación.
2. Ubica el caso de uso dentro de `features/mXX_nombre/<verbo_objeto>/`. Separa presentación, aplicación y adaptador REST; conserva dominio Dart puro compartido dentro del módulo solo cuando sea estable.
3. No uses DTO en widgets ni importes infraestructura de otro slice. La composición de la app conecta puertos y adaptadores.
4. Modela estado unidireccional e inmutable y navegación declarativa por sesión/capacidad. Ocultar UI mejora experiencia, pero nunca sustituye autorización del servidor.
5. Trata el backend como fuente de verdad. Muestra éxito de una mutación solo tras confirmación; reutiliza `Idempotency-Key` en reintentos y traduce los códigos de error uniformes.
6. Reutiliza temas, componentes y recursos vigentes. Extrae código compartido solo cuando ambas apps lo reutilicen realmente; no dupliques reglas del backend.

## Verificación

- Ejecuta pruebas focales del controlador/caso de uso, adaptador REST, guardas, errores y widgets modificados. Corre análisis y suite completa al cerrar el bloque.
- Para UI, compara claro y oscuro contra referencias verificadas de `docs/referencias-visuales/`; los goldens propios solo detectan regresiones. Registra diferencias antes de corregirlas.
- No inicialices Flutter, reinstales dependencias ni agregues paquetes sin autorización.
