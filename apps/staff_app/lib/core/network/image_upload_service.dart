import 'dart:convert';
import 'dart:typed_data';

import 'api_client.dart';

class ImageUploadException implements Exception {
  const ImageUploadException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ImageUploadService {
  ImageUploadService({ApiClient? apiClient}) : _apiClient = apiClient;

  final ApiClient? _apiClient;

  /// Límite oficial de peso de imagen: 10 MB
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Sube los bytes de una imagen al backend seguro de KAIRO
  /// devolviendo la URL directa servida por el sistema.
  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    // 1. Validar límite de peso antes de transmitir
    if (bytes.isEmpty) {
      throw const ImageUploadException(
        'El archivo seleccionado está vacío o no contiene datos válidos.',
      );
    }

    if (bytes.lengthInBytes > maxFileSizeBytes) {
      final double sizeMb = bytes.lengthInBytes / (1024 * 1024);
      throw ImageUploadException(
        'La imagen pesa ${sizeMb.toStringAsFixed(1)} MB y supera el límite máximo permitido de 10 MB. '
        'Por favor selecciona una imagen de menor peso o resolución.',
      );
    }

    // 2. Determinar tipo MIME a partir de la extensión
    final String cleanName = filename.isNotEmpty ? filename : 'plato.jpg';
    final String extension =
        cleanName.contains('.') ? cleanName.split('.').last.toLowerCase() : 'jpg';

    String contentType = 'image/jpeg';
    if (extension == 'png') {
      contentType = 'image/png';
    } else if (extension == 'webp') {
      contentType = 'image/webp';
    } else if (extension == 'gif') {
      contentType = 'image/gif';
    }

    // 3. Subir mediante el ApiClient al backend de KAIRO
    final ApiClient? client = _apiClient;
    if (client != null) {
      try {
        final dynamic res = await client.post(
          '/catalog/upload-image',
          body: <String, dynamic>{
            'filename': cleanName,
            'content_type': contentType,
            'data_base64': base64Encode(bytes),
          },
          requiresAuth: true,
        );

        if (res is Map<String, dynamic> && res.containsKey('image_url')) {
          final String url = res['image_url'].toString().trim();
          if (url.isNotEmpty) {
            return url;
          }
        }
        throw const ImageUploadException(
          'El servidor no retornó una dirección URL válida para la imagen subida.',
        );
      } on ApiException catch (e) {
        if (e.statusCode == 413) {
          throw const ImageUploadException(
            'El servidor rechazó la imagen porque supera el límite de 10 MB.',
          );
        }
        if (e.statusCode == 404) {
          throw const ImageUploadException(
            'El endpoint de subida de imágenes aún no está desplegado en el backend de Render (404). '
            'Debes hacer "git push origin develop" en el backend para desplegarlo, o ingresar un enlace web manual.',
          );
        }
        throw ImageUploadException(
          e.message.isNotEmpty
              ? e.message
              : 'Error al guardar la imagen en el servidor (${e.statusCode}).',
        );
      } on ImageUploadException {
        rethrow;
      } catch (e) {
        throw ImageUploadException(
          'Error de conexión con el servidor al subir la imagen: $e',
        );
      }
    }

    throw const ImageUploadException(
      'No se encontró una conexión configurada con el backend para subir imágenes.',
    );
  }
}
