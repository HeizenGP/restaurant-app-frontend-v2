---
name: restaurant-flutter-slice
description: Usar para implementar o revisar un slice Flutter autorizado de Chifa ASIA (customer_app Android; staff_app Android/Web). No usar en backend, BD ni planificación.
---

# Flutter Slice · Chifa ASIA

## Contexto mínimo
Leer `AGENTS.md` y checkpoint una vez por sesión. Por bloque autorizado: solo RF/CA, contrato REST, archivos afectados y captura Figma de la pantalla activa. Ampliar por dudas concretas; no releer etapas, OpenAPI entero, otros módulos o las 20 pantallas.

## Implementación
1. Cliente/Invitado → `customer_app`; personal + panel Web → `staff_app`. No crear tercera app.
2. Organizar `features/mXX_modulo/<caso_de_uso>/`: dominio Dart puro, aplicación sin widgets, infraestructura REST; enlazar por puertos en la composición.
3. Estado unidireccional e inmutable; navegación según sesión/permiso. El backend autoriza. No usar DTO REST directamente en widgets.
4. Reutilizar temas/componentes; no inventar datos, endpoints, permisos ni acciones. Confirmar mutaciones antes de mostrar éxito; preservar `Idempotency-Key` en reintentos de la misma operación.

## Fidelidad visual
- Comparar **una pantalla** y ambos temas contra Figma verificado en `docs/referencias-visuales/`. Capturar Flutter con igual viewport (referencia 390×844) y revisar layout, dimensiones, espaciado, fuentes, colores, iconos y scroll.
- Registrar diferencias específicas antes de modificar. Un golden Flutter prueba regresión, **no** igualdad con Figma.
- Si falta referencia o existe conflicto con el backend, documentar bloqueo; no improvisar.

## Verificación y entrega
Pruebas focales primero; `flutter analyze` y suite completa al cerrar bloque. Ejecutar en Android si procede. Informar en pocas líneas: cambios, pruebas reales, discrepancias, pendientes y próximo paso. Sin logs extensos, dependencias nuevas ni commit/push sin permiso.
