import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/category_repository.dart';
import 'package:marketplace_flutter_application/models/categories/category.dart';

class CreateListingViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final List<String> conditions = [
  'New',
  'Like New',
  'Used',
  ];
  String selectedCondition = 'Like New';
  void selectCondition(String condition) {
  selectedCondition = condition;
  notifyListeners();
  }
  CreateListingViewModel({
    CategoryRepository? categoryRepository,
  }) : _categoryRepository = categoryRepository ?? CategoryRepository() {
    loadCategories();
  }

  bool isLoadingCategories = false;
  String? categoriesErrorMessage;

  List<Category> categories = [];
  Category? selectedCategory;

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
}