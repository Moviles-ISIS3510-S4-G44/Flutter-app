import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/domains/favorites/favorite_listings.dart';
import 'package:marketplace_flutter_application/data/repositories/favorite_listings_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final FavoritesRepository _repository;

  FavoritesViewModel({required FavoritesRepository repository})
      : _repository = repository;

  List<FavoriteListing> _favorites = [];
  List<FavoriteListing> get favorites => List.unmodifiable(_favorites);

  bool isLoading = false;

  // Cache local de IDs para consultas desde cualquier widget
  final Set<String> _favoriteIds = {};

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> loadFavorites() async {
    isLoading = true;
    notifyListeners();
    try {
      _favorites = await _repository.getAll();
      _favoriteIds
        ..clear()
        ..addAll(_favorites.map((f) => f.id));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(FavoriteListing listing) async {
    if (_favoriteIds.contains(listing.id)) {
      await _repository.remove(listing.id);
      _favoriteIds.remove(listing.id);
      _favorites.removeWhere((f) => f.id == listing.id);
    } else {
      await _repository.add(listing);
      _favoriteIds.add(listing.id);
      _favorites = [..._favorites, listing];
    }
    notifyListeners();
  }
}