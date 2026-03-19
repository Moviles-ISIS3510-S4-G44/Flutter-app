import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ProductViewModel extends ChangeNotifier {
  final dynamic _productRepo;
  final dynamic _analytics;

  ProductViewModel(this._productRepo, this._analytics);

  ListingSummary? product;
  bool isLoading = false;
  String? error;

  // load product by searching all products for matching id
  // not ideal but works for now since we dont have a getById on firestore
  Future<void> loadProduct(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await _productRepo.getAll() as List<ListingSummary>;
      product = all.where((p) => p.id == id).firstOrNull;
      if (product != null) {
        await _analytics.logViewProduct(product!.id, product!.title);
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
