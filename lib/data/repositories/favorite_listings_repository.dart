import 'package:marketplace_flutter_application/data/domains/favorites/favorite_listings.dart';
import 'package:marketplace_flutter_application/data/storage/favorite_listings_db_storage.dart';

class FavoritesRepository {
  final FavoritesDb _db;

  FavoritesRepository({FavoritesDb? db}) : _db = db ?? FavoritesDb();

  Future<List<FavoriteListing>> getAll() => _db.getAll();

  Future<bool> isFavorite(String id) => _db.isFavorite(id);

  Future<void> add(FavoriteListing listing) => _db.insert(listing);

  Future<void> remove(String id) => _db.delete(id);
}