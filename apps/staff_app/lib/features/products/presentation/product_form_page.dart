import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../../core/network/image_upload_service.dart';
import '../application/catalog_controller.dart';
import '../domain/catalog_models.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    required this.catalogController,
    this.product,
    this.productId,
    super.key,
  });

  final CatalogController catalogController;
  final Product? product;
  final String? productId;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imgCtrl;

  String? _selectedCategoryId;
  bool _isAvailable = true;
  String? _formError;

  Uint8List? _localImageBytes;
  String? _pickedFileName;
  int? _pickedFileSize;
  bool _isUploadingImage = false;
  late final ImageUploadService _uploadService;
  final ImagePicker _imagePicker = ImagePicker();

  bool get isEdit => widget.product != null || widget.productId != null;

  Product? get resolvedProduct {
    if (widget.product != null) return widget.product;
    if (widget.productId != null) {
      return widget.catalogController.products.cast<Product?>().firstWhere(
            (Product? p) => p?.id == widget.productId,
            orElse: () => null,
          );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _uploadService = ImageUploadService(
      apiClient: widget.catalogController.repository.apiClient,
    );
    final Product? initial = resolvedProduct;

    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _priceCtrl = TextEditingController(
      text: initial != null ? initial.price.toStringAsFixed(2) : '',
    );
    _stockCtrl = TextEditingController(
      text: initial != null ? initial.stockQty.toString() : '50',
    );
    _descCtrl = TextEditingController(text: initial?.description ?? '');
    _imgCtrl = TextEditingController(text: initial?.imageUrl ?? '');

    _isAvailable = initial?.isAvailable ?? true;

    final List<Category> cats = widget.catalogController.categories;
    if (initial != null && cats.any((Category c) => c.id == initial.categoryId)) {
      _selectedCategoryId = initial.categoryId;
    } else if (cats.isNotEmpty) {
      _selectedCategoryId = cats.first.id;
    }

    _nameCtrl.addListener(() => setState(() {}));
    _priceCtrl.addListener(() => setState(() {}));
    _stockCtrl.addListener(() => setState(() {}));
    _descCtrl.addListener(() => setState(() {}));
    _imgCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _descCtrl.dispose();
    _imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (file == null) return;

      final Uint8List bytes = await file.readAsBytes();

      if (bytes.lengthInBytes > ImageUploadService.maxFileSizeBytes) {
        final double mb = bytes.lengthInBytes / (1024 * 1024);
        setState(() {
          _formError =
              'La imagen seleccionada pesa ${mb.toStringAsFixed(1)} MB y supera el límite de 10 MB. '
              'Por favor selecciona una foto más ligera o de menor resolución.';
        });
        return;
      }

      setState(() {
        _localImageBytes = bytes;
        _pickedFileName = file.name;
        _pickedFileSize = bytes.lengthInBytes;
        _isUploadingImage = true;
        _formError = null;
      });

      final String uploadedUrl = await _uploadService.uploadImage(
        bytes: bytes,
        filename: file.name,
      );

      if (mounted) {
        setState(() {
          _imgCtrl.text = uploadedUrl;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotografía subida al servidor y vinculada al plato con éxito.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _localImageBytes = null;
          _pickedFileName = null;
          _pickedFileSize = null;
          final String msg = e.toString().replaceFirst('Exception: ', '').trim();
          _formError = msg.isNotEmpty
              ? msg
              : 'No se pudo subir la imagen desde tu dispositivo. Puedes intentar de nuevo o ingresar un enlace manual.';
        });
      }
    }
  }

  void _clearImage() {
    setState(() {
      _localImageBytes = null;
      _pickedFileName = null;
      _pickedFileSize = null;
      _imgCtrl.clear();
    });
  }

  Future<void> _submit() async {
    setState(() => _formError = null);

    if (_isUploadingImage) {
      setState(() => _formError =
          'La fotografía todavía se está procesando y subiendo. Por favor espera a que termine antes de guardar.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      setState(() => _formError = 'Debes seleccionar una categoría para el producto.');
      return;
    }

    final double? price = double.tryParse(_priceCtrl.text.trim());
    if (price == null || price < 0) {
      setState(() => _formError = 'El precio debe ser un número válido mayor o igual a 0.');
      return;
    }

    final int stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    final Product? current = resolvedProduct;
    final bool success = await widget.catalogController.saveProduct(
      productId: current?.id,
      categoryId: _selectedCategoryId!,
      name: _nameCtrl.text.trim(),
      price: price,
      initialStock: stock,
      imageUrl: _imgCtrl.text.trim().isEmpty ? null : _imgCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      isAvailable: _isAvailable,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? 'Plato "${_nameCtrl.text.trim()}" actualizado correctamente.'
                : 'Plato "${_nameCtrl.text.trim()}" agregado a la carta.',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.go('/products');
    } else if (mounted && widget.catalogController.errorMessage != null) {
      setState(() => _formError = widget.catalogController.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDesktop = Breakpoints.isDesktop(context);
    final List<Category> categories = widget.catalogController.categories;

    final String selectedCatName = categories
        .cast<Category?>()
        .firstWhere((Category? c) => c?.id == _selectedCategoryId, orElse: () => null)
        ?.name ??
        'Sin categoría';

    return Form(
      key: _formKey,
      child: Scaffold(
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
                  // Breadcrumb & Action bar
                  _buildHeader(context, tokens),
                  const SizedBox(height: AsiaSpacing.xl),

                  // Error banner if any
                  if (_formError != null) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(AsiaSpacing.md),
                      decoration: BoxDecoration(
                        color: tokens.error.withValues(alpha: 0.12),
                        borderRadius: AsiaRadii.md,
                        border: Border.all(color: tokens.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(LucideIcons.alertTriangle, color: tokens.error, size: 20),
                          const SizedBox(width: AsiaSpacing.md),
                          Expanded(
                            child: Text(
                              _formError!,
                              style: AsiaTypography.bodyMedium.copyWith(color: tokens.error),
                            ),
                          ),
                          IconButton(
                            icon: Icon(LucideIcons.x, size: 16, color: tokens.error),
                            onPressed: () => setState(() => _formError = null),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AsiaSpacing.lg),
                  ],

                  // Main layout: 2 columns on desktop, 1 on mobile
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _buildGeneralInfoCard(tokens, categories),
                              const SizedBox(height: AsiaSpacing.xl),
                              _buildPricingInventoryCard(tokens),
                              const SizedBox(height: AsiaSpacing.xl),
                              _buildMediaCard(tokens),
                            ],
                          ),
                        ),
                        const SizedBox(width: AsiaSpacing.xl),
                        Expanded(
                          flex: 2,
                          child: _buildLivePreviewCard(tokens, selectedCatName),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildLivePreviewCard(tokens, selectedCatName),
                        const SizedBox(height: AsiaSpacing.xl),
                        _buildGeneralInfoCard(tokens, categories),
                        const SizedBox(height: AsiaSpacing.xl),
                        _buildPricingInventoryCard(tokens),
                        const SizedBox(height: AsiaSpacing.xl),
                        _buildMediaCard(tokens),
                      ],
                    ),
                  const SizedBox(height: AsiaSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsiaThemeTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Navigation button
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isEdit ? 'Editar Plato en Carta' : 'Nuevo Plato Gastronómico',
                    style: AsiaTypography.displayMedium.copyWith(
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEdit
                        ? 'Modifica las características, precio o estado del producto en la carta'
                        : 'Ingresa los detalles para publicar este plato en los canales de atención',
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                AdminButton(
                  label: 'Cancelar',
                  variant: AdminButtonVariant.secondary,
                  size: AdminButtonSize.md,
                  onPressed: () => context.go('/products'),
                ),
                const SizedBox(width: AsiaSpacing.md),
                AdminButton(
                  label: isEdit ? 'Guardar Cambios' : 'Publicar Plato',
                  icon: LucideIcons.save,
                  variant: AdminButtonVariant.primary,
                  size: AdminButtonSize.md,
                  isLoading: widget.catalogController.isSaving || _isUploadingImage,
                  onPressed: _isUploadingImage ? null : _submit,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard(
    AsiaThemeTokens tokens,
    List<Category> categories,
  ) {
    return AdminCard(
      title: 'Información General',
      subtitle: 'Identificación y descripción para el cliente y comandas de cocina',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AdminTextField(
            controller: _nameCtrl,
            label: 'Nombre del Plato *',
            hintText: 'Ej. Chaufa Especial de Mariscos al Wok',
            prefixIcon: LucideIcons.utensils,
            autofocus: !isEdit,
            validator: (String? val) {
              if (val == null || val.trim().isEmpty) {
                return 'El nombre del plato es obligatorio.';
              }
              if (val.trim().length < 2) {
                return 'El nombre debe contener al menos 2 caracteres.';
              }
              return null;
            },
          ),
          const SizedBox(height: AsiaSpacing.lg),

          // Category Selector with quick action
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Categoría de la Carta *',
                    style: AsiaTypography.caption.copyWith(
                      color: tokens.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () => context.go('/products/categories/new'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(LucideIcons.folderPlus, size: 14, color: tokens.brandCrimson),
                          const SizedBox(width: 4),
                          Text(
                            '+ Nueva Categoría',
                            style: AsiaTypography.caption.copyWith(
                              color: tokens.brandCrimson,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AsiaSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AsiaSpacing.md),
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AsiaRadii.md,
                  border: Border.all(color: tokens.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    dropdownColor: tokens.cardElevated,
                    hint: Text(
                      'Selecciona una categoría',
                      style: AsiaTypography.bodyMedium.copyWith(color: tokens.textTertiary),
                    ),
                    items: categories.map((Category cat) {
                      return DropdownMenuItem<String>(
                        value: cat.id,
                        child: Text(
                          cat.name,
                          style: AsiaTypography.bodyMedium.copyWith(color: tokens.textPrimary),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? val) {
                      if (val != null) {
                        setState(() => _selectedCategoryId = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.lg),

          AdminTextField(
            controller: _descCtrl,
            label: 'Descripción / Ingredientes Destacados',
            hintText:
                'Describe el plato, acompañamientos o preparación (ej. Salteado al wok a fuego alto con lomo fino, cebolla roja, tomate y sillao premium)...',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInventoryCard(AsiaThemeTokens tokens) {
    return AdminCard(
      title: 'Precio & Inventario',
      subtitle: 'Configuración comercial y control de existencias en tiempo real',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AdminTextField(
                  controller: _priceCtrl,
                  label: 'Precio de Venta (S/.) *',
                  hintText: '35.00',
                  prefixIcon: LucideIcons.coins,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (String? val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Ingresa un precio.';
                    }
                    final double? parsed = double.tryParse(val.trim());
                    if (parsed == null || parsed < 0) {
                      return 'Precio inválido.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AsiaSpacing.md),
              Expanded(
                child: AdminTextField(
                  controller: _stockCtrl,
                  label: 'Stock Disponible (unidades)',
                  hintText: '50',
                  prefixIcon: LucideIcons.boxes,
                  keyboardType: TextInputType.number,
                  validator: (String? val) {
                    if (val != null && val.isNotEmpty && int.tryParse(val.trim()) == null) {
                      return 'Debe ser un número entero.';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AsiaSpacing.lg),

          // Availability toggle tile
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _isAvailable
                        ? tokens.brandJade.withValues(alpha: 0.15)
                        : tokens.error.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isAvailable ? LucideIcons.check : LucideIcons.x,
                    size: 18,
                    color: _isAvailable ? tokens.brandJade : tokens.error,
                  ),
                ),
                const SizedBox(width: AsiaSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Disponible para venta al público',
                        style: AsiaTypography.headingMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isAvailable
                            ? 'El plato se encuentra visible y listo para ordenar en salón, app y delivery.'
                            : 'El plato se marcará como agotado/oculto temporalmente en todos los canales.',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  activeThumbColor: tokens.brandCrimson,
                  onChanged: (bool val) => setState(() => _isAvailable = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(AsiaThemeTokens tokens) {
    final bool hasImage =
        _localImageBytes != null || _imgCtrl.text.trim().isNotEmpty;
    final String currentUrl = _imgCtrl.text.trim();

    return AdminCard(
      title: 'Fotografía Gastronómica',
      subtitle:
          'Sube una imagen desde tu dispositivo o ingresa un enlace web',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Device upload box
          Container(
            padding: const EdgeInsets.all(AsiaSpacing.lg),
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AsiaRadii.lg,
              border: Border.all(
                color: hasImage
                    ? tokens.brandJade.withValues(alpha: 0.5)
                    : tokens.border,
                width: 1.5,
              ),
            ),
            child: hasImage
                ? Row(
                    children: <Widget>[
                      // Thumbnail
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: AsiaRadii.md,
                          border: Border.all(color: tokens.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _localImageBytes != null
                            ? Image.memory(
                                _localImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                currentUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  BuildContext _,
                                  Object __,
                                  StackTrace? ___,
                                ) =>
                                    Icon(
                                  LucideIcons.utensils,
                                  color: tokens.textTertiary,
                                ),
                              ),
                      ),
                      const SizedBox(width: AsiaSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                AdminBadge(
                                  label: _localImageBytes != null
                                      ? 'Foto del Dispositivo'
                                      : 'Enlace Web',
                                  variant: AdminBadgeVariant.success,
                                ),
                                if (_isUploadingImage) ...<Widget>[
                                  const SizedBox(width: AsiaSpacing.sm),
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pickedFileName != null
                                  ? '$_pickedFileName${_pickedFileSize != null ? ' (${(_pickedFileSize! / (1024 * 1024)).toStringAsFixed(1)} MB)' : ''}'
                                  : (currentUrl.length > 40
                                      ? '${currentUrl.substring(0, 37)}...'
                                      : currentUrl),
                              style: AsiaTypography.caption.copyWith(
                                color: tokens.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isUploadingImage
                                  ? 'Subiendo al servidor de KAIRO...'
                                  : 'Lista y vinculada al producto',
                              style: AsiaTypography.caption.copyWith(
                                color: tokens.textTertiary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AsiaSpacing.sm),
                      AdminButton(
                        label: 'Cambiar',
                        icon: LucideIcons.upload,
                        variant: AdminButtonVariant.secondary,
                        size: AdminButtonSize.sm,
                        isLoading: _isUploadingImage,
                        onPressed: _pickAndUploadImage,
                      ),
                      const SizedBox(width: AsiaSpacing.xs),
                      IconButton(
                        icon: Icon(
                          LucideIcons.trash2,
                          color: tokens.error,
                          size: 18,
                        ),
                        tooltip: 'Quitar imagen',
                        onPressed: _clearImage,
                      ),
                    ],
                  )
                : Column(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: tokens.brandCrimson.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.imagePlus,
                          size: 26,
                          color: tokens.brandCrimson,
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.md),
                      Text(
                        'Selecciona una foto desde tu dispositivo',
                        style: AsiaTypography.headingMedium.copyWith(
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Formatos compatibles: JPG, PNG, WEBP (Límite máx. 10 MB)',
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.md),
                      AdminButton(
                        label: 'Subir desde Dispositivo',
                        icon: LucideIcons.upload,
                        variant: AdminButtonVariant.primary,
                        size: AdminButtonSize.sm,
                        isLoading: _isUploadingImage,
                        onPressed: _pickAndUploadImage,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AsiaSpacing.lg),

          // Secondary Manual URL option
          AdminTextField(
            controller: _imgCtrl,
            label: 'O enlace web directo (Opcional)',
            hintText: 'https://images.unsplash.com/...',
            prefixIcon: LucideIcons.image,
            onChanged: (String _) {
              if (_localImageBytes != null) {
                setState(() => _localImageBytes = null);
              }
            },
          ),
          const SizedBox(height: AsiaSpacing.sm),
          Row(
            children: <Widget>[
              Icon(LucideIcons.info, size: 14, color: tokens.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Recomendación: usa fotos cuadradas (1:1) o panorámicas (16:9) con buena iluminación sobre fondo neutro.',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewCard(AsiaThemeTokens tokens, String categoryName) {
    final String name = _nameCtrl.text.trim().isEmpty
        ? 'Nombre del Plato'
        : _nameCtrl.text.trim();
    final double price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final int stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;
    final String desc = _descCtrl.text.trim().isEmpty
        ? 'Aquí se visualizará la descripción gastronómica y notas de ingredientes que los clientes apreciarán.'
        : _descCtrl.text.trim();
    final String imgUrl = _imgCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AdminCard(
          title: 'Vista Previa en Carta',
          subtitle:
              'Simulación visual de cómo se presenta este plato a los clientes',
          child: Container(
            decoration: BoxDecoration(
              color: tokens.cardElevated,
              borderRadius: AsiaRadii.lg,
              border: Border.all(
                color: tokens.brandCrimson.withValues(alpha: 0.25),
                width: 1.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Image or Placeholder
                Stack(
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _localImageBytes != null
                          ? Image.memory(
                              _localImageBytes!,
                              fit: BoxFit.cover,
                            )
                          : (imgUrl.isNotEmpty
                              ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    BuildContext context,
                                    Object error,
                                    StackTrace? stackTrace,
                                  ) =>
                                      _buildImagePlaceholder(tokens),
                                )
                              : _buildImagePlaceholder(tokens)),
                    ),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.65),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                CircularProgressIndicator(
                                  color: tokens.brandCrimson,
                                ),
                                const SizedBox(height: AsiaSpacing.sm),
                                Text(
                                  'Subiendo fotografía...',
                                  style: AsiaTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: AsiaRadii.sm,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          categoryName.toUpperCase(),
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.brandGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: AdminBadge(
                        label: _isAvailable ? 'En Carta' : 'Agotado',
                        variant: _isAvailable
                            ? AdminBadgeVariant.success
                            : AdminBadgeVariant.neutral,
                      ),
                    ),
                  ],
                ),

                // Dish details
                Padding(
                  padding: const EdgeInsets.all(AsiaSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              name,
                              style: AsiaTypography.headingLarge.copyWith(
                                color: tokens.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: AsiaSpacing.md),
                          Text(
                            'S/. ${price.toStringAsFixed(2)}',
                            style: AsiaTypography.headingLarge.copyWith(
                              color: tokens.brandCrimson,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AsiaSpacing.sm),
                      Text(
                        desc,
                        style: AsiaTypography.bodyMedium.copyWith(
                          color: tokens.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AsiaSpacing.md),
                      const Divider(height: 1),
                      const SizedBox(height: AsiaSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                LucideIcons.boxes,
                                size: 14,
                                color: stock <= 10 ? tokens.brandGold : tokens.brandJade,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$stock unidades en inventario',
                                style: AsiaTypography.caption.copyWith(
                                  color: stock <= 10 ? tokens.brandGold : tokens.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'KAIRO Gastronomía',
                            style: AsiaTypography.caption.copyWith(
                              color: tokens.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AsiaSpacing.lg),

        // Tips card
        AdminCard(
          padding: const EdgeInsets.all(AsiaSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: tokens.brandGold.withValues(alpha: 0.15),
                  borderRadius: AsiaRadii.sm,
                ),
                child: Icon(LucideIcons.sparkles, color: tokens.brandGold, size: 16),
              ),
              const SizedBox(width: AsiaSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Tip Gastronómico KAIRO',
                      style: AsiaTypography.headingMedium.copyWith(
                        color: tokens.brandGold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Los platos con fotografías nítidas y descripciones de textura e ingredientes obtienen hasta un 40% más de preferencia en la app.',
                      style: AsiaTypography.caption.copyWith(
                        color: tokens.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(AsiaThemeTokens tokens) {
    return Container(
      color: tokens.canvas,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(LucideIcons.utensils, size: 36, color: tokens.textTertiary),
            const SizedBox(height: 6),
            Text(
              'Sin imagen o enlace no disponible',
              style: AsiaTypography.caption.copyWith(color: tokens.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
