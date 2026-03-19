import 'dart:io';
import 'package:marketplace_flutter_application/data/services/firebase_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ProductRepository {
  final FirebaseService _firebaseService;

  ProductRepository(this._firebaseService);

  Future<List<ListingSummary>> getAll() {
    return _firebaseService.getProducts();
  }

  Future<List<ListingSummary>> search(String query) {
    return _firebaseService.searchProducts(query);
  }

  // get products that have location data for the map
  Future<List<ListingSummary>> getWithLocation() async {
    final all = await getAll();
    return all.where((p) => p.latitude != null && p.longitude != null).toList();
  }

  // create a new product listing with image upload
  Future<String> createProduct(Map<String, dynamic> data, {File? image}) async {
    String imageUrl = '';
    // upload image first if provided
    if (image != null) {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      imageUrl = await _firebaseService.uploadProductImage(image, tempId);
    }
    data['imageUrl'] = imageUrl;
    return _firebaseService.createProduct(data);
  }
}
