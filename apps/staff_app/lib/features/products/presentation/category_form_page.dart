import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/components/admin_badge.dart';
import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_card.dart';
import '../../../core/design_system/components/admin_text_field.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../../core/layout/breakpoints.dart';
import '../application/catalog_controller.dart';
import '../domain/catalog_models.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    required this.catalogController,
    super.key,
  });

  final CatalogController catalogController;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();

  String? _editingCategoryId;
  final TextEditingController _renameCtrl = TextEditingController();

  String? _formError;

  final List<String> _suggestions = const <String>[
    'Dim Sum & Piqueos',
    'Chaufas & Wok',
    'Tallarines & Salteados',
    'Sopas & Cremas',
    'Bebidas & Coctelería',
    'Postres Orientales',
    'Especialidades del Chef',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _renameCtrl.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    setState(() => _formError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String name = _nameCtrl.text.trim();
    final bool ok = await widget.catalogController.createCategory(name);

    if (ok && mounted) {
      _nameCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría "$name" creada exitosamente.'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    } else if (mounted && widget.catalogController.errorMessage != null) {
      setState(() => _formError = widget.catalogController.errorMessage);
    }
  }

  Future<void> _submitRename(String categoryId) async {
    final String newName = _renameCtrl.text.trim();
    if (newName.isEmpty) return;

    final bool ok = await widget.catalogController.renameCategory(
      categoryId,
      newName,
    );

    if (ok && mounted) {
      setState(() => _editingCategoryId = null);
      _renameCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Categoría renombrada a "$newName".'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDesktop = Breakpoints.isDesktop(context);

    return ListenableBuilder(
      listenable: widget.catalogController,
      builder: (BuildContext context, _) {
        final List<Category> categories = widget.catalogController.categories;
        final List<Product> products = widget.catalogController.products;

        return Scaffold(
          backgroundColor: tokens.canvas,
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AsiaSpacing.xl,
              vertical: AsiaSpacing.lg,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(context, tokens),
                    const SizedBox(height: AsiaSpacing.xl),

                    if (_formError != null) ...<Widget>[
                      Container(
                        padding: const EdgeInsets.all(AsiaSpacing.md),
                        decoration: BoxDecoration(
                          color: tokens.error.withValues(alpha: 0.12),
                          borderRadius: AsiaRadii.md,
                          border: Border.all(
                            color: tokens.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(LucideIcons.alertTriangle,
                                color: tokens.error, size: 20),
                            const SizedBox(width: AsiaSpacing.md),
                            Expanded(
                              child: Text(
                                _formError!,
                                style: AsiaTypography.bodyMedium
                                    .copyWith(color: tokens.error),
                              ),
                            ),
                            IconButton(
                              icon: Icon(LucideIcons.x,
                                  size: 16, color: tokens.error),
                              onPressed: () =>
                                  setState(() => _formError = null),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.lg),
                    ],

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: _buildCreateCard(tokens),
                          ),
                          const SizedBox(width: AsiaSpacing.xl),
                          Expanded(
                            flex: 3,
                            child: _buildCategoryListCard(
                              tokens,
                              categories,
                              products,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _buildCreateCard(tokens),
                          const SizedBox(height: AsiaSpacing.xl),
                          _buildCategoryListCard(
                            tokens,
                            categories,
                            products,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AsiaThemeTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () => context.go('/products'),
          borderRadius: AsiaRadii.sm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  LucideIcons.arrowLeft,
                  size: 16,
                  color: tokens.brandCrimson,
                ),
                const SizedBox(width: AsiaSpacing.xs),
                Text(
                  'Volver a Carta & Productos',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.brandCrimson,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AsiaSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Categorías de la Carta',
                  style: AsiaTypography.displayMedium.copyWith(
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crea, renombra y organiza las secciones gastronómicas de KAIRO',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ],
            ),
            AdminButton(
              label: 'Ir a Productos',
              icon: LucideIcons.utensils,
              variant: AdminButtonVariant.secondary,
              size: AdminButtonSize.md,
              onPressed: () => context.go('/products'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateCard(AsiaThemeTokens tokens) {
    final String currentName = _nameCtrl.text.trim().isEmpty
        ? 'Nombre de la Categoría'
        : _nameCtrl.text.trim();

    return Form(
      key: _formKey,
      child: AdminCard(
        title: 'Nueva Sección en Menú',
        subtitle: 'Asigna un nombre descriptivo para agrupar platos en la carta',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AdminTextField(
              controller: _nameCtrl,
              label: 'Nombre de la Categoría *',
              hintText: 'Ej. Sopas & Dim Sum',
              prefixIcon: LucideIcons.folderPlus,
              autofocus: true,
              validator: (String? val) {
                if (val == null || val.trim().isEmpty) {
                  return 'El nombre de la categoría es requerido.';
                }
                if (val.trim().length < 2) {
                  return 'Debe tener al menos 2 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: AsiaSpacing.lg),

            // Live chip preview
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Vista Previa del Chip / Pestaña',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AsiaSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AsiaRadii.md,
                    border: Border.all(color: tokens.border),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.brandCrimson.withValues(alpha: 0.15),
                          borderRadius: AsiaRadii.pill,
                          border: Border.all(
                            color: tokens.brandCrimson.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              LucideIcons.check,
                              size: 14,
                              color: tokens.brandCrimson,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentName,
                              style: AsiaTypography.caption.copyWith(
                                color: tokens.brandCrimson,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AsiaSpacing.lg),

            // Quick Suggestions
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sugerencias Rápidas',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AsiaSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestions.map((String s) {
                    return InkWell(
                      onTap: () {
                        _nameCtrl.text = s;
                        _nameCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: s.length),
                        );
                      },
                      borderRadius: AsiaRadii.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tokens.cardElevated,
                          borderRadius: AsiaRadii.sm,
                          border: Border.all(color: tokens.border),
                        ),
                        child: Text(
                          '+ $s',
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: AsiaSpacing.xl),

            AdminButton(
              label: 'Crear Categoría',
              icon: LucideIcons.plus,
              variant: AdminButtonVariant.primary,
              size: AdminButtonSize.md,
              isLoading: widget.catalogController.isSaving,
              onPressed: _createCategory,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryListCard(
    AsiaThemeTokens tokens,
    List<Category> categories,
    List<Product> products,
  ) {
    return AdminCard(
      title: 'Categorías Registradas (${categories.length})',
      subtitle: 'Listado oficial de secciones activas en la carta gastronómica',
      child: categories.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AsiaSpacing.xxl),
                child: Column(
                  children: <Widget>[
                    Icon(LucideIcons.folder,
                        size: 40, color: tokens.textTertiary),
                    const SizedBox(height: AsiaSpacing.md),
                    Text(
                      'No hay categorías creadas aún.',
                      style: AsiaTypography.bodyMedium
                          .copyWith(color: tokens.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (BuildContext _, int _) =>
                  const SizedBox(height: AsiaSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final Category cat = categories[index];
                final int productCount =
                    products.where((Product p) => p.categoryId == cat.id).length;
                final bool isEditing = _editingCategoryId == cat.id;

                return Container(
                  padding: const EdgeInsets.all(AsiaSpacing.md),
                  decoration: BoxDecoration(
                    color: tokens.cardElevated,
                    borderRadius: AsiaRadii.md,
                    border: Border.all(
                      color: isEditing
                          ? tokens.brandCrimson
                          : tokens.borderSubtle,
                    ),
                  ),
                  child: isEditing
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: AdminTextField(
                                controller: _renameCtrl,
                                hintText: 'Nuevo nombre...',
                                autofocus: true,
                                onSubmitted: (_) => _submitRename(cat.id),
                              ),
                            ),
                            const SizedBox(width: AsiaSpacing.sm),
                            AdminButton(
                              label: 'Guardar',
                              size: AdminButtonSize.sm,
                              onPressed: () => _submitRename(cat.id),
                            ),
                            const SizedBox(width: AsiaSpacing.xs),
                            IconButton(
                              icon: const Icon(LucideIcons.x, size: 16),
                              onPressed: () =>
                                  setState(() => _editingCategoryId = null),
                            ),
                          ],
                        )
                      : Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: tokens.brandCrimson
                                    .withValues(alpha: 0.12),
                                borderRadius: AsiaRadii.sm,
                              ),
                              child: Icon(
                                LucideIcons.folder,
                                size: 20,
                                color: tokens.brandCrimson,
                              ),
                            ),
                            const SizedBox(width: AsiaSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    cat.name,
                                    style: AsiaTypography.headingMedium.copyWith(
                                      color: tokens.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$productCount ${productCount == 1 ? 'plato registrado' : 'platos registrados'}',
                                    style: AsiaTypography.caption.copyWith(
                                      color: tokens.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AdminBadge(
                              label: '$productCount platos',
                              variant: productCount > 0
                                  ? AdminBadgeVariant.neutral
                                  : AdminBadgeVariant.warning,
                            ),
                            const SizedBox(width: AsiaSpacing.sm),
                            IconButton(
                              icon: Icon(
                                LucideIcons.pencil,
                                size: 16,
                                color: tokens.textSecondary,
                              ),
                              tooltip: 'Renombrar categoría',
                              onPressed: () {
                                setState(() {
                                  _editingCategoryId = cat.id;
                                  _renameCtrl.text = cat.name;
                                });
                              },
                            ),
                          ],
                        ),
                );
              },
            ),
    );
  }
}
