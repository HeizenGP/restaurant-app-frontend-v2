part of 'map_location_picker_page.dart';

extension _PremiumMapLocationPickerLayout on _MapLocationPickerPageState {
  Widget _buildPremiumLocationPicker(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;
    final String streetDisplay =
        _detectedAddress?.readableStreet.isNotEmpty == true
        ? _detectedAddress!.readableStreet
        : (_detectedAddress?.hasStreet == false
              ? 'Punto seleccionado en el mapa'
              : (_detectedAddress?.address ?? 'Coordenadas GPS'));
    final String areaDisplay =
        _detectedAddress?.readableArea ?? 'Lima Metropolitana';
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      key: const ValueKey<String>('map-location-picker-page'),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compactHeight = constraints.maxHeight < 720;
          final double minExtent = compactHeight ? 0.35 : 0.27;
          final double initialExtent = compactHeight ? 0.39 : 0.30;
          final double maxExtent = compactHeight ? 0.78 : 0.68;
          final double extentForControls = _sheetExtent.clamp(
            minExtent,
            maxExtent,
          );
          final double controlsBottom =
              (constraints.maxHeight * extentForControls + AsiaSpacing.md)
                  .clamp(AsiaSpacing.xxxl * 3, constraints.maxHeight - 260)
                  .toDouble();

          return Stack(
            children: <Widget>[
              Positioned.fill(child: _buildMapLayer(theme)),
              _buildPrecisionPin(theme),
              _buildTopSearch(theme, constraints),
              if (_mapLoadError != null && !_searchFocus.hasFocus)
                _buildMapErrorBanner(theme),
              Positioned(
                right: AsiaSpacing.md,
                bottom: controlsBottom,
                child: _buildMapControlRail(theme),
              ),
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (DraggableScrollableNotification notification) {
                  _updateSheetExtent(notification.extent);
                  return false;
                },
                child: DraggableScrollableSheet(
                  key: const ValueKey<String>('map-location-sheet'),
                  controller: _sheetController,
                  minChildSize: minExtent,
                  initialChildSize: initialExtent,
                  maxChildSize: maxExtent,
                  snap: true,
                  snapSizes: <double>[minExtent, initialExtent, maxExtent],
                  builder:
                      (
                        BuildContext context,
                        ScrollController scrollController,
                      ) {
                        return _buildLocationSheet(
                          theme: theme,
                          scrollController: scrollController,
                          streetDisplay: streetDisplay,
                          areaDisplay: areaDisplay,
                          keyboardInset: keyboardInset,
                        );
                      },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrecisionPin(AsiaTheme theme) {
    return IgnorePointer(
      child: Center(
        child: AnimatedBuilder(
          animation: _pinElevationAnim,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: Offset(0, _pinElevationAnim.value - 22),
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: theme.brandCrimson,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.brandGold, width: 1.8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AsiaColors.black.withValues(alpha: 0.22),
                      blurRadius: 9,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.mapPin,
                  color: AsiaColors.white,
                  size: 21,
                ),
              ),
              Container(width: 2.5, height: 7, color: theme.brandCrimson),
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? AsiaMotion.instant
                    : AsiaMotion.feedback,
                width: _isMoving ? 8 : 13,
                height: _isMoving ? 3 : 5,
                decoration: BoxDecoration(
                  color: AsiaColors.black.withValues(
                    alpha: _isMoving ? 0.13 : 0.28,
                  ),
                  borderRadius: AsiaRadii.brPill,
                  border: Border.all(
                    color: theme.surface.withValues(alpha: 0.56),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSearch(AsiaTheme theme, BoxConstraints constraints) {
    final bool showResults =
        _searchFocus.hasFocus &&
        (_isSearching || _searchResults.isNotEmpty || _searchError != null);
    final double maxResultsHeight =
        (constraints.maxHeight -
                MediaQuery.paddingOf(context).top -
                MediaQuery.viewInsetsOf(context).bottom -
                190)
            .clamp(120.0, 320.0)
            .toDouble();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AsiaSpacing.md,
          AsiaSpacing.sm,
          AsiaSpacing.md,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                _MapChromeButton(
                  key: const ValueKey<String>('map-back-button'),
                  icon: LucideIcons.arrowLeft,
                  semanticLabel: 'Volver',
                  theme: theme,
                  onPressed:
                      widget.onBack ?? () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: AsiaSpacing.sm),
                Expanded(
                  child: AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? AsiaMotion.instant
                        : AsiaMotion.feedback,
                    curve: AsiaMotion.emphasized,
                    constraints: const BoxConstraints(minHeight: 52),
                    decoration: BoxDecoration(
                      color: theme.surface.withValues(alpha: 0.97),
                      borderRadius: AsiaRadii.brPill,
                      border: Border.all(
                        color: _searchFocus.hasFocus
                            ? theme.brandCrimson
                            : theme.border,
                        width: _searchFocus.hasFocus ? 1.4 : 0.8,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AsiaColors.black.withValues(
                            alpha: theme.isDark ? 0.28 : 0.12,
                          ),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Semantics(
                      textField: true,
                      label: 'Buscar una dirección',
                      child: TextField(
                        key: const ValueKey<String>('map-search-field'),
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        keyboardType: TextInputType.streetAddress,
                        autofillHints: const <String>[
                          AutofillHints.fullStreetAddress,
                        ],
                        onSubmitted: (_) {
                          if (_searchResults.isNotEmpty) {
                            unawaited(
                              _selectSearchResult(_searchResults.first),
                            );
                          }
                        },
                        style: AsiaTypography.bodyLarge.copyWith(
                          color: theme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar calle, avenida o distrito',
                          hintStyle: AsiaTypography.bodyLarge.copyWith(
                            color: theme.textTertiary,
                          ),
                          prefixIcon: Icon(
                            LucideIcons.search,
                            color: _searchFocus.hasFocus
                                ? theme.brandCrimson
                                : theme.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? AsiaPressable(
                                  key: const ValueKey<String>(
                                    'map-search-clear',
                                  ),
                                  semanticLabel: 'Limpiar búsqueda',
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _onSearchChanged('');
                                  },
                                  child: SizedBox.square(
                                    dimension: 48,
                                    child: Icon(
                                      LucideIcons.x,
                                      color: theme.textSecondary,
                                      size: 18,
                                    ),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AsiaSpacing.base,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? AsiaMotion.instant
                  : AsiaMotion.standard,
              switchInCurve: AsiaMotion.emphasized,
              switchOutCurve: Curves.easeInCubic,
              child: showResults
                  ? Container(
                      key: const ValueKey<String>('map-search-results'),
                      margin: const EdgeInsets.only(
                        top: AsiaSpacing.sm,
                        left: 56,
                      ),
                      constraints: BoxConstraints(maxHeight: maxResultsHeight),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: AsiaRadii.brCard,
                        border: Border.all(color: theme.border),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AsiaColors.black.withValues(alpha: 0.20),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _buildSearchResults(theme),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('map-search-results-hidden'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsiaTheme theme) {
    if (_isSearching) {
      return Semantics(
        liveRegion: true,
        label: 'Buscando direcciones',
        child: Padding(
          padding: const EdgeInsets.all(AsiaSpacing.lg),
          child: Row(
            children: <Widget>[
              SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.brandCrimson,
                ),
              ),
              const SizedBox(width: AsiaSpacing.md),
              Text(
                'Buscando direcciones cercanas…',
                style: AsiaTypography.bodyMedium.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchError != null) {
      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.all(AsiaSpacing.base),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(LucideIcons.searchX, size: 20, color: theme.textSecondary),
              const SizedBox(width: AsiaSpacing.md),
              Expanded(
                child: Text(
                  _searchError!,
                  style: AsiaTypography.bodyMedium.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _searchResults.length,
      separatorBuilder: (_, _) => Divider(color: theme.border, height: 1),
      itemBuilder: (BuildContext context, int index) {
        final GeocodedAddress item = _searchResults[index];
        final String title = item.readableStreet.isNotEmpty
            ? item.readableStreet
            : item.address;
        return AsiaPressable(
          key: ValueKey<String>('map-search-result-$index'),
          semanticLabel: '$title, ${item.readableArea}',
          onPressed: () => unawaited(_selectSearchResult(item)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 66),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AsiaSpacing.base,
                vertical: AsiaSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.brandCrimson.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: theme.brandCrimson,
                    ),
                  ),
                  const SizedBox(width: AsiaSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AsiaTypography.bodyMedium.copyWith(
                            color: theme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AsiaSpacing.xs),
                        Text(
                          item.readableArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AsiaTypography.bodySmall.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronRight,
                    size: 17,
                    color: theme.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapErrorBanner(AsiaTheme theme) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(72, 72, AsiaSpacing.md, 0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            key: const ValueKey<String>('map-load-error'),
            padding: const EdgeInsets.fromLTRB(
              AsiaSpacing.md,
              AsiaSpacing.sm,
              AsiaSpacing.sm,
              AsiaSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: AsiaRadii.brMd,
              border: Border.all(color: theme.error.withValues(alpha: 0.40)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AsiaColors.black.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Icon(LucideIcons.wifiOff, size: 18, color: theme.error),
                const SizedBox(width: AsiaSpacing.sm),
                Expanded(
                  child: Text(
                    _mapLoadError!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AsiaTypography.bodySmall.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                ),
                AsiaPressable(
                  key: const ValueKey<String>('map-retry-style'),
                  semanticLabel: 'Reintentar carga del mapa',
                  onPressed: () => unawaited(_retryMapStyle()),
                  child: SizedBox.square(
                    dimension: 48,
                    child: Icon(
                      LucideIcons.refreshCw,
                      size: 18,
                      color: theme.brandCrimson,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControlRail(AsiaTheme theme) {
    return Container(
      key: const ValueKey<String>('map-control-rail'),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.97),
        borderRadius: AsiaRadii.brLg,
        border: Border.all(color: theme.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AsiaColors.black.withValues(
              alpha: theme.isDark ? 0.30 : 0.14,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _MapRailAction(
            key: const ValueKey<String>('map-style-control'),
            icon: _isSatellite ? LucideIcons.satellite : LucideIcons.layers,
            semanticLabel: 'Cambiar tipo de mapa',
            theme: theme,
            isActive: _isSatellite,
            onPressed: () => _showMapTypeSelector(theme),
          ),
          _MapRailDivider(theme: theme),
          _MapRailAction(
            key: const ValueKey<String>('map-zoom-in'),
            icon: LucideIcons.plus,
            semanticLabel: 'Acercar mapa',
            theme: theme,
            onPressed: () => unawaited(_zoomIn()),
          ),
          _MapRailDivider(theme: theme),
          _MapRailAction(
            key: const ValueKey<String>('map-zoom-out'),
            icon: LucideIcons.minus,
            semanticLabel: 'Alejar mapa',
            theme: theme,
            onPressed: () => unawaited(_zoomOut()),
          ),
          _MapRailDivider(theme: theme),
          _MapRailAction(
            key: const ValueKey<String>('map-locate-me'),
            icon: LucideIcons.locateFixed,
            semanticLabel: 'Usar mi ubicación actual',
            theme: theme,
            isActive: true,
            isLoading: widget.controller.isLocatingGps,
            onPressed: () => unawaited(_onLocateGps()),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSheet({
    required AsiaTheme theme,
    required ScrollController scrollController,
    required String streetDisplay,
    required String areaDisplay,
    required double keyboardInset,
  }) {
    final DeliveryZoneQuote? quote = _zoneQuote;
    final bool outOfCoverage = quote?.isCovered == false;
    final double systemBottom = MediaQuery.viewPaddingOf(context).bottom;
    final bool showExpandedDetails =
        _sheetExtent > 0.36 || _referenceFocus.hasFocus || keyboardInset > 0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: AsiaRadii.rLg),
        border: Border(top: BorderSide(color: theme.border)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AsiaColors.black.withValues(
              alpha: theme.isDark ? 0.38 : 0.16,
            ),
            blurRadius: 24,
            offset: const Offset(0, -7),
          ),
        ],
      ),
      child: ListView(
        key: const ValueKey<String>('map-location-sheet-scroll'),
        controller: scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AsiaSpacing.lg,
          AsiaSpacing.sm,
          AsiaSpacing.lg,
          systemBottom + keyboardInset + AsiaSpacing.base,
        ),
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.border,
                borderRadius: AsiaRadii.brPill,
              ),
            ),
          ),
          const SizedBox(height: AsiaSpacing.md),
          if (showExpandedDetails) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'PUNTO DE ENTREGA',
                        style: AsiaTypography.labelSmall.copyWith(
                          color: theme.brandGold,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: AsiaSpacing.xs),
                      Text(
                        'Confirma la ubicación exacta',
                        style: AsiaTypography.titleMedium.copyWith(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronsDown,
                  size: 18,
                  color: theme.textTertiary,
                ),
              ],
            ),
            const SizedBox(height: AsiaSpacing.md),
          ] else
            Align(
              alignment: Alignment.centerRight,
              child: Semantics(
                label: 'Arrastra el panel para añadir una referencia',
                child: Icon(
                  LucideIcons.chevronsUp,
                  size: 18,
                  color: theme.textTertiary,
                ),
              ),
            ),
          Semantics(
            liveRegion: true,
            container: true,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? AsiaMotion.instant
                  : AsiaMotion.standard,
              child: _isLoadingAddress
                  ? _AddressLoadingRow(theme: theme)
                  : _SelectedAddressRow(
                      key: ValueKey<String>(streetDisplay + areaDisplay),
                      theme: theme,
                      street: streetDisplay,
                      area: areaDisplay,
                      onEdit: () => _showConfirmDetailsSheet(context),
                    ),
            ),
          ),
          if (_geocodeError != null) ...<Widget>[
            const SizedBox(height: AsiaSpacing.sm),
            _InlineLocationMessage(
              key: const ValueKey<String>('map-geocode-error'),
              theme: theme,
              icon: LucideIcons.triangleAlert,
              color: theme.warning,
              message: _geocodeError!,
              actionLabel: 'Reintentar',
              onAction: () => unawaited(_reverseGeocodeCenter(_currentCenter)),
            ),
          ],
          if (quote != null) ...<Widget>[
            const SizedBox(height: AsiaSpacing.sm),
            _CoverageStatus(theme: theme, quote: quote),
          ],
          if (showExpandedDetails) ...<Widget>[
            const SizedBox(height: AsiaSpacing.base),
            AsiaTextField(
              controller: _referenceCtrl,
              focusNode: _referenceFocus,
              semanticKey: const ValueKey<String>('map-reference-field'),
              label: 'Referencia para el repartidor',
              hintText: 'Ej. fachada roja, portón negro, piso 3',
              prefixIcon: LucideIcons.messageSquareText,
              textInputAction: TextInputAction.newline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
          ],
          const SizedBox(height: AsiaSpacing.base),
          AsiaButton(
            key: const ValueKey<String>('map-confirm-location'),
            label: outOfCoverage
                ? 'Ubicación fuera de cobertura'
                : 'Confirmar ubicación',
            loadingLabel: 'Guardando ubicación…',
            isLoading: widget.controller.isSaving,
            leading: LucideIcons.mapPinned,
            enabled: !outOfCoverage && !_isLoadingAddress,
            onPressed: () => _showConfirmDetailsSheet(context),
          ),
          if (showExpandedDetails) ...<Widget>[
            const SizedBox(height: AsiaSpacing.sm),
            Text(
              'Mueve el mapa para ajustar el pin. La dirección se actualizará automáticamente.',
              textAlign: TextAlign.center,
              style: AsiaTypography.bodySmall.copyWith(
                color: theme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapChromeButton extends StatelessWidget {
  const _MapChromeButton({
    required this.icon,
    required this.semanticLabel,
    required this.theme,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final AsiaTheme theme;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AsiaPressable(
      semanticLabel: semanticLabel,
      borderRadius: AsiaRadii.brPill,
      onPressed: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: 0.97),
          shape: BoxShape.circle,
          border: Border.all(color: theme.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AsiaColors.black.withValues(alpha: 0.13),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 21, color: theme.textPrimary),
      ),
    );
  }
}

class _MapRailAction extends StatelessWidget {
  const _MapRailAction({
    required this.icon,
    required this.semanticLabel,
    required this.theme,
    required this.onPressed,
    this.isActive = false,
    this.isLoading = false,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final AsiaTheme theme;
  final VoidCallback onPressed;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return AsiaPressable(
      semanticLabel: semanticLabel,
      onPressed: isLoading ? null : onPressed,
      child: SizedBox.square(
        dimension: 48,
        child: Center(
          child: isLoading
              ? SizedBox.square(
                  dimension: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.brandCrimson,
                  ),
                )
              : Icon(
                  icon,
                  size: 19,
                  color: isActive ? theme.brandCrimson : theme.textPrimary,
                ),
        ),
      ),
    );
  }
}

class _MapRailDivider extends StatelessWidget {
  const _MapRailDivider({required this.theme});

  final AsiaTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 24, child: Divider(height: 1, color: theme.border));
  }
}

class _AddressLoadingRow extends StatelessWidget {
  const _AddressLoadingRow({required this.theme});

  final AsiaTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('map-address-loading'),
      constraints: const BoxConstraints(minHeight: 58),
      child: Row(
        children: <Widget>[
          SizedBox.square(
            dimension: 34,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: theme.brandCrimson,
            ),
          ),
          const SizedBox(width: AsiaSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Identificando dirección…',
                  style: AsiaTypography.bodyMedium.copyWith(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AsiaSpacing.xs),
                Text(
                  'Consultando cobertura y tiempo de entrega',
                  style: AsiaTypography.bodySmall.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedAddressRow extends StatelessWidget {
  const _SelectedAddressRow({
    required this.theme,
    required this.street,
    required this.area,
    required this.onEdit,
    super.key,
  });

  final AsiaTheme theme;
  final String street;
  final String area;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: theme.brandCrimson.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            LucideIcons.mapPinCheck,
            size: 20,
            color: theme.brandCrimson,
          ),
        ),
        const SizedBox(width: AsiaSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                street,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AsiaTypography.titleSmall.copyWith(
                  color: theme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AsiaSpacing.xs),
              Text(
                area,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AsiaTypography.bodySmall.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        AsiaPressable(
          key: const ValueKey<String>('map-edit-address'),
          semanticLabel: 'Editar detalles de la dirección',
          onPressed: onEdit,
          child: SizedBox.square(
            dimension: 48,
            child: Icon(
              LucideIcons.penLine,
              size: 18,
              color: theme.brandCrimson,
            ),
          ),
        ),
      ],
    );
  }
}

class _InlineLocationMessage extends StatelessWidget {
  const _InlineLocationMessage({
    required this.theme,
    required this.icon,
    required this.color,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final AsiaTheme theme;
  final IconData icon;
  final Color color;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AsiaSpacing.md,
          AsiaSpacing.sm,
          AsiaSpacing.sm,
          AsiaSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: AsiaRadii.brMd,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AsiaSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AsiaTypography.bodySmall.copyWith(
                  color: theme.textPrimary,
                ),
              ),
            ),
            AsiaPressable(
              semanticLabel: actionLabel,
              onPressed: onAction,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                child: Center(
                  child: Text(
                    actionLabel,
                    style: AsiaTypography.labelSmall.copyWith(color: color),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverageStatus extends StatelessWidget {
  const _CoverageStatus({required this.theme, required this.quote});

  final AsiaTheme theme;
  final DeliveryZoneQuote quote;

  @override
  Widget build(BuildContext context) {
    final Color color = quote.isCovered ? theme.success : theme.error;
    final String text = quote.isCovered
        ? 'Cobertura KAIRO · Delivery ${quote.formattedFee} · ${quote.formattedEta}'
        : (quote.message ?? 'Esta ubicación está fuera de nuestra cobertura');

    return Container(
      key: const ValueKey<String>('map-coverage-status'),
      padding: const EdgeInsets.symmetric(
        horizontal: AsiaSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: AsiaRadii.brMd,
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            quote.isCovered ? LucideIcons.circleCheck : LucideIcons.circleAlert,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AsiaSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AsiaTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
