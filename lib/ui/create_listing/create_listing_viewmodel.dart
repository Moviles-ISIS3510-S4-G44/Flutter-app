import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CreateListingViewModel extends ChangeNotifier {
  final dynamic _productRepo;
  final dynamic _userRepo;
  final dynamic _analytics;
  final ImagePicker _picker = ImagePicker();

  CreateListingViewModel(this._productRepo, this._userRepo, this._analytics);

  File? selectedImage;
  bool isLoading = false;
  String? error;
  bool created = false;
  double? selectedLat;
  double? selectedLng;
  String? selectedLocationName;

  void setLocation(double lat, double lng, String name) {
    selectedLat = lat;
    selectedLng = lng;
    selectedLocationName = name;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

  // category label -> backend uuid mapping
  static const Map<String, String> _categoryIds = {
    'Textbooks': '1ce3178f-12ca-4916-a448-887405ef0676',
    'Electronics': '2de3178f-12ca-4916-a448-887405ef0677',
    'Notes': '3ee3178f-12ca-4916-a448-887405ef0678',
    // fallback labels
    'Books': '1ce3178f-12ca-4916-a448-887405ef0676',
    'Furniture': '3ee3178f-12ca-4916-a448-887405ef0678',
    'Clothing': '3ee3178f-12ca-4916-a448-887405ef0678',
    'Other': '3ee3178f-12ca-4916-a448-887405ef0678',
  };

  Future<bool> createListing({
    required String title,
    required String description,
    required String price,
    required String category,
    String condition = 'New',
    String location = 'Uniandes',
  }) async {
    if (selectedImage == null) {
      error = 'Please select an image first';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final parsedPrice = double.tryParse(price) ?? 0;
      final categoryId = _categoryIds[category] ?? _categoryIds['Other']!;

      // try to get auth token if user is logged in
      String? token;
      try {
        token = (_userRepo as dynamic).token as String?;
      } catch (_) {}

      final productId = await _productRepo.createProduct({
        'title': title,
        'description': description,
        'price': parsedPrice,
        'category_id': categoryId,
        'condition': condition,
        'location': location,
        'images': <String>[],
        'status': 'active',
      }, token: token);

      try {
        await _analytics.logCreateListing(productId, parsedPrice);
      } catch (_) {}
      created = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Failed to create listing: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    selectedImage = null;
    created = false;
    error = null;
    selectedLat = null;
    selectedLng = null;
    selectedLocationName = null;
    notifyListeners();
  }
}
