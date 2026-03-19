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

  Future<bool> createListing({
    required String title,
    required String description,
    required String price,
    required String category,
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

      final productId = await _productRepo.createProduct({
        'title': title,
        'description': description,
        'price': parsedPrice,
        'category': category,
        'createdAt': DateTime.now().toIso8601String(),
      });

      await _analytics.logCreateListing(productId, parsedPrice);
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
    notifyListeners();
  }
}
