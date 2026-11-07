import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../core/design_system/design_system.dart';
import '../../m01_access/profile/domain/profile_models.dart';
import '../application/location_delivery_controller.dart';
import '../domain/location_models.dart';
import '../infrastructure/location_service.dart';
import 'kairo_map_style.dart';

part 'map_location_picker_layout.dart';

class MapLocationPickerPage extends StatefulWidget {
  const MapLocationPickerPage({
    required this.controller,
    this.initialPosition,
    this.addressToEdit,
    this.onAddressSaved,
    this.onBack,
    super.key,
  });

  final LocationDeliveryController controller;
  final ll.LatLng? initialPosition;
  final CustomerAddress? addressToEdit;
  final void Function(CustomerAddress address)? onAddressSaved;
  final VoidCallback? onBack;

  @override
  State<MapLocationPickerPage> createState() => _MapLocationPickerPageState();
}

class _MapLocationPickerPageState extends State<MapLocationPickerPage>
    with SingleTickerProviderStateMixin {
  MapboxMap? _mapboxMap;
  late final AnimationController _pinAnimController;
  late final Animation<double> _pinElevationAnim;

  Timer? _debounceTimer;
  Timer? _searchDebounce;
  ll.LatLng _currentCenter = LocationService.defaultTarapotoLocation;
  GeocodedAddress? _detectedAddress;
  DeliveryZoneQuote? _zoneQuote;
  bool _isMoving = false;
  bool _isLoadingAddress = false;

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _referenceCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _referenceFocus = FocusNode();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  List<GeocodedAddress> _searchResults = <GeocodedAddress>[];
  bool _isSearching = false;
  String? _searchError;
  String? _mapLoadError;
  String? _geocodeError;
  KairoMapLayer _mapLayer = KairoMapLayer.standard;
  bool? _lastThemeIsDark;
  CameraOptions? _cameraBeforeStyleChange;
  int _reverseRequestId = 0;
  int _searchRequestId = 0;
  double _sheetExtent = 0.30;
  bool _isRecoveringSatelliteLimit = false;

  bool get _isSatellite => _mapLayer == KairoMapLayer.satellite;

  @override
  void initState() {
    super.initState();

    if (widget.addressToEdit?.hasCoordinates == true) {
      _currentCenter = ll.LatLng(
        widget.addressToEdit!.latitude!,
        widget.addressToEdit!.longitude!,
      );
    } else if (widget.initialPosition != null) {
      _currentCenter = widget.initialPosition!;
    } else if (widget.controller.selectedAddress?.hasCoordinates == true) {
      _currentCenter = ll.LatLng(
        widget.controller.selectedAddress!.latitude!,
        widget.controller.selectedAddress!.longitude!,
      );
    } else {
      _currentCenter = LocationService.defaultTarapotoLocation;
    }

    _referenceCtrl.text = widget.addressToEdit?.reference ?? '';

    _pinAnimController = AnimationController(
      vsync: this,
      duration: AsiaMotion.standard,
    );

    _pinElevationAnim = Tween<double>(begin: 0.0, end: -9.0).animate(
      CurvedAnimation(parent: _pinAnimController, curve: AsiaMotion.emphasized),
    );

    widget.controller.addListener(_onControllerChanged);
    _searchFocus.addListener(_onSearchFocusChanged);
    _referenceFocus.addListener(_onReferenceFocusChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reverseGeocodeCenter(_currentCenter);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool isDark = context.asiaTheme.isDark;
    if (_lastThemeIsDark == isDark) return;
    _lastThemeIsDark = isDark;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_applyMapStyleProfile());
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchDebounce?.cancel();
    _reverseRequestId++;
    _searchRequestId++;
    widget.controller.removeListener(_onControllerChanged);
    _searchFocus.removeListener(_onSearchFocusChanged);
    _referenceFocus.removeListener(_onReferenceFocusChanged);
    _pinAnimController.dispose();
    _sheetController.dispose();
    _searchCtrl.dispose();
    _referenceCtrl.dispose();
    _searchFocus.dispose();
    _referenceFocus.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _updateSheetExtent(double extent) {
    if (!mounted || (_sheetExtent - extent).abs() <= 0.004) return;
    setState(() => _sheetExtent = extent);
  }

  Future<void> _retryMapStyle() async {
    if (mounted) setState(() => _mapLoadError = null);
    await _mapboxMap?.setStyleURI(_resolvedMapStyle.styleUri);
  }

  void _onSearchFocusChanged() {
    if (mounted) setState(() {});
  }

  void _onReferenceFocusChanged() {
    if (!mounted) return;
    setState(() {});
    if (_referenceFocus.hasFocus && _sheetController.isAttached) {
      final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
      unawaited(
        _sheetController.animateTo(
          0.68,
          duration: reduceMotion ? Duration.zero : AsiaMotion.standard,
          curve: AsiaMotion.emphasized,
        ),
      );
    }
  }

  KairoMapStyle get _resolvedMapStyle => KairoMapStyle.resolve(
    layer: _mapLayer,
    isDark: _lastThemeIsDark ?? false,
  );

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;

    unawaited(
      mapboxMap.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(
              _currentCenter.longitude,
              _currentCenter.latitude,
            ),
          ),
          zoom: 16.2,
        ),
      ),
    );

    // Los ornamentos se mantienen visibles y fuera de la hoja inferior.
    unawaited(
      mapboxMap.logo.updateSettings(
        LogoSettings(marginBottom: 188, marginLeft: 12),
      ),
    );
    unawaited(
      mapboxMap.attribution.updateSettings(
        AttributionSettings(marginBottom: 188, marginRight: 12),
      ),
    );
    unawaited(
      mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
    );
    unawaited(
      mapboxMap.compass.updateSettings(CompassSettings(enabled: false)),
    );
    unawaited(_applyMapStyleProfile());
  }

  Future<void> _applyMapStyleProfile() async {
    final MapboxMap? map = _mapboxMap;
    if (map == null) return;

    try {
      await map.setStyleImportConfigProperties(
        'basemap',
        _resolvedMapStyle.importConfig,
      );
      if (!mounted) return;
      setState(() => _mapLoadError = null);
    } catch (error) {
      debugPrint('Mapbox Standard configuration error: $error');
      if (mounted) {
        setState(() {
          _mapLoadError =
              'El mapa no pudo aplicar el estilo visual. Puedes reintentar.';
        });
      }
    }
  }

  Future<void> _onStyleLoaded(StyleLoadedEventData event) async {
    await _applyMapStyleProfile();
    final CameraOptions? camera = _cameraBeforeStyleChange;
    if (camera != null && _mapboxMap != null) {
      _cameraBeforeStyleChange = null;
      await _mapboxMap!.setCamera(camera);
    }
  }

  void _onMapLoadError(MapLoadingErrorEventData event) {
    debugPrint('Mapbox load error (${event.type.name}): ${event.message}');
    if (_isSatellite &&
        KairoMapStyle.isSatelliteRateLimitError(event.type, event.message)) {
      unawaited(_recoverFromSatelliteRateLimit());
      return;
    }
    if (mounted && KairoMapStyle.isBlockingLoadError(event.type)) {
      setState(() {
        _mapLoadError =
            'No pudimos cargar el mapa base. Revisa tu conexión y reintenta.';
      });
    }
  }

  Future<void> _recoverFromSatelliteRateLimit() async {
    if (_isRecoveringSatelliteLimit || !mounted) return;
    _isRecoveringSatelliteLimit = true;
    final MapboxMap? map = _mapboxMap;

    try {
      if (map != null) {
        final CameraState camera = await map.getCameraState();
        _cameraBeforeStyleChange = CameraOptions(
          center: camera.center,
          padding: camera.padding,
          zoom: camera.zoom,
          bearing: camera.bearing,
          pitch: camera.pitch,
        );
      }
      if (!mounted) return;
      setState(() => _mapLayer = KairoMapLayer.standard);
      await map?.setStyleURI(_resolvedMapStyle.styleUri);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'La vista satelital alcanzó temporalmente el límite del '
              'proveedor. Mostramos el mapa de calles.',
            ),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
    } catch (error) {
      debugPrint('Satellite fallback error: $error');
    } finally {
      _isRecoveringSatelliteLimit = false;
    }
  }

  void _onMapLoaded(MapLoadedEventData event) {
    if (mounted && _mapLoadError != null) {
      setState(() => _mapLoadError = null);
    }
  }

  void _onCameraChanged(CameraChangedEventData event) {
    if (!_isMoving) {
      setState(() => _isMoving = true);
      if (MediaQuery.disableAnimationsOf(context)) {
        _pinAnimController.value = 1;
      } else {
        unawaited(_pinAnimController.forward());
      }
    }
  }

  void _onMapIdle(MapIdleEventData event) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 420), () async {
      if (!mounted || _mapboxMap == null) return;
      final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
      try {
        final CameraState state = await _mapboxMap!.getCameraState();
        final num lon = state.center.coordinates.lng;
        final num lat = state.center.coordinates.lat;
        final ll.LatLng center = ll.LatLng(lat.toDouble(), lon.toDouble());

        setState(() {
          _isMoving = false;
          _currentCenter = center;
        });
        if (reduceMotion) {
          _pinAnimController.value = 0;
        } else {
          unawaited(_pinAnimController.reverse());
        }
        unawaited(_reverseGeocodeCenter(center));
      } catch (e) {
        debugPrint('Mapbox getCameraState error: $e');
        if (mounted) {
          setState(() => _isMoving = false);
          if (reduceMotion) {
            _pinAnimController.value = 0;
          } else {
            unawaited(_pinAnimController.reverse());
          }
        }
      }
    });
  }

  Future<void> _reverseGeocodeCenter(ll.LatLng center) async {
    final int requestId = ++_reverseRequestId;
    if (mounted) {
      setState(() {
        _isLoadingAddress = true;
        _geocodeError = null;
      });
    }

    try {
      final Future<GeocodedAddress> addressFuture = widget.controller
          .reverseGeocode(center.latitude, center.longitude);
      final Future<DeliveryZoneQuote> quoteFuture = widget.controller.checkZone(
        center.latitude,
        center.longitude,
      );
      final GeocodedAddress address = await addressFuture;
      final DeliveryZoneQuote quote = await quoteFuture;

      if (!mounted || requestId != _reverseRequestId) return;
      setState(() {
        _detectedAddress = address;
        _zoneQuote = quote;
        _isLoadingAddress = false;
        _geocodeError = address.hasStreet ? null : 'No encontramos el nombre exacto de la vía. Mueve el mapa o añade una referencia.';
      });
    } catch (error) {
      debugPrint('Reverse geocoding error: $error');
      if (!mounted || requestId != _reverseRequestId) return;
      setState(() {
        _isLoadingAddress = false;
        _geocodeError = 'No pudimos identificar la dirección. Revisa tu conexión e inténtalo otra vez.';
      });
    }
  }

  Future<void> _onLocateGps() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final ll.LatLng? pos = await widget.controller.locateCurrentGps();
    if (pos != null && mounted) {
      _currentCenter = pos;
      if (_mapboxMap != null) {
        await _mapboxMap!.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(pos.longitude, pos.latitude)),
            zoom: 16.5,
          ),
          MapAnimationOptions(duration: reduceMotion ? 0 : 650),
        );
      }
      await HapticFeedback.selectionClick();
      unawaited(_reverseGeocodeCenter(pos));
    } else if (mounted) {
      setState(() {
        _geocodeError = 'No pudimos acceder al GPS. Activa la ubicación y revisa el permiso de KAIRO.';
      });
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> _zoomIn() async {
    if (_mapboxMap == null) return;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    try {
      final CameraState state = await _mapboxMap!.getCameraState();
      final double currentZoom = state.zoom;
      final double nextZoom = (currentZoom + 1.0).clamp(10.0, 20.0);
      await _mapboxMap!.flyTo(
        CameraOptions(zoom: nextZoom),
        MapAnimationOptions(duration: reduceMotion ? 0 : 220),
      );
    } catch (_) {}
  }

  Future<void> _zoomOut() async {
    if (_mapboxMap == null) return;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    try {
      final CameraState state = await _mapboxMap!.getCameraState();
      final double currentZoom = state.zoom;
      final double nextZoom = (currentZoom - 1.0).clamp(10.0, 20.0);
      await _mapboxMap!.flyTo(
        CameraOptions(zoom: nextZoom),
        MapAnimationOptions(duration: reduceMotion ? 0 : 220),
      );
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final int requestId = ++_searchRequestId;
    final String clean = query.trim();
    if (clean.length < 2) {
      setState(() {
        _searchResults = <GeocodedAddress>[];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 380), () async {
      try {
        final List<GeocodedAddress> results = await widget.controller
            .searchAddresses(
              clean,
              proximityLat: _currentCenter.latitude,
              proximityLon: _currentCenter.longitude,
            );
        if (!mounted || requestId != _searchRequestId) return;
        setState(() {
          _searchResults = results;
          _isSearching = false;
          _searchError = results.isEmpty
              ? 'No encontramos coincidencias. Prueba con calle y distrito.'
              : null;
        });
      } catch (error) {
        debugPrint('Address search error: $error');
        if (!mounted || requestId != _searchRequestId) return;
        setState(() {
          _searchResults = <GeocodedAddress>[];
          _isSearching = false;
          _searchError = 'No pudimos buscar direcciones. Revisa tu conexión y vuelve a intentar.';
        });
      }
    });
  }

  Future<void> _selectSearchResult(GeocodedAddress result) async {
    _searchRequestId++;
    _searchCtrl.clear();
    _searchFocus.unfocus();
    final ll.LatLng target = ll.LatLng(result.latitude, result.longitude);
    setState(() {
      _searchResults = <GeocodedAddress>[];
      _searchError = null;
      _detectedAddress = result;
      _currentCenter = target;
    });

    if (_mapboxMap != null) {
      await _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(result.longitude, result.latitude),
          ),
          zoom: 16.5,
        ),
        MapAnimationOptions(
          duration: MediaQuery.disableAnimationsOf(context) ? 0 : 650,
        ),
      );
    }
    await HapticFeedback.selectionClick();
    unawaited(_reverseGeocodeCenter(target));
  }

  void _showConfirmDetailsSheet(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final AsiaTheme theme = context.asiaTheme;
    final NavigatorState navigator = Navigator.of(context);

    final CustomerAddress? edit = widget.addressToEdit;
    String selectedLabel = edit?.label ?? 'Casa';
    if (selectedLabel != 'Casa' && selectedLabel != 'Trabajo') {
      selectedLabel = 'Otro';
    }

    final TextEditingController customLabelCtrl = TextEditingController(
      text: (edit != null && edit.label != 'Casa' && edit.label != 'Trabajo')
          ? edit.label
          : '',
    );

    // Initial address prefilled: either existing address, detected readable street, or formatted
    final String initialAddr =
        edit?.address ??
        (_detectedAddress?.readableStreet.isNotEmpty == true
            ? _detectedAddress!.readableStreet
            : (_detectedAddress?.address ?? ''));

    final TextEditingController addressCtrl = TextEditingController(
      text: initialAddr,
    );
    final TextEditingController dptoCtrl = TextEditingController(
      text: edit?.department ?? '',
    );
    final TextEditingController refCtrl = TextEditingController(
      text: _referenceCtrl.text.trim().isNotEmpty
          ? _referenceCtrl.text.trim()
          : (edit?.reference ?? ''),
    );
    final TextEditingController instructionsCtrl = TextEditingController(
      text: edit?.deliveryInstructions ?? '',
    );
    final TextEditingController phoneCtrl = TextEditingController(
      text: edit?.recipientPhone ?? '',
    );

    bool makeDefault =
        edit?.isDefault ?? (widget.controller.savedAddresses.isEmpty);

    final Future<void> sheetFuture = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final String areaSubtitle =
                _detectedAddress?.readableArea ?? 'Tarapoto, San Martín';

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Header
                    Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.brandCrimson.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.mapPin,
                            color: theme.brandCrimson,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                edit != null
                                    ? 'Editar dirección'
                                    : 'Guardar dirección',
                                style: AsiaTypography.titleMedium,
                              ),
                              Text(
                                'Confirma o ajusta los detalles de entrega en KAIRO',
                                style: AsiaTypography.bodySmall.copyWith(
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Label type chips (Casa, Trabajo, Otro)
                    Text(
                      'Tipo de dirección',
                      style: AsiaTypography.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        _buildLabelChip(
                          label: 'Casa',
                          icon: LucideIcons.home,
                          isSelected: selectedLabel == 'Casa',
                          onTap: () {
                            setModalState(() => selectedLabel = 'Casa');
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildLabelChip(
                          label: 'Trabajo',
                          icon: LucideIcons.briefcase,
                          isSelected: selectedLabel == 'Trabajo',
                          onTap: () {
                            setModalState(() => selectedLabel = 'Trabajo');
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildLabelChip(
                          label: 'Otro',
                          icon: LucideIcons.mapPin,
                          isSelected: selectedLabel == 'Otro',
                          onTap: () {
                            setModalState(() => selectedLabel = 'Otro');
                          },
                        ),
                      ],
                    ),

                    if (selectedLabel == 'Otro') ...<Widget>[
                      const SizedBox(height: 12),
                      AsiaTextField(
                        controller: customLabelCtrl,
                        label:
                            'Nombre personalizado (ej. Pareja, Playa, Estudio)',
                        prefixIcon: LucideIcons.tag,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Street address textfield
                    AsiaTextField(
                      controller: addressCtrl,
                      label: 'Dirección (Calle, Avenida, Jirón)',
                      prefixIcon: LucideIcons.mapPin,
                    ),

                    // Detected Area tag (District, Province, Department)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            LucideIcons.compass,
                            size: 13,
                            color: theme.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Zona detectada: $areaSubtitle',
                              style: AsiaTypography.bodySmall.copyWith(
                                color: theme.textSecondary,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Housing / interior number & Contact Phone
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: AsiaTextField(
                            controller: dptoCtrl,
                            label: 'N° vivienda / Dpto / Int',
                            prefixIcon: LucideIcons.building,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AsiaTextField(
                            controller: phoneCtrl,
                            label: 'Teléfono de contacto',
                            prefixIcon: LucideIcons.phone,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Reference field
                    AsiaTextField(
                      controller: refCtrl,
                      label: 'Referencia (ej. Frente al parque, fachada roja)',
                      prefixIcon: LucideIcons.info,
                    ),
                    const SizedBox(height: 14),

                    // Delivery instructions field
                    AsiaTextField(
                      controller: instructionsCtrl,
                      label: 'Instrucciones para el repartidor (Opcional)',
                      hintText: 'Ej. Dejar en recepción, tocar timbre 3B, llamar al llegar',
                      prefixIcon: LucideIcons.messageSquare,
                    ),
                    const SizedBox(height: 16),

                    // Checkbox predeterminada
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: makeDefault,
                          activeColor: theme.brandCrimson,
                          onChanged: (bool? val) {
                            setModalState(() => makeDefault = val ?? false);
                          },
                        ),
                        Expanded(
                          child: Text(
                            'Establecer como dirección de entrega principal',
                            style: AsiaTypography.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Action button: Guardar dirección
                    AsiaButton(
                      label: edit != null
                          ? 'Actualizar dirección'
                          : 'Guardar dirección',
                      leading: LucideIcons.check,
                      onPressed: () async {
                        final String finalAddr = addressCtrl.text.trim();
                        if (finalAddr.isEmpty) return;

                        final String finalLabel =
                            selectedLabel == 'Otro' &&
                                customLabelCtrl.text.trim().isNotEmpty
                            ? customLabelCtrl.text.trim()
                            : selectedLabel;

                        Navigator.of(sheetCtx).pop();

                        CustomerAddress? saved;
                        if (edit != null) {
                          saved = await widget.controller.updateExistingAddress(
                            id: edit.id,
                            label: finalLabel,
                            address: finalAddr,
                            latitude: _currentCenter.latitude,
                            longitude: _currentCenter.longitude,
                            department: dptoCtrl.text.trim().isNotEmpty
                                ? dptoCtrl.text.trim()
                                : null,
                            reference: refCtrl.text.trim().isNotEmpty
                                ? refCtrl.text.trim()
                                : null,
                            deliveryInstructions:
                                instructionsCtrl.text.trim().isNotEmpty
                                ? instructionsCtrl.text.trim()
                                : null,
                            recipientPhone: phoneCtrl.text.trim().isNotEmpty
                                ? phoneCtrl.text.trim()
                                : null,
                            isDefault: makeDefault,
                          );
                        } else {
                          saved = await widget.controller.saveNewAddress(
                            label: finalLabel,
                            address: finalAddr,
                            latitude: _currentCenter.latitude,
                            longitude: _currentCenter.longitude,
                            department: dptoCtrl.text.trim().isNotEmpty
                                ? dptoCtrl.text.trim()
                                : null,
                            reference: refCtrl.text.trim().isNotEmpty
                                ? refCtrl.text.trim()
                                : null,
                            deliveryInstructions:
                                instructionsCtrl.text.trim().isNotEmpty
                                ? instructionsCtrl.text.trim()
                                : null,
                            recipientPhone: phoneCtrl.text.trim().isNotEmpty
                                ? phoneCtrl.text.trim()
                                : null,
                            isDefault: makeDefault,
                          );
                        }

                        if (saved != null) {
                          widget.onAddressSaved?.call(saved);
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else {
                            navigator.pop(saved);
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    unawaited(
      sheetFuture.whenComplete(() {
        customLabelCtrl.dispose();
        addressCtrl.dispose();
        dptoCtrl.dispose();
        refCtrl.dispose();
        instructionsCtrl.dispose();
        phoneCtrl.dispose();
      }),
    );
  }

  Widget _buildLabelChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final AsiaTheme theme = context.asiaTheme;
    return Expanded(
      child: AsiaPressable(
        onPressed: onTap,
        child: AnimatedContainer(
          duration: MediaQuery.disableAnimationsOf(context)
              ? AsiaMotion.instant
              : AsiaMotion.feedback,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.brandCrimson.withValues(alpha: 0.12)
                : (theme.isDark ? AsiaColors.darkSurface : AsiaColors.white),
            borderRadius: AsiaRadii.brPill,
            border: Border.all(
              color: isSelected ? theme.brandCrimson : theme.border,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: isSelected ? theme.brandCrimson : theme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AsiaTypography.labelMedium.copyWith(
                  color: isSelected ? theme.brandCrimson : theme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeMapStyle(KairoMapLayer layer) async {
    if (_mapLayer == layer) return;

    final MapboxMap? map = _mapboxMap;
    if (map != null) {
      final CameraState camera = await map.getCameraState();
      _cameraBeforeStyleChange = CameraOptions(
        center: camera.center,
        padding: camera.padding,
        zoom: camera.zoom,
        bearing: camera.bearing,
        pitch: camera.pitch,
      );
    }

    if (!mounted) return;
    setState(() => _mapLayer = layer);
    await HapticFeedback.selectionClick();
    await map?.setStyleURI(_resolvedMapStyle.styleUri);
  }

  void _showMapTypeSelector(AsiaTheme theme) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetCtx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: theme.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Tipo de mapa',
                        style: AsiaTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20),
                        onPressed: () => Navigator.of(sheetCtx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      // Opción Estándar
                      Expanded(
                        child: _buildMapTypeCard(
                          title: 'Vectorial',
                          subtitle: 'Calles, edificios y parques',
                          icon: LucideIcons.map,
                          isSelected: !_isSatellite,
                          onTap: () {
                            unawaited(_changeMapStyle(KairoMapLayer.standard));
                            Navigator.of(sheetCtx).pop();
                          },
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Opción Satélite
                      Expanded(
                        child: _buildMapTypeCard(
                          title: 'Satélite',
                          subtitle: 'Imágenes aéreas, vías y lugares',
                          icon: LucideIcons.satellite,
                          isSelected: _isSatellite,
                          onTap: () {
                            unawaited(_changeMapStyle(KairoMapLayer.satellite));
                            Navigator.of(sheetCtx).pop();
                          },
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required AsiaTheme theme,
  }) {
    return AsiaPressable(
      onPressed: onTap,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? AsiaMotion.instant
            : AsiaMotion.feedback,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.brandCrimson.withValues(alpha: 0.08)
              : (theme.isDark ? AsiaColors.darkSurface : AsiaColors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.brandCrimson : theme.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? <BoxShadow>[
                  BoxShadow(
                    color: theme.brandCrimson.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.brandCrimson
                    : (theme.isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.04)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : theme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  style: AsiaTypography.labelLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? theme.brandCrimson : theme.textPrimary,
                  ),
                ),
                if (isSelected) ...<Widget>[
                  const SizedBox(width: 4),
                  Icon(LucideIcons.check, size: 14, color: theme.brandCrimson),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AsiaTypography.bodySmall.copyWith(
                color: theme.textSecondary,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool get _isTestEnvironment {
    return WidgetsBinding.instance.runtimeType.toString().contains('Test');
  }

  Widget _buildMapLayer(AsiaTheme theme) {
    if (!_isTestEnvironment) {
      return MapWidget(
        key: const ValueKey<String>('mapbox_picker_map'),
        styleUri: _resolvedMapStyle.styleUri,
        onMapCreated: _onMapCreated,
        onStyleLoadedListener: _onStyleLoaded,
        onCameraChangeListener: _onCameraChanged,
        onMapIdleListener: _onMapIdle,
        onMapLoadedListener: _onMapLoaded,
        onMapLoadErrorListener: _onMapLoadError,
      );
    }

    // Fallback canvas for headless widget test environments without platform channels
    return Container(
      key: const ValueKey<String>('mapbox_mock_canvas'),
      color: theme.isDark ? AsiaColors.mapDarkLand : AsiaColors.mapLightLand,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              LucideIcons.map,
              size: 48,
              color: theme.textSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Mapbox Native Map View',
              style: AsiaTypography.bodySmall.copyWith(
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildPremiumLocationPicker(context);
}
