import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_flutter_application/data/repositories/category_repository.dart';
import 'package:marketplace_flutter_application/models/categories/category.dart';

class CreateListingViewModel extends ChangeNotifier {
  //Categories
  final CategoryRepository _categoryRepository;
  bool isLoadingCategories = false;
  String? categoriesErrorMessage;
  List<Category> categories = [];
  Category? selectedCategory;
  // Conditions
  final List<String> conditions = ['New', 'Like New', 'Used'];
  String selectedCondition = 'Like New';
  //Images
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> selectedImages = [];
  final int maxImages = 5;
  //Basic info
  String title = '';
  String price = '';
  String description = '';
  //Map
  String? location;
  // Constructor
  CreateListingViewModel({CategoryRepository? categoryRepository})
    : _categoryRepository = categoryRepository ?? CategoryRepository() {
    loadCategories();
  }

  void updateTitle(String value) {
    title = value;
    notifyListeners();
  }

  void updatePrice(String value) {
    price = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    description = value;
    notifyListeners();
  }

  void selectCondition(String condition) {
    selectedCondition = condition;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    isLoadingCategories = true;
    categoriesErrorMessage = null;
    notifyListeners();

    try {
      categories = await _categoryRepository.getCategories();

      if (categories.isNotEmpty) {
        selectedCategory = categories.first;
      }
    } catch (error) {
      categoriesErrorMessage = error.toString();
      categories = [];
      selectedCategory = null;
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  void selectCategory(Category? category) {
    selectedCategory = category;
    notifyListeners();
  }

  // Images
  Future<void> pickImageFromGallery() async {
    if (selectedImages.length >= maxImages) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    if (selectedImages.length < maxImages) {
      selectedImages = [...selectedImages, image];
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    if (selectedImages.length >= maxImages) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (image == null) return;

    if (selectedImages.length < maxImages) {
      selectedImages = [...selectedImages, image];
      notifyListeners();
    }
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= selectedImages.length) return;

    selectedImages = List<XFile>.from(selectedImages)..removeAt(index);
    notifyListeners();
  }

  //Map

  void updateLocationFromCoordinates(double latitude, double longitude) {
    location = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
    notifyListeners();
  }
}
