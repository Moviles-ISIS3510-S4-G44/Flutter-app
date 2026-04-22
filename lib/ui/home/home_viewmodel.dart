import 'package:flutter/foundation.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/data/services/category_api_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final CategoryApiService _categoryApiService;

  HomeViewModel({
    required this.connectivityService,
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
    required CategoryApiService categoryApiService,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository,
        _categoryApiService = categoryApiService {
    loadHomeData();
  }

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategory = 'All';

  List<String> categories = ['All'];

  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];
  List<ListingSummary> filteredListings = [];
  List<ListingSummary> topInteractionListings = [];

  Future<void> loadHomeData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final categoriesResponse = await _categoryApiService.getCategories();
      categories = [
        'All',
        ...categoriesResponse.map((category) => category.name),
      ];

      final listings = await _listingRepository.getListings();

      featuredListings = listings.take(5).toList();
      recentListings = listings;

      try {
        final topIds = await _interactionRepository.getTopInteractedListingIds();

        topInteractionListings = recentListings
            .where((listing) => topIds.contains(listing.id))
            .toList();
      } catch (error) {
        debugPrint('Failed to load top interactions: $error');
        topInteractionListings = [];
      }

      _applyFilters();
    } catch (error) {
      errorMessage = error.toString();
      categories = ['All'];
      featuredListings = [];
      recentListings = [];
      filteredListings = [];
      topInteractionListings = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadListings() async {
    await loadHomeData();
  }

  void updateSearchQuery(String query) {
    searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void updateSelectedCategory(String category) {
    selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<ListingSummary> results = recentListings;

    if (selectedCategory != 'All') {
      results = results.where(
        (listing) =>
            listing.category.toLowerCase() == selectedCategory.toLowerCase(),
      );
    }

    if (searchQuery.isEmpty) {
      filteredListings = results.toList();
      return;
    }

    final scoredListings = results.map((listing) {
      return {
        'listing': listing,
        'score': _calculateListingScore(listing),
      };
    }).toList();

    scoredListings.removeWhere((item) => (item['score'] as int) < 55);

    scoredListings.sort(
      (a, b) => (b['score'] as int).compareTo(a['score'] as int),
    );

    filteredListings = scoredListings
        .map((item) => item['listing'] as ListingSummary)
        .toList();
  }

  int _calculateListingScore(ListingSummary listing) {
    final query = searchQuery.toLowerCase().trim();
    final title = listing.title.toLowerCase();
    final category = listing.category.toLowerCase();

    if (title.contains(query)) {
      return 100;
    }

    if (category.contains(query)) {
      return 85;
    }

    final titleWords = title.split(' ');
    for (final word in titleWords) {
      if (word.contains(query)) {
        return 95;
      }
    }

    final titleScore = weightedRatio(query, title);
    final categoryScore = weightedRatio(query, category);

    return titleScore > categoryScore ? titleScore : categoryScore;
  }
}