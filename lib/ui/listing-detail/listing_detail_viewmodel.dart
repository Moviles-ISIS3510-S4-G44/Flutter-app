import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/data/services/connectivity_service.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingDetailViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;
  final ConnectivityService _connectivityService;

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  ListingDetailViewModel({
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository;
    ConnectivityService? connectivityService,
  }) : _listingRepository = listingRepository ?? ListingRepository(),
       _connectivityService = connectivityService ?? ConnectivityService();

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

      try {
        await _interactionRepository.registerInteraction(
          listingId: listingId,
        );
      } catch (_) {}
    } catch (e) {
      errorMessage = 'Failed to load listing details';
      isLoading = false;
      notifyListeners();
    }
  }
}