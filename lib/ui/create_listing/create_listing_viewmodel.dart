import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marketplace_flutter_application/data/dtos/listings/create_listing_request.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/category_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/categories/category.dart';

class CreateListingViewModel extends ChangeNotifier {
  // Connectivity
  final ConnectivityService _connectivityService;
  // Submission
  final ListingRepository _listingRepository;
  final AuthRepository _authRepository;

  bool isSubmitting = false;
  String? submitErrorMessage;

  // Current user
  AppUser? currentUser;
  bool isLoadingUser = false;
  String? userErrorMessage;

  // Categories
  final CategoryRepository _categoryRepository;
  bool isLoadingCategories = false;
  String? categoriesErrorMessage;
  List<Category> categories = [];
  Category? selectedCategory;

  // Conditions
  final List<String> conditions = ['New', 'Like New', 'Used'];
  String selectedCondition = 'Like New';

  // Images
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> selectedImages = [];
  final int maxImages = 5;

  // Basic info
  String title = '';
  String price = '';
  String description = '';
  // Map
  String? location;

  // Constructor
  CreateListingViewModel({
    ConnectivityService? connectivityService,
    CategoryRepository? categoryRepository,
    ListingRepository? listingRepository,
    required AuthRepository authRepository,
  })  : _categoryRepository = categoryRepository ?? CategoryRepository(),
        _listingRepository = listingRepository ?? ListingRepository(),
        _authRepository = authRepository {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      loadCategories(),
      loadCurrentUser(),
    ]);
  }) : _connectivityService = connectivityService ?? ConnectivityService(),
       _categoryRepository = categoryRepository ?? CategoryRepository(),
       _listingRepository = listingRepository ?? ListingRepository() {
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

  Future<void> loadCurrentUser() async {
    isLoadingUser = true;
    userErrorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authRepository.getMyProfile();
    } catch (error) {
      currentUser = null;
      userErrorMessage = error.toString();
    } finally {
      isLoadingUser = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    if (!await _connectivityService.isOnline) {
      categoriesErrorMessage = 'No internet connection';
      notifyListeners();
      return;
    }

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

  // Map
  void updateLocationFromCoordinates(double latitude, double longitude) {
    location = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
    notifyListeners();
  }

  Future<bool> submitListing() async {
    if (currentUser == null) {
      submitErrorMessage = 'Could not identify current user';
    if (!await _connectivityService.isOnline) {
      submitErrorMessage = 'No internet connection';
      notifyListeners();
      return false;
    }

    if (selectedCategory == null) {
      submitErrorMessage = 'Please select a category';
      notifyListeners();
      return false;
    }

    if (title.trim().isEmpty) {
      submitErrorMessage = 'Title is required';
      notifyListeners();
      return false;
    }

    if (price.trim().isEmpty) {
      submitErrorMessage = 'Price is required';
      notifyListeners();
      return false;
    }

    if (description.trim().isEmpty) {
      submitErrorMessage = 'Description is required';
      notifyListeners();
      return false;
    }

    if (location == null || location!.trim().isEmpty) {
      submitErrorMessage = 'Location is required';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    submitErrorMessage = null;
    notifyListeners();

    try {
      final request = CreateListingRequest(
        sellerId: currentUser!.id,
        categoryId: selectedCategory!.id,
        title: title.trim(),
        description: description.trim(),
        price: price.trim(),
        condition: selectedCondition,
        images: const [],
        status: 'active',
        location: location!,
      );

      await _listingRepository.createListing(request);
      return true;
    } catch (error) {
      submitErrorMessage = error.toString();
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}