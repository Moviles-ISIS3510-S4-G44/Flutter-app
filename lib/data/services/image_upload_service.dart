import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_flutter_application/config/app_config.dart';

class ImageUploadService {
  /// Tipo de dato MIME basado en la extensión del archivo.
  MediaType _mediaTypeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Future<List<String>> uploadListingImages(List<XFile> images) async {
    if (images.isEmpty) return [];

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/uploads/listing-images');

    final request = http.MultipartRequest('POST', uri);

    for (final image in images) {
      final mediaType = _mediaTypeFromPath(image.path);
      request.files.add(
        await http.MultipartFile.fromPath(
          'files',
          image.path,
          contentType: mediaType,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('UPLOAD IMAGES STATUS: ${response.statusCode}');
    print('UPLOAD IMAGES BODY: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to upload images: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final urls = decoded['urls'] as List<dynamic>;

    return urls.map((url) => url.toString()).toList();
  }
}