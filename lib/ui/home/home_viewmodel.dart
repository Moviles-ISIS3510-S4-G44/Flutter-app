import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/location_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/recently_viewed_repository.dart';
import 'package:marketplace_flutter_application/data/services/category_api_service.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final CategoryApiService _categoryApiService;
  final LocationRepository _locationRepository;
  final RecentlyViewedRepository _recentlyViewedRepository;

  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;

  HomeViewModel({
    required this.connectivityService,
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
    required CategoryApiService categoryApiService,
    required LocationRepository locationRepository,
    required RecentlyViewedRepository recentlyViewedRepository,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository,
        _categoryApiService = categoryApiService,
        _locationRepository = locationRepository,
        _recentlyViewedRepository = recentlyViewedRepository {
    loadListings();
    _subscribeToConnectivity();
  }

  // ── Estado ─────────────────────────────────────────────────────────────────

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';
  String selectedCategory = 'All';

  List<String> categories = ['All'];
  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];
  List<ListingSummary> filteredListings = [];
  List<ListingSummary> topInteractionListings = [];
  List<ListingSummary> recentlyViewed = [];
  Map<String, double> distances = {};

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
    super.dispose();
  }

  // Load

  Future<void> loadListings() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final categoriesResponse = await _categoryApiService.getCategories();
      categories = [
        'All',
        ...categoriesResponse.map((c) => c.name),
      ];
    } catch (_) {
      // Categorías fallan silenciosamente — mantener las anteriores
    }

    try {
      final result = await _listingRepository.getListings();

      featuredListings = result.listings.take(5).toList();
      recentListings = result.listings;
      filteredListings = result.listings;

      isShowingCachedData = result.fromCache;
      cachedAt = result.cachedAt;
    } catch (error) {
      errorMessage = error.toString();
      featuredListings = [];
      recentListings = [];
      filteredListings = [];
      topInteractionListings = [];
      recentlyViewed = [];
      distances = {};
      isShowingCachedData = false;
      cachedAt = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    await Future.wait([
      _loadTopInteractions(),
      _loadDistances(),
      _loadRecentlyViewed(),
    ]);

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
      notifyListeners();
    } catch (e) {
      debugPrint('_loadDistances error: $e');
    }
  }

  // Filtros

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
        (l) => l.category.toLowerCase() == selectedCategory.toLowerCase(),
      );
    }

    if (searchQuery.isEmpty) {
      filteredListings = results.toList();
      return;
    }

    final scored = results.map((listing) {
      return {'listing': listing, 'score': _calculateListingScore(listing)};
    }).toList();

    scored.removeWhere((item) => (item['score'] as int) < 55);
    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    filteredListings =
        scored.map((item) => item['listing'] as ListingSummary).toList();
  }

  int _calculateListingScore(ListingSummary listing) {
    final query = searchQuery.toLowerCase().trim();
    final title = listing.title.toLowerCase();
    final category = listing.category.toLowerCase();

    if (title.contains(query)) return 100;
    if (category.contains(query)) return 85;
    for (final word in title.split(' ')) {
      if (word.contains(query)) return 95;
    }
    final titleScore = weightedRatio(query, title);
    final categoryScore = weightedRatio(query, category);
    return titleScore > categoryScore ? titleScore : categoryScore;
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