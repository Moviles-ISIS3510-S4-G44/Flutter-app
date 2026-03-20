import 'package:marketplace_flutter_application/data/dtos/category_dto.dart';
import 'package:marketplace_flutter_application/data/services/category_api_service.dart';
import 'package:marketplace_flutter_application/models/categories/category.dart';

class CategoryRepository {
  final CategoryApiService _categoryApiService = CategoryApiService();

  Future<List<Category>> getCategories() async {
    final categoryDtos = await _categoryApiService.getCategories();
    return categoryDtos.map(_toCategory).toList();
  }

  Category _toCategory(CategoryDto dto) {
    return Category(
      id: dto.id,
      name: dto.name,
    );
  }
}