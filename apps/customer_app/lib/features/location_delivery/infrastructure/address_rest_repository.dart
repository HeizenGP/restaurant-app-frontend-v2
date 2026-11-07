import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/api_environment.dart';
import '../../m01_access/profile/domain/profile_models.dart';
import '../domain/delivery_coverage.dart';
import '../domain/location_models.dart';

class AddressRestRepository {
  AddressRestRepository({
    required Uri baseUri,
    http.Client? httpClient,
    String? Function()? tokenGetter,
    // Public parameter names are part of the constructor API; the backing
    // fields stay private to the REST adapter.
    // ignore: prefer_initializing_formals
  }) : _baseUri = baseUri,
       _client = httpClient ?? http.Client(),
       // ignore: prefer_initializing_formals
       _tokenGetter = tokenGetter;

  final Uri _baseUri;
  final http.Client _client;
  final String? Function()? _tokenGetter;

  Map<String, String> _buildHeaders() {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final String? token = _tokenGetter?.call();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<CustomerAddress>> getSavedAddresses() async {
    final Uri url = _baseUri.resolve('/api/v1/users/me/addresses');
    try {
      final http.Response response = await _client.get(
        url,
        headers: _buildHeaders(),
      );
      if (response.statusCode == 200) {
        final List<dynamic> decoded =
            jsonDecode(response.body) as List<dynamic>;
        return decoded
            .map(
              (dynamic item) =>
                  CustomerAddress.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }
      return <CustomerAddress>[];
    } catch (e) {
      debugPrint('Error fetching saved addresses from backend: $e');
      return <CustomerAddress>[];
    }
  }

  Future<CustomerAddress?> createAddress({
    required String label,
    required String address,
    required double latitude,
    required double longitude,
    String? department,
    String? reference,
    String? deliveryInstructions,
    String? recipientPhone,
    bool isDefault = false,
  }) async {
    final Uri url = _baseUri.resolve('/api/v1/users/me/addresses');
    final Map<String, dynamic> body = <String, dynamic>{
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      if (department != null && department.isNotEmpty) 'department': department,
      if (reference != null && reference.isNotEmpty) 'reference': reference,
      if (deliveryInstructions != null && deliveryInstructions.isNotEmpty)
        'delivery_instructions': deliveryInstructions,
      if (recipientPhone != null && recipientPhone.isNotEmpty)
        'recipient_phone': recipientPhone,
      'is_default': isDefault,
    };

    try {
      final http.Response response = await _client.post(
        url,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.body) as Map<String, dynamic>;
        return CustomerAddress.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error creating address in backend: $e');
    }
    return null;
  }

  Future<CustomerAddress?> updateAddress({
    required String id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    String? department,
    String? reference,
    String? deliveryInstructions,
    String? recipientPhone,
    bool? isDefault,
  }) async {
    final Uri url = _baseUri.resolve('/api/v1/users/me/addresses/$id');
    final Map<String, dynamic> body = <String, dynamic>{
      'label': ?label,
      'address': ?address,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'department': ?department,
      'reference': ?reference,
      'delivery_instructions': ?deliveryInstructions,
      'recipient_phone': ?recipientPhone,
      'is_default': ?isDefault,
    };

    try {
      final http.Response response = await _client.put(
        url,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.body) as Map<String, dynamic>;
        return CustomerAddress.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error updating address in backend: $e');
    }
    return null;
  }

  Future<bool> deleteAddress(String id) async {
    final Uri url = _baseUri.resolve('/api/v1/users/me/addresses/$id');
    try {
      final http.Response response = await _client.delete(
        url,
        headers: _buildHeaders(),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    }
  }

  Future<CustomerAddress?> setDefaultAddress(String id) async {
    final Uri url = _baseUri.resolve(
      '/api/v1/users/me/addresses/$id/set-default',
    );
    try {
      final http.Response response = await _client.post(
        url,
        headers: _buildHeaders(),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.body) as Map<String, dynamic>;
        return CustomerAddress.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error setting default address: $e');
    }
    return null;
  }

  Future<DeliveryZoneQuote> checkDeliveryZone(
    double latitude,
    double longitude,
  ) async {
    final Uri url = _baseUri.resolve('/api/v1/delivery/check-zone');
    try {
      final http.Response response = await _client.post(
        url,
        headers: _buildHeaders(),
        body: jsonEncode(<String, dynamic>{
          'latitude': latitude,
          'longitude': longitude,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.body) as Map<String, dynamic>;
        final double? backendLatitude = (decoded['restaurant_latitude'] as num?)
            ?.toDouble();
        final double? backendLongitude =
            (decoded['restaurant_longitude'] as num?)?.toDouble();

        // Compatibilidad temporal: el backend desplegado aún puede responder
        // con la antigua sede de Lima. Solo se usa su cotización cuando declara
        // una sede en Tarapoto; al actualizarse el servidor, vuelve a ser la
        // fuente autoritativa sin requerir otro cambio en el cliente.
        if (backendLatitude != null &&
            backendLongitude != null &&
            KairoDeliveryCoverage.isTarapotoCenter(
              backendLatitude,
              backendLongitude,
            )) {
          return DeliveryZoneQuote.fromJson(decoded);
        }
        debugPrint(
          'Delivery zone backend uses a legacy coverage center; '
          'applying Tarapoto fallback.',
        );
      }
    } catch (e) {
      debugPrint('Error checking delivery zone: $e');
    }

    // Client-side fallback calculation if backend unreachable
    return _calculateClientFallbackZone(latitude, longitude);
  }

  // Client-side in-memory caching to strictly respect OSM and Photon usage policies
  static final Map<String, _AddressCacheEntry<GeocodedAddress>> _reverseCache =
      <String, _AddressCacheEntry<GeocodedAddress>>{};
  static final Map<String, _AddressCacheEntry<List<GeocodedAddress>>>
  _searchCache = <String, _AddressCacheEntry<List<GeocodedAddress>>>{};
  static const Duration _cacheTtl = Duration(minutes: 15);

  Future<GeocodedAddress> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    final String cacheKey =
        '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
    final DateTime now = DateTime.now();
    if (_reverseCache.containsKey(cacheKey)) {
      final _AddressCacheEntry<GeocodedAddress> entry =
          _reverseCache[cacheKey]!;
      if (now.difference(entry.timestamp) < _cacheTtl) {
        return entry.data;
      }
    }

    // 1. Try Mapbox Reverse Geocoding if token is available
    if (ApiEnvironment.mapboxAccessToken.isNotEmpty) {
      try {
        final Uri mapboxUrl = Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json'
          '?access_token=${ApiEnvironment.mapboxAccessToken}'
          '&types=address,poi,neighborhood,locality'
          '&language=es',
        );
        final http.Response mbResponse = await _client
            .get(mapboxUrl)
            .timeout(const Duration(seconds: 4));

        if (mbResponse.statusCode == 200) {
          final Map<String, dynamic> mbData =
              jsonDecode(mbResponse.body) as Map<String, dynamic>;
          final List<dynamic> features =
              mbData['features'] as List<dynamic>? ?? <dynamic>[];
          if (features.isNotEmpty) {
            final Map<String, dynamic> feat =
                features.first as Map<String, dynamic>;
            final String placeName =
                feat['place_name'] as String? ??
                feat['place_name_es'] as String? ??
                '';
            final String text =
                feat['text'] as String? ?? feat['text_es'] as String? ?? '';
            final String? houseNumber = feat['address'] as String?;
            final String street = text;

            String? district;
            String province = '';
            String department = '';

            final List<dynamic> context =
                feat['context'] as List<dynamic>? ?? <dynamic>[];
            for (final dynamic ctx in context) {
              if (ctx is Map<String, dynamic>) {
                final String id = ctx['id'] as String? ?? '';
                final String ctxText = ctx['text'] as String? ?? '';
                if (id.startsWith('locality') ||
                    id.startsWith('neighborhood')) {
                  district = ctxText;
                } else if (id.startsWith('place')) {
                  province = ctxText;
                } else if (id.startsWith('region')) {
                  department = ctxText;
                }
              }
            }

            final String streetPart =
                houseNumber != null && houseNumber.isNotEmpty
                ? '$street $houseNumber'
                : street;
            final List<String> areaParts = <String>[];
            if (district != null && district.isNotEmpty) {
              areaParts.add(district);
            }
            if (province.isNotEmpty && !areaParts.contains(province)) {
              areaParts.add(province);
            }
            if (department.isNotEmpty && !areaParts.contains(department)) {
              areaParts.add(department);
            }

            final String readable =
                streetPart.isNotEmpty && areaParts.isNotEmpty
                ? '$streetPart, ${areaParts.join(', ')}'
                : (placeName.isNotEmpty
                      ? placeName
                      : (streetPart.isNotEmpty
                            ? streetPart
                            : 'Ubicación seleccionada'));

            final GeocodedAddress result = GeocodedAddress(
              displayName: placeName.isNotEmpty ? placeName : readable,
              address: readable,
              street: street.isNotEmpty ? street : null,
              houseNumber: houseNumber,
              district: district,
              province: province,
              department: department,
              city: province,
              latitude: latitude,
              longitude: longitude,
            );

            _reverseCache[cacheKey] = _AddressCacheEntry<GeocodedAddress>(
              result,
              now,
            );
            return result;
          }
        }
      } catch (e) {
        debugPrint('Mapbox reverse geocode fallback to backend/OSM: $e');
      }
    }

    final Uri backendUrl = _baseUri.resolve(
      '/api/v1/delivery/geocode/reverse?latitude=$latitude&longitude=$longitude',
    );
    try {
      final http.Response response = await _client
          .get(backendUrl, headers: _buildHeaders())
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded =
            jsonDecode(response.body) as Map<String, dynamic>;
        final GeocodedAddress result = GeocodedAddress.fromJson(decoded);
        _reverseCache[cacheKey] = _AddressCacheEntry<GeocodedAddress>(
          result,
          now,
        );
        return result;
      }
    } catch (_) {}

    // Direct fallback to OpenStreetMap Nominatim with proper User-Agent identification
    try {
      final Uri osmUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$latitude&lon=$longitude&addressdetails=1',
      );
      final http.Response response = await _client
          .get(
            osmUrl,
            headers: <String, String>{
              'User-Agent': 'KairoCustomerApp/2.0 (soporte@kairo.pe)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> addr =
            data['address'] is Map<String, dynamic>
            ? data['address'] as Map<String, dynamic>
            : <String, dynamic>{};

        final String? road =
            addr['road'] as String? ?? addr['pedestrian'] as String?;
        final String? houseNumber = addr['house_number'] as String?;
        final String? suburb =
            addr['suburb'] as String? ?? addr['neighbourhood'] as String?;
        final String? district =
            addr['city_district'] as String? ??
            addr['district'] as String? ??
            suburb;
        final String province =
            addr['county'] as String? ?? addr['city'] as String? ?? '';
        final String department = addr['state'] as String? ?? '';

        final List<String> streetParts = <String>[];
        if (road != null && road.isNotEmpty) {
          streetParts.add(
            houseNumber != null && houseNumber.isNotEmpty
                ? '$road $houseNumber'
                : road,
          );
        }

        final List<String> areaParts = <String>[];
        if (district != null && district.isNotEmpty) areaParts.add(district);
        if (province.isNotEmpty && !areaParts.contains(province)) {
          areaParts.add(province);
        }
        if (department.isNotEmpty && !areaParts.contains(department)) {
          areaParts.add(department);
        }

        final String readable;
        if (streetParts.isNotEmpty && areaParts.isNotEmpty) {
          readable = '${streetParts.join(' ')}, ${areaParts.join(', ')}';
        } else if (streetParts.isNotEmpty) {
          readable = streetParts.join(' ');
        } else if (areaParts.isNotEmpty) {
          readable = areaParts.join(', ');
        } else {
          readable =
              data['display_name'] as String? ?? 'Ubicación seleccionada';
        }

        final GeocodedAddress result = GeocodedAddress(
          displayName: data['display_name'] as String? ?? readable,
          address: readable,
          street: road,
          houseNumber: houseNumber,
          district: district,
          province: province,
          department: department,
          city: province,
          latitude: latitude,
          longitude: longitude,
        );

        _reverseCache[cacheKey] = _AddressCacheEntry<GeocodedAddress>(
          result,
          now,
        );
        return result;
      }
    } catch (e) {
      debugPrint('OSM reverse geocode direct fallback failed: $e');
    }

    final bool isNearTarapoto =
        KairoDeliveryCoverage.distanceFromCenterKm(latitude, longitude) <= 30;
    return GeocodedAddress(
      displayName:
          '${isNearTarapoto ? 'Ubicación en Tarapoto' : 'Ubicación seleccionada'} '
          '(${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})',
      address:
          'Coordenadas GPS: ${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
      district: isNearTarapoto ? KairoDeliveryCoverage.city : null,
      province: isNearTarapoto ? KairoDeliveryCoverage.city : null,
      department: isNearTarapoto ? KairoDeliveryCoverage.department : null,
      latitude: latitude,
      longitude: longitude,
      city: isNearTarapoto ? KairoDeliveryCoverage.city : null,
    );
  }

  Future<List<GeocodedAddress>> searchAddresses(
    String query, {
    double? proximityLat,
    double? proximityLon,
  }) async {
    final String clean = query.trim();
    if (clean.length < 2) return <GeocodedAddress>[];

    final double resolvedProximityLat =
        proximityLat ?? KairoDeliveryCoverage.centerLatitude;
    final double resolvedProximityLon =
        proximityLon ?? KairoDeliveryCoverage.centerLongitude;
    final String cacheKey =
        '${clean.toLowerCase()}|'
        '${resolvedProximityLat.toStringAsFixed(2)}|'
        '${resolvedProximityLon.toStringAsFixed(2)}';
    final DateTime now = DateTime.now();
    if (_searchCache.containsKey(cacheKey)) {
      final _AddressCacheEntry<List<GeocodedAddress>> entry =
          _searchCache[cacheKey]!;
      if (now.difference(entry.timestamp) < _cacheTtl) {
        return entry.data;
      }
    }

    // 1. Try Mapbox Autocomplete / Search if token is available
    if (ApiEnvironment.mapboxAccessToken.isNotEmpty) {
      try {
        final Uri mapboxUrl = Uri.parse(
          'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(clean)}.json'
          '?access_token=${ApiEnvironment.mapboxAccessToken}'
          '&proximity=$resolvedProximityLon,$resolvedProximityLat'
          '&country=PE'
          '&types=address,poi,neighborhood,locality'
          '&language=es'
          '&autocomplete=true'
          '&limit=8',
        );
        final http.Response mbResponse = await _client
            .get(mapboxUrl)
            .timeout(const Duration(seconds: 4));

        if (mbResponse.statusCode == 200) {
          final Map<String, dynamic> mbData =
              jsonDecode(mbResponse.body) as Map<String, dynamic>;
          final List<dynamic> features =
              mbData['features'] as List<dynamic>? ?? <dynamic>[];
          if (features.isNotEmpty) {
            final List<GeocodedAddress> list = <GeocodedAddress>[];
            for (final dynamic f in features) {
              if (f is Map<String, dynamic>) {
                final Map<String, dynamic> geom =
                    f['geometry'] as Map<String, dynamic>? ??
                    <String, dynamic>{};
                final List<dynamic> coords =
                    geom['coordinates'] as List<dynamic>? ??
                    <dynamic>[0.0, 0.0];
                final double lon = coords.isNotEmpty && coords[0] is num
                    ? (coords[0] as num).toDouble()
                    : 0.0;
                final double lat = coords.length > 1 && coords[1] is num
                    ? (coords[1] as num).toDouble()
                    : 0.0;

                final String placeName =
                    f['place_name'] as String? ??
                    f['place_name_es'] as String? ??
                    '';
                final String text =
                    f['text'] as String? ?? f['text_es'] as String? ?? '';
                final String? houseNumber = f['address'] as String?;
                final String street = text;

                String? district;
                String province = '';
                String department = '';

                final List<dynamic> context =
                    f['context'] as List<dynamic>? ?? <dynamic>[];
                for (final dynamic ctx in context) {
                  if (ctx is Map<String, dynamic>) {
                    final String id = ctx['id'] as String? ?? '';
                    final String ctxText = ctx['text'] as String? ?? '';
                    if (id.startsWith('locality') ||
                        id.startsWith('neighborhood')) {
                      district = ctxText;
                    } else if (id.startsWith('place')) {
                      province = ctxText;
                    } else if (id.startsWith('region')) {
                      department = ctxText;
                    }
                  }
                }

                final String streetPart =
                    houseNumber != null && houseNumber.isNotEmpty
                    ? '$street $houseNumber'
                    : street;
                final List<String> areaParts = <String>[];
                if (district != null && district.isNotEmpty) {
                  areaParts.add(district);
                }
                if (province.isNotEmpty && !areaParts.contains(province)) {
                  areaParts.add(province);
                }
                if (department.isNotEmpty && !areaParts.contains(department)) {
                  areaParts.add(department);
                }

                final String readable =
                    streetPart.isNotEmpty && areaParts.isNotEmpty
                    ? '$streetPart, ${areaParts.join(', ')}'
                    : (placeName.isNotEmpty
                          ? placeName
                          : (streetPart.isNotEmpty ? streetPart : 'Ubicación'));

                list.add(
                  GeocodedAddress(
                    displayName: placeName.isNotEmpty ? placeName : readable,
                    address: readable,
                    street: street.isNotEmpty ? street : null,
                    houseNumber: houseNumber,
                    district: district,
                    province: province,
                    department: department,
                    city: province,
                    latitude: lat,
                    longitude: lon,
                  ),
                );
              }
            }
            if (list.isNotEmpty) {
              _searchCache[cacheKey] =
                  _AddressCacheEntry<List<GeocodedAddress>>(list, now);
              return list;
            }
          }
        }
      } catch (e) {
        debugPrint('Mapbox search fallback to backend/Photon: $e');
      }
    }

    // 2. Try Backend Proxy with autocomplete
    final Uri backendUrl = _baseUri.resolve(
      '/api/v1/delivery/geocode/search?query=${Uri.encodeComponent(clean)}',
    );
    try {
      final http.Response response = await _client
          .get(backendUrl, headers: _buildHeaders())
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final List<dynamic> decoded =
            jsonDecode(response.body) as List<dynamic>;
        final List<GeocodedAddress> list = decoded
            .map(
              (dynamic item) =>
                  GeocodedAddress.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        _searchCache[cacheKey] = _AddressCacheEntry<List<GeocodedAddress>>(
          list,
          now,
        );
        return list;
      }
    } catch (_) {}

    // 2. Direct Photon fallback (Komoot OSM autocomplete provider)
    // Respects OSM policies by using Photon designed for search-as-you-type, NOT Nominatim.
    try {
      final Uri photonUrl = Uri.parse(
        'https://photon.komoot.io/api/?q=${Uri.encodeComponent(clean)}'
        '&lat=$resolvedProximityLat&lon=$resolvedProximityLon'
        '&limit=5&bbox=${KairoDeliveryCoverage.photonBoundingBox}',
      );
      final http.Response response = await _client
          .get(
            photonUrl,
            headers: <String, String>{
              'User-Agent': 'KairoCustomerApp/2.0 (soporte@kairo.pe)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> features = data['features'] is List<dynamic>
            ? data['features'] as List<dynamic>
            : <dynamic>[];

        final List<GeocodedAddress> results = features.map((dynamic feat) {
          final Map<String, dynamic> f = feat as Map<String, dynamic>;
          final Map<String, dynamic> props =
              f['properties'] is Map<String, dynamic>
              ? f['properties'] as Map<String, dynamic>
              : <String, dynamic>{};
          final Map<String, dynamic> geom =
              f['geometry'] is Map<String, dynamic>
              ? f['geometry'] as Map<String, dynamic>
              : <String, dynamic>{};
          final List<dynamic> coords = geom['coordinates'] is List<dynamic>
              ? geom['coordinates'] as List<dynamic>
              : <dynamic>[0.0, 0.0];

          final double lon = (coords.isNotEmpty && coords[0] is num)
              ? (coords[0] as num).toDouble()
              : 0.0;
          final double lat = (coords.length > 1 && coords[1] is num)
              ? (coords[1] as num).toDouble()
              : 0.0;

          final String name = props['name'] as String? ?? '';
          final String street =
              props['street'] as String? ??
              (props['type'] == 'street' ? name : '');
          final String? houseNumber = props['housenumber'] as String?;
          final String? district =
              props['district'] as String? ??
              props['locality'] as String? ??
              props['city'] as String?;
          final String province =
              props['county'] as String? ?? props['city'] as String? ?? '';
          final String department = props['state'] as String? ?? '';

          final String streetLine;
          if (street.isNotEmpty) {
            streetLine = houseNumber != null && houseNumber.isNotEmpty
                ? '$street $houseNumber'
                : street;
          } else if (name.isNotEmpty) {
            streetLine = houseNumber != null && houseNumber.isNotEmpty
                ? '$name $houseNumber'
                : name;
          } else {
            streetLine = '';
          }

          final List<String> areaParts = <String>[];
          if (district != null && district.isNotEmpty) areaParts.add(district);
          if (province.isNotEmpty && !areaParts.contains(province)) {
            areaParts.add(province);
          }
          if (department.isNotEmpty && !areaParts.contains(department)) {
            areaParts.add(department);
          }

          final String formatted;
          if (streetLine.isNotEmpty && areaParts.isNotEmpty) {
            formatted = '$streetLine, ${areaParts.join(', ')}';
          } else if (streetLine.isNotEmpty) {
            formatted = streetLine;
          } else if (areaParts.isNotEmpty) {
            formatted = areaParts.join(', ');
          } else {
            formatted = 'Ubicación ($lat, $lon)';
          }

          return GeocodedAddress(
            displayName: formatted,
            address: formatted,
            street: street.isNotEmpty
                ? street
                : (name.isNotEmpty ? name : null),
            houseNumber: houseNumber,
            district: district,
            province: province,
            department: department,
            city: province,
            latitude: lat,
            longitude: lon,
          );
        }).toList();

        _searchCache[cacheKey] = _AddressCacheEntry<List<GeocodedAddress>>(
          results,
          now,
        );
        return results;
      }
    } catch (_) {}

    return <GeocodedAddress>[];
  }

  DeliveryZoneQuote _calculateClientFallbackZone(double lat, double lon) {
    final double dist = KairoDeliveryCoverage.distanceFromCenterKm(lat, lon);

    if (dist <= 3.0) {
      return DeliveryZoneQuote(
        isCovered: true,
        distanceKm: dist,
        zoneCode: 'ZONE_1',
        zoneName: 'Zona 1 - Tarapoto centro',
        deliveryFee: '5.00',
        estimatedMinMinutes: 20,
        estimatedMaxMinutes: 35,
        message: '¡Estás dentro de la zona exprés de KAIRO!',
      );
    } else if (dist <= 7.0) {
      return DeliveryZoneQuote(
        isCovered: true,
        distanceKm: dist,
        zoneCode: 'ZONE_2',
        zoneName: 'Zona 2 - Tarapoto, Morales y La Banda de Shilcayo',
        deliveryFee: '8.00',
        estimatedMinMinutes: 35,
        estimatedMaxMinutes: 50,
        message: 'Entrega estándar disponible.',
      );
    } else if (dist <= 12.0) {
      return DeliveryZoneQuote(
        isCovered: true,
        distanceKm: dist,
        zoneCode: 'ZONE_3',
        zoneName: 'Zona 3 - Área metropolitana de Tarapoto',
        deliveryFee: '12.00',
        estimatedMinMinutes: 45,
        estimatedMaxMinutes: 65,
        message: 'Zona extendida disponible para pedidos.',
      );
    } else {
      return DeliveryZoneQuote(
        isCovered: false,
        distanceKm: dist,
        message:
            'La ubicación se encuentra a ${dist.toStringAsFixed(1)} km, '
            'fuera del área de reparto de Tarapoto '
            '(máximo ${KairoDeliveryCoverage.maximumRadiusKm.toStringAsFixed(0)} km).',
      );
    }
  }
}

class _AddressCacheEntry<T> {
  const _AddressCacheEntry(this.data, this.timestamp);

  final T data;
  final DateTime timestamp;
}
