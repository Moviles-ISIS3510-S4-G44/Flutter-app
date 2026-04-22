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

  // Guardamos el listingId para poder hacer retry
  String? _currentListingId;

  ListingDetailViewModel({
    required ListingRepository listingRepository,
    required InteractionRepository interactionRepository,
    required ConnectivityService connectivityService,
    required AuthRepository authRepository,
  })  : _listingRepository = listingRepository,
        _interactionRepository = interactionRepository,
        _connectivityService = connectivityService,
        _authRepository = authRepository;

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
    notifyListeners();

    try {
      final result = await _listingRepository.getListingById(listingId);
      listing = result;
      isLoading = false;
      notifyListeners();

      // Cargar vendedor e interacción en paralelo, ambos fallan silenciosamente
      await Future.wait([
        _loadSeller(result.sellerId),
        _registerInteraction(listingId),
      ]);
    } catch (e) {
      errorMessage = 'No se pudo cargar el detalle del listing';
      isLoading = false;
      notifyListeners();
    }
  }

  /// Reintenta la carga usando el último listingId conocido.
  Future<void> retry() async {
    if (_currentListingId == null) return;
    await loadListing(_currentListingId!);
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