import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class ListingsResult {
  final List<ListingSummary> listings;
  final bool fromCache;
  final DateTime? cachedAt;

  const ListingsResult({
    required this.listings,
    required this.fromCache,
    this.cachedAt,
  });
}