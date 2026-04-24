import 'package:marketplace_flutter_application/data/dtos/listings/create_listing_request.dart';
import 'package:marketplace_flutter_application/data/dtos/listings/listing_dto.dart';
import 'package:marketplace_flutter_application/data/services/listing_api_service.dart';
import 'package:marketplace_flutter_application/data/storage/listing_cache_storage.dart';
import 'package:marketplace_flutter_application/models/listings/listing_detail.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';
import 'package:marketplace_flutter_application/models/listings/listings_result.dart';

class ListingRepository {
  final ListingApiService _listingApiService;
  final ListingCacheStorage _cacheStorage;

  ListingRepository({
    ListingApiService? listingApiService,
    ListingCacheStorage? cacheStorage,
  })  : _listingApiService = listingApiService ?? ListingApiService(),
        _cacheStorage = cacheStorage ?? ListingCacheStorage();

  /// Intenta cargar del backend. Si falla, usa el caché local.
  /// Siempre retorna un [ListingsResult] indicando si viene del caché.
  Future<ListingsResult> getListings() async {
    try {
      final listingDtos = await _listingApiService.getListings();
      final listings = listingDtos.map(_toListingSummary).toList();

      // Guarda en caché silenciosamente — no bloquea el return
      _cacheStorage.saveListings(listings);

      return ListingsResult(listings: listings, fromCache: false);
    } catch (error) {
      // Backend falló — intentar caché
      final cached = await _cacheStorage.getListings();
      if (cached.isNotEmpty) {
        final cachedAt = await _cacheStorage.getLastUpdated();
        return ListingsResult(
          listings: cached,
          fromCache: true,
          cachedAt: cachedAt,
        );
      }
      // Sin caché tampoco — relanzar el error original
      rethrow;
    }
  }

  Future<ListingDetail> createListing(CreateListingRequest request) async {
    final listingDto = await _listingApiService.createListing(request);
    return _toListingDetail(listingDto);
  }

  Future<ListingDetail> getListingById(String listingId) async {
    final listingDto = await _listingApiService.getListingById(listingId);
    return _toListingDetail(listingDto);
  }

  // Conversores 

  ListingSummary _toListingSummary(ListingDto dto) {
    return ListingSummary(
      id: dto.id,
      title: dto.title,
      price: dto.price,
      category: dto.categoryId.toString(),
      imageUrl: dto.images.isNotEmpty ? dto.images[0] : '',
      location: dto.location,
    );
  }

  ListingDetail _toListingDetail(ListingDto dto) {
    return ListingDetail(
      id: dto.id,
      sellerId: dto.sellerId,
      categoryId: dto.categoryId,
      title: dto.title,
      description: dto.description,
      price: dto.price,
      condition: dto.condition,
      images: dto.images,
      location: dto.location,
    );
  }
}