import 'package:flutter/foundation.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/location_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class HomeViewModel extends ChangeNotifier {
  final ConnectivityService connectivityService;
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final LocationRepository _locationRepository;

  HomeViewModel({
    required this.connectivityService,
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
    required LocationRepository locationRepository,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository,
        _locationRepository = locationRepository {
    loadListings();
  }

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  List<ListingSummary> featuredListings = [];
  List<ListingSummary> recentListings = [];
  List<ListingSummary> filteredListings = [];
  List<ListingSummary> topInteractionListings = [];

  /// Map de listingId → distancia en km desde la ubicación del usuario.
  /// Si el GPS no está disponible o el listing no tiene coordenadas, no habrá
  /// entrada para ese id.
  Map<String, double> distances = {};

  List<ListingSummary> get displayedListings {
    if (searchQuery.isEmpty) return recentListings;
    return filteredListings;
  }

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
      distances = {};
      isLoading = false;
      notifyListeners();
      return;
    }

    // Cargar interacciones y distancias en paralelo, ambas fallan silenciosamente
    await Future.wait([
      _loadTopInteractions(),
      _loadDistances(),
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

  Future<void> _loadDistances() async {
    try {
      final Position? userPosition =
          await _locationRepository.getCurrentPosition();

      if (userPosition == null) return;

      // Parsear coordenadas de cada listing desde el campo location "lat,lng"
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
      // Falla silenciosamente — las cards se muestran sin distancia
    }
  }

  /// Parsea "lat,lng" → record con lat y lng. Retorna null si es inválido.
  ({double lat, double lng})? _parseCoords(String? location) {
    if (location == null || location.isEmpty) return null;
    final parts = location.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  void updateSearchQuery(String query) {
    searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      filteredListings = recentListings;
      notifyListeners();
      return;
    }

    final scoredListings = recentListings.map((listing) {
      return {'listing': listing, 'score': _calculateListingScore(listing)};
    }).toList();

    scoredListings.removeWhere((item) => (item['score'] as int) < 55);
    scoredListings.sort(
        (a, b) => (b['score'] as int).compareTo(a['score'] as int));

    filteredListings =
        scoredListings.map((item) => item['listing'] as ListingSummary).toList();

    notifyListeners();
  }

  int _calculateListingScore(ListingSummary listing) {
    final query = searchQuery.toLowerCase().trim();
    final title = listing.title.toLowerCase();
    final category = listing.category.toLowerCase();

    if (title.contains(query)) return 100;
    if (category.contains(query)) return 85;

    final titleWords = title.split(' ');
    for (final word in titleWords) {
      if (word.contains(query)) return 95;
    }

    final titleScore = weightedRatio(query, title);
    final categoryScore = weightedRatio(query, category);
    return titleScore > categoryScore ? titleScore : categoryScore;
  }
}