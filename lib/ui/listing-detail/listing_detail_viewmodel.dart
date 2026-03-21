import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/interaction_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingDetailViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;
  final InteractionRepository _interactionRepository;

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  ListingDetailViewModel({
    ListingRepository? listingRepository,
    required InteractionRepository interactionRepository,
  })  : _listingRepository = listingRepository ?? ListingRepository(),
        _interactionRepository = interactionRepository;

  Future<void> loadListing(String listingId) async {
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