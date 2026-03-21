import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;
  final ListingRepository _listingRepository;

  HomeViewModel({
    required this.connectivityService,
    ListingRepository? listingRepository
  }) : _listingRepository = listingRepository ?? ListingRepository() {
    loadListings();
  }

  bool isLoading = false;
  String? errorMessage;

  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];

  Future<void> loadListings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final listings = await _listingRepository.getListings();

      featuredListings = listings.take(5).toList();
      recentListings = listings;
    } catch (error) {
      errorMessage = error.toString();
      featuredListings = [];
      recentListings = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}