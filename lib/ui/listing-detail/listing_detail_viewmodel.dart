import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
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

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  AppUser? seller;
  bool isLoadingSeller = false;

  double? distanceKm;

  String? _currentListingId;

  ListingDetailViewModel({
    required ListingRepository listingRepository,
    required InteractionRepository interactionRepository,
    required ConnectivityService connectivityService,
    required AuthRepository authRepository,
    required LocationRepository locationRepository,
  })  : _listingRepository = listingRepository,
        _interactionRepository = interactionRepository,
        _connectivityService = connectivityService,
        _authRepository = authRepository,
        _locationRepository = locationRepository;

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

      await Future.wait([
        _loadSeller(result.sellerId),
        _registerInteraction(listingId),
        _loadDistance(result.location),
      ]);

      debugPrint('[ListingDetailViewModel] Parallel tasks finished');
      debugPrint('[ListingDetailViewModel] seller loaded: ${seller != null}');
      debugPrint('[ListingDetailViewModel] distanceKm: $distanceKm');
      debugPrint('[ListingDetailViewModel] loadListing END');
      debugPrint('------------------------------');
    } catch (e, stackTrace) {
      debugPrint('[ListingDetailViewModel] ERROR loading listing detail');
      debugPrint('[ListingDetailViewModel] Exception: $e');
      debugPrint('[ListingDetailViewModel] StackTrace: $stackTrace');

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

      debugPrint('[ListingDetailViewModel] parsed lat: $lat');
      debugPrint('[ListingDetailViewModel] parsed lng: $lng');

      if (lat == null || lng == null) {
        debugPrint('[ListingDetailViewModel] Distance skipped: lat/lng could not be parsed');
        return;
      }

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
    debugPrint('[ListingDetailViewModel] _registerInteraction START');
    debugPrint('[ListingDetailViewModel] listingId: $listingId');

    try {
      await _interactionRepository.registerInteraction(listingId: listingId);

      debugPrint('[ListingDetailViewModel] Interaction registered successfully');
    } catch (e, stackTrace) {
      debugPrint('[ListingDetailViewModel] ERROR registering interaction');
      debugPrint('[ListingDetailViewModel] Exception: $e');
      debugPrint('[ListingDetailViewModel] StackTrace: $stackTrace');
    } finally {
      debugPrint('[ListingDetailViewModel] _registerInteraction END');
    }
  }
}