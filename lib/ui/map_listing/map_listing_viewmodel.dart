import 'package:flutter/material.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';

class MapListingViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;

  ListingDetail? listing;
  bool isLoading = false;
  String? errorMessage;

  double? latitude;
  double? longitude;

  MapListingViewModel({
    ListingRepository? listingRepository,
  }) : _listingRepository = listingRepository ?? ListingRepository();

  Future<void> loadListing(String listingId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _listingRepository.getListingById(listingId);
      listing = result;
      _parseLocation(result.location);
    } catch (e) {
      errorMessage = 'Failed to load listing location';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _parseLocation(String location) {
    final parts = location.split(',');

    if (parts.length != 2) {
      latitude = null;
      longitude = null;
      return;
    }

    latitude = double.tryParse(parts[0].trim());
    longitude = double.tryParse(parts[1].trim());
  }

  bool get hasListing {
    return listing != null;
  }

  bool get hasValidCoordinates {
    return latitude != null && longitude != null;
  }
}