import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/domains/favorites/favorite_listings.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/favorite_listings_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/location_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingDetailViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final ConnectivityService _connectivityService;
  final AuthRepository _authRepository;
  final LocationRepository _locationRepository;
  final FavoritesRepository _favoritesRepository;

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  AppUser? seller;
  bool isLoadingSeller = false;

  double? distanceKm;

  bool isFavorite = false;
  bool _togglingFavorite = false;

  String? _currentListingId;

  ListingDetailViewModel({
    required ListingRepository listingRepository,
    required InteractionRepository interactionRepository,
    required ConnectivityService connectivityService,
    required AuthRepository authRepository,
    required LocationRepository locationRepository,
    required FavoritesRepository favoritesRepository,
  })  : _listingRepository = listingRepository,
        _interactionRepository = interactionRepository,
        _connectivityService = connectivityService,
        _authRepository = authRepository,
        _locationRepository = locationRepository,
        _favoritesRepository = favoritesRepository;

  Future<void> loadListing(String listingId) async {
    debugPrint('------------------------------');
    debugPrint('[ListingDetailViewModel] loadListing START');
    debugPrint('[ListingDetailViewModel] listingId: $listingId');

    _currentListingId = listingId;

    final isOnline = await _connectivityService.isOnline;
    debugPrint('[ListingDetailViewModel] isOnline: $isOnline');

    if (!isOnline) {
      errorMessage = 'Sin conexión a internet';
      debugPrint('[ListingDetailViewModel] ERROR: Sin conexión a internet');
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    seller = null;
    distanceKm = null;
    notifyListeners();

    try {
      debugPrint('[ListingDetailViewModel] Fetching listing detail...');

      final result = await _listingRepository.getListingById(listingId);

      debugPrint('[ListingDetailViewModel] Listing loaded successfully');
      debugPrint('[ListingDetailViewModel] listing.id: ${result.id}');
      debugPrint('[ListingDetailViewModel] listing.sellerId: ${result.sellerId}');
      debugPrint('[ListingDetailViewModel] listing.location: ${result.location}');

      listing = result;
      isLoading = false;
      notifyListeners();

      debugPrint('[ListingDetailViewModel] Running parallel tasks...');
      debugPrint('[ListingDetailViewModel] 1. Load seller');
      debugPrint('[ListingDetailViewModel] 2. Register interaction');
      debugPrint('[ListingDetailViewModel] 3. Load distance');

      _registerInteraction(listingId); // fire-and-forget, no bloquea
      await Future.wait([
        _loadSeller(result.sellerId),
        _loadDistance(result.location),
        _checkFavorite(listingId),
      ]);
    } catch (e) {
      errorMessage = 'No se pudo cargar el detalle del listing';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    debugPrint('[ListingDetailViewModel] retry called');
    debugPrint('[ListingDetailViewModel] currentListingId: $_currentListingId');

    if (_currentListingId == null) {
      debugPrint('[ListingDetailViewModel] retry cancelled: no current listing id');
      return;
    }

    await loadListing(_currentListingId!);
  }

  Future<void> toggleFavorite() async {
    if (_togglingFavorite || listing == null) return;
    _togglingFavorite = true;

    try {
      final fav = FavoriteListing(
        id: listing!.id,
        title: listing!.title,
        price: listing!.price,
        imageUrl: listing!.images.isNotEmpty ? listing!.images.first : '',
        category: listing!.categoryId,
        location: listing!.location,
      );

      if (isFavorite) {
        await _favoritesRepository.remove(fav.id);
        isFavorite = false;
      } else {
        await _favoritesRepository.add(fav);
        isFavorite = true;
      }
      notifyListeners();
    } finally {
      _togglingFavorite = false;
    }
  }

  Future<void> _checkFavorite(String listingId) async {
    isFavorite = await _favoritesRepository.isFavorite(listingId);
    notifyListeners();
  }

  Future<void> _loadSeller(String sellerId) async {
    debugPrint('[ListingDetailViewModel] _loadSeller START');
    debugPrint('[ListingDetailViewModel] sellerId: $sellerId');

    isLoadingSeller = true;
    notifyListeners();

    try {
      seller = await _authRepository.getUserById(sellerId);

      debugPrint('[ListingDetailViewModel] Seller loaded successfully');
      debugPrint('[ListingDetailViewModel] seller.id: ${seller?.id}');
      debugPrint('[ListingDetailViewModel] seller.name: ${seller?.name}');
      debugPrint('[ListingDetailViewModel] seller.email: ${seller?.email}');
    } catch (e, stackTrace) {
      debugPrint('[ListingDetailViewModel] ERROR loading seller');
      debugPrint('[ListingDetailViewModel] Exception: $e');
      debugPrint('[ListingDetailViewModel] StackTrace: $stackTrace');

      seller = null;
    } finally {
      isLoadingSeller = false;
      notifyListeners();
      debugPrint('[ListingDetailViewModel] _loadSeller END');
    }
  }

  Future<void> _loadDistance(String? location) async {
    debugPrint('[ListingDetailViewModel] _loadDistance START');
    debugPrint('[ListingDetailViewModel] raw location: $location');

    try {
      if (location == null || location.isEmpty) {
        debugPrint('[ListingDetailViewModel] Distance skipped: location is null or empty');
        return;
      }

      final parts = location.split(',');
      debugPrint('[ListingDetailViewModel] location parts: $parts');

      if (parts.length != 2) {
        debugPrint('[ListingDetailViewModel] Distance skipped: invalid location format');
        return;
      }

      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) return;
      distanceKm = await _locationRepository.getDistanceTo(lat, lng);

      debugPrint('[ListingDetailViewModel] Distance loaded successfully');
      debugPrint('[ListingDetailViewModel] distanceKm: $distanceKm');

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[ListingDetailViewModel] ERROR loading distance');
      debugPrint('[ListingDetailViewModel] Exception: $e');
      debugPrint('[ListingDetailViewModel] StackTrace: $stackTrace');

      distanceKm = null;
    } finally {
      debugPrint('[ListingDetailViewModel] _loadDistance END');
    }
  }

  Future<void> _registerInteraction(String listingId) async {
    try {
      await _interactionRepository.registerInteraction(listingId: listingId);
    } catch (_) {}
  }
}