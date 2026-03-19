import 'package:flutter/foundation.dart';
import '../../models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  final dynamic _productRepo;
  final dynamic _analytics;

  HomeViewModel(this._productRepo, this._analytics);

  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];
  bool isLoading = false;

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();

    try {
      final all = await _productRepo.getAll() as List<ListingSummary>;
      // first 2 are featured, rest are recents
      featuredListings = all.length > 2 ? all.sublist(0, 2) : all;
      recentListings = all.length > 2 ? all.sublist(2) : [];
      await _analytics.logScreenView('home');
    } catch (e) {
      print('failed to load products: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
