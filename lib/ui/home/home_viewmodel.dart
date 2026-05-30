import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketplace_flutter_application/data/dtos/search/intent_filters.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/location_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/recently_viewed_repository.dart';
import 'package:marketplace_flutter_application/data/services/category_api_service.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/data/services/semantic_search_service.dart';
import 'package:marketplace_flutter_application/data/services/semantic_similarity.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';
import 'package:marketplace_flutter_application/models/listings/listings_result.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final CategoryApiService _categoryApiService;
  final LocationRepository _locationRepository;
  final RecentlyViewedRepository _recentlyViewedRepository;
  final SemanticSearchService _semanticSearchService;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  Timer? _searchDebounce;

  Map<String, String> _categoryNameById = {};

  HomeViewModel({
    required this.connectivityService,
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
    required CategoryApiService categoryApiService,
    required LocationRepository locationRepository,
    required RecentlyViewedRepository recentlyViewedRepository,
    required SemanticSearchService semanticSearchService,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository,
        _categoryApiService = categoryApiService,
        _locationRepository = locationRepository,
        _recentlyViewedRepository = recentlyViewedRepository,
        _semanticSearchService = semanticSearchService {
    loadListings();
    _subscribeToConnectivity();
  }

  // Estado

  bool isLoading = false;
  bool isSearchLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategory = 'All';
  IntentFilters currentIntentFilters = IntentFilters.empty;

  List<String> categories = ['All'];
  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];
  List<ListingSummary> filteredListings = [];
  List<ListingSummary> topInteractionListings = [];
  List<ListingSummary> recentlyViewed = [];
  List<ListingSummary> nearYouListings = [];
  Map<String, double> distances = {};

  static const double _nearYouRadiusKm = 10.0;

  bool isShowingCachedData = false;
  DateTime? cachedAt;

  List<ListingSummary> get displayedListings =>
      searchQuery.isEmpty ? recentListings : filteredListings;

  // Connectivity listener 

  void _subscribeToConnectivity() {
    _connectivitySubscription =
        connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.online && isShowingCachedData) {
        debugPrint('HomeViewModel: conexión restaurada — recargando listings');
        loadListings();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Load

  Future<void> loadListings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final categoriesResponse = await _categoryApiService.getCategories();
      _categoryNameById = {
        for (final c in categoriesResponse) c.id: c.name,
      };
      categories = [
        'All',
        ...categoriesResponse.map((c) => c.name),
      ];
    } catch (_) {
      // Categorías fallan silenciosamente
    }

    ListingsResult result;
    try {
      result = await _listingRepository.getListings();
    } catch (error) {
      errorMessage = error.toString();
      featuredListings = [];
      recentListings = [];
      filteredListings = [];
      topInteractionListings = [];
      recentlyViewed = [];
      nearYouListings = [];
      distances = {};
      isShowingCachedData = false;
      cachedAt = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    final normalizedListings = _applyCategoryNames(result.listings);
    featuredListings = normalizedListings.take(5).toList();
    recentListings = normalizedListings;
    filteredListings = normalizedListings;

    isShowingCachedData = result.fromCache;
    cachedAt = result.cachedAt;

    try {
      await _semanticSearchService.rebuildIndex(recentListings);
    } catch (e) {
      debugPrint('HomeViewModel: rebuildIndex error: $e');
    }

    await Future.wait([
      _loadTopInteractions(),
      _loadDistances(),
      _loadRecentlyViewed(),
    ]);

    if (searchQuery.isNotEmpty) {
      try {
        await _performSemanticSearch();
      } catch (e) {
        debugPrint('HomeViewModel: semantic search error: $e');
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadTopInteractions() async {
    try {
      final topIds = await _interactionRepository.getTopInteractedListingIds();
      topInteractionListings = recentListings
          .where((listing) => topIds.contains(listing.id))
          .toList();
    } catch (error) {
      debugPrint('Failed to load top interactions: $error');
      topInteractionListings = [];
    }
  }

  Future<void> _loadRecentlyViewed() async {
    try {
      recentlyViewed = await _recentlyViewedRepository.getAll();
    } catch (e) {
      debugPrint('HomeViewModel: failed to load recently viewed: $e');
      recentlyViewed = [];
    }
  }

  /// Refresca solo la sección de vistos recientemente.
  /// Se llama al volver del detalle de un listing.
  Future<void> refreshRecentlyViewed() async {
    await _loadRecentlyViewed();
    notifyListeners();
  }

  Future<void> _loadDistances() async {
    try {
      final Position? userPosition =
          await _locationRepository.getCurrentPosition();
      if (userPosition == null) return;

      final coords = <String, ({double lat, double lng})>{};
      for (final listing in recentListings) {
        final parsed = _parseCoords(listing.location);
        if (parsed != null) coords[listing.id] = parsed;
      }
      if (coords.isEmpty) return;

      distances = _locationRepository.calculateDistances(
        userPosition: userPosition,
        listingCoords: coords,
      );

      // Filtra listings dentro del radio — ordenados de más cercano a más lejano
      nearYouListings = recentListings
          .where((l) {
            final d = distances[l.id];
            return d != null && d <= _nearYouRadiusKm;
          })
          .toList()
        ..sort((a, b) => distances[a.id]!.compareTo(distances[b.id]!));

      notifyListeners();
    } catch (e) {
      debugPrint('_loadDistances error: $e');
    }
  }

  // Filtros

  void updateSearchQuery(String query) {
    searchQuery = query.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _performSemanticSearch();
    });
    notifyListeners();
  }

  void updateSelectedCategory(String category) {
    selectedCategory = category;
    if (searchQuery.isEmpty) {
      _applyCategoryOnly();
      notifyListeners();
      return;
    }
    _performSemanticSearch();
  }

  Future<void> _performSemanticSearch() async {
    if (searchQuery.isEmpty) {
      currentIntentFilters = IntentFilters.empty;
      _applyCategoryOnly();
      notifyListeners();
      return;
    }

    isSearchLoading = true;
    notifyListeners();

    final candidates = _applyCategoryOnly(returnResults: true);
    final isOnline = await connectivityService.isOnline;

    List<SemanticMatch> matches = [];
    IntentFilters intentFilters = IntentFilters.empty;

    try {
      matches = await _semanticSearchService.semanticSearch(
        searchQuery,
        candidates: candidates,
      );
    } catch (e) {
      debugPrint('HomeViewModel: semanticSearch error: $e');
    }

    try {
      if (isOnline) {
        intentFilters = await _semanticSearchService.parseIntent(searchQuery);
      }
    } catch (e) {
      debugPrint('HomeViewModel: parseIntent error: $e');
    }

    currentIntentFilters = intentFilters;

    var filtered = candidates.toList();
    filtered = _applyIntentFilters(filtered, intentFilters);

    if (matches.isNotEmpty) {
      final matchIds = matches.map((m) => m.id).toList();
      final byId = {
        for (final listing in filtered) listing.id: listing,
      };
      filtered = matchIds
          .map((id) => byId[id])
          .whereType<ListingSummary>()
          .toList();
    } else {
      filtered = _fallbackTextSearch(filtered, searchQuery);
    }

    filteredListings = filtered;
    isSearchLoading = false;
    notifyListeners();
  }

  List<ListingSummary> _applyCategoryOnly({bool returnResults = false}) {
    Iterable<ListingSummary> results = recentListings;
    if (selectedCategory != 'All') {
      results = results.where(
        (l) => l.category.toLowerCase() == selectedCategory.toLowerCase(),
      );
    }
    final list = results.toList();
    if (!returnResults) {
      filteredListings = list;
    }
    return list;
  }

  List<ListingSummary> _applyIntentFilters(
    List<ListingSummary> source,
    IntentFilters filters,
  ) {
    var results = source;

    if (filters.category != null) {
      final match = _matchCategory(filters.category!);
      if (match != null) {
        results = results
            .where((l) => l.category.toLowerCase() == match.toLowerCase())
            .toList();
      }
    }

    if (filters.minPrice != null) {
      results = results.where((l) => l.price >= filters.minPrice!).toList();
    }

    if (filters.maxPrice != null) {
      results = results.where((l) => l.price <= filters.maxPrice!).toList();
    }

    if (filters.condition != null) {
      results = results
          .where((l) => l.condition?.toLowerCase() == filters.condition)
          .toList();
    }

    return results;
  }

  String? _matchCategory(String raw) {
    final normalized = raw.trim().toLowerCase();
    for (final category in categories) {
      if (category.toLowerCase() == normalized) return category;
      if (category.toLowerCase().contains(normalized)) return category;
    }
    return null;
  }

  List<ListingSummary> _fallbackTextSearch(
    List<ListingSummary> source,
    String query,
  ) {
    final q = query.toLowerCase();
    return source
        .where((listing) =>
            listing.title.toLowerCase().contains(q) ||
            listing.category.toLowerCase().contains(q) ||
            (listing.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<ListingSummary> _applyCategoryNames(List<ListingSummary> listings) {
    if (_categoryNameById.isEmpty) return listings;
    return listings
        .map(
          (l) => ListingSummary(
            id: l.id,
            sellerId: l.sellerId,
            title: l.title,
            price: l.price,
            category: _categoryNameById[l.category] ?? l.category,
            imageUrl: l.imageUrl,
            location: l.location,
            description: l.description,
            condition: l.condition,
          ),
        )
        .toList(growable: false);
  }

  ({double lat, double lng})? _parseCoords(String? location) {
    if (location == null || location.isEmpty) return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }
}