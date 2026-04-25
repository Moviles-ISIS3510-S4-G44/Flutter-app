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
    _currentListingId = listingId;

    if (!await _connectivityService.isOnline) {
      errorMessage = 'Sin conexión a internet';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    seller = null;
    distanceKm = null;
    notifyListeners();

    try {
      final result = await _listingRepository.getListingById(listingId);
      listing = result;
      isLoading = false;
      notifyListeners();

      await Future.wait([
        _loadSeller(result.sellerId),
        _registerInteraction(listingId),
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
    if (_currentListingId == null) return;
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
    isLoadingSeller = true;
    notifyListeners();
    try {
      seller = await _authRepository.getUserById(sellerId);
    } catch (_) {
      seller = null;
    } finally {
      isLoadingSeller = false;
      notifyListeners();
    }
  }

  Future<void> _loadDistance(String? location) async {
    try {
      if (location == null || location.isEmpty) return;
      final parts = location.split(',');
      if (parts.length != 2) return;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat == null || lng == null) return;
      distanceKm = await _locationRepository.getDistanceTo(lat, lng);
      notifyListeners();
    } catch (_) {
      distanceKm = null;
    }
  }

  Future<void> _registerInteraction(String listingId) async {
    try {
      await _interactionRepository.registerInteraction(listingId: listingId);
    } catch (_) {}
  }
}