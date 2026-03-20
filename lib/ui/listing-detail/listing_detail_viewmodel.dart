import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class ListingDetailViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  ListingDetailViewModel({ListingRepository? listingRepository})
    : _listingRepository = listingRepository ?? ListingRepository();

  Future<void> loadListing(String listingId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _listingRepository.getListingById(listingId);
      listing = result;
    } catch (e) {
      errorMessage = 'Failed to load listing details';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}