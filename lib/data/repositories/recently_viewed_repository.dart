import 'package:marketplace_flutter_application/data/storage/recently_viewed_storage.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class RecentlyViewedRepository {
  final RecentlyViewedStorage _storage;

  RecentlyViewedRepository({RecentlyViewedStorage? storage})
      : _storage = storage ?? RecentlyViewedStorage();

  Future<void> add(ListingSummary listing) => _storage.add(listing);

  Future<List<ListingSummary>> getAll() => _storage.getAll();

  Future<void> clear() => _storage.clear();
}