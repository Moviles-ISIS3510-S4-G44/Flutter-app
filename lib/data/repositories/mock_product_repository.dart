import 'package:marketplace_flutter_application/data/services/mock_firebase_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

// mock product repo for testing without firebase
// delete when firebase is configured
class MockProductRepository {
  final MockFirebaseService _mockService;

  MockProductRepository(this._mockService);

  Future<List<ListingSummary>> getAll() {
    return _mockService.getProducts();
  }

  Future<List<ListingSummary>> search(String query) {
    return _mockService.searchProducts(query);
  }

  Future<List<ListingSummary>> getWithLocation() async {
    final all = await getAll();
    return all.where((p) => p.latitude != null && p.longitude != null).toList();
  }

  Future<String> createProduct(Map<String, dynamic> data, {String? token}) {
    return _mockService.createProduct(data);
  }
}
