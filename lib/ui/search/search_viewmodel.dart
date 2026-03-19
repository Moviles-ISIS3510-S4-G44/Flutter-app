import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class SearchViewModel extends ChangeNotifier {
  final dynamic _productRepo;
  final dynamic _analytics;

  SearchViewModel(this._productRepo, this._analytics);

  List<ListingSummary> results = [];
  bool isLoading = false;
  String query = '';

  Future<void> search(String q) async {
    if (q.trim().isEmpty) {
      results = [];
      notifyListeners();
      return;
    }

    query = q;
    isLoading = true;
    notifyListeners();

    try {
      results = await _productRepo.search(q);
      await _analytics.logSearch(q);
    } catch (e) {
      print('search failed: $e');
      results = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
