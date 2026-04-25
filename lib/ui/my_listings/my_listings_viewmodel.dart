import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/data/repositories/listing_repository.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class MyListingsViewModel extends ChangeNotifier {
  final ListingRepository _listingRepository;
  final AuthRepository _authRepository;

  MyListingsViewModel({
    required ListingRepository listingRepository,
    required AuthRepository authRepository,
  })  : _listingRepository = listingRepository,
        _authRepository = authRepository;

  List<ListingSummary> listings = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> load() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.getMyProfile();
      final result = await _listingRepository.getListings();

      listings = result.listings
          .where((l) => l.sellerId == user.id)
          .toList();
    } catch (e) {
      errorMessage = 'No se pudieron cargar tus listings.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}