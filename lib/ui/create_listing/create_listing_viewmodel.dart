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
  final ConnectivityService _connectivityService;
  final ListingRepository _listingRepository;
  final AuthRepository _authRepository;
  final CategoryRepository _categoryRepository;

  // Submit state
  bool isSubmitting = false;
  bool submitSuccess = false;
  String? submitErrorMessage;

  // User state
  AppUser? currentUser;
  bool isLoadingUser = false;
  String? userErrorMessage;

  // Category state
  bool isLoadingCategories = false;
  String? categoriesErrorMessage;
  List<Category> categories = [];
  Category? selectedCategory;

  // Condition
  final List<String> conditions = ['New', 'Like New', 'Used'];
  String selectedCondition = 'Like New';

  // Images
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> selectedImages = [];
  final int maxImages = 5;

  // Form fields
  String title = '';
  int price = 0;
  String description = '';
  String? location;
  double? locationLat;
  double? locationLng;

  // Field-level validation errors
  String? titleError;
  String? priceError;
  String? descriptionError;
  String? locationError;
  String? categoryError;

  CreateListingViewModel({
    required ConnectivityService connectivityService,
    required CategoryRepository categoryRepository,
    required ListingRepository listingRepository,
    required AuthRepository authRepository,
  })  : _connectivityService = connectivityService,
        _categoryRepository = categoryRepository,
        _listingRepository = listingRepository,
        _authRepository = authRepository {
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      loadCategories(),
      loadCurrentUser(),
    ]);
  }

  // Field updates

  void updateTitle(String value) {
    title = value;
    if (titleError != null) {
      titleError = null;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void updatePrice(String value) {
    price = int.tryParse(value) ?? 0;
    if (priceError != null) {
      priceError = null;
    }
    notifyListeners();
  }

  void updateDescription(String value) {
    description = value;
    if (descriptionError != null) {
      descriptionError = null;
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  void selectCondition(String condition) {
    selectedCondition = condition;
    notifyListeners();
  }

  void selectCategory(Category? category) {
    selectedCategory = category;
    if (categoryError != null) categoryError = null;
    notifyListeners();
  }

  void updateLocationFromCoordinates(double latitude, double longitude) {
    locationLat = latitude;
    locationLng = longitude;
    location = '${latitude.toStringAsFixed(6)},${longitude.toStringAsFixed(6)}';
    if (locationError != null) locationError = null;
    notifyListeners();
  }

  // User / categories loading 

  Future<void> loadCurrentUser() async {
    isLoadingUser = true;
    userErrorMessage = null;
    notifyListeners();

    try {
      currentUser = await _authRepository.getMyProfile();
    } catch (error) {
      currentUser = null;
      userErrorMessage = 'No se pudo verificar la sesión. Inicia sesión de nuevo.';
    } finally {
      isLoadingUser = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    if (!await _connectivityService.isOnline) {
      categoriesErrorMessage = 'Sin conexión para cargar categorías';
      notifyListeners();
      return;
    }

    isLoadingCategories = true;
    categoriesErrorMessage = null;
    notifyListeners();

    try {
      categories = await _categoryRepository.getCategories();
      if (categories.isNotEmpty) selectedCategory = categories.first;
    } catch (error) {
      categoriesErrorMessage = 'No se pudieron cargar las categorías';
      categories = [];
      selectedCategory = null;
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Image picking 

  Future<void> pickImageFromGallery() async {
    if (selectedImages.length >= maxImages) return;
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    if (selectedImages.length < maxImages) {
      selectedImages = [...selectedImages, image];
      notifyListeners();
    }
  }

  Future<void> pickImageFromCamera() async {
    if (selectedImages.length >= maxImages) return;
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
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

  // Validation

  bool _validate() {
    titleError = null;
    priceError = null;
    descriptionError = null;
    locationError = null;
    categoryError = null;

    bool valid = true;

    if (currentUser == null) {
      submitErrorMessage = 'No hay sesión activa. Inicia sesión de nuevo.';
      valid = false;
    }

    if (selectedCategory == null) {
      categoryError = 'Selecciona una categoría';
      valid = false;
    }

    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      titleError = 'El título es requerido';
      valid = false;
    } else if (trimmedTitle.length < 5) {
      titleError = 'El título debe tener al menos 5 caracteres';
      valid = false;
    }

    if (price <= 0) {
      priceError = 'Ingresa un precio mayor a 0';
      valid = false;
    }

    final trimmedDesc = description.trim();
    if (trimmedDesc.isEmpty) {
      descriptionError = 'La descripción es requerida';
      valid = false;
    } else if (trimmedDesc.length < 10) {
      descriptionError = 'La descripción debe tener al menos 10 caracteres';
      valid = false;
    }

    if (location == null || location!.trim().isEmpty) {
      locationError = 'Selecciona una ubicación en el mapa';
      valid = false;
    }

    return valid;
  }

  // Submit 

  Future<bool> submitListing() async {
    if (isSubmitting) return false;

    submitErrorMessage = null;
    submitSuccess = false;

    if (!await _connectivityService.isOnline) {
      submitErrorMessage = 'Sin conexión a internet';
      notifyListeners();
      return false;
    }

    if (!_validate()) {
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    notifyListeners();

    try {
      final request = CreateListingRequest(
        sellerId: currentUser!.id,
        categoryId: selectedCategory!.id,
        title: title.trim(),
        description: description.trim(),
        price: price,
        condition: selectedCondition,
        images: const [],
        location: location!,
      );

      await _listingRepository.createListing(request);
      submitSuccess = true;
      _resetForm();
      return true;
    } catch (error) {
      submitErrorMessage = 'No se pudo publicar el listing. Intenta de nuevo.';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void _resetForm() {
    title = '';
    price = 0;
    description = '';
    location = null;
    locationLat = null;
    locationLng = null;
    selectedCondition = 'Like New';
    selectedImages = [];
    if (categories.isNotEmpty) selectedCategory = categories.first;
    titleError = null;
    priceError = null;
    descriptionError = null;
    locationError = null;
    categoryError = null;
    submitErrorMessage = null;
  }
}