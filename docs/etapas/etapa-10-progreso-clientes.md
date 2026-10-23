# ETAPA 10 — Checkpoint · App de clientes

**Estado:** 10.00 conservado; pantallas de 10.01–10.03 retiradas por decisión del usuario el 2026-10-23; reconstrucción pendiente desde 10.01. No iniciar 10.04.
**Base:** `restaurant-app-frontend-v2` / `develop` / `20c38e0`, alineada con `origin/develop` antes de los cambios locales. Sin commit ni push.

- **Retiro realizado:** 13 archivos de páginas, navegación visual y widgets específicos; 3 pruebas UI; 3 harness golden y 16 PNG golden. El router conserva nombres, rutas y redirección de sesión con un `Scaffold` vacío neutral, únicamente para mantener un esqueleto compilable.
- **Preservado:** design system central, temas, fuentes, SVG, configuración, contratos, dominio, controladores, adaptadores REST, almacenamiento seguro y pruebas no visuales. Arquitectura Hexagonal + Vertical Slicing y reglas de negocio sin cambios.
- **Trazabilidad pendiente de reconstrucción:** 10.01 es fundación visual; 10.02 cubre RF-M01-01/02 y CA-M01-01-01/02, CA-M01-02-01; 10.03 cubre RF-M02-01 y CA-M02-01-01.
- **Contrato M02 preservado:** `GET /api/v1/catalog/categories` y `GET /api/v1/catalog/categories/{category_id}/products`; no existe detalle por id ni descripción, imagen o stock exacto.
- **Referencia visual:** se conservan las 14 capturas Figma verificadas, claro/oscuro y 390×844, en [referencia local 10.01–10.03](../referencias-visuales/etapa-10-01-03.md). La comparación anterior queda como antecedente; no hay golden Flutter vigente ni afirmación de fidelidad.
- **Validación posterior al retiro:** `dart format` sin cambios; `flutter analyze --no-pub` sin incidencias; suite vigente `flutter test --no-pub` **58/58**. El anterior 96/96 corresponde a la implementación retirada y no es evidencia actual.
- **Próxima acción:** revisar este estado limpio y autorizar la reconstrucción de 10.01 contra Figma, pantalla por pantalla y en ambos temas. Mantener 10.02–10.10 pendientes hasta avanzar bloque a bloque.

“Contrato preservado” no significa “pantalla implementada”; las pantallas actuales están deliberadamente vacías hasta su reconstrucción.
