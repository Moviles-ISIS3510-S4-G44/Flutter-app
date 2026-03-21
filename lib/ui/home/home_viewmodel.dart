import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;

  HomeViewModel({
    required this.connectivityService,
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository {
    loadListings();
  }

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];
  List<ListingSummary> filteredListings = [];
  List<ListingSummary> topInteractionListings = [];

  Future<void> loadListings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final listings = await _listingRepository.getListings();

      featuredListings = listings.take(5).toList();
      recentListings = listings;
      filteredListings = listings;
    } catch (error) {
      errorMessage = error.toString();
      featuredListings = [];
      recentListings = [];
      filteredListings = [];
      topInteractionListings = [];
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final topIds = await _interactionRepository.getTopInteractedListingIds();

      topInteractionListings =
          recentListings.where((listing) => topIds.contains(listing.id)).toList();
    } catch (error) {
      debugPrint('Failed to load top interactions: $error');
      topInteractionListings = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      filteredListings = recentListings;
    } else {
      final normalizedQuery = searchQuery.toLowerCase();

      filteredListings = recentListings.where((listing) {
        return listing.title.toLowerCase().contains(normalizedQuery) ||
            listing.category.toLowerCase().contains(normalizedQuery);
      }).toList();
    }

    notifyListeners();
  }
}