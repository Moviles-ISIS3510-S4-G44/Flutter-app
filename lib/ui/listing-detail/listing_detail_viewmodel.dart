import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/domains/auth/app_user.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingDetailViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final ConnectivityService _connectivityService;
  final AuthRepository _authRepository;

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  AppUser? seller;
  bool isLoadingSeller = false;

  ListingDetailViewModel({
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
    ConnectivityService? connectivityService,
    required AuthRepository authRepository,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository,
        _connectivityService = connectivityService ?? ConnectivityService(),
        _authRepository = authRepository;

  Future<void> loadListing(String listingId) async {
    if (!await _connectivityService.isOnline) {
      errorMessage = 'No internet connection';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _listingRepository.getListingById(listingId);
      listing = result;
      isLoading = false;
      notifyListeners();

      // Cargar vendedor e interacción en paralelo
      await Future.wait([
        _loadSeller(result.sellerId),
        _registerInteraction(listingId),
      ]);
    } catch (e) {
      errorMessage = 'Failed to load listing details';
      isLoading = false;
      notifyListeners();
    }
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

  Future<void> _registerInteraction(String listingId) async {
    try {
      await _interactionRepository.registerInteraction(listingId: listingId);
    } catch (_) {}
  }
}