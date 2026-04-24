import 'package:image_picker/image_picker.dart';
import 'package:marketplace_flutter_application/data/services/image_upload_service.dart';

class ImageUploadRepository {
  final ImageUploadService _imageUploadService;

  ImageUploadRepository({
    ImageUploadService? imageUploadService,
  }) : _imageUploadService = imageUploadService ?? ImageUploadService();

  Future<List<String>> uploadListingImages(List<XFile> images) {
    return _imageUploadService.uploadListingImages(images);
  }
}